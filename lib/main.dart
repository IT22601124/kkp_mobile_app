import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kkp_rep_mobile_app/provider/auth_provider.dart';
import 'package:kkp_rep_mobile_app/provider/shop_provider.dart';
import 'package:kkp_rep_mobile_app/provider/item_provider.dart';
import 'package:kkp_rep_mobile_app/provider/sales_provider.dart';
import 'package:kkp_rep_mobile_app/widgets/main_navigation_shell/main_navigation_shell.dart';
import 'theme/app_theme.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
      ],
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
  final AuthProvider _authProvider = AuthProvider();

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
              ? MainNavigationShell(
                  isDarkMode: _isDarkMode,
                  onToggleTheme: _toggleTheme,
                  onLogout: () async {
                    await _authProvider.logout();
                    setState(() => _isLoggedIn = false);
                  },
                )
              : LoginScreen(
                  onLoginSuccess: () => setState(() => _isLoggedIn = true),
                )),
    );
  }
}
