import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as appsync from 'aws-cdk-lib/aws-appsync';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as ssm from 'aws-cdk-lib/aws-ssm';

export class AppSyncStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Retrieve Cognito resources from SSM
    const userPoolId = ssm.StringParameter.valueForStringParameter(this, '/auth/userPoolId');
    const identityPoolId = ssm.StringParameter.valueForStringParameter(this, '/auth/identityPoolId');

    // Retrieve existing Lambda functions (from LambdaStack)
    const getUIPageFn = lambda.Function.fromFunctionArn(
      this,
      'GetUIPageFn',
      ssm.StringParameter.valueForStringParameter(this, '/lambda/get-ui-page-arn')
    );

    const controlDeviceFn = lambda.Function.fromFunctionArn(
      this,
      'ControlDeviceFn',
      ssm.StringParameter.valueForStringParameter(this, '/lambda/control-device-arn')
    );

    const getAnalyticsFn = lambda.Function.fromFunctionArn(
      this,
      'GetAnalyticsFn',
      ssm.StringParameter.valueForStringParameter(this, '/lambda/get-analytics-arn')
    );

    // AppSync GraphQL API
    const api = new appsync.GraphqlApi(this, 'GraphqlApi', {
      name: 'MyApi',
      definition: appsync.Definition.fromFile('schema.graphql'), // Ensure this path is correct
    });

    // Lambda data sources
    const getUIPageSource = api.addLambdaDataSource('GetUIPageSource', getUIPageFn);
    getUIPageSource.grantPrincipal.addToPrincipalPolicy(new iam.PolicyStatement({
      actions: ['lambda:InvokeFunction'],
      resources: [getUIPageFn.functionArn], // Use the exact ARN
    }));

    const controlDeviceSource = api.addLambdaDataSource('ControlDeviceSource', controlDeviceFn);
    controlDeviceSource.grantPrincipal.addToPrincipalPolicy(new iam.PolicyStatement({
      actions: ['lambda:InvokeFunction'],
      resources: [controlDeviceFn.functionArn], // Use the exact ARN
    }));

    const getAnalyticsSource = api.addLambdaDataSource('GetAnalyticsSource', getAnalyticsFn);
    getAnalyticsSource.grantPrincipal.addToPrincipalPolicy(new iam.PolicyStatement({
      actions: ['lambda:InvokeFunction'],
      resources: [getAnalyticsFn.functionArn], // Use the exact ARN
    }));

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
  }
}