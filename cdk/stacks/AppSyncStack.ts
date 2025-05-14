import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as appsync from 'aws-cdk-lib/aws-appsync';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as ssm from 'aws-cdk-lib/aws-ssm';

export class AppSyncStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create mock Lambda functions for development
    // In production, these would be imported from SSM parameters
    const getUIPageFn = new lambda.Function(this, 'GetUIPageFunction', {
      runtime: lambda.Runtime.NODEJS_18_X,
      handler: 'get-ui-page.handler',
      code: lambda.Code.fromInline(`
        exports.handler = async (event) => {
          console.log('GetUIPage event:', JSON.stringify(event));
          return {
            success: true,
            data: { title: "Example UI Page" }
          };
        };
      `),
    });

    const controlDeviceFn = new lambda.Function(this, 'ControlDeviceFunction', {
      runtime: lambda.Runtime.NODEJS_18_X,
      handler: 'control-device.handler',
      code: lambda.Code.fromInline(`
        exports.handler = async (event) => {
          console.log('ControlDevice event:', JSON.stringify(event));
          return {
            success: true,
            message: "Command sent to device"
          };
        };
      `),
    });

    const getAnalyticsFn = new lambda.Function(this, 'GetAnalyticsFunction', {
      runtime: lambda.Runtime.NODEJS_18_X,
      handler: 'get-analytics.handler',
      code: lambda.Code.fromInline(`
        exports.handler = async (event) => {
          console.log('GetAnalytics event:', JSON.stringify(event));
          return {
            success: true,
            data: { metrics: [{ date: "2025-05-14", value: 42 }] }
          };
        };
      `),
    });

    // Store Lambda ARNs in SSM for other stacks to use
    new ssm.StringParameter(this, 'GetUIPageArnParam', {
      parameterName: '/lambda/get-ui-page-arn',
      stringValue: getUIPageFn.functionArn,
    });

    new ssm.StringParameter(this, 'ControlDeviceArnParam', {
      parameterName: '/lambda/control-device-arn',
      stringValue: controlDeviceFn.functionArn,
    });

    new ssm.StringParameter(this, 'GetAnalyticsArnParam', {
      parameterName: '/lambda/get-analytics-arn',
      stringValue: getAnalyticsFn.functionArn,
    });

    // AppSync GraphQL API
    const api = new appsync.GraphqlApi(this, 'GraphqlApi', {
      name: 'SmartHomeAPI',
      schema: appsync.SchemaFile.fromAsset('schema.graphql'),
      authorizationConfig: {
        defaultAuthorization: {
          authorizationType: appsync.AuthorizationType.API_KEY,
          apiKeyConfig: {
            expires: cdk.Expiration.after(cdk.Duration.days(365))
          }
        }
      }
    });

    // Lambda data sources
    const getUIPageSource = api.addLambdaDataSource('GetUIPageSource', getUIPageFn);
    const controlDeviceSource = api.addLambdaDataSource('ControlDeviceSource', controlDeviceFn);
    const getAnalyticsSource = api.addLambdaDataSource('GetAnalyticsSource', getAnalyticsFn);

    // Resolver bindings
    getUIPageSource.createResolver('GetUIPageResolver', {
      typeName: 'Query',
      fieldName: 'getUiPage',
    });

    controlDeviceSource.createResolver('ControlDeviceResolver', {
      typeName: 'Mutation',
      fieldName: 'controlDevice',
    });

    getAnalyticsSource.createResolver('GetAnalyticsResolver', {
      typeName: 'Query',
      fieldName: 'getAnalytics',
    });

    controlDeviceSource.createResolver('OnDeviceStateChangeResolver', {
      typeName: 'Subscription',
      fieldName: 'onDeviceStateChange',
      requestMappingTemplate: appsync.MappingTemplate.fromString(`
        {
          "version": "2018-05-29",
          "payload": {}
        }
      `),
      responseMappingTemplate: appsync.MappingTemplate.fromString('$util.toJson($ctx.result)'),
    });

    // Export GraphQL API URL and key
    new cdk.CfnOutput(this, 'GraphQLApiUrl', {
      value: api.graphqlUrl,
    });

    new cdk.CfnOutput(this, 'GraphQLApiId', {
      value: api.apiId,
    });

    new cdk.CfnOutput(this, 'GraphQLApiKey', {
      value: api.apiKey || 'No API Key defined',
    });
  }
}