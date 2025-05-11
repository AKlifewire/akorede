import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ssm from 'aws-cdk-lib/aws-ssm';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as iam from 'aws-cdk-lib/aws-iam';

interface SSMParameterStackProps extends cdk.StackProps {
  parameters: {
    [key: string]: string;
  };
  secureKeys?: string[]; // Optional keys to store as SecureString
  environmentTag?: string;
  enableCleanupLambda?: boolean;
}

export class SSMParameterStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: SSMParameterStackProps) {
    super(scope, id, props);

    const secureKeys = props.secureKeys ?? [];
    const envTag = props.environmentTag ?? 'prod';

    // Create Parameters
    Object.entries(props.parameters).forEach(([key, value]) => {
      if (secureKeys.includes(key)) {
        // Create a secure parameter
        new ssm.StringParameter(this, `Param-${key}`, {
          parameterName: `/${envTag}/${key}`,
          stringValue: value,
          tier: ssm.ParameterTier.STANDARD,
        });
      } else {
        // Create a standard parameter
        new ssm.StringParameter(this, `Param-${key}`, {
          parameterName: `/${envTag}/${key}`,
          stringValue: value,
          tier: ssm.ParameterTier.STANDARD,
        });
      }
    });

    // Optional Cleanup Lambda
    if (props.enableCleanupLambda) {
      const cleanupFunction = new lambda.Function(this, 'SSMCleanupFunction', {
        runtime: lambda.Runtime.NODEJS_18_X,
        handler: 'index.handler',
        code: lambda.Code.fromInline(`
          const AWS = require('aws-sdk');
          const ssm = new AWS.SSM();
          exports.handler = async function () {
            const env = '${envTag}';
            const result = await ssm.describeParameters({}).promise();
            const toDelete = result.Parameters.filter(p => p.Name.startsWith('/' + env + '/') && p.Tags?.some(tag => tag.Key === 'obsolete'));
            for (const param of toDelete) {
              await ssm.deleteParameter({ Name: param.Name }).promise();
              console.log('Deleted:', param.Name);
            }
            return 'Cleanup complete';
          };
        `),
        timeout: cdk.Duration.seconds(30),
      });

      // Grant permissions
      cleanupFunction.addToRolePolicy(new iam.PolicyStatement({
        actions: ['ssm:DescribeParameters', 'ssm:DeleteParameter', 'ssm:ListTagsForResource'],
        resources: ['*'],
      }));

      new cdk.CfnOutput(this, 'CleanupFunctionName', {
        value: cleanupFunction.functionName,
      });
    }
  }
}