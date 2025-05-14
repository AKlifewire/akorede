@echo off
echo === Smart Home Platform Deployment Script ===
echo This script will deploy your Smart Home platform using AWS CDK

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

REM Deploy all stacks
echo Deploying all stacks...
call cdk deploy --all --require-approval never

echo === Deployment Complete ===