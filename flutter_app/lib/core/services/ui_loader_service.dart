import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import '../models/ui_model.dart';
import '../../config/constants.dart';

/// Service to load UI definitions from S3
class UILoaderService {
  // Cache for UI definitions to avoid repeated S3 downloads
  final Map<String, UIPage> _uiCache = {};
  
  // Flag to determine if we should use cached UI or always fetch from S3
  final bool _useCache;
  
  // Default constructor
  UILoaderService({bool useCache = true}) : _useCache = useCache;
  
  /// Load a UI page from S3 by its path
  Future<UIPage?> loadUIPage(String path) async {
    try {
      // Check cache first if enabled
      if (_useCache && _uiCache.containsKey(path)) {
        safePrint('Using cached UI for: $path');
        return _uiCache[path];
      }
      
      safePrint('Loading UI from S3: $path');
      
      // Get the file from S3
      final result = await Amplify.Storage.downloadData(
        key: path,
        options: const StorageDownloadDataOptions(
          accessLevel: StorageAccessLevel.guest,
        ),
      ).result;
      
      // Convert bytes to string
      final jsonString = String.fromCharCodes(result.bytes);
      
      // Parse the JSON
      final jsonData = jsonDecode(jsonString);
      
      // Create a UIPage object
      final uiPage = UIPage.fromJson(jsonData);
      
      // Cache the result if caching is enabled
      if (_useCache) {
        _uiCache[path] = uiPage;
      }
      
      return uiPage;
    } catch (e) {
      safePrint('Error loading UI from S3: $e');
      return null;
    }
  }
  
  /// Load the home UI
  Future<UIPage?> loadHomeUI() async {
    return loadUIPage(AppConstants.homeUiPath);
  }
  
  /// Load the login UI
  Future<UIPage?> loadLoginUI() async {
    return loadUIPage(AppConstants.loginUiPath);
  }
  
  /// Load the device list UI
  Future<UIPage?> loadDeviceListUI() async {
    return loadUIPage(AppConstants.deviceListUiPath);
  }
  
  /// Load the device control UI
  Future<UIPage?> loadDeviceControlUI() async {
    return loadUIPage(AppConstants.deviceControlUiPath);
  }
  
  /// Clear the UI cache
  void clearCache() {
    _uiCache.clear();
  }
  
  /// Clear a specific UI from the cache
  void clearCacheFor(String path) {
    _uiCache.remove(path);
  }
}