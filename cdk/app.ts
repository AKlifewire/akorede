import * as cdk from 'aws-cdk-lib';
import { AmplifyHostingStack } from './stacks/AmplifyHostingStack';
import { CodePipelineStack } from './stacks/CodePipelineStack';
import { UIStack } from './stacks/UIStack';
import { LambdaStack } from './stacks/LambdaStack';

const app = new cdk.App();

new AmplifyHostingStack(app, 'AmplifyHostingStack', {
  domainName: 'example.com', // Replace with your actual domain name
});

new CodePipelineStack(app, 'CodePipelineStack');

new UIStack(app, 'UIStack');

new LambdaStack(app, 'LambdaStack', {
  app: 'SmartHomeApp',
  envName: 'dev',
});