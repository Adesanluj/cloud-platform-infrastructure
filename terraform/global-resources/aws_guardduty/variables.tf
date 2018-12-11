variable "aws_account_id" {}
variable "aws_profile" {}
variable "aws_region" {}
variable "integration_key" {}
variable "endpoint" {}
variable "topic_arn" {}

variable "users" {
  type = "list"
}

variable "bucket_prefix" {
  default = "security"
}

variable "guardduty_assets" {
  default = "guardduty"
}

variable "group_name" {
  default = "guardduty-admin"
}

variable "tags" {
  default = {
    "owner"   = "rahook"
    "project" = "guardduty-test"
    "client"  = "Internal"
  }
}

variable "sns_topic_name" {
  type        = "string"
  description = "GuardDuty-notifications"
}