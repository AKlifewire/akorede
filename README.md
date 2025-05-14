# Smart Home Platform

A serverless IoT platform for smart home automation built with AWS CDK.

## Architecture

This project uses:
- AWS CDK for infrastructure as code
- AWS AppSync for GraphQL API
- AWS IoT Core for device connectivity
- AWS Cognito for authentication
- AWS Amplify for web hosting
- Flutter for mobile and web applications

## Deployment with GitHub Actions

The project is deployed using GitHub Actions. Three workflows are available:

1. **deploy-cdk.yml**: Deploys all CDK stacks
2. **deploy-flutter.yml**: Deploys the Flutter web application
3. **test-app.yml**: Tests the deployed infrastructure

### Prerequisites

To deploy this project, you need to:

1. Fork this repository
2. Add the following secrets to your GitHub repository:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### Manual Deployment

If you prefer to deploy manually:

```bash
# Install dependencies
npm install

# Build the project
npm run build

# Deploy all stacks
npm run deploy

# Test the deployment
npm run test:app
```

## Development

### Local Setup

```bash
# Install dependencies
npm install
cd cdk && npm install

# Build the project
npm run build

# Run tests
npm test
```

### Flutter Development

```bash
cd flutter_app
flutter pub get
flutter run
```

## Testing

To test the deployed infrastructure:

```bash
# Run the test script
npm run test:app
```

This will check:
- Cognito User Pool
- AppSync API
- IoT Core
- Lambda Functions
- Amplify Hosting

## License

MIT