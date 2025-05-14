import * as cdk from 'aws-cdk-lib';
import { AmplifyHostingStack } from './stacks/AmplifyHostingStack';
import { UIStack } from './stacks/UIStack';
import { LambdaStack } from './stacks/LambdaStack';
import { AuthStack } from './stacks/AuthStack';
import { IoTStack } from './stacks/IoTStack';
import { AppSyncStack } from './stacks/AppSyncStack';
import { SSMParameterStack } from './stacks/ssm/ssm-parameter-stack';

const app = new cdk.App();

// Define common environment
const env = {
  account: process.env.CDK_DEFAULT_ACCOUNT,
  region: process.env.CDK_DEFAULT_REGION || 'us-east-1'
};

// Instantiate the AuthStack for authentication
const authStack = new AuthStack(app, 'AuthStack', {
  appName: 'SmartHome',
  envName: 'dev',
  env
});

// Instantiate the SSMParameterStack for centralized parameter management
const ssmStack = new SSMParameterStack(app, 'SSMParameterStack', {
  parameters: {
    UserPoolId: authStack.userPool.userPoolId,
    UserPoolClientId: authStack.userPoolClient.userPoolClientId,
    IdentityPoolId: authStack.identityPool.ref,
    StorageBucketName: 'smart-home-storage-bucket',
    AppSyncApiUrl: 'placeholder-to-be-updated',
  },
  secureKeys: ['UserPoolClientId'],
  environmentTag: 'dev',
  enableCleanupLambda: true,
  env
});

// Add dependency to ensure proper order
ssmStack.addDependency(authStack);

// Instantiate the LambdaStack for backend logic
const lambdaStack = new LambdaStack(app, 'LambdaStack', {
  app: 'SmartHomeApp',
  envName: 'dev',
  env
});

// Instantiate the IoTStack for IoT functionality
const iotStack = new IoTStack(app, 'IoTStack', {
  env
});

// Instantiate the AppSyncStack for GraphQL API
const appSyncStack = new AppSyncStack(app, 'AppSyncStack', {
  env
});

// Add dependencies to ensure proper order
appSyncStack.addDependency(lambdaStack);
appSyncStack.addDependency(authStack);

// Instantiate the UIStack for hosting the frontend UI
const uiStack = new UIStack(app, 'UIStack', {
  env
});

// Instantiate the AmplifyHostingStack for web hosting
const amplifyStack = new AmplifyHostingStack(app, 'AmplifyHostingStack', {
  domainName: 'example.com',
  env
});