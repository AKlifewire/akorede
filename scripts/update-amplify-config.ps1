# PowerShell script to update the Flutter app's amplifyconfiguration.dart file with values from SSM Parameter Store

# Stop on error
$ErrorActionPreference = "Stop"

Write-Host "Updating Amplify configuration for Flutter app..." -ForegroundColor Green

# Get the directory of this script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Install required npm packages
Write-Host "Installing required npm packages..." -ForegroundColor Yellow
npm install @aws-sdk/client-ssm

# Run the Node.js script to update the configuration
Write-Host "Running configuration update script..." -ForegroundColor Yellow
node "$scriptDir\update-amplify-config.js"

Write-Host "Amplify configuration updated successfully!" -ForegroundColor Green