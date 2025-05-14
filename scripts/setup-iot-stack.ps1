# IoT Stack Setup Script for PowerShell
# This script automates the setup of the IoT Stack for the AK Smart Home Platform

# Stop on first error
$ErrorActionPreference = "Stop"

# Check if AWS CLI is installed
try {
    aws --version | Out-Null
}
catch {
    Write-Error "AWS CLI is not installed. Please install it first."
    exit 1
}

# Check if CDK is installed
try {
    cdk --version | Out-Null
}
catch {
    Write-Host "AWS CDK is not installed. Installing now..."
    npm install -g aws-cdk
}

# Set environment variables
$ENVIRONMENT = if ($args[0]) { $args[0] } else { "dev" }
$APP_NAME = "AKSmartHome"
$REGION = aws configure get region
if (-not $REGION) {
    $REGION = "us-east-1"
    Write-Host "AWS region not configured. Using default: $REGION"
}

Write-Host "Setting up IoT Stack for $APP_NAME in $ENVIRONMENT environment ($REGION)"

# Create IoT Stack file if it doesn't exist
$IOT_STACK_PATH = "./cdk/stacks/IoTStack.ts"
if (-not (Test-Path $IOT_STACK_PATH)) {
    Write-Host "Creating IoT Stack file..."
    
    # Ensure directory exists
    New-Item -ItemType Directory -Path "./cdk/stacks" -Force | Out-Null
    
    $IoTStackContent = @'
import * as cdk from 'aws-cdk-lib';
import { Stack, StackProps, Duration, RemovalPolicy } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as iot from 'aws-cdk-lib/aws-iot';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as logs from 'aws-cdk-lib/aws-logs';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as sns from 'aws-cdk-lib/aws-sns';
import * as ssm from 'aws-cdk-lib/aws-ssm';

interface IoTStackProps extends StackProps {
  appName?: string;
  envName?: string;
}

export class IoTStack extends Stack {
  public readonly iotEndpoint: string;
  
  constructor(scope: Construct, id: string, props?: IoTStackProps) {
    super(scope, id, props);

    const appName = props?.appName || 'AKSmartHome';
    const envName = props?.envName || 'dev';
    
    // Get IoT endpoint
    const iotEndpointParam = new ssm.StringParameter(this, 'IoTEndpointParam', {
      parameterName: `/${appName}/${envName}/iot/endpoint`,
      stringValue: cdk.Fn.join('', [
        'data.iot.',
        cdk.Stack.of(this).region,
        '.amazonaws.com'
      ]),
      description: 'IoT endpoint for device connection',
    });
    this.iotEndpoint = iotEndpointParam.stringValue;

    // 1. Create IoT Policy for devices
    const devicePolicy = new iot.CfnPolicy(this, 'DevicePolicy', {
      policyName: `${appName}DevicePolicy`,
      policyDocument: {
        Version: '2012-10-17',
        Statement: [
          {
            Effect: 'Allow',
            Action: [
              'iot:Connect',
            ],
            Resource: [
              `arn:aws:iot:${this.region}:${this.account}:client/\${iot:Connection.Thing.ThingName}`,
            ],
            Condition: {
              Bool: {
                'iot:Connection.Thing.IsAttached': ['true']
              }
            }
          },
          {
            Effect: 'Allow',
            Action: [
              'iot:Publish',
            ],
            Resource: [
              `arn:aws:iot:${this.region}:${this.account}:topic/device/\${iot:Connection.Thing.ThingName}/state`,
              `arn:aws:iot:${this.region}:${this.account}:topic/device/\${iot:Connection.Thing.ThingName}/telemetry`,
            ],
          },
          {
            Effect: 'Allow',
            Action: [
              'iot:Subscribe',
            ],
            Resource: [
              `arn:aws:iot:${this.region}:${this.account}:topicfilter/device/\${iot:Connection.Thing.ThingName}/command`,
            ],
          },
          {
            Effect: 'Allow',
            Action: [
              'iot:Receive',
            ],
            Resource: [
              `arn:aws:iot:${this.region}:${this.account}:topic/device/\${iot:Connection.Thing.ThingName}/command`,
            ],
          },
        ],
      },
    });

    // Store policy name in SSM
    new ssm.StringParameter(this, 'DevicePolicyParam', {
      parameterName: `/${appName}/${envName}/iot/devicePolicy`,
      stringValue: devicePolicy.policyName,
      description: 'IoT policy for devices',
    });

    // 2. Create IoT Thing Type for categorizing devices
    const thingType = new iot.CfnThingType(this, 'SmartHomeDeviceType', {
      thingTypeName: `${appName}Device`,
      thingTypeProperties: {
        searchableAttributes: ['deviceModel', 'manufacturer', 'location'],
        thingTypeDescription: 'Smart Home Device for AK Platform',
      },
    });

    // Store thing type in SSM
    new ssm.StringParameter(this, 'ThingTypeParam', {
      parameterName: `/${appName}/${envName}/iot/thingType`,
      stringValue: thingType.thingTypeName,
      description: 'IoT thing type for devices',
    });

    // 3. Create IoT Rule for device state updates
    const deviceStateRole = new iam.Role(this, 'DeviceStateRole', {
      assumedBy: new iam.ServicePrincipal('iot.amazonaws.com'),
    });

    // Create a topic for device state notifications
    const deviceStateTopic = new sns.Topic(this, 'DeviceStateTopic', {
      displayName: `${appName}-${envName}-DeviceState`,
    });

    // IoT Rule to publish to SNS when device state changes
    new iot.CfnTopicRule(this, 'DeviceStateRule', {
      ruleName: `${appName}_${envName}_DeviceStateUpdate`,
      topicRulePayload: {
        sql: "SELECT state.reported AS state, topic(3) as deviceId, timestamp() as timestamp FROM 'device/+/state'",
        actions: [
          {
            sns: {
              targetArn: deviceStateTopic.topicArn,
              roleArn: deviceStateRole.roleArn,
              messageFormat: 'JSON',
            },
          },
        ],
        ruleDisabled: false,
        awsIotSqlVersion: '2016-03-23',
      },
    });

    // Grant permissions to the role
    deviceStateTopic.grantPublish(deviceStateRole);

    // 4. Create IoT Rule for device telemetry
    const telemetryRole = new iam.Role(this, 'TelemetryRole', {
      assumedBy: new iam.ServicePrincipal('iot.amazonaws.com'),
    });

    // IoT Rule for telemetry data
    new iot.CfnTopicRule(this, 'DeviceTelemetryRule', {
      ruleName: `${appName}_${envName}_DeviceTelemetry`,
      topicRulePayload: {
        sql: "SELECT *, topic(3) as deviceId, timestamp() as timestamp FROM 'device/+/telemetry'",
        actions: [
          {
            firehose: {
              deliveryStreamName: `${appName}-${envName}-telemetry`,
              roleArn: telemetryRole.roleArn,
              separator: '\n',
            },
          },
        ],
        ruleDisabled: false,
        awsIotSqlVersion: '2016-03-23',
      },
    });

    // 5. Set up IoT Logging
    new iot.CfnLoggingOptions(this, 'IoTLogging', {
      roleArn: new iam.Role(this, 'IoTLoggingRole', {
        assumedBy: new iam.ServicePrincipal('iot.amazonaws.com'),
        managedPolicies: [
          iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSIoTLogging'),
        ],
      }).roleArn,
      logLevel: 'INFO',
    });

    // 6. IoT Device Defender Security Profile
    const securityAlertTopic = new sns.Topic(this, 'SecurityAlertTopic', {
      displayName: `${appName}-${envName}-SecurityAlerts`,
    });

    const securityAlertRole = new iam.Role(this, 'SecurityAlertRole', {
      assumedBy: new iam.ServicePrincipal('iot.amazonaws.com'),
    });

    securityAlertTopic.grantPublish(securityAlertRole);

    new iot.CfnSecurityProfile(this, 'DeviceSecurityProfile', {
      securityProfileName: `${appName}SecurityProfile`,
      securityProfileDescription: 'Security profile for AK Smart Home devices',
      behaviors: [
        {
          name: 'MessageSizeLimit',
          metric: 'aws:message-byte-size',
          criteria: {
            comparisonOperator: 'less-than',
            value: {
              count: 5120, // 5KB limit
            },
            consecutiveDatapointsToAlarm: 1,
            consecutiveDatapointsToClear: 1,
          },
        },
        {
          name: 'MessageRateLimit',
          metric: 'aws:num-messages-received',
          criteria: {
            comparisonOperator: 'less-than',
            value: {
              count: 100, // 100 messages per minute limit
            },
            durationSeconds: 60,
            consecutiveDatapointsToAlarm: 1,
            consecutiveDatapointsToClear: 1,
          },
        },
      ],
      alertTargets: {
        'SNS': {
          alertTargetArn: securityAlertTopic.topicArn,
          roleArn: securityAlertRole.roleArn,
        },
      },
    });

    // 7. S3 bucket for firmware updates
    const firmwareBucket = new s3.Bucket(this, 'FirmwareBucket', {
      bucketName: `${appName.toLowerCase()}-${envName.toLowerCase()}-firmware-${this.account}`,
      removalPolicy: RemovalPolicy.RETAIN,
      encryption: s3.BucketEncryption.S3_MANAGED,
      versioned: true,
    });

    // Store firmware bucket name in SSM
    new ssm.StringParameter(this, 'FirmwareBucketParam', {
      parameterName: `/${appName}/${envName}/iot/firmwareBucket`,
      stringValue: firmwareBucket.bucketName,
      description: 'S3 bucket for firmware updates',
    });

    // Export resources for cross-stack references
    new cdk.CfnOutput(this, 'IoTPolicyName', {
      value: devicePolicy.policyName,
      description: 'IoT Policy for devices',
      exportName: `${appName}-${envName}-IoTPolicyName`,
    });

    new cdk.CfnOutput(this, 'FirmwareBucketName', {
      value: firmwareBucket.bucketName,
      description: 'S3 Bucket for firmware updates',
      exportName: `${appName}-${envName}-FirmwareBucketName`,
    });
  }
}
'@

    Set-Content -Path $IOT_STACK_PATH -Value $IoTStackContent
    Write-Host "IoT Stack file created at $IOT_STACK_PATH"
}

