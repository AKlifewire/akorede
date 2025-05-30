#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { WireStack } from '../lib/wire-stack';
import { AuthStack } from '../cdk/stacks/AuthStack';
import { LambdaStack } from '../cdk/stacks/LambdaStack';
import { IoTStack } from '../cdk/stacks/IoTStack';
// import { UIStack } from './stacks/UIStack'; // Removed as it is unused and missing

const app = new cdk.App();

new WireStack(app, 'WireStack', {
  /* If you don't specify 'env', this stack will be environment-agnostic.
   * Account/Region-dependent features and context lookups will not work,
   * but a single synthesized template can be deployed anywhere. */

  /* Uncomment the next line to specialize this stack for the AWS Account
   * and Region that are implied by the current CLI configuration. */
  // env: { account: process.env.CDK_DEFAULT_ACCOUNT, region: process.env.CDK_DEFAULT_REGION },

  /* Uncomment the next line if you know exactly what Account and Region you
   * want to deploy the stack to. */
  // env: { account: '123456789012', region: 'us-east-1' },

  /* For more information, see https://docs.aws.amazon.com/cdk/latest/guide/environments.html */
});

new AuthStack(app, 'AuthStack', {
  appName: 'YourAppName', // Replace with your app name
  envName: 'dev',         // Replace with your environment name
  env: {                  // Specify your AWS account and region
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});

new LambdaStack(app, 'LambdaStack', {
  app: 'YourAppName', // Replace with your app name
  envName: 'dev',     // Replace with your environment name
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});

new IoTStack(app, 'IoTStack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});