# Syncing Your Flutter App with AWS Backend

This guide will help you fully sync your Flutter app with your AWS backend resources created via CDK.

## Step 1: Update amplifyconfiguration.dart

The `amplifyconfiguration.dart` file needs to be updated with the actual values from your deployed AWS resources. There are two methods to do this:

### Method 1: Using the update-amplify-config script (Recommended)

This script automatically pulls values from SSM Parameter Store and updates your configuration file.

**For Windows:**
```powershell
# From the project root directory
.\scripts\update-amplify-config.ps1
```

**For Mac/Linux:**
```bash
# From the project root directory
./scripts/update-amplify-config.sh
```

### Method 2: Manually getting values and updating

If you prefer to see the values before updating:

1. **Get the values from CloudFormation:**

   **For Windows:**
   ```powershell
   # From the project root directory
   .\scripts\get-config-values.ps1
   ```

   This will display and save the values to `scripts/config-values.json`.

2. **Manually update the amplifyconfiguration.dart file:**

   Open `flutter_app/lib/config/amplifyconfiguration.dart` and replace the placeholder values with the actual values from the previous step.

## Step 2: Push Code to GitHub for Auto-Deploy

Since you've already set up Amplify Hosting with CI/CD:

1. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Update amplifyconfiguration with real values"
   ```

2. **Push to your GitHub repository:**
   ```bash
   git push origin main
   ```

   This will trigger the Amplify Hosting build pipeline to deploy your updated Flutter web app.

## Step 3: Verify Deployment

1. Go to the AWS Amplify Console in your AWS account
2. Select your app and check the build status
3. Once deployed, click on the generated URL to test your app

## Troubleshooting

If you encounter issues:

1. **SSM Parameter Store Issues:**
   - Ensure your AWS CLI is configured with the correct credentials and region
   - Verify that the SSM parameters exist with the expected paths (see `scripts/update-amplify-config.js` for the paths)

2. **CloudFormation Stack Issues:**
   - Verify that your stack names match those in the scripts (AuthStack, AppSyncStack, UIStack)
   - Check if the expected outputs exist in your CloudFormation stacks

3. **Amplify Hosting Issues:**
   - Check the build logs in the Amplify Console for any errors
   - Verify that your GitHub repository is correctly connected to Amplify Hosting

## Next Steps

After successful deployment:

1. Test user authentication flows
2. Verify API connections
3. Test IoT device interactions
4. Ensure S3 storage access is working properly