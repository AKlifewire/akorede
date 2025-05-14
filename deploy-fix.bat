@echo off
echo === Smart Home Platform Deployment Fix Script ===

REM Install dependencies
echo Installing dependencies...
call npm ci
cd cdk && call npm ci
cd ..

REM Install AWS Amplify Alpha package
echo Installing AWS Amplify Alpha package...
call npm install @aws-cdk/aws-amplify-alpha
cd cdk && call npm install @aws-cdk/aws-amplify-alpha
cd ..

REM Copy schema.graphql to CDK directory
echo Copying schema.graphql to CDK directory...
if not exist cdk\schema.graphql mkdir cdk\schema.graphql
copy schema.graphql cdk\schema.graphql\

REM Build the project
echo Building the project...
call npm run build

REM Bootstrap CDK (if needed)
echo Bootstrapping CDK environment...
call npx cdk bootstrap

REM Deploy all stacks
echo Deploying all stacks...
call npx cdk deploy --all --require-approval never

echo === Deployment Complete ===