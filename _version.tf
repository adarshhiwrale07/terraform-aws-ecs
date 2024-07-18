terraform {
  backend "s3" {
    bucket         = "terraform-statefiles-001"
    key            = "sndkcorp/terraform.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}
