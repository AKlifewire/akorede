#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { UIStack } from '../stacks/UIStack';
import { SSMParameterStack } from '../stacks/ssm/ssm-parameter-stack';
import { AppSyncStack } from '../stacks/AppSyncStack';

const app = new cdk.App();

// Instantiate the UIStack
new UIStack(app, 'UIStack');

// Instantiate the SSMParameterStack
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

// Instantiate the AppSyncStack
new AppSyncStack(app, 'AppSyncStack');