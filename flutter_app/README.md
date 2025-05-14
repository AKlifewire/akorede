# Wire IoT Platform - Flutter App

This is the Flutter frontend for the Wire IoT Platform. It connects to AWS backend services deployed using CDK.

## Setup Instructions

### 1. Update Amplify Configuration

Before running the app, you need to update the `amplifyconfiguration.dart` file with values from your CDK deployment:

#### Option 1: Automatic Configuration (Recommended)

Use the provided scripts to automatically fetch values from your CloudFormation stacks:

```powershell
# Navigate to the project root
cd c:\wire

# Step 1: Get configuration values from AWS CloudFormation
.\scripts\get-config-values.ps1

# Step 2: Update the Flutter app configuration
.\scripts\update-config.ps1
```

#### Option 2: Manual Configuration

If you prefer to enter the values manually:

```powershell
# Navigate to the project root
cd c:\wire

# Run the manual configuration script
.\scripts\manual-config.ps1
```

This script will prompt you for each required value and update the configuration file.

#### Option 3: Direct Editing

You can also directly edit `lib/config/amplifyconfiguration.dart` with values from your AWS Console:

1. **Cognito User Pool ID and Client ID**: 
   - AWS Console → Cognito → User Pools → Your User Pool → App integration tab

2. **Cognito Identity Pool ID**:
   - AWS Console → Cognito → Identity Pools → Your Identity Pool

3. **AppSync GraphQL API URL**:
   - AWS Console → AppSync → Your API → Settings

4. **S3 Bucket Name**:
   - AWS Console → S3 → Buckets

5. **IoT Endpoint**:
   - AWS Console → IoT Core → Settings → Device data endpoint

### 2. Install Dependencies

```
flutter pub get
```

### 3. Run the App

```
flutter run
```

## Architecture

This Flutter application uses a clean architecture approach with the following structure:

```
lib/
│
├── main.dart              # Entry point
├── app.dart               # App configuration
│
├── config/
│   ├── amplifyconfiguration.dart   # AWS configuration
│   └── constants.dart              # App constants
│
├── core/
│   ├── models/            # Data models
│   ├── services/          # Business logic and API services
│   └── utils/             # Helper utilities
│
├── ui/
│   ├── screens/           # App screens
│   └── widgets/           # Reusable UI components
│       └── widget_factory.dart     # Dynamic UI renderer
```

## Dynamic UI System

The app uses a dynamic UI system that renders screens based on JSON definitions fetched from the backend. This allows for:

1. Remote UI updates without app releases
2. Personalized experiences for different user types
3. A/B testing of UI variations
4. Quick iteration on UI designs

The `widget_factory.dart` is responsible for converting JSON UI definitions into Flutter widgets.

## Key Features

- Authentication with Amazon Cognito
- Dynamic UI rendering from backend JSON definitions
- GraphQL API integration with AppSync
- File storage with S3
- IoT device control with MQTT
- Analytics and monitoring

## Development

### Adding a new screen

1. Create a new JSON UI definition in the backend
2. Add any new widget types to `widget_factory.dart` if needed
3. Add navigation to the new screen

### Testing

Run tests with:

```
flutter test
```