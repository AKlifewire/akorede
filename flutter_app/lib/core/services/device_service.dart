import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/device_model.dart';
import '../../config/constants.dart';

/// Service to handle device operations and communication
class DeviceService {
  MqttServerClient? _mqttClient;
  bool _isConnected = false;

  /// Initialize MQTT client
  Future<void> initMqttClient(String clientId) async {
    try {
      _mqttClient = MqttServerClient(AppConstants.iotEndpoint, clientId);
      _mqttClient!.logging(on: false);
      _mqttClient!.keepAlivePeriod = 20;
      _mqttClient!.onDisconnected = _onDisconnected;
      _mqttClient!.onConnected = _onConnected;
      _mqttClient!.onSubscribed = _onSubscribed;
      
      // Set secure connection
      _mqttClient!.secure = true;
      _mqttClient!.port = 8883;
      
      // TODO: Implement AWS IoT WebSocket connection using Cognito credentials
    } catch (e) {
      safePrint('Error initializing MQTT client: $e');
      rethrow;
    }
  }

  /// Connect to MQTT broker
  Future<bool> connectMqtt() async {
    try {
      if (_mqttClient == null) {
        throw Exception('MQTT client not initialized');
      }
      
      final connStatus = await _mqttClient!.connect();
      if (connStatus == MqttConnectionState.connected) {
        _isConnected = true;
        safePrint('Connected to MQTT broker');
        return true;
      } else {
        safePrint('Failed to connect to MQTT broker: $connStatus');
        return false;
      }
    } catch (e) {
      safePrint('Error connecting to MQTT broker: $e');
      return false;
    }
  }

  /// Disconnect from MQTT broker
  void disconnectMqtt() {
    if (_mqttClient != null && _isConnected) {
      _mqttClient!.disconnect();
    }
  }

  /// Subscribe to device status topic
  void subscribeToDeviceStatus(String deviceId, Function(String) callback) {
    if (_mqttClient != null && _isConnected) {
      final topic = AppConstants.deviceStatusTopic(deviceId);
      _mqttClient!.subscribe(topic, MqttQos.atLeastOnce);
      
      _mqttClient!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        for (var msg in messages) {
          final recMess = msg.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          
          if (msg.topic == topic) {
            callback(payload);
          }
        }
      });
    }
  }

  /// Subscribe to device telemetry topic
  void subscribeToDeviceTelemetry(String deviceId, Function(Map<String, dynamic>) callback) {
    if (_mqttClient != null && _isConnected) {
      final topic = AppConstants.deviceTelemetryTopic(deviceId);
      _mqttClient!.subscribe(topic, MqttQos.atLeastOnce);
      
      _mqttClient!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        for (var msg in messages) {
          final recMess = msg.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          
          if (msg.topic == topic) {
            try {
              final data = jsonDecode(payload) as Map<String, dynamic>;
              callback(data);
            } catch (e) {
              safePrint('Error parsing telemetry data: $e');
            }
          }
        }
      });
    }
  }

  /// Send command to device
  void sendDeviceCommand(String deviceId, Map<String, dynamic> command) {
    if (_mqttClient != null && _isConnected) {
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
    }
  }

  /// Get user's devices from AppSync API
  Future<List<Device>> getUserDevices() async {
    try {
      final request = GraphQLRequest(
        document: '''
          query GetUserDevices {
            getDevicesByOwner {
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
        ''',
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        safePrint('GraphQL errors: ${response.errors}');
        return [];
      }

      if (response.data == null) {
        return [];
      }

      final items = response.data?['getDevicesByOwner']['items'] as List<dynamic>;
      return items.map((item) => Device.fromJson(item)).toList();
    } catch (e) {
      safePrint('Error fetching user devices: $e');
      return [];
    }
  }

  /// Get device details
  Future<Device?> getDeviceDetails(String deviceId) async {
    try {
      final request = GraphQLRequest(
        document: '''
          query GetDevice(\$id: ID!) {
            getDevice(id: \$id) {
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
        variables: {'id': deviceId},
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        safePrint('GraphQL errors: ${response.errors}');
        return null;
      }

      if (response.data == null || response.data?['getDevice'] == null) {
        return null;
      }

      return Device.fromJson(response.data?['getDevice']);
    } catch (e) {
      safePrint('Error fetching device details: $e');
      return null;
    }
  }

  /// Control device through AppSync API
  Future<bool> controlDevice(String deviceId, Map<String, dynamic> command) async {
    try {
      final request = GraphQLRequest(
        document: '''
          mutation ControlDevice(\$id: ID!, \$command: AWSJSON!) {
            controlDevice(id: \$id, command: \$command) {
              success
              message
            }
          }
        ''',
        variables: {
          'id': deviceId,
          'command': jsonEncode(command),
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        safePrint('GraphQL errors: ${response.errors}');
        return false;
      }

      return response.data?['controlDevice']['success'] ?? false;
    } catch (e) {
      safePrint('Error controlling device: $e');
      return false;
    }
  }

  // MQTT callbacks
  void _onConnected() {
    safePrint('Connected to MQTT broker');
    _isConnected = true;
  }

  void _onDisconnected() {
    safePrint('Disconnected from MQTT broker');
    _isConnected = false;
  }

  void _onSubscribed(String topic) {
    safePrint('Subscribed to topic: $topic');
  }
}