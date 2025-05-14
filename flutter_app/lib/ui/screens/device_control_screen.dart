import 'package:flutter/material.dart';
import '../../core/models/device_model.dart';
import '../../core/services/device_control_service.dart';
import '../../core/services/ui_loader_service.dart';
import '../../core/services/realtime_service.dart';
import '../widgets/widget_factory.dart';

class DeviceControlScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;
  final String deviceType;

  const DeviceControlScreen({
    Key? key,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
  }) : super(key: key);

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  final DeviceControlService _deviceService = DeviceControlService();
  final UILoaderService _uiLoader = UILoaderService();
  final RealtimeService _realtimeService = RealtimeService();
  
  Device? _device;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadDevice();
    _setupRealtimeUpdates();
  }
  
  Future<void> _loadDevice() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final device = await _deviceService.getDevice(widget.deviceId);
      
      setState(() {
        _device = device;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load device: $e';
        _isLoading = false;
      });
    }
  }
  
  void _setupRealtimeUpdates() {
    // Initialize the realtime service
    _realtimeService.initialize();
    
    // Listen for device updates
    _realtimeService.onDeviceUpdate.listen((updatedDevice) {
      if (updatedDevice.id == widget.deviceId) {
        setState(() {
          _device = updatedDevice;
        });
      }
    });
    
    // Listen for device status changes
    _realtimeService.onDeviceStatus.listen((statusData) {
      if (statusData['deviceId'] == widget.deviceId) {
        _loadDevice(); // Refresh the device data
      }
    });
  }
  
  Future<void> _toggleDevice(bool turnOn) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final success = await _deviceService.toggleDevice(widget.deviceId, turnOn);
      
      if (success) {
        // The device state will be updated via the realtime subscription
      } else {
        setState(() {
          _errorMessage = 'Failed to ${turnOn ? 'turn on' : 'turn off'} device';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error controlling device: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _setProperty(String property, dynamic value) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final success = await _deviceService.setDeviceProperty(
        widget.deviceId,
        property,
        value,
      );
      
      if (success) {
        // The device state will be updated via the realtime subscription
      } else {
        setState(() {
          _errorMessage = 'Failed to set $property';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error setting property: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDevice,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _device == null
                  ? _buildDeviceNotFoundView()
                  : _buildDeviceControlView(),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDevice,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeviceNotFoundView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.device_unknown, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Device not found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Could not find device with ID: ${widget.deviceId}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeviceControlView() {
    // Try to load a dynamic UI for this device type
    return FutureBuilder(
      future: _uiLoader.loadDeviceControlUI(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return _buildDefaultDeviceControlView();
        }
        
        final uiPage = snapshot.data;
        if (uiPage == null) {
          return _buildDefaultDeviceControlView();
        }
        
        // We have a dynamic UI definition, use it
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: WidgetFactory.buildWidget(context, uiPage.rootComponent),
        );
      },
    );
  }
  
  Widget _buildDefaultDeviceControlView() {
    final isOnline = _device?.status == 'online';
    final properties = _device?.properties ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: isOnline ? Colors.white : Colors.black,
                          ),
                        ),
                        backgroundColor: isOnline ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Power'),
                      Switch(
                        value: properties['power'] == 'on',
                        onChanged: isOnline
                            ? (value) => _setProperty('power', value ? 'on' : 'off')
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Properties card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Properties',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...properties.entries
                      .where((entry) => entry.key != 'power')
                      .map((entry) => _buildPropertyControl(entry.key, entry.value))
                      .toList(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Device info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Device Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('ID', widget.deviceId),
                  _buildInfoRow('Type', widget.deviceType),
                  _buildInfoRow('Firmware', _device?.firmware ?? 'Unknown'),
                  _buildInfoRow(
                    'Last Connected',
                    _device?.lastConnected?.toString() ?? 'Unknown',
                  ),
                  if (_device?.location != null)
                    _buildInfoRow('Room', _device!.location!.roomName),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPropertyControl(String property, dynamic value) {
    // Handle different property types
    if (value is bool) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(property),
          Switch(
            value: value,
            onChanged: (newValue) => _setProperty(property, newValue),
          ),
        ],
      );
    } else if (value is num) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(property),
              Text(value.toString()),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: (newValue) => _setProperty(property, newValue),
          ),
        ],
      );
    } else if (value is String) {
      if (value == 'on' || value == 'off') {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(property),
            Switch(
              value: value == 'on',
              onChanged: (newValue) => _setProperty(property, newValue ? 'on' : 'off'),
            ),
          ],
        );
      }
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(property),
          Text(value),
        ],
      );
    }
    
    // Default case
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(property),
        Text(value.toString()),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _realtimeService.dispose();
    super.dispose();
  }
}