# Update app.ts to include IoT Stack
$APP_TS_PATH = "./cdk/app.ts"
if (Test-Path $APP_TS_PATH) {
    $appContent = Get-Content $APP_TS_PATH -Raw
    
    if (-not ($appContent -match "IoTStack")) {
        Write-Host "Updating app.ts to include IoT Stack..."
        
        # Add import if not present
        if (-not ($appContent -match "import { IoTStack }")) {
            $appContent = "import { IoTStack } from './stacks/IoTStack';" + "`r`n" + $appContent
        }
        
        # Add stack instantiation if not present
        if (-not ($appContent -match "new IoTStack")) {
            # Find the last closing brace to add our stack before it
            $lastBraceIndex = $appContent.LastIndexOf("});")
            if ($lastBraceIndex -gt 0) {
                $insertPosition = $appContent.IndexOf("`n", $lastBraceIndex) + 1
                if ($insertPosition -gt 0) {
                    $newContent = @"
new IoTStack(app, 'IoTStack', {
  appName: 'AKSmartHome',
  envName: '$ENVIRONMENT',
});

"@
                    $appContent = $appContent.Insert($insertPosition, $newContent)
                }
            }
        }
        
        Set-Content -Path $APP_TS_PATH -Value $appContent
        Write-Host "app.ts updated to include IoT Stack"
    }
}

