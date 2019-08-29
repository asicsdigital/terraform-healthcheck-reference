# Healthcheck service

locals {
  consul_prefix      = "${local.service_name}"
  ecs_cluster        = "asics-services-${var.env}-infra-svc"
  ecs_security_group = "ecs-sg-${local.ecs_cluster}"
  extra_args         = "-consul-retry -consul-retry-attempts=3"
  service_fqdn       = "${local.service_name}.${local.hostname}"
  service_name       = "healthcheck"
}

data "aws_ecs_cluster" "ecs" {
  cluster_name = "${local.ecs_cluster}"
}

data "aws_security_group" "ecs" {
  name = "${local.ecs_security_group}"
}

module "healthcheck" {
  source                       = "github.com/FitnessKeeper/tf_aws_ecs_service?ref=v3.2.0"
  docker_image                 = "${var.docker_image}"
  region                       = "us-east-1"
  ecs_cluster_arn              = "${data.aws_ecs_cluster.ecs.arn}"
  service_identifier           = "${var.stack}"
  task_identifier              = "api-${var.env}"
  ecs_security_group_id        = "${data.aws_security_group.ecs.id}"
  ecs_desired_count            = "${var.ecs_desired_count}"
  network_mode                 = "bridge"
  acm_cert_domain              = "${aws_acm_certificate.cert.domain_name}"
  alb_subnet_ids               = ["${data.aws_subnet_ids.public.ids}"]
  app_port                     = "${var.port}"
  vpc_id                       = "${data.aws_vpc.vpc.id}"
  alb_healthcheck_path         = "${var.healthcheck_path}"
  alb_healthcheck_interval     = 10
  lb_bucket_name               = "asics-devops-${data.aws_region.current.name}"


  docker_port_mappings = [
    {
      "containerPort" = "${var.port}"
    },
  ]

  docker_environment = [
    {
      "name"  = "PORT"
      "value" = "${var.port}"
    },
    {
      "name"  = "CONSUL_PREFIX"
      "value" = "${local.consul_prefix}"
    },
    {
      "name"  = "EXTRA_ARGS"
      "value" = "${local.extra_args}"
    },
  ]
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${local.service_fqdn}"
  validation_method = "DNS"
  provider          = "aws.us-east-1"
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_route53_record" "api_a" {
  name    = "${local.service_fqdn}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.zone.id}"

  alias {
    name                   = "${module.healthcheck.alb_dns_name}"
    zone_id                = "${module.healthcheck.alb_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api_aaaa" {
  name    = "${local.service_fqdn}"
  type    = "AAAA"
  zone_id = "${data.aws_route53_zone.zone.id}"

  alias {
    name                   = "${module.healthcheck.alb_dns_name}"
    zone_id                = "${module.healthcheck.alb_zone_id}"
    evaluate_target_health = false
  }
}
