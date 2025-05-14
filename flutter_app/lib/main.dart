import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app.dart';
import 'app_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // If running on web, use the web version
  if (kIsWeb) {
    runApp(const WireAppWeb());
  } else {
    // For mobile/desktop, try to configure Amplify
    try {
      await _configureAmplify();
      runApp(const WireApp());
    } catch (e) {
      print('Error configuring Amplify: $e');
      // Fallback to a basic app if Amplify fails
      runApp(const WireAppFallback());
    }
  }
}

Future<void> _configureAmplify() async {
  // This is a placeholder for the actual Amplify configuration
  // The real implementation is in the original main.dart
  // We're using this simplified version to avoid Amplify issues on web
  await Future.delayed(const Duration(milliseconds: 100));
}

class WireAppFallback extends StatelessWidget {
  const WireAppFallback({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wire IoT Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Wire IoT Platform'),
        ),
        body: const Center(
          child: Text('Failed to initialize Amplify. Please check your configuration.'),
        ),
      ),
    );
  }
}