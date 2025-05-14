#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { UIStack } from '../stacks/UIStack';
import { SSMParameterStack } from '../stacks/ssm/ssm-parameter-stack';
import { AppSyncStack } from '../stacks/AppSyncStack';
import { CodePipelineStack } from '../stacks/CodePipelineStack';
import { LambdaStack } from '../stacks/LambdaStack';
import { IoTStack } from '../stacks/IoTStack';
import { AuthStack } from '../stacks/AuthStack';
import { AmplifyHostingStack } from '../stacks/AmplifyHostingStack';

const app = new cdk.App();

// Instantiate the UIStack for hosting the frontend UI
new UIStack(app, 'UIStack');

// Instantiate the SSMParameterStack for centralized parameter management
new SSMParameterStack(app, 'SSMParameterStack', {
  parameters: {
    UserPoolId: 'example-user-pool-id',
    UserPoolClientId: 'example-user-pool-client-id',
    IdentityPoolId: 'example-identity-pool-id',
    StorageBucketName: 'example-bucket-name',
    AppSyncApiUrl: 'example-appsync-api-url',
  },
  secureKeys: ['UserPoolClientId'],
  environmentTag: 'prod',
  enableCleanupLambda: true,
});

// Instantiate the AppSyncStack for GraphQL API
new AppSyncStack(app, 'AppSyncStack');

// Instantiate the CodePipelineStack for CI/CD
new CodePipelineStack(app, 'CodePipelineStack');

// Instantiate the LambdaStack for backend logic
new LambdaStack(app, 'LambdaStack', {
  app: 'SmartHomeApp',
  envName: 'dev',
});

// Instantiate the IoTStack for IoT functionality
new IoTStack(app, 'IoTStack');

// Instantiate the AuthStack for authentication
new AuthStack(app, 'AuthStack', {
  appName: 'SmartHome',
  envName: 'dev'
});

// Instantiate the AmplifyHostingStack for web hosting
new AmplifyHostingStack(app, 'AmplifyHostingStack', {
  domainName: 'example.com'
});