import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../resources/api_routes.dart';

class DioClient {
  late final Dio _dio;
  static String? _authToken;
  static bool _tokenLoaded = false;
  static int _sessionVersion = 0;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiRoutes.baseUrl,
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 25),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!_tokenLoaded) {
            final prefs = await SharedPreferences.getInstance();
            // A login/logout during preference loading takes precedence.
            if (!_tokenLoaded) {
              _authToken = prefs.getString('auth_token');
              _tokenLoaded = true;
            }
          }
          final uri = Uri.tryParse(ApiRoutes.baseUrl);
          if (uri == null ||
              !uri.hasAuthority ||
              (uri.scheme != 'http' && uri.scheme != 'https') ||
              (const bool.fromEnvironment('dart.vm.product') &&
                  uri.scheme != 'https')) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error:
                    'A valid HTTPS server address is required for release builds.',
              ),
            );
          }
          options.extra['sessionVersion'] = _sessionVersion;
          options.headers.remove('Authorization');
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.requestOptions.extra['sessionVersion'] !=
              _sessionVersion) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                type: DioExceptionType.cancel,
                error: 'Session changed while the request was running.',
              ),
            );
          }
          handler.next(response);
        },
        onError: (DioException error, handler) {
          // Handle global errors here (e.g., 401 unauthorized, 500 server error)
          return handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    if (_authToken != token) _sessionVersion++;
    _authToken = token;
    _tokenLoaded = true;
  }

  void clearAuthToken() {
    _sessionVersion++;
    _authToken = null;
    _tokenLoaded = true;
  }

  Dio get dio => _dio;

  // GET Method
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  // POST Method
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  // PUT Method
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  // DELETE Method
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }
}
