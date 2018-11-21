# Create class for persistent prometheus storage
resource "kubernetes_storage_class" "prometheus_storage" {
  metadata {
    name = "prometheus-storage"
  }

  storage_provisioner = "kubernetes.io/aws-ebs"

  parameters {
    type = "gp2"
  }
}

# Randomise Grafana username and password
resource "random_id" "username" {
  byte_length = 8
}

resource "random_id" "password" {
  byte_length = 8
}

# Build values.yaml for ${helm_release.prometheus_operator}
data "template_file" "kube_prometheus" {
  template = "${file("${path.module}/templates/prometheus-operator.yaml.tpl")}"

  vars {
    alertmanager_ingress = "https://alertmanager.apps.${data.terraform_remote_state.cluster.cluster_domain_name}"
    grafana_ingress      = "grafana.apps.${data.terraform_remote_state.cluster.cluster_domain_name}"
    grafana_root         = "https://grafana.apps.${data.terraform_remote_state.cluster.cluster_domain_name}"
    pagerduty_config     = "${var.pagerduty_config}"
    slack_config         = "${var.slack_config}"
    promtheus_ingress    = "https://prometheus.apps.${data.terraform_remote_state.cluster.cluster_domain_name}"
    random_username      = "${random_id.username.hex}"
    random_password      = "${random_id.password.hex}"
  }
}

# Prometheus-operator install from https://github.com/helm/charts/tree/master/stable/prometheus-operator
resource "helm_release" "prometheus_operator" {
  name          = "prometheus-operator"
  chart         = "stable/prometheus-operator"
  namespace     = "monitoring"
  recreate_pods = "true"

  values = [
    "${data.template_file.kube_prometheus.rendered}",
  ]

  depends_on = [
    "null_resource.deploy",
  ]
}
