# PowerShell script to manually configure amplifyconfiguration.dart
# This script prompts for configuration values and updates the Flutter app configuration

# Get the directory of this script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$flutterConfigPath = Join-Path $scriptDir "..\flutter_app\lib\config\amplifyconfiguration.dart"

Write-Host "Manual Configuration for Flutter App" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host "Please enter the following values from your AWS Console:" -ForegroundColor Yellow

# Prompt for configuration values
$region = Read-Host "AWS Region (e.g., us-east-1)"
$userPoolId = Read-Host "Cognito User Pool ID"
$userPoolClientId = Read-Host "Cognito User Pool Client ID"
$identityPoolId = Read-Host "Cognito Identity Pool ID"
$apiUrl = Read-Host "AppSync GraphQL API URL"
$bucketName = Read-Host "S3 Bucket Name for UI definitions"
$iotEndpoint = Read-Host "IoT Endpoint (e.g., abcdef123456-ats.iot.region.amazonaws.com)"

# Create the configuration content
$configContent = @"
// This file was manually configured with values from AWS Console
// Last updated: $(Get-Date)

const amplifyconfig = '''{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify/cli",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CredentialsProvider": {
          "CognitoIdentity": {
            "Default": {
              "PoolId": "$identityPoolId",
              "Region": "$region"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "$userPoolId",
            "AppClientId": "$userPoolClientId",
            "Region": "$region"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "socialProviders": [],
            "usernameAttributes": ["EMAIL"],
            "signupAttributes": ["EMAIL"],
            "passwordProtectionSettings": {
              "passwordPolicyMinLength": 8,
              "passwordPolicyCharacters": []
            },
            "mfaConfiguration": "OFF",
            "mfaTypes": ["SMS"],
            "verificationMechanisms": ["EMAIL"]
          }
        }
      }
    }
  },
  "api": {
    "plugins": {
      "awsAPIPlugin": {
        "wireAPI": {
          "endpointType": "GraphQL",
          "endpoint": "$apiUrl",
          "region": "$region",
          "authorizationType": "AMAZON_COGNITO_USER_POOLS"
        }
      }
    }
  },
  "storage": {
    "plugins": {
      "awsS3StoragePlugin": {
        "bucket": "$bucketName",
        "region": "$region"
      }
    }
  },
  "iot": {
    "AWSIoTEndpoint": "$iotEndpoint"
  }
}''';
"@

# Create the directory if it doesn't exist
$configDir = Split-Path -Parent $flutterConfigPath
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

# Write the configuration to the file
Set-Content -Path $flutterConfigPath -Value $configContent

Write-Host "`nConfiguration file updated successfully: $flutterConfigPath" -ForegroundColor Green
Write-Host "Your Flutter app is now configured to use your CDK-deployed backend resources." -ForegroundColor Green