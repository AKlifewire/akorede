#!/bin/bash
set -e

# Deploy all CDK stacks
echo "Deploying CDK stacks..."
cdk deploy --all --require-approval never

# Update Amplify configuration
echo "Updating Amplify configuration..."
node scripts/update-amplify-config.js

# Initialize Amplify in the frontend project
echo "Initializing Amplify in the frontend project..."
cd frontend
amplify init --yes

# Add hosting to Amplify
echo "Adding hosting to Amplify..."
amplify add hosting --yes

# Build the Flutter web app
echo "Building Flutter web app..."
flutter build web

# Publish to Amplify hosting
echo "Publishing to Amplify hosting..."
amplify publish --yes

echo "Deployment and configuration complete!"
echo "Your app is now live on Amplify Hosting."