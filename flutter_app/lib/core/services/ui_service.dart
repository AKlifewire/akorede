import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/ui_model.dart';

/// Service to fetch dynamic UI pages from AppSync GraphQL API
class UIService {
  /// Fetches a UI page by its ID from the backend
  Future<UIPage?> getUIPage(String pageId) async {
    try {
      final request = GraphQLRequest(
        document: '''
          query GetUIPage(\$id: ID!) {
            getUIPage(id: \$id) {
              id
              name
              version
              content
              metadata
            }
          }
        ''',
        variables: {'id': pageId},
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        safePrint('GraphQL errors: ${response.errors}');
        return null;
      }

      if (response.data == null) {
        safePrint('No data returned for UI page: $pageId');
        return null;
      }

      final pageData = response.data?['getUIPage'];
      if (pageData == null) {
        return null;
      }

      // Parse the content string which contains the rootComponent
      final content = jsonDecode(pageData['content']);
      
      return UIPage(
        id: pageData['id'],
        name: pageData['name'],
        version: pageData['version'],
        rootComponent: UIComponent.fromJson(content),
        metadata: pageData['metadata'] ?? {},
      );
    } catch (e) {
      safePrint('Error fetching UI page: $e');
      return null;
    }
  }

  /// Fetches the default home page UI
  Future<UIPage?> getHomePage() async {
    return getUIPage('home');
  }

  /// Fetches a device control page for a specific device type
  Future<UIPage?> getDeviceControlPage(String deviceType) async {
    return getUIPage('device-control-$deviceType');
  }
}