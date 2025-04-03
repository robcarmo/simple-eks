terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Pinning provider version is recommended
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0" # Adjust version as needed
    }
    # Add external provider if still needed, though it seems removed now
    # external = {
    #   source = "hashicorp/external"
    #   version = "~> 2.0"
    # }
  }

  backend "s3" {
    # Bucket name will be provided during init via -backend-config
    key     = "infra/terraform.tfstate" # Path to state file within the bucket
    region  = "us-east-1"               # Assuming bucket region matches provider/workflows
    encrypt = true                      # Enable server-side encryption
  }
}