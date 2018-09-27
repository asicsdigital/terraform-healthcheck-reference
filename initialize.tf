#Initialize.tf contains empty variable declarations for the variables that will be populated in each env’s .tfvars file

variable "env" {
  type = "string"
}

variable "fqdn" {
  type    = "string"
  default = "asics.digital"
}

variable "docker_image" {
  type    = "string"
  default = "asicsdigital/healthcheck:latest"
}

variable "ecs_desired_count" {
  type    = "string"
  default = "2"
}

variable "port" {
  type    = "string"
  default = "8080"
}

variable "healthcheck_path" {
  type    = "string"
  default = "/static-hc"
}

variable "consul_http_auth" {}
