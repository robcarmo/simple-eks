# Terraform EKS Module

This repository contains Terraform configurations for deploying an Amazon EKS cluster with integrated networking and Kubernetes resource management. It now also includes a Helm chart for managing Kubernetes resources.

## Repository Structure
```
├── helm/
│   └── demo-service/ # Helm chart for deploying the demo service
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/ # Kubernetes manifest templates
├── infra/
│   ├── main.tf # Core configuration
│   ├── modules/
│   │   ├── eks/ # EKS cluster module
│   │   │   ├── main.tf # Security groups, IAM roles, EKS cluster
│   │   │   ├── variables.tf # Module inputs
│   │   │   └── outputs.tf # Module outputs
│   │   ├── vpc/ # Networking module
│   │   │   ├── main.tf # VPC, subnets, routing
│   │   │   ├── variables.tf # Networking inputs
│   │   │   └── outputs.tf # Networking outputs
│   ├── outputs.tf
│   └── variables.tf
```

## Prerequisites

### AWS Access Keys for GitHub Actions

To deploy this infrastructure via GitHub Actions, you need to set up AWS access keys with the necessary permissions. Follow these steps:

1. **Create an IAM User with Programmatic Access**:
   - Go to the IAM console in AWS
   - Create a new user with programmatic access
   - Attach policies that allow managing EKS, ECR, VPC, and other required resources

2. **Set GitHub Secrets**:
   - Go to your GitHub repository settings
   - Under "Secrets and variables" → "Actions", add the following secrets:
     - `AWS_ACCESS_KEY_ID`: Your IAM user's access key ID
     - `AWS_SECRET_ACCESS_KEY`: Your IAM user's secret access key
     - `TF_STATE_BUCKET`: The S3 bucket name for storing Terraform state
     - `ADMIN_USER_ARN`: ARN of the admin user for EKS access
     - `ADMIN_K8S_USERNAME`: Kubernetes username for admin access
     - `ECR_REPOSITORY`: Name of your ECR repository

## Testing Your Application After Deployment

### Automated Testing

You can use the provided GitHub Actions workflow to test your deployment:

1. Go to the GitHub Actions tab in your repository
2. Manually trigger the "Manual EKS Cluster Verification" workflow
3. This workflow will:
   - Verify the deployment has at least one replica running
   - Wait for the LoadBalancer service to get an external IP/hostname
   - Test the endpoint with curl to confirm it returns "Hello World!"

### Manual Testing

1. Get the LoadBalancer endpoint:
   ```shell
   kubectl get svc demo-service-svc -n demo-service
   ```

2. Test the endpoint using curl:
   ```shell
   curl http://<EXTERNAL-IP>:8080
   ```
   You should receive "Hello World!" as the response.

3. Troubleshooting if the application doesn't respond:
   - Check pod status: `kubectl get pods -n demo-service`
   - Check pod logs: `kubectl logs -n demo-service -l app=demo-service`
   - Verify port configuration: `kubectl describe deployment demo-service -n demo-service`
   - Ensure the container port (in deployment) matches the application's listening port (8080)

## Important Configuration Note

Ensure that the `targetPort` in your `values.yaml` matches the port your application is listening on. The Node.js application in this repository listens on port 8080, so the `targetPort` should be set to 8080:

```yaml
service:
  name: demo-service-svc
  type: LoadBalancer
  port: 8080
  targetPort: 8080  # Must match the port your application listens on
```

## References

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)

## Last Updated

Last updated: April 2025 (Terraform 1.5+, AWS Provider 5.0+, Helm 3.0+)