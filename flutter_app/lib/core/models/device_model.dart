import 'dart:convert';

/// Model representing a device in the system
class Device {
  final String id;
  final String name;
  final String type;
  final String status;
  final String? firmware;
  final DateTime? lastConnected;
  final Map<String, dynamic> properties;
  final Map<String, dynamic>? telemetry;
  final DeviceLocation? location;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.firmware,
    this.lastConnected,
    required this.properties,
    this.telemetry,
    this.location,
  });

  /// Create a Device from JSON
  factory Device.fromJson(Map<String, dynamic> json) {
    // Parse properties
    Map<String, dynamic> props = {};
    if (json['properties'] != null) {
      if (json['properties'] is String) {
        props = jsonDecode(json['properties']);
      } else if (json['properties'] is Map) {
        props = Map<String, dynamic>.from(json['properties']);
      }
    }

    // Parse telemetry
    Map<String, dynamic>? telemetry;
    if (json['telemetry'] != null) {
      if (json['telemetry'] is String) {
        telemetry = jsonDecode(json['telemetry']);
      } else if (json['telemetry'] is Map) {
        telemetry = Map<String, dynamic>.from(json['telemetry']);
      }
    }

    // Parse lastConnected timestamp
    DateTime? lastConnected;
    if (json['lastConnected'] != null) {
      if (json['lastConnected'] is String) {
        lastConnected = DateTime.tryParse(json['lastConnected']);
      } else if (json['lastConnected'] is int) {
        lastConnected = DateTime.fromMillisecondsSinceEpoch(json['lastConnected']);
      }
    }

    // Parse location
    DeviceLocation? location;
    if (json['location'] != null) {
      location = DeviceLocation.fromJson(json['location']);
    }

    return Device(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      status: json['status'] ?? 'offline',
      firmware: json['firmware'],
      lastConnected: lastConnected,
      properties: props,
      telemetry: telemetry,
      location: location,
    );
  }

  /// Convert Device to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'firmware': firmware,
      'lastConnected': lastConnected?.toIso8601String(),
      'properties': jsonEncode(properties),
      'telemetry': telemetry != null ? jsonEncode(telemetry) : null,
      'location': location?.toJson(),
    };
  }

  /// Create a copy of this Device with updated fields
  Device copyWith({
    String? id,
    String? name,
    String? type,
    String? status,
    String? firmware,
    DateTime? lastConnected,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? telemetry,
    DeviceLocation? location,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      firmware: firmware ?? this.firmware,
      lastConnected: lastConnected ?? this.lastConnected,
      properties: properties ?? this.properties,
      telemetry: telemetry ?? this.telemetry,
      location: location ?? this.location,
    );
  }
}

/// Model representing a device's location
class DeviceLocation {
  final String roomId;
  final String roomName;
  final String? propertyId;
  final String? propertyName;

  DeviceLocation({
    required this.roomId,
    required this.roomName,
    this.propertyId,
    this.propertyName,
  });

  /// Create a DeviceLocation from JSON
  factory DeviceLocation.fromJson(Map<String, dynamic> json) {
    return DeviceLocation(
      roomId: json['roomId'],
      roomName: json['roomName'],
      propertyId: json['propertyId'],
      propertyName: json['propertyName'],
    );
  }

  /// Convert DeviceLocation to JSON
  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'roomName': roomName,
      'propertyId': propertyId,
      'propertyName': propertyName,
    };
  }
}