import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      if (options != null &&
          options.apiKey != 'AIzaSyDQhqqkB_gsl7aJmPHrBygW7pS6Td_6Q6g' &&
          options.apiKey != 'YOUR-WEB-API-KEY' &&
          options.apiKey != 'YOUR-IOS-API-KEY') {
        await Firebase.initializeApp(options: options);
      } else {
        await Firebase.initializeApp();
      }
      _isInitialized = true;
      debugPrint('Firebase Core initialized successfully.');
    } catch (e) {
      _isInitialized = false;
      debugPrint('Firebase Core initialization warning: $e');
      debugPrint(
          'If running on Android without google-services.json, place it in android/app/google-services.json or run "flutterfire configure".');
    }
  }
}
