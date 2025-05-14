import { AppSyncResolverHandler } from 'aws-lambda';
import * as AWS from 'aws-sdk';

const s3 = new AWS.S3();

interface GetUIPageEvent {
  pageName: string;
  deviceType?: string;
  userRole?: string;
}

interface UIPageResponse {
  success: boolean;
  message?: string;
  data?: any;
}

/**
 * Resolver for getUIPage query
 * Retrieves UI page definitions from S3
 */
export const handler: AppSyncResolverHandler<GetUIPageEvent, UIPageResponse> = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  try {
    const { pageName, deviceType, userRole } = event.arguments;
    
    // Determine the S3 key based on parameters
    let s3Key = `pages/${pageName}.json`;
    
    if (deviceType) {
      s3Key = `pages/${deviceType}/${pageName}.json`;
    }
    
    if (userRole) {
      s3Key = `pages/${userRole}/${pageName}.json`;
    }
    
    if (deviceType && userRole) {
      s3Key = `pages/${userRole}/${deviceType}/${pageName}.json`;
    }
    
    // Get the UI page from S3
    const params = {
      Bucket: process.env.UI_BUCKET || 'smart-home-ui-pages',
      Key: s3Key,
    };
    
    const response = await s3.getObject(params).promise();
    
    if (!response.Body) {
      throw new Error(`UI page ${pageName} not found`);
    }
    
    const uiDefinition = JSON.parse(response.Body.toString('utf-8'));
    
    return {
      success: true,
      data: uiDefinition,
    };
  } catch (error: any) {
    console.error('Error:', error);
    
    // If the page doesn't exist, try to get the default page
    if (error.code === 'NoSuchKey') {
      try {
        const defaultParams = {
          Bucket: process.env.UI_BUCKET || 'smart-home-ui-pages',
          Key: 'pages/default.json',
        };
        
        const defaultResponse = await s3.getObject(defaultParams).promise();
        
        if (defaultResponse.Body) {
          const defaultDefinition = JSON.parse(defaultResponse.Body.toString('utf-8'));
          
          return {
            success: true,
            message: 'Using default UI page',
            data: defaultDefinition,
          };
        }
      } catch (defaultError) {
        console.error('Error getting default page:', defaultError);
      }
    }
    
    return {
      success: false,
      message: `Failed to retrieve UI page: ${error.message}`,
    };
  }
};