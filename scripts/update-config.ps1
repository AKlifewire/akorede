# PowerShell script to update amplifyconfiguration.dart with values from config-values.json
# This script reads the configuration values and updates the Flutter app configuration

# Get the directory of this script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configJsonPath = Join-Path $scriptDir "config-values.json"
$flutterConfigPath = Join-Path $scriptDir "..\flutter_app\lib\config\amplifyconfiguration.dart"

Write-Host "Updating Flutter configuration file..." -ForegroundColor Green

try {
    # Check if config-values.json exists
    if (-not (Test-Path $configJsonPath)) {
        Write-Host "Configuration file not found: $configJsonPath" -ForegroundColor Red
        Write-Host "Please run get-config-values.ps1 first to generate the configuration values." -ForegroundColor Yellow
        exit 1
    }
    
    # Read the configuration values
    $config = Get-Content -Path $configJsonPath | ConvertFrom-Json
    
    # Create the configuration content
    $configContent = @"
// This file was auto-generated from your CDK deployment values
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
              "PoolId": "$($config.identityPoolId)",
              "Region": "$($config.region)"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "$($config.userPoolId)",
            "AppClientId": "$($config.userPoolClientId)",
            "Region": "$($config.region)"
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
          "endpoint": "$($config.apiUrl)",
          "region": "$($config.region)",
          "authorizationType": "AMAZON_COGNITO_USER_POOLS"
        }
      }
    }
  },
  "storage": {
    "plugins": {
      "awsS3StoragePlugin": {
        "bucket": "$($config.bucketName)",
        "region": "$($config.region)"
      }
    }
  },
  "iot": {
    "AWSIoTEndpoint": "$($config.iotEndpoint)"
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
    
} catch {
    Write-Host "Error updating configuration file: $_" -ForegroundColor Red
}