#!/bin/bash
set -e

echo "=== Smart Home Platform Deployment Script ==="
echo "This script will deploy your Smart Home platform using AWS CDK"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if CDK is installed
if ! command -v cdk &> /dev/null; then
    echo "AWS CDK is not installed. Installing now..."
    npm install -g aws-cdk
fi

# Check AWS credentials
echo "Verifying AWS credentials..."
aws sts get-caller-identity || { echo "AWS credentials not configured. Please run 'aws configure'"; exit 1; }

# Install dependencies
echo "Installing dependencies..."
npm install

# Build the project
echo "Building the project..."
npm run build

# Bootstrap CDK (if needed)
echo "Bootstrapping CDK environment..."
cdk bootstrap

# Deploy all stacks
echo "Deploying all stacks..."
cdk deploy --all --require-approval never

echo "=== Deployment Complete ==="