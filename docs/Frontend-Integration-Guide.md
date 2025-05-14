# AK Smart Home Platform - Frontend Integration Guide

This guide explains how to integrate the Flutter frontend with the AWS backend services for authentication, device management, and real-time control.

## Overview

The AK Smart Home Platform frontend is built with Flutter and uses AWS Amplify for authentication, API access, and real-time updates. The UI is dynamically rendered based on device capabilities, allowing for a flexible and scalable user experience.

## Setup

### Prerequisites

- Flutter SDK (2.10.0 or later)
- AWS Amplify CLI
- Git

### Initial Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/AKlifewire/smart-home-flutter.git
   cd smart-home-flutter
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Create `amplify-config.json` in the `assets` folder:
   ```json
   {
     "aws_project_region": "us-east-1",
     "aws_cognito_region": "us-east-1",
     "aws_user_pools_id": "YOUR_USER_POOL_ID",
     "aws_user_pools_web_client_id": "YOUR_USER_POOL_CLIENT_ID",
     "aws_cognito_identity_pool_id": "YOUR_IDENTITY_POOL_ID",
     "aws_appsync_graphqlEndpoint": "YOUR_APPSYNC_ENDPOINT",
     "aws_appsync_region": "us-east-1",
     "aws_appsync_authenticationType": "AMAZON_COGNITO_USER_POOLS",
     "aws_iot_endpoint": "YOUR_IOT_ENDPOINT",
     "aws_user_files_s3_bucket": "YOUR_S3_BUCKET",
     "aws_user_files_s3_bucket_region": "us-east-1"
   }
   ```

4. Run the app:
   ```bash
   flutter run -d chrome
   ```

## Authentication Flow

The app uses Cognito for authentication with the following flow:

1. **Sign Up**: Users create an account with email, phone, and password
2. **Verification**: Users verify their email/phone with a code
3. **Sign In**: Users sign in with their credentials
4. **Session Management**: The app maintains the session and refreshes tokens

### Implementation

```dart
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

// Sign up
Future<void> signUp(String email, String password) async {
  try {
    final userAttributes = <CognitoUserAttributeKey, String>{
      CognitoUserAttributeKey.email: email,
    };
    
    final result = await Amplify.Auth.signUp(
      username: email,
      password: password,
      options: CognitoSignUpOptions(userAttributes: userAttributes),
    );
    
    if (result.isSignUpComplete) {
      // Sign up is complete, user can sign in
    } else {
      // Confirmation is required
    }
  } catch (e) {
    print('Error signing up: $e');
  }
}

// Sign in
Future<void> signIn(String email, String password) async {
  try {
    final result = await Amplify.Auth.signIn(
      username: email,
      password: password,
    );
    
    if (result.isSignedIn) {
      // User is signed in, navigate to home screen
    }
  } catch (e) {
    print('Error signing in: $e');
  }
}
```

## Device Management

The app allows users to:

1. **Add Devices**: Register new devices with the platform
2. **View Devices**: See a list of all registered devices
3. **Control Devices**: Send commands to devices
4. **Monitor Devices**: View real-time device state

### Adding a Device

```dart
import 'package:amplify_api/amplify_api.dart';

Future<void> addDevice(String deviceId, String deviceName, String deviceType) async {
  try {
    final request = ModelMutations.create(
      Device(
        id: deviceId,
        name: deviceName,
        type: deviceType,
        ownerId: await getCurrentUserId(),
      ),
    );
    
    final response = await Amplify.API.mutate(request: request).response;
    
    if (response.hasErrors) {
      print('Errors: ${response.errors}');
    } else {
      print('Added device: ${response.data}');
    }
  } catch (e) {
    print('Error adding device: $e');
  }
}
```

### Fetching Devices

```dart
Future<List<Device>> fetchDevices() async {
  try {
    final userId = await getCurrentUserId();
    
    final request = ModelQueries.list(
      Device.classType,
      where: Device.OWNER_ID.eq(userId),
    );
    
    final response = await Amplify.API.query(request: request).response;
    
    if (response.hasErrors) {
      print('Errors: ${response.errors}');
      return [];
    } else {
      return response.data!.items.cast<Device>();
    }
  } catch (e) {
    print('Error fetching devices: $e');
    return [];
  }
}
```

## Dynamic UI Rendering

The app uses a component-based UI system that dynamically renders the interface based on device capabilities:

