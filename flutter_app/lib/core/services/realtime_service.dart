import 'dart:async';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../../config/constants.dart';
import '../models/device_model.dart';

/// Service to handle real-time communication between AppSync and IoT Core
class RealtimeService {
  // AppSync subscription streams
  StreamSubscription<GraphQLResponse<String>>? _deviceUpdateSubscription;
  StreamSubscription<GraphQLResponse<String>>? _deviceStatusSubscription;
  
  // MQTT client for IoT Core
  MqttServerClient? _mqttClient;
  bool _mqttConnected = false;
  
  // Stream controllers to broadcast events to the UI
  final _deviceUpdateController = StreamController<Device>.broadcast();
  final _deviceStatusController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Public streams that UI components can listen to
  Stream<Device> get onDeviceUpdate => _deviceUpdateController.stream;
  Stream<Map<String, dynamic>> get onDeviceStatus => _deviceStatusController.stream;

  /// Initialize the service
  Future<void> initialize() async {
    await _setupAppSyncSubscriptions();
    await _setupIoTConnection();
  }

  /// Set up AppSync GraphQL subscriptions
  Future<void> _setupAppSyncSubscriptions() async {
    try {
      // Subscribe to device updates
      final deviceUpdateSubscription = Amplify.API.subscribe(
        GraphQLRequest<String>(
          document: '''
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
                location {
                  roomId
                  roomName
                }
              }
            }
          ''',
        ),
        onEstablished: () => safePrint('Device update subscription established'),
      );

      _deviceUpdateSubscription = deviceUpdateSubscription.listen(
        (event) {
          if (event.data != null) {
            try {
              final jsonData = jsonDecode(event.data!);
              final device = Device.fromJson(jsonData['onUpdateDevice']);
              _deviceUpdateController.add(device);
            } catch (e) {
              safePrint('Error parsing device update data: $e');
            }
          }
        },
        onError: (error) {
          safePrint('Device update subscription error: $error');
        },
      );

      // Subscribe to device status changes
      final deviceStatusSubscription = Amplify.API.subscribe(
        GraphQLRequest<String>(
          document: '''
            subscription OnDeviceStatusChange {
              onDeviceStatusChange {
                deviceId
                status
                timestamp
                data
              }
            }
          ''',
        ),
        onEstablished: () => safePrint('Device status subscription established'),
      );

      _deviceStatusSubscription = deviceStatusSubscription.listen(
        (event) {
          if (event.data != null) {
            try {
              final jsonData = jsonDecode(event.data!);
              final statusData = jsonData['onDeviceStatusChange'];
              _deviceStatusController.add(statusData);
            } catch (e) {
              safePrint('Error parsing device status data: $e');
            }
          }
        },
        onError: (error) {
          safePrint('Device status subscription error: $error');
        },
      );
    } catch (e) {
      safePrint('Error setting up AppSync subscriptions: $e');
    }
  }

  /// Set up MQTT connection to IoT Core
  Future<void> _setupIoTConnection() async {
    try {
      // Get IoT endpoint from constants
      final endpoint = AppConstants.iotEndpoint;
      
      // Generate a unique client ID
      final clientId = 'flutter_app_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create MQTT client
      _mqttClient = MqttServerClient(endpoint, clientId);
      _mqttClient!.port = 8883; // WSS port
      _mqttClient!.secure = true;
      _mqttClient!.keepAlivePeriod = 20;
      _mqttClient!.onDisconnected = _onDisconnected;
      _mqttClient!.onConnected = _onConnected;
      _mqttClient!.onSubscribed = _onSubscribed;
      
      // Set up WebSocket connection with Cognito credentials
      // This requires getting AWS credentials from Cognito Identity Pool
      final credentials = await _getAwsCredentials();
      
      // TODO: Implement WebSocket connection with SigV4 signing
      // This is a complex process that requires signing the WebSocket URL
      // with AWS SigV4 using the credentials from Cognito
      
      // For now, we'll rely on AppSync subscriptions for real-time updates
      safePrint('IoT Core MQTT connection setup skipped - using AppSync subscriptions');
    } catch (e) {
      safePrint('Error setting up IoT connection: $e');
    }
  }

  /// Get AWS credentials from Cognito Identity Pool
  Future<Map<String, String>> _getAwsCredentials() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession(
        options: const FetchAuthSessionOptions(forceRefresh: true),
      ) as CognitoAuthSession;
      
      final credentials = session.credentials;
      if (credentials == null) {
        throw Exception('Failed to get AWS credentials');
      }
      
      return {
        'accessKey': credentials.awsAccessKey,
        'secretKey': credentials.awsSecretKey,
        'sessionToken': credentials.sessionToken,
      };
    } catch (e) {
      safePrint('Error getting AWS credentials: $e');
      rethrow;
    }
  }

  /// Subscribe to a specific device's telemetry topic
  Future<void> subscribeToDeviceTelemetry(String deviceId) async {
    if (_mqttClient != null && _mqttConnected) {
      final topic = AppConstants.deviceTelemetryTopic(deviceId);
      _mqttClient!.subscribe(topic, MqttQos.atLeastOnce);
    } else {
      safePrint('MQTT client not connected, using AppSync subscriptions instead');
    }
  }

  /// Send a command to a device
  Future<void> sendDeviceCommand(String deviceId, Map<String, dynamic> command) async {
    try {
      // First try to send via AppSync mutation
      final request = GraphQLRequest<String>(
        document: '''
          mutation ControlDevice(\$deviceId: ID!, \$command: AWSJSON!) {
            controlDevice(deviceId: \$deviceId, command: \$command) {
              success
              message
            }
          }
        ''',
        variables: {
          'deviceId': deviceId,
          'command': jsonEncode(command),
        },
      );
      
      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        safePrint('GraphQL errors: ${response.errors}');
        throw Exception('Failed to send command via AppSync');
      }
      
      safePrint('Command sent successfully via AppSync');
    } catch (e) {
      safePrint('Error sending command via AppSync: $e');
      
      // Fallback to MQTT if AppSync fails
      if (_mqttClient != null && _mqttConnected) {
        try {
          final topic = AppConstants.deviceControlTopic(deviceId);
          final payload = jsonEncode(command);
          
          final builder = MqttClientPayloadBuilder();
          builder.addString(payload);
          
          _mqttClient!.publishMessage(
            topic,
            MqttQos.atLeastOnce,
            builder.payload!,
            retain: false,
          );
          
          safePrint('Command sent successfully via MQTT');
        } catch (mqttError) {
          safePrint('Error sending command via MQTT: $mqttError');
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  // MQTT callbacks
  void _onConnected() {
    safePrint('Connected to MQTT broker');
    _mqttConnected = true;
  }

  void _onDisconnected() {
    safePrint('Disconnected from MQTT broker');
    _mqttConnected = false;
  }

  void _onSubscribed(String topic) {
    safePrint('Subscribed to topic: $topic');
  }

  /// Dispose resources
  void dispose() {
    _deviceUpdateSubscription?.cancel();
    _deviceStatusSubscription?.cancel();
    _deviceUpdateController.close();
    _deviceStatusController.close();
    
    if (_mqttClient != null && _mqttConnected) {
      _mqttClient!.disconnect();
    }
  }
}