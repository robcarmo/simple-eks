# Simple EKS Cluster with GitHub Actions

This repository contains Terraform configurations and GitHub Actions workflows for deploying and managing an Amazon EKS cluster using AWS access keys.

## Repository Structure

```
├── .github/workflows/    # GitHub Actions workflow definitions
├── app/                 # Demo application code and Dockerfile
├── helm/               # Helm chart for deploying the demo service
└── infra/              # Terraform configurations for AWS infrastructure
```

## Prerequisites

### AWS Access Keys Setup

1. Create an IAM user with appropriate permissions:
   - EKS cluster management
   - ECR repository access
   - VPC and networking management
   - S3 access for Terraform state

2. Generate access keys for the IAM user

3. Add the following secrets to your GitHub repository:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `AWS_ACCOUNT_ID`: Your AWS account ID
   - `ECR_REPOSITORY`: Name of your ECR repository
   - `TF_STATE_BUCKET`: Name of your S3 bucket for Terraform state
   - `ADMIN_USER_ARN`: ARN of the IAM user for cluster access
   - `ADMIN_K8S_USERNAME`: Kubernetes username for the admin user

## GitHub Actions Workflows

### Infrastructure Deployment
- **Workflow**: `.github/workflows/infra-deploy.yaml`
- **Trigger**: Push to `master` branch in `infra/` directory
- **Actions**: 
  - Initialize Terraform
  - Plan infrastructure changes
  - Apply infrastructure changes

### Application Deployment
- **Workflow**: `.github/workflows/app-build.yaml`
- **Trigger**: Push to `master` branch in `app/` directory
- **Actions**:
  - Build Docker image
  - Push to ECR
  - Deploy to EKS using Helm

### Cluster Testing
- **Workflow**: `.github/workflows/cluster-test.yaml`
- **Trigger**: Manual workflow dispatch
- **Actions**:
  - Verify EKS cluster health
  - Test service deployment
  - Validate endpoint access

## Port Configuration

The demo service runs on port 8080. This is configured in:
- `app/app.js`: Express server port
- `helm/demo-service/values.yaml`: Service port mapping
- `helm/demo-service/templates/deployment.yaml`: Container port

## Testing

1. Deploy infrastructure:
   ```bash
   git push origin master  # Updates to infra/ directory
   ```

2. Build and deploy application:
   ```bash
   git push origin master  # Updates to app/ directory
   ```

3. Run cluster tests:
   - Go to GitHub Actions tab
   - Select "Manual EKS Cluster Verification"
   - Click "Run workflow"
   - Monitor test results

## References

- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Last Updated

Last updated: April 2025 (AWS Provider 5.0+, GitHub Actions v4)