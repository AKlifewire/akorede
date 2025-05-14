#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { CodePipelineStack } from '../stacks/CodePipelineStack';

const app = new cdk.App();

// Only deploy the CodePipelineStack
new CodePipelineStack(app, 'CodePipelineStack');