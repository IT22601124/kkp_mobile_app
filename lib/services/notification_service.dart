import 'dart:convert';
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  String? _fcmToken;
  bool _isInitialized = false;
  final ValueNotifier<bool> inboxRequested = ValueNotifier(false);
  final StreamController<void> _inboxUpdates =
      StreamController<void>.broadcast();
  Stream<void> get inboxUpdates => _inboxUpdates.stream;

  void _handleNotificationTap(Map<String, dynamic> data) {
    if (data['type'] == 'announcement') inboxRequested.value = true;
  }

  String? get fcmToken => _fcmToken;
  Function(String token)? onTokenRefreshCallback;
  Function()? onStockUpdateReceived;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Fetch or return cached FCM token
  Future<String?> getOrFetchFcmToken() async {
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      return _fcmToken;
    }

    if (!FirebaseService.isInitialized) {
      debugPrint(
        'NotificationService: Firebase not initialized when fetching FCM token',
      );
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
    if (_isInitialized) return;
    if (!FirebaseService.isInitialized) {
      debugPrint(
        'NotificationService skipped: Firebase Core is not initialized.',
      );
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

      debugPrint(
        'User notification permission status: ${settings.authorizationStatus}',
      );

      // iOS presents the remote notification itself while the app is open.
      // Android uses the local high-importance notification below instead.
      await _messaging!.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Initialize Local Notifications for Android/iOS foreground banners
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint(
            'Notification tapped in local banner: ${response.payload}',
          );
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            try {
              _handleNotificationTap(
                Map<String, dynamic>.from(jsonDecode(payload) as Map),
              );
            } on FormatException {
              debugPrint('Ignoring an invalid notification payload.');
            }
          }
        },
      );

      // Create Android Notification Channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);

      // A local foreground banner can launch a terminated Android app too.
      final launch = await _localNotifications
          .getNotificationAppLaunchDetails();
      final launchPayload = launch?.notificationResponse?.payload;
      if (launch?.didNotificationLaunchApp == true && launchPayload != null) {
        try {
          _handleNotificationTap(
            Map<String, dynamic>.from(jsonDecode(launchPayload) as Map),
          );
        } on FormatException {
          debugPrint('Ignoring an invalid notification launch payload.');
        }
      }

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
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint(
          'Foreground FCM message received: ${message.notification?.title}',
        );
        if (message.data['type'] == 'announcement') _inboxUpdates.add(null);

        final title = (message.notification?.title ?? message.data['title']?.toString() ?? '').toLowerCase();
        final body = (message.notification?.body ?? message.data['body']?.toString() ?? '').toLowerCase();
        final type = (message.data['type']?.toString() ?? '').toLowerCase();

        if (type.contains('stock') || title.contains('stock') || body.contains('stock') || title.contains('issued') || body.contains('issued')) {
          onStockUpdateReceived?.call();
        }

        await _showForegroundNotification(message);
      });

      // Background notification tap listener (app was running in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationTap(message.data);
        debugPrint(
          'Notification opened from background state: ${message.data}',
        );
      });

      _isInitialized = true;

      // Terminated notification tap (app opened via notification)
      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage.data);
        debugPrint(
          'App launched from terminated state via notification: ${initialMessage.data}',
        );
      }
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    // Apple uses native foreground presentation; showing another local
    // notification there would display the same announcement twice.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body =
        notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    try {
      await _localNotifications.show(
        message.messageId?.hashCode ?? message.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: notification?.android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (error, stackTrace) {
      debugPrint('Unable to display foreground notification: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
