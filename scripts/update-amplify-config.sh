#!/bin/bash
# Script to update the Flutter app's amplifyconfiguration.dart file with values from SSM Parameter Store

# Exit on error
set -e

echo "Updating Amplify configuration for Flutter app..."

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Install required npm packages
echo "Installing required npm packages..."
npm install @aws-sdk/client-ssm

# Run the Node.js script to update the configuration
echo "Running configuration update script..."
node "$SCRIPT_DIR/update-amplify-config.js"

echo "Amplify configuration updated successfully!"