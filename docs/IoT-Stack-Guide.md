# AK Smart Home Platform - IoT Stack Guide

This guide explains how to set up and use the IoT Stack for the AK Smart Home Platform.

## Overview

The IoT Stack provides the infrastructure for connecting, managing, and securing IoT devices in the AK Smart Home Platform. It includes:

- IoT Core configuration for MQTT messaging
- Device policies and permissions
- IoT rules for message routing
- Device Defender for security monitoring
- OTA update infrastructure

## Automated Setup

We provide automated setup scripts to help you get started quickly:

- **Windows**: Run `.\scripts\setup-iot-stack.ps1` in PowerShell
- **Linux/macOS**: Run `./scripts/setup-iot-stack.sh` in Terminal

These scripts will:
1. Create the IoT Stack CDK file if it doesn't exist
2. Update the CDK app to include the IoT Stack
3. Create a device simulator for testing
4. Deploy the IoT Stack to your AWS account

## Manual Setup

If you prefer to set up the IoT Stack manually, follow these steps:

1. Create the IoT Stack file at `cdk/stacks/IoTStack.ts`
2. Add the IoT Stack to your CDK app in `cdk/app.ts`
3. Build and deploy the stack with `npm run build && cdk deploy IoTStack`

## IoT Stack Components

### 1. Device Policies

The IoT Stack creates a device policy with least-privilege permissions:

- **Connect**: Devices can only connect using their Thing name
- **Publish**: Devices can only publish to their own topics
- **Subscribe**: Devices can only subscribe to their own command topics
- **Receive**: Devices can only receive messages from their own command topics

### 2. IoT Rules

The IoT Stack sets up rules for message routing:

- **Device State Rule**: Routes device state updates to SNS for processing
- **Device Telemetry Rule**: Routes telemetry data to Firehose for analytics

### 3. Device Defender

The IoT Stack configures Device Defender to monitor for security issues:

- **Message Size Limit**: Alerts if messages exceed 5KB
- **Message Rate Limit**: Alerts if devices send more than 100 messages per minute

### 4. Firmware Updates

The IoT Stack creates an S3 bucket for firmware updates and OTA deployment.

## Device Communication

Devices communicate with the platform using the following MQTT topics:

- **Device State**: `device/{deviceId}/state`
- **Device Telemetry**: `device/{deviceId}/telemetry`
- **Device Commands**: `device/{deviceId}/command`

## Testing with the Device Simulator

The setup script creates a device simulator in the `tools/device-simulator` directory. To use it:

1. Install dependencies: `cd tools/device-simulator && npm install`
2. Create a `certs` directory and add your device certificates
3. Run the simulator: `npm start`

## Security Best Practices

- Always use X.509 certificates for device authentication
- Rotate certificates regularly
- Monitor Device Defender alerts
- Use thing groups to manage permissions at scale
- Implement device-side validation of commands

## Troubleshooting

### Common Issues

1. **Deployment Failures**:
   - Check that your AWS credentials are properly configured
   - Ensure you have the necessary permissions to create IoT resources

2. **Device Connection Issues**:
   - Verify that the device certificate is activated and attached to the thing
   - Check that the device policy is attached to the certificate
   - Ensure the device is using the correct endpoint and credentials

3. **Rule Execution Failures**:
   - Check the CloudWatch logs for the rule
   - Verify that the IAM role has the necessary permissions

## Next Steps

After setting up the IoT Stack, you should:

1. Create a fleet provisioning template for device onboarding
2. Implement device authentication and certificate management
3. Set up monitoring and alerting for device health
4. Integrate with the AppSync API for real-time updates

## Resources

- [AWS IoT Core Documentation](https://docs.aws.amazon.com/iot/latest/developerguide/what-is-aws-iot.html)
- [AWS CDK IoT Module](https://docs.aws.amazon.com/cdk/api/latest/docs/aws-iot-readme.html)
- [MQTT Protocol](https://mqtt.org/)