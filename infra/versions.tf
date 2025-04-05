terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" // Ensure compatibility with AWS resources
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0" // Ensure compatibility with Kubernetes resources
    }
  }

  backend "s3" {
    bucket  = "tfstate-dev-qjau56sf"    // Added bucket name
    key     = "infra/terraform.tfstate" // Path to state file within the bucket
    region  = "us-east-1"               // Ensure this matches the bucket's region
    encrypt = true                      // Enable server-side encryption
  }
}