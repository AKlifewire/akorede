const AWS = require('aws-sdk');
const cloudformation = new AWS.CloudFormation({ region: 'us-east-1' });

// Get stack name from command line argument
const stackName = process.argv[2];

if (!stackName) {
  console.error('Please provide a stack name as an argument');
  console.error('Usage: node cancel-stack-update.js UIStack');
  process.exit(1);
}

async function cancelStackUpdate() {
  console.log(`Cancelling update for stack: ${stackName}`);
  
  try {
    // Check if stack exists and is in UPDATE_IN_PROGRESS state
    const { Stacks } = await cloudformation.describeStacks({ StackName: stackName }).promise();
    
    if (Stacks.length === 0) {
      console.error(`Stack ${stackName} not found`);
      return;
    }
    
    const stack = Stacks[0];
    
    if (stack.StackStatus !== 'UPDATE_IN_PROGRESS') {
      console.log(`Stack ${stackName} is in ${stack.StackStatus} state, not UPDATE_IN_PROGRESS`);
      console.log('No action needed');
      return;
    }
    
    // Cancel the update
    await cloudformation.cancelUpdateStack({ StackName: stackName }).promise();
    console.log(`✅ Successfully requested cancellation of update for stack ${stackName}`);
    console.log('It may take a few minutes for the cancellation to complete');
    
  } catch (error) {
    console.error('Error:', error);
  }
}

cancelStackUpdate();