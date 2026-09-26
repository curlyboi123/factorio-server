terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.4.1"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
  }
}
