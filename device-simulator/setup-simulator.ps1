# Setup script for AK Smart Home Device Simulator
Write-Host "Setting up AK Smart Home Device Simulator..." -ForegroundColor Green

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
npm install

# Get AWS IoT endpoint
Write-Host "Getting AWS IoT endpoint..." -ForegroundColor Yellow
$iotEndpoint = aws iot describe-endpoint --endpoint-type iot:Data-ATS --query endpointAddress --output text

if (-not $iotEndpoint) {
    Write-Host "Error: Could not get IoT endpoint. Make sure you have AWS CLI configured." -ForegroundColor Red
    exit 1
}

# Create .env file with IoT endpoint
Write-Host "Creating .env file with IoT endpoint..." -ForegroundColor Yellow
"IOT_ENDPOINT=$iotEndpoint" | Out-File -FilePath .env -Encoding utf8

# Create certs directory if it doesn't exist
if (-not (Test-Path -Path ".\certs")) {
    Write-Host "Creating certs directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path ".\certs" | Out-Null
}

# Download Amazon Root CA certificate
if (-not (Test-Path -Path ".\certs\AmazonRootCA1.pem")) {
    Write-Host "Downloading Amazon Root CA certificate..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://www.amazontrust.com/repository/AmazonRootCA1.pem" -OutFile ".\certs\AmazonRootCA1.pem"
}

# Get current user ID from Cognito
Write-Host "Getting current user ID..." -ForegroundColor Yellow
$userId = Read-Host -Prompt "Enter your Cognito User ID (or press Enter to skip)"

if ($userId) {
    # Add user ID to .env file
    "OWNER_ID=$userId" | Out-File -FilePath .env -Encoding utf8 -Append
    Write-Host "User ID added to .env file." -ForegroundColor Green
} else {
    Write-Host "Skipping user ID. You'll need to provide it when registering devices." -ForegroundColor Yellow
}

# Get device table name
Write-Host "Getting device table name..." -ForegroundColor Yellow
$deviceTable = Read-Host -Prompt "Enter your device table name (or press Enter to use default)"

if ($deviceTable) {
    # Add device table to .env file
    "DEVICE_TABLE=$deviceTable" | Out-File -FilePath .env -Encoding utf8 -Append
    Write-Host "Device table name added to .env file." -ForegroundColor Green
} else {
    Write-Host "Using default device table name." -ForegroundColor Yellow
}

Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Create a device certificate: npm run create-cert" -ForegroundColor Cyan
Write-Host "2. Register a device: npm run register -- --type light --name \"Living Room Light\"" -ForegroundColor Cyan
Write-Host "3. Start the device simulator: npm run simulate-light" -ForegroundColor Cyan
Write-Host "4. Monitor device messages: npm run monitor" -ForegroundColor Cyan
Write-Host "5. Send test commands: npm run send-command -- --id your-device-id --command power --value true" -ForegroundColor Cyan