#!/bin/bash
# Setup script for AK Smart Home Device Simulator

echo -e "\e[32mSetting up AK Smart Home Device Simulator...\e[0m"

# Install dependencies
echo -e "\e[33mInstalling dependencies...\e[0m"
npm install

# Get AWS IoT endpoint
echo -e "\e[33mGetting AWS IoT endpoint...\e[0m"
IOT_ENDPOINT=$(aws iot describe-endpoint --endpoint-type iot:Data-ATS --query endpointAddress --output text)

if [ -z "$IOT_ENDPOINT" ]; then
    echo -e "\e[31mError: Could not get IoT endpoint. Make sure you have AWS CLI configured.\e[0m"
    exit 1
fi

# Create .env file with IoT endpoint
echo -e "\e[33mCreating .env file with IoT endpoint...\e[0m"
echo "IOT_ENDPOINT=$IOT_ENDPOINT" > .env

# Create certs directory if it doesn't exist
if [ ! -d "./certs" ]; then
    echo -e "\e[33mCreating certs directory...\e[0m"
    mkdir -p certs
fi

# Download Amazon Root CA certificate
if [ ! -f "./certs/AmazonRootCA1.pem" ]; then
    echo -e "\e[33mDownloading Amazon Root CA certificate...\e[0m"
    curl -o ./certs/AmazonRootCA1.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem
fi

# Get current user ID from Cognito
echo -e "\e[33mGetting current user ID...\e[0m"
read -p "Enter your Cognito User ID (or press Enter to skip): " USER_ID

if [ ! -z "$USER_ID" ]; then
    # Add user ID to .env file
    echo "OWNER_ID=$USER_ID" >> .env
    echo -e "\e[32mUser ID added to .env file.\e[0m"
else
    echo -e "\e[33mSkipping user ID. You'll need to provide it when registering devices.\e[0m"
fi

# Get device table name
echo -e "\e[33mGetting device table name...\e[0m"
read -p "Enter your device table name (or press Enter to use default): " DEVICE_TABLE

if [ ! -z "$DEVICE_TABLE" ]; then
    # Add device table to .env file
    echo "DEVICE_TABLE=$DEVICE_TABLE" >> .env
    echo -e "\e[32mDevice table name added to .env file.\e[0m"
else
    echo -e "\e[33mUsing default device table name.\e[0m"
fi

echo -e "\e[32mSetup complete!\e[0m"
echo ""
echo -e "\e[36mNext steps:\e[0m"
echo -e "\e[36m1. Create a device certificate: npm run create-cert\e[0m"
echo -e "\e[36m2. Register a device: npm run register -- --type light --name \"Living Room Light\"\e[0m"
echo -e "\e[36m3. Start the device simulator: npm run simulate-light\e[0m"
echo -e "\e[36m4. Monitor device messages: npm run monitor\e[0m"
echo -e "\e[36m5. Send test commands: npm run send-command -- --id your-device-id --command power --value true\e[0m"