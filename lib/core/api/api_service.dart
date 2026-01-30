import 'package:dio/dio.dart';
import 'package:influcollb_app/core/api/api_endpoints.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  /// Login user with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email, // Backend uses username field
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Login failed';
        throw Exception(message);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Register/Signup new user
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
    String? username,
    String? profilePicture,
    bool isInfluencer = false,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'username': username ??
              email.split('@')[0], // Auto-generate username from email
          'email': email,
          'password': password,
          'confirmPassword': password,
          'fullName': fullName,
          'profilePicture': profilePicture,
          'isInfluencer': isInfluencer,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Signup failed');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Signup failed';
        throw Exception(message);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get user profile by ID
  Future<Map<String, dynamic>> getUserProfile(
      String userId, String token) async {
    try {
      final response = await _dio.get(
        '/admin/users/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get profile');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Failed to get profile';
        throw Exception(message);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
