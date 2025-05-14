import 'package:flutter/material.dart';

class WireAppWeb extends StatelessWidget {
  const WireAppWeb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wire IoT Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wire IoT Platform'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_work, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Wire IoT Platform',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your smart home management solution',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DevicesScreen()),
                );
              },
              child: const Text('View Devices'),
            ),
          ],
        ),
      ),
    );
  }
}

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample device data
    final devices = [
      {'id': 'dev-001', 'name': 'Living Room Light', 'type': 'light', 'status': 'online'},
      {'id': 'dev-002', 'name': 'Kitchen Thermostat', 'type': 'thermostat', 'status': 'online'},
      {'id': 'dev-003', 'name': 'Front Door Lock', 'type': 'lock', 'status': 'offline'},
      {'id': 'dev-004', 'name': 'Bedroom Camera', 'type': 'camera', 'status': 'online'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Devices'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          final isOnline = device['status'] == 'online';
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: _getDeviceIcon(device['type'] as String),
              title: Text(device['name'] as String),
              subtitle: Text('Type: ${device['type']}'),
              trailing: Chip(
                label: Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline ? Colors.white : Colors.black,
                  ),
                ),
                backgroundColor: isOnline ? Colors.green : Colors.grey,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceControlScreen(
                      deviceId: device['id'] as String,
                      deviceName: device['name'] as String,
                      deviceType: device['type'] as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _getDeviceIcon(String deviceType) {
    switch (deviceType) {
      case 'light':
        return const Icon(Icons.lightbulb, color: Colors.amber);
      case 'thermostat':
        return const Icon(Icons.thermostat, color: Colors.red);
      case 'lock':
        return const Icon(Icons.lock, color: Colors.blue);
      case 'camera':
        return const Icon(Icons.camera_alt, color: Colors.purple);
      default:
        return const Icon(Icons.devices, color: Colors.grey);
    }
  }
}

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
  bool _isOn = false;
  double _brightness = 50;
  String _mode = 'Auto';
  
  @override
  void initState() {
    super.initState();
    // Initialize with mock data based on device type
    if (widget.deviceType == 'light') {
      _isOn = true;
      _brightness = 75;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName),
      ),
      body: SingleChildScrollView(
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Online',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Power'),
                        Switch(
                          value: _isOn,
                          onChanged: (value) {
                            setState(() {
                              _isOn = value;
                            });
                          },
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
                    if (widget.deviceType == 'light') ...[
                      // Brightness control for lights
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Brightness'),
                          Text('${_brightness.round()}%'),
                        ],
                      ),
                      Slider(
                        value: _brightness,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: _isOn ? (value) {
                          setState(() {
                            _brightness = value;
                          });
                        } : null,
                      ),
                    ] else if (widget.deviceType == 'thermostat') ...[
                      // Temperature control for thermostat
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Temperature'),
                          Text('${(20 + _brightness / 10).toStringAsFixed(1)}°C'),
                        ],
                      ),
                      Slider(
                        value: _brightness,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        onChanged: _isOn ? (value) {
                          setState(() {
                            _brightness = value;
                          });
                        } : null,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mode'),
                          DropdownButton<String>(
                            value: _mode,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _mode = newValue;
                                });
                              }
                            },
                            items: <String>['Auto', 'Heat', 'Cool', 'Fan']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ] else if (widget.deviceType == 'lock') ...[
                      // Lock controls
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              _isOn ? Icons.lock_outline : Icons.lock_open,
                              size: 64,
                              color: _isOn ? Colors.green : Colors.red,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isOn = !_isOn;
                                });
                              },
                              child: Text(_isOn ? 'Unlock Door' : 'Lock Door'),
                            ),
                          ],
                        ),
                      ),
                    ] else if (widget.deviceType == 'camera') ...[
                      // Camera controls
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.black,
                              child: const Center(
                                child: Text(
                                  'Camera Feed',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.videocam),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.photo_camera),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.mic),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    _buildInfoRow('Firmware', 'v1.2.3'),
                    _buildInfoRow('Last Connected', DateTime.now().toString()),
                    _buildInfoRow('Room', 'Living Room'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
}