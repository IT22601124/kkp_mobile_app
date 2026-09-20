import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../provider/auth_provider.dart';
import '../resources/api_routes.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final Function(bool isLoggedIn) onInitializationComplete;

  const SplashScreen({
    super.key,
    required this.onInitializationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final AuthProvider _authProvider = AuthProvider();
  String _statusMessage = 'Initializing application...';
  bool _hasConnectionError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    _initializeAndCheckHealth();
  }

  Future<void> _initializeAndCheckHealth() async {
    setState(() {
      _hasConnectionError = false;
      _statusMessage = 'Checking server health...';
    });

    final startTime = DateTime.now();
    bool isLoggedIn = false;

    try {
      // 1. Execute health check FIRST before checking token or other APIs
      await _authProvider.checkHealth();

      // 2. If server health check passes, then check saved token
      isLoggedIn = await _authProvider.checkSavedToken();

      setState(() {
        _hasConnectionError = false;
        _statusMessage = isLoggedIn ? 'Session active! Loading dashboard...' : 'Server online! Please login...';
      });
    } catch (e) {
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Professional Corporate Logo Emblem
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryOrange, Color(0xFFFF7A00), Color(0xFFC53000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withOpacity(0.45),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: -10,
                          right: -10,
                          child: Icon(
                            Icons.circle_outlined,
                            size: 80,
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.storefront_rounded,
                              size: 42,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'SUNDARAM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // App Title
                  Text(
                    'Sundaram DSR',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Van Sales & Distribution System',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Connection Error Box or Loading Indicator
                  if (_hasConnectionError) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.roseDanger.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.roseDanger),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wifi_off_rounded, color: AppColors.roseDanger, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Connection Problem',
                                style: TextStyle(
                                  color: AppColors.roseDanger,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Unable to connect to server at ${ApiRoutes.baseUrl}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _initializeAndCheckHealth,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('RETRY'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryOrange,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => widget.onInitializationComplete(false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.cyanAccent,
                                    side: const BorderSide(color: AppColors.cyanAccent),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('PROCEED OFFLINE', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: LoadingAnimationWidget.fallingDot(
                        color: AppColors.primaryOrange,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'Version 1.0.0 • Sundaram Multi-Brand',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: (isDark ? AppColors.darkTextSub : AppColors.lightTextSub).withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
