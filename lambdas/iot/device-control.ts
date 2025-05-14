import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import * as AWS from 'aws-sdk';

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  console.log('device-control event:', JSON.stringify(event, null, 2));
  
  try {
    // Parse the request body
    const body = event.body ? JSON.parse(event.body) : {};
    const { deviceId, command, value } = body;
    
    if (!deviceId || !command) {
      return {
        statusCode: 400,
        body: JSON.stringify({ 
          message: 'Missing required parameters: deviceId and command are required' 
        }),
      };
    }
    
    // Initialize IoT Data client
    const iotData = new AWS.IotData({ 
      endpoint: process.env.IOT_ENDPOINT || '' 
    });
    
    // Create the command payload
    const payload = {
      command,
      value: value || {},
      timestamp: new Date().toISOString(),
      source: 'api',
    };
    
    // Publish command to device topic
    await iotData.publish({
      topic: `device/${deviceId}/command`,
      payload: JSON.stringify(payload),
      qos: 1,
    }).promise();
    
    return {
      statusCode: 200,
      body: JSON.stringify({ 
        message: `Command ${command} sent to device ${deviceId}`,
        timestamp: payload.timestamp
      }),
    };
  } catch (error: any) {
    console.error('Error:', error);
    
    return {
      statusCode: 500,
      body: JSON.stringify({ 
        message: `Error processing request: ${error.message}` 
      }),
    };
  }
};