1. **Fetch UI Definition**: Get the UI definition from the backend
2. **Parse Components**: Parse the JSON into UI components
3. **Render UI**: Render the components based on the definition

### Fetching UI Definition

```dart
Future<Map<String, dynamic>> fetchUiDefinition(String deviceId) async {
  try {
    final request = GraphQLRequest<String>(
      document: '''
        query GetDeviceUI(\$deviceId: ID!, \$userId: ID!) {
          getDeviceUI(deviceId: \$deviceId, userId: \$userId) {
            deviceInfo
            sections
            controls
            state
            metadata
          }
        }
      ''',
      variables: {
        'deviceId': deviceId,
        'userId': await getCurrentUserId(),
      },
    );
    
    final response = await Amplify.API.query(request: request).response;
    
    if (response.hasErrors) {
      print('Errors: ${response.errors}');
      return {};
    } else {
      return jsonDecode(response.data!)['getDeviceUI'];
    }
  } catch (e) {
    print('Error fetching UI definition: $e');
    return {};
  }
}
```

### Rendering UI Components

```dart
Widget buildDynamicUI(Map<String, dynamic> uiDefinition) {
  final List<Widget> sections = [];
  
  for (final section in uiDefinition['sections']) {
    sections.add(buildSection(section));
  }
  
  return ListView(
    children: sections,
  );
}

Widget buildSection(Map<String, dynamic> section) {
  switch (section['type']) {
    case 'card':
      return Card(
        child: Column(
          children: [
            Text(section['title']),
            ...buildContent(section['content']),
          ],
        ),
      );
    default:
      return Container();
  }
}

List<Widget> buildContent(List<dynamic> content) {
  final List<Widget> widgets = [];
  
  for (final item in content) {
    switch (item['type']) {
      case 'value':
        widgets.add(Text('${item['value']} ${item['unit']}'));
        break;
      case 'chart':
        widgets.add(buildChart(item));
        break;
      case 'switch':
        widgets.add(buildSwitch(item));
        break;
      default:
        break;
    }
  }
  
  return widgets;
}
```

## Real-time Updates

The app subscribes to device state changes using AppSync subscriptions:

```dart
void subscribeToDeviceUpdates(String deviceId) {
  final subscriptionRequest = GraphQLRequest<String>(
    document: '''
      subscription OnDeviceStateChanged(\$deviceId: ID!) {
        onDeviceStateChanged(deviceId: \$deviceId) {
          deviceId
          state
          timestamp
        }
      }
    ''',
    variables: {
      'deviceId': deviceId,
    },
  );
  
  final subscription = Amplify.API.subscribe(
    request: subscriptionRequest,
    onData: (event) {
      final data = jsonDecode(event.data!)['onDeviceStateChanged'];
      updateDeviceState(data);
    },
    onEstablished: () {
      print('Subscription established');
    },
    onError: (error) {
      print('Subscription error: $error');
    },
    onDone: () {
      print('Subscription completed');
    },
  );
  
  // Store subscription for later cancellation
  _subscription = subscription;
}
```

## Device Control

The app sends commands to devices using GraphQL mutations:

```dart
Future<void> controlDevice(String deviceId, String command, dynamic value) async {
  try {
    final request = GraphQLRequest<String>(
      document: '''
        mutation ControlDevice(\$deviceId: ID!, \$command: String!, \$value: AWSJSON!) {
          controlDevice(deviceId: \$deviceId, command: \$command, value: \$value) {
            success
            message
          }
        }
      ''',
      variables: {
        'deviceId': deviceId,
        'command': command,
        'value': jsonEncode(value),
      },
    );
    
    final response = await Amplify.API.mutate(request: request).response;
    
    if (response.hasErrors) {
      print('Errors: ${response.errors}');
    } else {
      print('Command sent: ${response.data}');
    }
  } catch (e) {
    print('Error controlling device: $e');
  }
}
```

## Deployment

The app is automatically deployed to AWS Amplify Hosting when changes are pushed to the main branch:

1. Push changes to GitHub
2. AWS Amplify detects the changes
3. Amplify builds and deploys the app
4. The app is available at the Amplify URL

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [AWS Amplify Flutter Documentation](https://docs.amplify.aws/start/q/integration/flutter/)
- [GraphQL Documentation](https://graphql.org/learn/)
- [AWS AppSync Documentation](https://docs.aws.amazon.com/appsync/latest/devguide/welcome.html)