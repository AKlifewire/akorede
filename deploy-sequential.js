const { execSync } = require('child_process');

// Define the stacks in the order they should be deployed
const stacks = [
  'AuthStack',
  'SSMParameterStack',
  'LambdaStack',
  'IoTStack',
  'AppSyncStack',
  'UIStack',
  'AmplifyHostingStack'
];

// Function to deploy a single stack
function deployStack(stackName) {
  console.log(`\n=== Deploying ${stackName} ===`);
  try {
    execSync(`npx cdk deploy ${stackName} --require-approval never`, { 
      stdio: 'inherit',
      timeout: 600000 // 10 minutes timeout
    });
    return true;
  } catch (error) {
    console.error(`Failed to deploy ${stackName}:`);
    console.error(error.message);
    return false;
  }
}

// Main function to deploy stacks sequentially
async function deploySequentially() {
  console.log('=== Starting Sequential Deployment ===');
  
  // First, bootstrap CDK if needed
  try {
    console.log('\n=== Bootstrapping CDK ===');
    execSync('npx cdk bootstrap', { stdio: 'inherit' });
  } catch (error) {
    console.error('Failed to bootstrap CDK:');
    console.error(error.message);
    process.exit(1);
  }
  
  // Deploy each stack in sequence
  for (const stack of stacks) {
    const success = deployStack(stack);
    if (!success) {
      console.error(`\n❌ Deployment failed at stack: ${stack}`);
      console.error('Stopping deployment sequence.');
      process.exit(1);
    }
    
    // Add a small delay between deployments
    await new Promise(resolve => setTimeout(resolve, 5000));
  }
  
  console.log('\n=== Deployment Complete ===');
}

// Start the deployment
deploySequentially().catch(error => {
  console.error('Deployment failed with error:');
  console.error(error);
  process.exit(1);
});