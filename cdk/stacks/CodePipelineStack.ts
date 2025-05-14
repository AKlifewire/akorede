import {
  Stack,
  StackProps,
  SecretValue,
  aws_codepipeline as codepipeline,
  aws_codepipeline_actions as actions,
  aws_codebuild as codebuild,
  aws_s3 as s3,
  aws_iam as iam,
  RemovalPolicy,
  aws_sns as sns,
  aws_sns_subscriptions as subscriptions,
  aws_cloudwatch as cloudwatch,
  aws_cloudwatch_actions as cloudwatch_actions,
} from 'aws-cdk-lib';
import { Construct } from 'constructs';

export class CodePipelineStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    // S3 bucket for storing pipeline artifacts
    const artifactBucket = new s3.Bucket(this, 'ArtifactBucket', {
      versioned: true,
      removalPolicy: RemovalPolicy.DESTROY,
      autoDeleteObjects: true,
    });

    // Define pipeline artifacts
    const sourceOutput = new codepipeline.Artifact();
    const buildOutput = new codepipeline.Artifact();

    // CodeBuild project for building the CDK app
    const buildProject = new codebuild.PipelineProject(this, 'BuildProject', {
      environment: {
        buildImage: codebuild.LinuxBuildImage.STANDARD_7_0,
      },
      buildSpec: codebuild.BuildSpec.fromObject({
        version: '0.2',
        phases: {
          install: {
            'runtime-versions': { nodejs: '18' },
            commands: [
              'npm install -g aws-cdk',
              'npm install',
              'mkdir -p cdk.out'
            ],
          },
          build: {
            commands: [
              'npm run build',
              'cd cdk && npm install',
              'npx cdk synth'
            ],
          },
        },
        artifacts: {
          'base-directory': 'cdk.out',
          files: ['**/*'],
        },
      }),
    });

    // Grant necessary permissions to the CodeBuild project
    buildProject.addToRolePolicy(
      new iam.PolicyStatement({
        actions: [
          'cloudformation:*', 
          's3:*', 
          'iam:*', 
          'lambda:*', 
          'appsync:*', 
          'cognito:*', 
          'iot:*', 
          'ssm:*',
          'amplify:*',
          'cloudwatch:*',
          'sns:*',
          'logs:*',
          'codebuild:*',
          'codepipeline:*'
        ],
        resources: ['*'],
      })
    );

    // Create SNS topic for deployment notifications
    const deploymentTopic = new sns.Topic(this, 'DeploymentNotifications', {
      displayName: 'Smart Home Deployment Notifications',
    });
    
    // Add email subscription - replace with your email
    // Comment out for initial deployment - you'll need to confirm subscription
    // Uncomment and update with your email to enable notifications
    // deploymentTopic.addSubscription(
    //   new subscriptions.EmailSubscription('your-email@example.com')
    // );

    // Define the CodePipeline with deployment handling
    const pipeline = new codepipeline.Pipeline(this, 'SmartHomePipeline', {
      pipelineName: 'SmartHomeCDKPipeline',
      pipelineType: codepipeline.PipelineType.V2,
      artifactBucket,
      stages: [
        {
          stageName: 'Source',
          actions: [
            new actions.GitHubSourceAction({
              actionName: 'GitHub_Source',
              owner: 'AKlifewire',
              repo: 'akorede',
              branch: 'main',
              oauthToken: SecretValue.secretsManager('github-token'),
              output: sourceOutput,
              trigger: actions.GitHubTrigger.WEBHOOK,
            }),
          ],
        },
        {
          stageName: 'Build',
          actions: [
            new actions.CodeBuildAction({
              actionName: 'Build_CDK',
              project: buildProject,
              input: sourceOutput,
              outputs: [buildOutput],
            }),
          ],
        },
        {
          stageName: 'Deploy',
          actions: [
            // Following the specified deployment order
            new actions.CloudFormationCreateUpdateStackAction({
              actionName: 'Deploy_AuthStack',
              stackName: 'AuthStack',
              templatePath: buildOutput.atPath('AuthStack.template.json'),
              adminPermissions: true,
              runOrder: 1,
              notificationTopic: deploymentTopic,
            }),
            new actions.CloudFormationCreateUpdateStackAction({
              actionName: 'Deploy_SSMParameterStack',
              stackName: 'SSMParameterStack',
              templatePath: buildOutput.atPath('SSMParameterStack.template.json'),
              adminPermissions: true,
              runOrder: 2,
              notificationTopic: deploymentTopic,
            }),
            new actions.CloudFormationCreateUpdateStackAction({
              actionName: 'Deploy_UIStack',
              stackName: 'UIStack',
              templatePath: buildOutput.atPath('UIStack.template.json'),
              adminPermissions: true,
              runOrder: 3,
              notificationTopic: deploymentTopic,
            }),
            new actions.CloudFormationCreateUpdateStackAction({
              actionName: 'Deploy_IoTStack',
              stackName: 'IoTStack',
              templatePath: buildOutput.atPath('IoTStack.template.json'),
              adminPermissions: true,
              runOrder: 4,
              notificationTopic: deploymentTopic,
            }),
            new actions.CloudFormationCreateUpdateStackAction({
              actionName: 'Deploy_LambdaStack',
              stackName: 'LambdaStack',
              templatePath: buildOutput.atPath('LambdaStack.template.json'),
              adminPermissions: true,
              runOrder: 5,
              notificationTopic: deploymentTopic,
            }),
            new actions.CloudFormationCreateUpdateStackAction({
              actionName: 'Deploy_AppSyncStack',
              stackName: 'AppSyncStack',
              templatePath: buildOutput.atPath('AppSyncStack.template.json'),
              adminPermissions: true,
              runOrder: 6,
              notificationTopic: deploymentTopic,
            }),
            new actions.CloudFormationCreateUpdateStackAction({
              actionName: 'Deploy_AmplifyHostingStack',
              stackName: 'AmplifyHostingStack',
              templatePath: buildOutput.atPath('AmplifyHostingStack.template.json'),
              adminPermissions: true,
              runOrder: 7,
              notificationTopic: deploymentTopic,
            }),
          ],
        },
        {
          stageName: 'Verify',
          actions: [
            new actions.CodeBuildAction({
              actionName: 'RunTests',
              project: new codebuild.PipelineProject(this, 'TestProject', {
                environment: {
                  buildImage: codebuild.LinuxBuildImage.STANDARD_7_0,
                },
                buildSpec: codebuild.BuildSpec.fromObject({
                  version: '0.2',
                  phases: {
                    install: {
                      'runtime-versions': { nodejs: '18' },
                      commands: ['npm install'],
                    },
                    build: {
                      commands: [
                        'echo "Running verification tests"',
                        'echo "Checking AuthStack deployment..."',
                        'aws cognito-idp list-user-pools --max-results 10',
                        'echo "Checking IoT deployment..."',
                        'aws iot list-things',
                        'echo "Checking AppSync deployment..."',
                        'aws appsync list-graphql-apis',
                      ],
                    },
                  },
                  artifacts: {
                    files: ['test-results.json'],
                  },
                }),
              }),
              input: sourceOutput,
            }),
          ],
        },
      ],
    });

    // Create CloudWatch alarms for pipeline failures
    const pipelineFailureMetric = new cloudwatch.Metric({
      namespace: 'AWS/CodePipeline',
      metricName: 'FailedPipelineCount',
      dimensionsMap: {
        PipelineName: pipeline.pipelineName,
      },
      statistic: 'Sum',
      period: cloudwatch.Duration.minutes(5),
    });

    const pipelineFailureAlarm = new cloudwatch.Alarm(this, 'PipelineFailureAlarm', {
      metric: pipelineFailureMetric,
      threshold: 1,
      evaluationPeriods: 1,
      alarmDescription: 'Smart Home Pipeline Deployment Failure',
      treatMissingData: cloudwatch.TreatMissingData.NOT_BREACHING,
    });

    pipelineFailureAlarm.addAlarmAction(
      new cloudwatch_actions.SnsAction(deploymentTopic)
    );
  }
}