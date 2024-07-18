# Terraform AWS Infrastructure

This repository contains Terraform configurations for setting up and managing AWS infrastructure. It includes configurations for various AWS services and uses an S3 bucket for remote state storage.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- AWS CLI configured with appropriate permissions.
- An S3 bucket for storing the Terraform state file.
- (Optional) A DynamoDB table for state locking.

## Files in this Repository

- `_context.tf`: Contains context-specific Terraform configurations.
- `_data.tf`: Data sources and external data configurations.
- `_fixtures.tfvars`: Variable definitions for the fixtures.
- `_providers.tf`: Provider configurations.
- `_variables.tf`: Variable definitions.
- `_version.tf`: Required Terraform version.
- `ecr.tf`: AWS Elastic Container Registry (ECR) configurations.
- `ecs.tf`: AWS Elastic Container Service (ECS) configurations.
- `vpc.tf`: Virtual Private Cloud (VPC) configurations.
- `ssl.tf`: SSL certificate configurations.

## Backend Configuration

The Terraform state is stored remotely in an S3 bucket. Below is the configuration for the backend.

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"  # replace with your bucket name
    key            = "path/to/your/terraform.tfstate"  # path within the bucket to store the state file
    region         = "your-region"  # e.g., us-west-2
    dynamodb_table = "your-lock-table"  # replace with your DynamoDB table name (if using state locking)
    encrypt        = true  # encrypt the state file
  }
}

provider "aws" {
  region = "your-region"  # e.g., us-west-2
}
