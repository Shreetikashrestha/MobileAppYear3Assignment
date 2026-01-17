import 'package:dio/dio.dart';
import 'package:influcollb_app/core/api/api_client.dart';
import 'package:influcollb_app/core/api/api_endpoints.dart';
import 'package:influcollb_app/core/services/storage/user_session_service.dart';
import 'package:influcollb_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.studentLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        final user = AuthApiModel.fromJson(userData);

        // Save user session with token
        await _userSessionService.saveUserSession(
          userId: user.id ?? '',
          email: user.email,
          fullName: user.fullName,
          username: user.username,
          profilePicture: user.profilePicture,
          token: token,
        );

        return user;
      }
      return null;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.studentRegister,
        data: user.toJson(),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        final registeredUser = AuthApiModel.fromJson(userData);

        // Save user session after registration with token
        await _userSessionService.saveUserSession(
          userId: registeredUser.id ?? '',
          email: registeredUser.email,
          fullName: registeredUser.fullName,
          username: registeredUser.username,
          profilePicture: registeredUser.profilePicture,
          token: token,
        );

        return registeredUser;
      }
      throw Exception('Failed to register user');
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.studentProfile,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return AuthApiModel.fromJson(data);
      }
      return null;
    } on DioException {
      rethrow;
    }
  }
}
