import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:influcollb_app/core/services/storage/user_session_service.dart';
import 'package:influcollb_app/core/services/storage/token_service.dart';
import 'package:influcollb_app/core/services/connectivity/network_info.dart';

class ApiClient {
  final Dio _dio;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;
  final INetworkInfo _networkInfo;

  ApiClient({
    required Dio dio,
    required UserSessionService userSessionService,
    required TokenService tokenService,
    required INetworkInfo networkInfo,
  })  : _dio = dio,
        _userSessionService = userSessionService,
        _tokenService = tokenService,
        _networkInfo = networkInfo {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['Content-Type'] = 'application/json';
          // Add Authorization header if token exists and not for login/register
          final token = await _tokenService.getToken();
          final isAuthRoute = options.path.contains('/auth/login') ||
              options.path.contains('/auth/register');

          debugPrint('ApiClient Request: ${options.method} ${options.path}');
          debugPrint(
              'ApiClient Token found: ${token != null && token.isNotEmpty}');

          if (token != null && token.isNotEmpty && !isAuthRoute) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('ApiClient added Authorization header');
          } else {
            debugPrint(
                'ApiClient NOT adding Authorization header. Reason: ${token == null ? 'Token is null' : token.isEmpty ? 'Token is empty' : 'Auth route'}');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401/403 Unauthorized/Forbidden
          if (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403) {
            await _userSessionService.clearSession();
            await _tokenService.removeToken();
            // Optionally: trigger logout UI or redirect
          }
          return handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
