const AWS = require('aws-sdk');
const cloudformation = new AWS.CloudFormation({ region: 'us-east-1' });

async function checkStacks() {
  console.log('Checking CloudFormation stack status...');
  
  try {
    // Get all stacks
    const { Stacks } = await cloudformation.describeStacks().promise();
    
    // Filter for stacks in problematic states
    const inProgressStacks = Stacks.filter(stack => 
      stack.StackStatus.includes('IN_PROGRESS') || 
      stack.StackStatus.includes('FAILED')
    );
    
    if (inProgressStacks.length === 0) {
      console.log('✅ No stacks are currently in progress or failed state.');
      return;
    }
    
    console.log(`Found ${inProgressStacks.length} stacks in progress or failed state:`);
    
    for (const stack of inProgressStacks) {
      console.log(`- ${stack.StackName}: ${stack.StackStatus}`);
    }
    
    // Ask if user wants to cancel in-progress operations
    console.log('\nTo fix this issue, you can:');
    console.log('1. Wait for the operations to complete');
    console.log('2. Run: aws cloudformation cancel-update-stack --stack-name STACK_NAME');
    console.log('3. If a stack is stuck, you may need to delete and recreate it');
    
  } catch (error) {
    console.error('Error checking stacks:', error);
  }
}

checkStacks();