# Create a basic IoT device simulator for testing
$SIMULATOR_DIR = "./tools/device-simulator"
New-Item -ItemType Directory -Path $SIMULATOR_DIR -Force | Out-Null

$deviceJsContent = @'
const AWS = require('aws-sdk');
const fs = require('fs');
const path = require('path');

// Configuration
const config = {
  region: process.env.AWS_REGION || 'us-east-1',
  deviceId: process.env.DEVICE_ID || 'test-device-001',
  certPath: process.env.CERT_PATH || path.join(__dirname, 'certs', 'device.cert.pem'),
  keyPath: process.env.KEY_PATH || path.join(__dirname, 'certs', 'private.key'),
  caPath: process.env.CA_PATH || path.join(__dirname, 'certs', 'root-CA.crt'),
  host: process.env.IOT_ENDPOINT || '', // Will be fetched from SSM
};

// Create AWS SDK clients
const iot = new AWS.Iot({ region: config.region });
const ssm = new AWS.SSM({ region: config.region });

async function getIoTEndpoint() {
  try {
    const params = {
      Name: '/AKSmartHome/dev/iot/endpoint'
    };
    const result = await ssm.getParameter(params).promise();
    return result.Parameter.Value;
  } catch (error) {
    console.error('Error fetching IoT endpoint:', error);
    throw error;
  }
}

