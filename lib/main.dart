import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kkp_rep_mobile_app/provider/auth_provider.dart';
import 'package:kkp_rep_mobile_app/provider/shop_provider.dart';
import 'package:kkp_rep_mobile_app/provider/item_provider.dart';
import 'package:kkp_rep_mobile_app/provider/sales_provider.dart';
import 'package:kkp_rep_mobile_app/provider/bank_account_provider.dart';
import 'package:kkp_rep_mobile_app/services/firebase_service.dart';
import 'package:kkp_rep_mobile_app/services/remote_config_service.dart';
import 'package:kkp_rep_mobile_app/services/notification_service.dart';
import 'package:kkp_rep_mobile_app/widgets/main_navigation_shell/main_navigation_shell.dart';
import 'theme/app_theme.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseService.initialize();
  debugPrint('Handling background FCM message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Core, Remote Config, and Push Notifications
  await FirebaseService.initialize();
  if (FirebaseService.isInitialized) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await RemoteConfigService().initialize();
    await NotificationService().initialize();
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const DsrRepMobileApp(),
    ),
  );
}

class DsrRepMobileApp extends StatefulWidget {
  const DsrRepMobileApp({super.key});

  @override
  State<DsrRepMobileApp> createState() => _DsrRepMobileAppState();
}

class _DsrRepMobileAppState extends State<DsrRepMobileApp> {
  bool _isDarkMode = true;
  bool _isLoggedIn = false;
  bool _showSplash = true;

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sundaram DSR Mobile',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _showSplash
          ? SplashScreen(
              onInitializationComplete: (isLoggedIn) => setState(() {
                _showSplash = false;
                _isLoggedIn = isLoggedIn;
              }),
            )
          : (_isLoggedIn
                ? MultiProvider(
                    key: ValueKey(
                      context.watch<AuthProvider>().sessionRevision,
                    ),
                    providers: [
                      ChangeNotifierProvider(create: (_) => ShopProvider()),
                      ChangeNotifierProvider(create: (_) => ItemProvider()),
                      ChangeNotifierProvider(create: (_) => SalesProvider()),
                      ChangeNotifierProvider(
                        create: (_) => BankAccountProvider(),
                      ),
                    ],
                    child: MainNavigationShell(
                      isDarkMode: _isDarkMode,
                      onToggleTheme: _toggleTheme,
                      onLogout: () async {
                        await context.read<AuthProvider>().logout();
                        if (!mounted) return;
                        setState(() => _isLoggedIn = false);
                      },
                    ),
                  )
                : LoginScreen(
                    onLoginSuccess: () => setState(() => _isLoggedIn = true),
                  )),
    );
  }
}
