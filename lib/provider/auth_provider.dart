import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:kkp_rep_mobile_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kkp_rep_mobile_app/dio/dio_client.dart';
import 'package:kkp_rep_mobile_app/resources/api_routes.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  final DioClient _dioClient = DioClient();
  UserModel? _user;
  UserModel? get user => _user;

  bool get isLoggedIn => _isLoggedIn;

  Future<bool> checkSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        _dioClient.setAuthToken(token);

        try {
          final response = await _dioClient.get(ApiRoutes.checkTokenUrl);
          final data = response.data;
          
          if (response.statusCode == 200) {
            if (data is Map) {
              // If backend explicitly returns success: false or valid: false
              if (data['success'] == false || (data['data'] is Map && data['data']['valid'] == false)) {
                await logout();
                return false;
              } else {
                Map<String, dynamic>? userMap;
                if (data['data'] is Map && (data['data'] as Map).containsKey('user') && data['data']['user'] is Map) {
                  userMap = Map<String, dynamic>.from(data['data']['user']);
                } else if (data['user'] is Map) {
                  userMap = Map<String, dynamic>.from(data['user']);
                } else if (data['data'] is Map && (data['data'] as Map).containsKey('id')) {
                  userMap = Map<String, dynamic>.from(data['data']);
                }

                if (userMap != null) {
                  _user = UserModel.fromJson(userMap);
                  debugPrint('User data loaded from token: ${_user?.name}, ${_user?.email}');
                }
              }
            }

            _isLoggedIn = true;
            notifyListeners();
            return true;
          } else {
            await logout();
            return false;
          }
        } on DioException catch (e) {
          // If 401 Unauthorized, token is invalid/expired -> logout and go to login
          if (e.response?.statusCode == 401) {
            await logout();
            return false;
          }
          // If network is offline/unreachable, allow offline session cached token
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error checking saved token: $e');
    }
    return false;
  }

  Future<bool> login(String phone, String password) async {
    try {
      final response = await _dioClient.post(
        ApiRoutes.loginUrl,
        data: {
          "phone": phone,
          "password": password,
        },
      );

      final data = response.data;
      if (data is Map && data['success'] == false) {
        throw Exception(data['message'] ?? 'Invalid credentials');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        String? token;
        if (data is Map) {
          if (data.containsKey('token')) {
            token = data['token'].toString();
          } else if (data.containsKey('data') && data['data'] is Map && (data['data'] as Map).containsKey('token')) {
            token = data['data']['token'].toString();
          }

          Map<String, dynamic>? userMap;
          if (data['user'] is Map) {
            userMap = Map<String, dynamic>.from(data['user']);
          } else if (data['data'] is Map && (data['data'] as Map).containsKey('user') && data['data']['user'] is Map) {
            userMap = Map<String, dynamic>.from(data['data']['user']);
          } else if (data['data'] is Map && (data['data'] as Map).containsKey('id')) {
            userMap = Map<String, dynamic>.from(data['data']);
          }

          if (userMap != null) {
            _user = UserModel.fromJson(userMap);
          }
        }

        if (token != null && token.isNotEmpty) {
          _dioClient.setAuthToken(token);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }

        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        }
      }
      debugPrint('Login network unreachable: $e');
      throw Exception('Unable to connect to server. Please check your network.');
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> checkHealth() async {
    try {
      final response = await _dioClient.get(ApiRoutes.CHECKHEALTH);
      if (response.statusCode == 200) {
        debugPrint('Health check successful');
      } else {
        throw Exception('Failed to check health: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to check health: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _dioClient.post(ApiRoutes.logoutUrl);
    } catch (e) {
      debugPrint('Logout API error (proceeding with local cleanup): $e');
    } finally {
      _isLoggedIn = false;
      _user = null;
      _dioClient.clearAuthToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      notifyListeners();
    }
  }
}
