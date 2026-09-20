import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '0771234567');
  final _pinController = TextEditingController(text: '1234');
  bool _isLoading = false;
  bool _rememberMe = true;
  final AuthProvider _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPhone = prefs.getString('remembered_phone');
      final savedPassword = prefs.getString('remembered_password');
      final rememberMe = prefs.getBool('remember_me_enabled') ?? true;

      if (mounted) {
        setState(() {
          _rememberMe = rememberMe;
          if (rememberMe) {
            if (savedPhone != null && savedPhone.isNotEmpty) {
              _phoneController.text = savedPhone;
            }
            if (savedPassword != null && savedPassword.isNotEmpty) {
              _pinController.text = savedPassword;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading remembered credentials: $e');
    }
  }

  Future<void> _saveOrClearCredentials(String phone, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me_enabled', _rememberMe);
      if (_rememberMe) {
        await prefs.setString('remembered_phone', phone);
        await prefs.setString('remembered_password', password);
      } else {
        await prefs.remove('remembered_phone');
        await prefs.remove('remembered_password');
      }
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    final phone = _phoneController.text.trim();
    final password = _pinController.text.trim();

    try {
      await _authProvider.login(phone, password);
      await _saveOrClearCredentials(phone, password);
      if (mounted) {
        widget.onLoginSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.roseDanger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo Header
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryOrange, width: 2),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: AppColors.primaryOrange,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'SUNDARAM DIRECT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'DSR Field Sales Mobile Handheld App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                ),
              ),
              const SizedBox(height: 40),

              // Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rep Log In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Mobile Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_android, color: AppColors.primaryOrange),
                        hintText: 'Enter phone number',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primaryOrange),
                        hintText: 'Enter password',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.primaryOrange,
                          onChanged: (val) => setState(() => _rememberMe = val ?? true),
                        ),
                        const Text('Remember phone & password', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: LoadingAnimationWidget.fallingDot(
                                  color: AppColors.primaryOrange,
                                  size: 48,
                                ),
                              )
                            : const Text('START DSR DAY TRIP'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Hutch Telecom DSD System v2.4.0',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
