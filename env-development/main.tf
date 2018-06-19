# DEVELOPMENT
locals {
  hostname = "${var.env}.${var.fqdn}"
  vpc_name = "asics-services-${var.env}-us-east-1"
}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "aws_region" "us-east-1" {
  name = "us-east-1"
}

data "aws_region" "us-west-1" {
  name = "us-west-1"
}

data "aws_route53_zone" "zone" {
  name = "${local.hostname}."
}

data "aws_vpc" "vpc" {
  tags = {
    "Name" = "${local.vpc_name}"
  }
}

# this returns a list of strings
# _e.g._ public_subnets = ["${data.aws_subnet_ids.public}"]
data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    Tier = "public"
  }
}

# this converts the corresponding list of strings
# into a list of resources
# _e.g._ public_cidrs = ["${data.aws_subnet.public.*[cidr_block]}"]
data "aws_subnet" "public" {
  count = "${length(data.aws_subnet_ids.public.ids)}"
  id    = "${data.aws_subnet_ids.public.ids[count.index]}"
}

data "aws_subnet_ids" "private" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    Tier = "private"
  }
}

data "aws_subnet" "private" {
  count = "${length(data.aws_subnet_ids.private.ids)}"
  id    = "${data.aws_subnet_ids.private.ids[count.index]}"
}

data "aws_subnet_ids" "database" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    Tier = "database"
  }
}

data "aws_subnet" "database" {
  count = "${length(data.aws_subnet_ids.database.ids)}"
  id    = "${data.aws_subnet_ids.database.ids[count.index]}"
}
