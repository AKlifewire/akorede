@echo off
echo === Deploying Smart Home Pipeline ===

REM Check if AWS CLI is installed
where aws >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo AWS CLI is not installed. Please install it first.
    exit /b 1
)

REM Check if CDK is installed
where cdk >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo AWS CDK is not installed. Installing now...
    call npm install -g aws-cdk
)

REM Check AWS credentials
echo Verifying AWS credentials...
aws sts get-caller-identity
if %ERRORLEVEL% NEQ 0 (
    echo AWS credentials not configured. Please run 'aws configure'
    exit /b 1
)

REM Install dependencies
echo Installing dependencies...
call npm install

REM Build the project
echo Building the project...
call npm run build

REM Bootstrap CDK (if needed)
echo Bootstrapping CDK environment...
call cdk bootstrap

REM Deploy only the CodePipeline stack
echo Deploying CodePipelineStack...
call npx cdk deploy CodePipelineStack --require-approval never --app "npx ts-node --prefer-ts-exts cdk/bin/deploy-pipeline.ts"

echo === Pipeline Deployment Complete ===
echo The CodePipeline has been deployed and will automatically deploy the remaining stacks in this order:
echo 1. AuthStack
echo 2. SSMParameterStack
echo 3. UIStack
echo 4. IoTStack
echo 5. LambdaStack
echo 6. AppSyncStack
echo 7. AmplifyHostingStack
echo.
echo You can monitor the deployment in the AWS CodePipeline console.