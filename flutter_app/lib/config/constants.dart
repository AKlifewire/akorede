// Application constants and endpoints

class AppConstants {
  // API Endpoints - these will be updated from amplifyconfiguration.dart at runtime
  static String appSyncEndpoint = 'https://pygewtdlpze3bcesak5siyg7am.appsync-api.us-east-1.amazonaws.com/graphql';
  static String iotEndpoint = 'a360bvzvgaaupj-ats.iot.us-east-1.amazonaws.com';
  static String s3Bucket = 'uistack-uibucketb980636d-5hxah7548zp9';
  static String region = 'us-east-1';
  
  // Feature flags
  static const bool enableAnalytics = true;
  static const bool enableNotifications = true;
  static const bool enableDarkMode = true;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonHeight = 48.0;
  
  // UI JSON file paths in S3
  static const String homeUiPath = 'ui-pages/home.json';
  static const String loginUiPath = 'ui-pages/login.json';
  static const String deviceListUiPath = 'ui-pages/device-list.json';
  static const String deviceControlUiPath = 'ui-pages/device-control.json';
  
  // MQTT Topics
  static String deviceStatusTopic(String deviceId) => 'device/$deviceId/status';
  static String deviceControlTopic(String deviceId) => 'device/$deviceId/control';
  static String deviceTelemetryTopic(String deviceId) => 'device/$deviceId/telemetry';
  
  // GraphQL operations
  static const String getDevicesQuery = '''
    query GetDevices {
      listDevices {
        items {
          id
          name
          type
          status
          firmware
          lastConnected
          properties
          location {
            roomId
            roomName
          }
        }
      }
    }
  ''';
  
  static String getDeviceQuery(String deviceId) => '''
    query GetDevice {
      getDevice(id: "$deviceId") {
        id
        name
        type
        status
        firmware
        lastConnected
        properties
        telemetry
        location {
          roomId
          roomName
        }
      }
    }
  ''';
  
  static String controlDeviceMutation(String deviceId, String command) => '''
    mutation ControlDevice {
      controlDevice(deviceId: "$deviceId", command: "$command") {
        success
        message
      }
    }
  ''';
  
  static const String deviceUpdateSubscription = '''
    subscription OnDeviceUpdate {
      onUpdateDevice {
        id
        name
        type
        status
        firmware
        lastConnected
        properties
        telemetry
      }
    }
  ''';
  
  static const String deviceStatusSubscription = '''
    subscription OnDeviceStatusChange {
      onDeviceStatusChange {
        deviceId
        status
        timestamp
        data
      }
    }
  ''';
}