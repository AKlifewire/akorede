const AWS = require('aws-sdk');
const cloudformation = new AWS.CloudFormation({ region: 'us-east-1' });

// Maximum time to wait in milliseconds (15 minutes)
const MAX_WAIT_TIME = 15 * 60 * 1000;
// Check interval in milliseconds (30 seconds)
const CHECK_INTERVAL = 30 * 1000;

async function waitForStacks() {
  console.log('Waiting for in-progress stack operations to complete...');
  
  const startTime = Date.now();
  let inProgress = true;
  
  while (inProgress && (Date.now() - startTime) < MAX_WAIT_TIME) {
    try {
      // Get all stacks
      const { Stacks } = await cloudformation.describeStacks().promise();
      
      // Filter for stacks in progress
      const inProgressStacks = Stacks.filter(stack => 
        stack.StackStatus.includes('IN_PROGRESS')
      );
      
      if (inProgressStacks.length === 0) {
        console.log('✅ All stack operations have completed.');
        inProgress = false;
        break;
      }
      
      console.log(`${new Date().toISOString()} - ${inProgressStacks.length} stacks still in progress:`);
      inProgressStacks.forEach(stack => {
        console.log(`- ${stack.StackName}: ${stack.StackStatus}`);
      });
      
      // Wait before checking again
      await new Promise(resolve => setTimeout(resolve, CHECK_INTERVAL));
      
    } catch (error) {
      console.error('Error checking stacks:', error);
      break;
    }
  }
  
  if (inProgress) {
    console.log('⚠️ Timed out waiting for stack operations to complete.');
    console.log('You may need to manually check the status or cancel operations.');
    process.exit(1);
  }
  
  return !inProgress;
}

waitForStacks().then(success => {
  if (success) {
    console.log('Ready to proceed with deployment.');
    process.exit(0);
  } else {
    process.exit(1);
  }
});