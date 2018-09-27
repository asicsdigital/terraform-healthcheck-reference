terraform {
  required_version = ">= 0.11.7"

  backend "s3" {
    bucket         = "asics-devops-state-us-east-1"
    region         = "us-east-1"
    key            = "terraform-healthcheck-reference/state/prod/prod.tfstate"
    dynamodb_table = "asics-services-terraformStateLock"
  }
}
