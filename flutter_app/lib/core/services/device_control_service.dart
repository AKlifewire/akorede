import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/device_model.dart';
import '../../config/constants.dart';

/// Service to handle device control operations
class DeviceControlService {
  /// Get a list of all devices
  Future<List<Device>> getDevices() async {
    try {
      final request = GraphQLRequest<String>(
        document: AppConstants.getDevicesQuery,
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        safePrint('GraphQL errors: ${response.errors}');
        return [];
      }

      if (response.data == null) {
        return [];
      }

      final jsonData = jsonDecode(response.data!);
      final items = jsonData['listDevices']['items'] as List<dynamic>;
      
      return items.map((item) => Device.fromJson(item)).toList();
    } catch (e) {
      safePrint('Error fetching devices: $e');
      return [];
    }
  }

  /// Get a specific device by ID
  Future<Device?> getDevice(String deviceId) async {
    try {
      final request = GraphQLRequest<String>(
        document: AppConstants.getDeviceQuery,
        variables: {'deviceId': deviceId},
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        safePrint('GraphQL errors: ${response.errors}');
        return null;
      }

      if (response.data == null) {
        return null;
      }

      final jsonData = jsonDecode(response.data!);
      final deviceData = jsonData['getDevice'];
      
      if (deviceData == null) {
        return null;
      }
      
      return Device.fromJson(deviceData);
    } catch (e) {
      safePrint('Error fetching device: $e');
      return null;
    }
  }

  /// Control a device by sending a command
  Future<bool> controlDevice(String deviceId, Map<String, dynamic> command) async {
    try {
      final request = GraphQLRequest<String>(
        document: AppConstants.controlDeviceMutation,
        variables: {
          'deviceId': deviceId,
          'command': jsonEncode(command),
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        safePrint('GraphQL errors: ${response.errors}');
        return false;
      }

      if (response.data == null) {
        return false;
      }

      final jsonData = jsonDecode(response.data!);
      return jsonData['controlDevice']['success'] ?? false;
    } catch (e) {
      safePrint('Error controlling device: $e');
      return false;
    }
  }

  /// Toggle a device on/off
  Future<bool> toggleDevice(String deviceId, bool turnOn) async {
    final command = {
      'action': turnOn ? 'turnOn' : 'turnOff',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    return controlDevice(deviceId, command);
  }

  /// Set a device property
  Future<bool> setDeviceProperty(String deviceId, String property, dynamic value) async {
    final command = {
      'action': 'setProperty',
      'property': property,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    return controlDevice(deviceId, command);
  }

  /// Execute a device action
  Future<bool> executeDeviceAction(String deviceId, String action, Map<String, dynamic> parameters) async {
    final command = {
      'action': action,
      'parameters': parameters,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    return controlDevice(deviceId, command);
  }
}