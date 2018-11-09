resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "dlm-lifecycle-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_dlm_lifecycle_policy" "Etcd-Backup" {
  description        = "Etcd DLM lifecycle policy"
  execution_role_arn = "${aws_iam_role.dlm_lifecycle_role.arn}"
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "2 weeks of daily snapshots - ${local.cluster_base_domain_name}"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["07:00"]
      }

      retain_rule {
        count = 14
      }

      tags_to_add {
        SnapshotCreator = "DLM"
      }
    }

    target_tags {
      Snapshot = "KubernetesCluster:${local.cluster_base_domain_name}"
    }
  }
}
