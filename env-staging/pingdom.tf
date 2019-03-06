data "vault_generic_secret" "pingdom" {
  path = "secret/pingdom"
}

data "consul_keys" "pingdom" {
  key {
    name    = "resolution"
    path    = "${local.service_identifier}/${local.task_identifier}/pingdom/resolution"
    default = "5"
  }

  key {
    name    = "sendnotificationwhendown"
    path    = "${local.service_identifier}/${local.task_identifier}/pingdom/sendnotificationwhendown"
    default = "0"
  }
}

locals {
  service_identifier = "${var.stack}"
  task_identifier    = "api"
  healthcheck_path   = "healthcheck"
}

variable "integrationids" {
  type        = "list"
  default     = []
  description = "List of integer integration IDs (defined by webhook URL) that will be triggered by the alerts. The ID can be extracted from the integrations page URL on the pingdom website."
}

provider "pingdom" {
  user          = "${data.vault_generic_secret.pingdom.data["user"]}"
  password      = "${data.vault_generic_secret.pingdom.data["password"]}"
  api_key       = "${data.vault_generic_secret.pingdom.data["apikey"]}"
  account_email = "${data.vault_generic_secret.pingdom.data["account_email"]}"
}

resource "pingdom_check" "app_http" {
  type                     = "http"
  encryption               = true
  name                     = "${local.service_identifier}-${local.task_identifier} - ${var.env} - ${data.aws_region.current.name}"
  host                     = "${aws_route53_record.api_a.fqdn}"
  url                      = "${local.healthcheck_path}"
  integrationids           = "${var.integrationids}"
  resolution               = "${data.consul_keys.pingdom.var.resolution}"
  sendnotificationwhendown = "${data.consul_keys.pingdom.var.sendnotificationwhendown}"
}
