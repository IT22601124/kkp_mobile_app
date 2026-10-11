import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  String? _fcmToken;

  String? get fcmToken => _fcmToken;
  Function(String token)? onTokenRefreshCallback;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  /// Fetch or return cached FCM token
  Future<String?> getOrFetchFcmToken() async {
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      return _fcmToken;
    }

    if (!FirebaseService.isInitialized) {
      debugPrint('NotificationService: Firebase not initialized when fetching FCM token');
      return null;
    }

    try {
      _messaging ??= FirebaseMessaging.instance;
      _fcmToken = await _messaging!.getToken();
      debugPrint('FCM Device Token retrieved: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      debugPrint('Error getting FCM token on demand: $e');
      return null;
    }
  }

  Future<void> initialize() async {
    if (!FirebaseService.isInitialized) {
      debugPrint('NotificationService skipped: Firebase Core is not initialized.');
      return;
    }

    try {
      _messaging = FirebaseMessaging.instance;

      // Request permissions
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('User notification permission status: ${settings.authorizationStatus}');

      // Initialize Local Notifications for Android/iOS foreground banners
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification tapped in local banner: ${response.payload}');
        },
      );

      // Create Android Notification Channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // Fetch FCM token
      try {
        _fcmToken = await _messaging!.getToken();
        debugPrint('FCM Device Token: $_fcmToken');
      } catch (e) {
        debugPrint('Error getting FCM token: $e');
      }

      // Token refresh listener
      _messaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Device Token Refreshed: $_fcmToken');
        onTokenRefreshCallback?.call(newToken);
      });

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground FCM message received: ${message.notification?.title}');
        _showForegroundNotification(message);
      });

      // Background notification tap listener (app was running in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification opened from background state: ${message.data}');
      });

      // Terminated notification tap (app opened via notification)
      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App launched from terminated state via notification: ${initialMessage.data}');
      }
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && !kIsWeb) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }
}
