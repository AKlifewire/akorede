import * as cdk from 'aws-cdk-lib';
import { UIStack } from '../cdk/stacks/UIStack';

const app = new cdk.App();
new UIStack(app, 'UIStack');