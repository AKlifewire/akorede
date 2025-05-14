# Configuration Scripts for Flutter App

These scripts help you configure your Flutter app to connect to your AWS CDK-deployed backend resources.

## Available Scripts

### 1. Automatic Configuration (Recommended)

This approach uses AWS CLI to automatically fetch configuration values from your CloudFormation stacks:

```powershell
# Step 1: Get configuration values from AWS CloudFormation
.\get-config-values.ps1

# Step 2: Update the Flutter app configuration
.\update-config.ps1
```

### 2. Manual Configuration

If you prefer to enter the values manually (or if the automatic approach doesn't work):

```powershell
# Run the manual configuration script
.\manual-config.ps1
```

This script will prompt you for each required value and update the configuration file.

## Prerequisites

1. **AWS CLI** must be installed and configured with the correct credentials
2. Your AWS profile must have permissions to read CloudFormation stacks and IoT endpoints
3. The stack names must match what's expected (AuthStack, AppSyncStack, UIStack)

## Troubleshooting

### Stack Names Don't Match

If your stack names are different, you can modify the `get-config-values.ps1` script to use the correct stack names.

### AWS CLI Not Configured

Make sure you have AWS CLI installed and configured:

```powershell
# Install AWS CLI (if not already installed)
# See: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

# Configure AWS CLI
aws configure
```

### Manual Value Lookup

If you need to find the values manually:

1. **Cognito User Pool ID and Client ID**: 
   - AWS Console → Cognito → User Pools → Your User Pool → App integration tab

2. **Cognito Identity Pool ID**:
   - AWS Console → Cognito → Identity Pools → Your Identity Pool

3. **AppSync GraphQL API URL**:
   - AWS Console → AppSync → Your API → Settings

4. **S3 Bucket Name**:
   - AWS Console → S3 → Buckets

5. **IoT Endpoint**:
   - AWS Console → IoT Core → Settings → Device data endpoint