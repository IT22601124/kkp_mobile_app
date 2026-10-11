import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  FirebaseRemoteConfig? _remoteConfig;
  bool _isConfigReady = false;

  bool get isConfigReady => _isConfigReady;

  static const Map<String, dynamic> _defaultValues = {
    'app_latest_version': '1.0.0',
    'maintenance_mode': false,
    'feature_sales_enabled': true,
    'banner_message': 'Welcome to Sundaram DSR Mobile',
  };

  Future<void> initialize() async {
    if (!FirebaseService.isInitialized) {
      debugPrint('RemoteConfigService skipped: Firebase Core is not initialized.');
      return;
    }

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );

      await _remoteConfig!.setDefaults(_defaultValues);
      
      final updated = await _remoteConfig!.fetchAndActivate();
      _isConfigReady = true;
      debugPrint('RemoteConfig initialized. Fetch and activate status: $updated');
    } catch (e) {
      debugPrint('RemoteConfig initialization error: $e');
    }
  }

  String getString(String key) {
    if (_remoteConfig != null && _isConfigReady) {
      return _remoteConfig!.getString(key);
    }
    return _defaultValues[key]?.toString() ?? '';
  }

  bool getBool(String key) {
    if (_remoteConfig != null && _isConfigReady) {
      return _remoteConfig!.getBool(key);
    }
    return _defaultValues[key] == true;
  }

  int getInt(String key) {
    if (_remoteConfig != null && _isConfigReady) {
      return _remoteConfig!.getInt(key);
    }
    return int.tryParse(_defaultValues[key]?.toString() ?? '0') ?? 0;
  }

  double getDouble(String key) {
    if (_remoteConfig != null && _isConfigReady) {
      return _remoteConfig!.getDouble(key);
    }
    return double.tryParse(_defaultValues[key]?.toString() ?? '0.0') ?? 0.0;
  }
}
