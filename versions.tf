terraform {
  # Due to the HashiCorp BSL License change, restricting the latest version of Terraform to 1.5.7.
  required_version = ">= 1.0.0, <= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95.0"
    }
  }
}
