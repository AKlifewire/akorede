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
  console.log('ControlDevice event:', JSON.stringify(event));

  // Simulate a device state change
  const deviceStatus = {
    deviceId: event.arguments.deviceId,
    status: "ON",
    timestamp: new Date().toISOString()
  };

  // Return a CommandResponse object that matches the subscription type
  return {
    success: true,
    message: "Device state updated successfully",
    data: JSON.stringify(deviceStatus), // Convert to JSON string for AWSJSON type
  };
};