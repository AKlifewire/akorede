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
            commands: ['npm install -g aws-cdk', 'npm install'],
          },
          build: {
            commands: ['npm run build'],
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
        actions: ['cloudformation:*', 's3:*', 'iam:*', 'lambda:*', 'appsync:*'],
        resources: ['*'],
      })
    );

    // Define the CodePipeline
    new codepipeline.Pipeline(this, 'SmartHomePipeline', {
      pipelineName: 'SmartHomeCDKPipeline',
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
              trigger: actions.GitHubTrigger.WEBHOOK, // Enable webhook trigger
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
            new actions.CloudFormationCreateUpdateStackAction({
              actionName: 'Deploy_Stacks',
              stackName: 'SmartHomeMasterStack',
              templatePath: buildOutput.atPath('SmartHomeMasterStack.template.json'),
              adminPermissions: true,
            }),
          ],
        },
      ],
    });
  }
}