async function createThing() {
  try {
    // Check if thing exists
    try {
      await iot.describeThing({ thingName: config.deviceId }).promise();
      console.log(`Thing ${config.deviceId} already exists`);
      return;
    } catch (error) {
      if (error.code !== 'ResourceNotFoundException') {
        throw error;
      }
    }

    // Create thing
    await iot.createThing({
      thingName: config.deviceId,
      thingTypeName: 'AKSmartHomeDevice',
      attributePayload: {
        attributes: {
          deviceModel: 'Simulator',
          manufacturer: 'AK',
          location: 'Virtual',
        }
      }
    }).promise();
    
    console.log(`Thing ${config.deviceId} created successfully`);
  } catch (error) {
    console.error('Error creating thing:', error);
    throw error;
  }
}

async function simulateDevice() {
  try {
    // Get IoT endpoint
    config.host = await getIoTEndpoint();
    
    // Create thing if it doesn't exist
    await createThing();
    
    // Setup device connection
    console.log('Setting up device connection...');
    console.log(`Device ID: ${config.deviceId}`);
    console.log(`IoT Endpoint: ${config.host}`);
    
    // In a real implementation, you would:
    // 1. Load certificates
    // 2. Connect to AWS IoT using MQTT
    // 3. Subscribe to command topics
    // 4. Publish state and telemetry
    
    console.log('Device simulator ready');
    
    // Simulate device state updates
    setInterval(() => {
      const state = {
        power: Math.random() > 0.5,
        temperature: 20 + Math.random() * 10,
        humidity: 30 + Math.random() * 40,
        lastUpdated: new Date().toISOString()
      };
      
      console.log(`Publishing state: ${JSON.stringify(state)}`);
      // In a real implementation:
      // mqttClient.publish(`device/${config.deviceId}/state`, JSON.stringify({ state: { reported: state } }));
    }, 5000);
    
    // Simulate telemetry
    setInterval(() => {
      const telemetry = {
        energy: Math.random() * 100,
        signal: -30 - Math.random() * 60,
        uptime: Math.floor(Date.now() / 1000),
        timestamp: new Date().toISOString()
      };
      
      console.log(`Publishing telemetry: ${JSON.stringify(telemetry)}`);
      // In a real implementation:
      // mqttClient.publish(`device/${config.deviceId}/telemetry`, JSON.stringify(telemetry));
    }, 10000);
    
  } catch (error) {
    console.error('Error in device simulation:', error);
  }
}

// Start simulation
simulateDevice();
'@

$packageJsonContent = @'
{
  "name": "device-simulator",
  "version": "1.0.0",
  "description": "IoT device simulator for AK Smart Home Platform",
  "main": "device.js",
  "scripts": {
    "start": "node device.js"
  },
  "dependencies": {
    "aws-sdk": "^2.1135.0"
  }
}
'@

Set-Content -Path "$SIMULATOR_DIR/device.js" -Value $deviceJsContent
Set-Content -Path "$SIMULATOR_DIR/package.json" -Value $packageJsonContent

Write-Host "Device simulator created at $SIMULATOR_DIR"

# Build and deploy the IoT stack
Write-Host "Building the project..."
npm run build

Write-Host "Deploying IoT Stack..."
npx cdk deploy IoTStack --require-approval never

Write-Host "IoT Stack setup complete!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Create certificates for your devices using AWS IoT Core console or CLI"
Write-Host "2. Attach the IoT policy to your certificates"
Write-Host "3. Register your devices using the Fleet Provisioning feature"
Write-Host "4. Test the setup using the device simulator in ./tools/device-simulator/"
Write-Host ""
Write-Host "For more information, see the README.md file."