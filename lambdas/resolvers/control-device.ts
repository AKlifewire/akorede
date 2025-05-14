import { AppSyncResolverHandler } from 'aws-lambda';
import * as AWS from 'aws-sdk';

const dynamoDB = new AWS.DynamoDB.DocumentClient();
const iotData = new AWS.IotData({ 
  endpoint: process.env.IOT_ENDPOINT || '' 
});

interface ControlDeviceEvent {
  deviceId: string;
  command: string;
  value: string; // JSON string
}

interface CommandResponse {
  success: boolean;
  message?: string;
  data?: any;
}

/**
 * Resolver for controlDevice mutation
 * Sends commands to IoT devices via MQTT
 */
export const handler: AppSyncResolverHandler<ControlDeviceEvent, CommandResponse> = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  try {
    const { deviceId, command, value } = event.arguments;
    
    // Get user identity - handle different identity types safely
    let userId = '';
    if (event.identity) {
      if ('username' in event.identity) {
        userId = event.identity.username;
      } else if ('claims' in event.identity && event.identity.claims && 'sub' in event.identity.claims) {
        userId = event.identity.claims.sub;
      }
    }
    
    if (!userId) {
      throw new Error('User not authenticated');
    }
    
    // Verify device ownership
    const deviceParams = {
      TableName: process.env.DEVICE_TABLE || 'Devices',
      Key: {
        id: deviceId,
      }
    };
    
    const deviceResult = await dynamoDB.get(deviceParams).promise();
    
    if (!deviceResult.Item) {
      throw new Error('Device not found');
    }
    
    if (deviceResult.Item.ownerId !== userId) {
      throw new Error('You do not have permission to control this device');
    }
    
    // Parse the command value
    const commandValue = JSON.parse(value);
    
    // Create the command payload
    const payload = {
      command,
      value: commandValue,
      timestamp: new Date().toISOString(),
      requestId: Math.random().toString(36).substring(2, 15),
    };
    
    // Publish command to device topic
    const publishParams = {
      topic: `device/${deviceId}/command`,
      payload: JSON.stringify(payload),
      qos: 1,
    };
    
    await iotData.publish(publishParams).promise();
    
    return {
      success: true,
      message: `Command ${command} sent to device ${deviceId}`,
      data: {
        requestId: payload.requestId,
        timestamp: payload.timestamp,
      },
    };
  } catch (error: any) {
    console.error('Error:', error);
    
    return {
      success: false,
      message: `Failed to send command: ${error.message}`,
    };
  }
};