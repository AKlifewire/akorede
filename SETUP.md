# GitHub Actions Setup Guide

This project uses GitHub Actions for CI/CD instead of AWS CodePipeline. Follow these steps to set up GitHub Actions for your repository:

## 1. Add GitHub Secrets

1. Go to your GitHub repository
2. Click on "Settings" > "Secrets and variables" > "Actions"
3. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

## 2. GitHub Actions Workflows

Two workflows are included:

### CDK Deployment Workflow

Located at `.github/workflows/deploy-cdk.yml`, this workflow:
- Deploys all CDK stacks in the correct order
- Runs on pushes to the main branch
- Can be manually triggered

### Flutter Deployment Workflow

Located at `.github/workflows/deploy-flutter.yml`, this workflow:
- Builds and deploys the Flutter web application
- Runs on pushes to the main branch that modify Flutter code
- Can be manually triggered

## 3. Manual Deployment

If you prefer to deploy manually:

```bash
# Windows
deploy.bat

# Linux/macOS
./deploy.sh
```

## 4. Monitoring Deployments

1. Go to your GitHub repository
2. Click on "Actions" tab
3. Select the workflow run to view details and logs

## 5. Troubleshooting

If you encounter issues:

1. Check the GitHub Actions logs for detailed error messages
2. Verify your AWS credentials are correct
3. Ensure your AWS account has the necessary permissions
4. Check that all dependencies are installed correctly