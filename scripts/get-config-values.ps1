# PowerShell script to extract configuration values from CloudFormation stacks
# This script uses AWS CLI to get the values needed for amplifyconfiguration.dart

Write-Host "Fetching configuration values from AWS..." -ForegroundColor Green

try {
    # Get values from CloudFormation stacks
    $userPoolId = aws cloudformation describe-stacks --stack-name AuthStack --query "Stacks[0].Outputs[?OutputKey=='AKSmartHome-UserPoolId'].OutputValue" --output text
    Write-Host "User Pool ID: $userPoolId" -ForegroundColor Cyan
    
    $userPoolClientId = aws cloudformation describe-stacks --stack-name AuthStack --query "Stacks[0].Outputs[?OutputKey=='AKSmartHome-UserPoolClientId'].OutputValue" --output text
    Write-Host "User Pool Client ID: $userPoolClientId" -ForegroundColor Cyan
    
    $identityPoolId = aws cloudformation describe-stacks --stack-name AuthStack --query "Stacks[0].Outputs[?OutputKey=='AKSmartHome-IdentityPoolId'].OutputValue" --output text
    Write-Host "Identity Pool ID: $identityPoolId" -ForegroundColor Cyan
    
    $apiUrl = aws cloudformation describe-stacks --stack-name AppSyncStack --query "Stacks[0].Outputs[?OutputKey=='AKSmartHome-GraphQLApiUrl'].OutputValue" --output text
    Write-Host "AppSync API URL: $apiUrl" -ForegroundColor Cyan
    
    $bucketName = aws cloudformation describe-stacks --stack-name UIStack --query "Stacks[0].Outputs[?OutputKey=='AKSmartHome-UIBucketName'].OutputValue" --output text
    Write-Host "S3 Bucket Name: $bucketName" -ForegroundColor Cyan
    
    $iotEndpoint = aws iot describe-endpoint --endpoint-type iot:Data-ATS --query "endpointAddress" --output text
    Write-Host "IoT Endpoint: $iotEndpoint" -ForegroundColor Cyan
    
    # Extract region from user pool ID (format: region_id)
    $region = $userPoolId.Split('_')[0]
    Write-Host "Region: $region" -ForegroundColor Cyan
    
    # Create a configuration object
    $config = @{
        region = $region
        userPoolId = $userPoolId
        userPoolClientId = $userPoolClientId
        identityPoolId = $identityPoolId
        apiUrl = $apiUrl
        bucketName = $bucketName
        iotEndpoint = $iotEndpoint
    }
    
    # Save the configuration to a temporary JSON file
    $configPath = Join-Path $PSScriptRoot "config-values.json"
    $config | ConvertTo-Json | Set-Content -Path $configPath
    
    Write-Host "`nConfiguration values saved to: $configPath" -ForegroundColor Green
    Write-Host "Run update-config.ps1 to update your amplifyconfiguration.dart file" -ForegroundColor Green
    
} catch {
    Write-Host "Error fetching configuration values: $_" -ForegroundColor Red
    Write-Host "Make sure you have AWS CLI installed and configured with the correct credentials." -ForegroundColor Yellow
    Write-Host "Also verify that your stack names are correct (AuthStack, AppSyncStack, UIStack)." -ForegroundColor Yellow
}