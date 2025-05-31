provider "aws" {
  region = "ap-southeast-2"
}

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
  }

  cloud {
    organization = "example-org"

    workspaces {
      name = "example-workspace"
    }
  }
}
