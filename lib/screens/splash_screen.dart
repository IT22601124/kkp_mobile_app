import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../provider/auth_provider.dart';
import '../resources/api_routes.dart';
import '../resources/image_resource.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final Function(bool isLoggedIn) onInitializationComplete;

  const SplashScreen({super.key, required this.onInitializationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusMessage = 'Initializing application...';
  bool _hasConnectionError = false;

  @override
  void initState() {
    super.initState();
    _initializeAndCheckHealth();
  }

  Future<void> _initializeAndCheckHealth() async {
    setState(() {
      _hasConnectionError = false;
      _statusMessage = 'Checking server health...';
    });

    final authProvider = context.read<AuthProvider>();
    final startTime = DateTime.now();
    bool isLoggedIn = false;

    try {
      // 1. Execute health check FIRST before checking token or other APIs
      await authProvider.checkHealth();

      // 2. If server health check passes, then check saved token
      isLoggedIn = await authProvider.checkSavedToken();

      if (!mounted) return;
      setState(() {
        _hasConnectionError = false;
        _statusMessage = isLoggedIn
            ? 'Session active! Loading dashboard...'
            : 'Server online! Please login...';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasConnectionError = true;
        _statusMessage = 'Connection Problem: Unable to reach server';
      });
    }

    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 2500) {
      await Future.delayed(Duration(milliseconds: 2500 - elapsed));
    }

    if (mounted) {
      if (_hasConnectionError) return;
      widget.onInitializationComplete(isLoggedIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (Expanded 100% Full Screen)
          Image.asset(
            ImageResource.splashScreenBackground,
            fit: BoxFit.cover,
            color: Colors.black.withAlpha((0.7 * 255).toInt()),
            colorBlendMode: BlendMode.darken,
            width: double.infinity,
            height: double.infinity,
          ),

          // Foreground Content
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 36),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          //   color: AppColors.darkCard.withAlpha((0.9 * 255).toInt()),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          ImageResource.logo,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // App Title & Subtitle
                      Column(
                        children: [
                          Text(
                            'Sundaram DSR',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Text(
                            'Sales & Distribution System',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(flex: 12),

                  // Connection Error Box or Loading Indicator
                  if (_hasConnectionError) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((0.85 * 255).toInt()),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.roseDanger,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(
                                (0.5 * 255).toInt(),
                              ),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.wifi_off_rounded,
                                  color: AppColors.roseDanger,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Connection Problem',
                                  style: TextStyle(
                                    color: AppColors.roseDanger,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Unable to connect to server at ${ApiRoutes.baseUrl}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _initializeAndCheckHealth,
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('RETRY'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryOrange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        widget.onInitializationComplete(false),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.cyanAccent,
                                      side: const BorderSide(
                                        color: AppColors.cyanAccent,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'PROCEED OFFLINE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Hexagon Dots Loading Animation
                    LoadingAnimationWidget.hexagonDots(
                      color: AppColors.primaryOrange,
                      size: 38,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Bottom Footer Version Text
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Version 1.0.0  |  Sundaram Multi-Brand',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white38,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
