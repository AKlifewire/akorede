# Deploy all CDK stacks
Write-Host "Deploying CDK stacks..." -ForegroundColor Green
cdk deploy --all --require-approval never

# Update Amplify configuration
Write-Host "Updating Amplify configuration..." -ForegroundColor Green
node scripts/update-amplify-config.js

# Initialize Amplify in the frontend project
Write-Host "Initializing Amplify in the frontend project..." -ForegroundColor Green
Set-Location -Path frontend
amplify init --yes

# Add hosting to Amplify
Write-Host "Adding hosting to Amplify..." -ForegroundColor Green
amplify add hosting --yes

# Build the Flutter web app
Write-Host "Building Flutter web app..." -ForegroundColor Green
flutter build web

# Publish to Amplify hosting
Write-Host "Publishing to Amplify hosting..." -ForegroundColor Green
amplify publish --yes

Write-Host "Deployment and configuration complete!" -ForegroundColor Green
Write-Host "Your app is now live on Amplify Hosting." -ForegroundColor Green

# Return to the root directory
Set-Location -Path ..