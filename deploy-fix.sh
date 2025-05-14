#!/bin/bash
set -e

echo "=== Smart Home Platform Deployment Fix Script ==="

# Install dependencies
echo "Installing dependencies..."
npm ci
cd cdk && npm ci
cd ..

# Install AWS Amplify Alpha package
echo "Installing AWS Amplify Alpha package..."
npm install @aws-cdk/aws-amplify-alpha
cd cdk && npm install @aws-cdk/aws-amplify-alpha
cd ..

# Copy schema.graphql to CDK directory
echo "Copying schema.graphql to CDK directory..."
mkdir -p cdk/schema.graphql
cp schema.graphql cdk/schema.graphql/schema.graphql

# Build the project
echo "Building the project..."
npm run build

# Bootstrap CDK (if needed)
echo "Bootstrapping CDK environment..."
npx cdk bootstrap

# Deploy all stacks
echo "Deploying all stacks..."
npx cdk deploy --all --require-approval never

echo "=== Deployment Complete ==="