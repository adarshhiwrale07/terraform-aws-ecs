terraform {
  required_version = "~> 1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.8.0"
    }
  }
}