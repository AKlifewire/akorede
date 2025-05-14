# Smart Home Platform Deployment

This repository contains the infrastructure code for the Smart Home platform using AWS CDK.

## Deployment Order

The stacks are deployed in the following order:

1. AuthStack
2. SSMParameterStack
3. UIStack
4. IoTStack
5. LambdaStack
6. AppSyncStack
7. AmplifyHostingStack

## Deployment Instructions

### Prerequisites

- AWS CLI installed and configured
- Node.js and npm installed
- AWS CDK installed globally (`npm install -g aws-cdk`)

### Deployment Steps

#### Windows

Run the deployment script:

```
deploy.bat
```

#### Linux/macOS

Run the deployment script:

```
./deploy.sh
```

### Manual Deployment

If you prefer to deploy manually:

1. Install dependencies:
   ```
   npm install
   ```

2. Build the project:
   ```
   npm run build
   ```

3. Bootstrap CDK (if not already done):
   ```
   cdk bootstrap
   ```

4. Deploy the CodePipeline stack:
   ```
   cdk deploy CodePipelineStack
   ```

5. The CodePipeline will automatically deploy the remaining stacks in the correct order.

## Monitoring Deployment

- You can monitor the deployment in the AWS CodePipeline console
- Email notifications will be sent for deployment events
- CloudWatch alarms are configured to alert on pipeline failures

## Troubleshooting

If deployment fails:

1. Check the CloudWatch logs for the specific stack that failed
2. Review the SNS notifications for error details
3. Fix the issues and restart the pipeline or deploy the specific stack manually