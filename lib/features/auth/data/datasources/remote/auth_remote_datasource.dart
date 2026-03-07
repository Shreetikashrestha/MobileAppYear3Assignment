import 'package:dio/dio.dart';
import 'package:influcollb_app/core/api/api_client.dart';
import 'package:influcollb_app/core/api/api_endpoints.dart';
import 'package:influcollb_app/core/services/storage/token_service.dart';
import 'package:influcollb_app/core/services/storage/user_session_service.dart';
import 'package:influcollb_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService,
        _tokenService = tokenService;

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final token = data['token'] as String? ?? '';
        final userData = data['user'] as Map<String, dynamic>;
        
        // Debug logging
        print('🔐 Login Response - User Data: $userData');
        print('🔐 User ID from response (_id): ${userData['_id']}');
        print('🔐 User ID from response (userId): ${userData['userId']}');
        print('🔐 User ID from response (id): ${userData['id']}');
        
        final user = AuthApiModel.fromJson(userData);
        
        print('🔐 Parsed User ID: ${user.id}');
        print('🔐 User Email: ${user.email}');
        print('🔐 User FullName: ${user.fullName}');
        print('🔐 Is Influencer: ${user.isInfluencer}');
        print('🔐 DEBUG - All userData keys: ${userData.keys.toList()}');
        print('🔐 DEBUG - userId value type: ${userData['userId'].runtimeType}');
        print('🔐 DEBUG - userId value: "${userData['userId']}"');

        // Save Auth Token
        await _tokenService.saveToken(token);

        // Ensure we have a valid user ID before saving - try all possible fields
        final userId = user.id ?? 
                       userData['userId'] as String? ?? 
                       userData['_id'] as String? ?? 
                       userData['id'] as String? ?? 
                       '';
        
        if (userId.isEmpty) {
          print('❌ ERROR: User ID is empty! Cannot save session.');
          print('❌ Available fields in userData: ${userData.keys.toList()}');
          throw Exception('User ID is missing from login response');
        }

        print('💾 Saving user session with ID: $userId');

        // Save user session with isInfluencer flag
        await _userSessionService.saveUserSession(
          userId: userId,
          email: user.email,
          fullName: user.fullName,
          profilePicture: user.profilePicture,
          isInfluencer: user.isInfluencer,
        );
        
        // Verify session was saved
        final savedUserId = _userSessionService.getCurrentUserId();
        print('✅ Verified saved user ID: $savedUserId');

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
        ApiEndpoints.register,
        data: user.toJson(),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final token = data['token'] as String? ?? '';
        final userData = data['user'] as Map<String, dynamic>;
        
        // Debug logging
        print('📝 Register Response - User Data: $userData');
        print('📝 User ID from response (_id): ${userData['_id']}');
        print('📝 User ID from response (userId): ${userData['userId']}');
        print('📝 User ID from response (id): ${userData['id']}');
        
        final registeredUser = AuthApiModel.fromJson(userData);
        
        print('📝 Parsed User ID: ${registeredUser.id}');

        // Save Auth Token
        await _tokenService.saveToken(token);

        // Ensure we have a valid user ID before saving - try all possible fields
        final userId = registeredUser.id ?? 
                       userData['userId'] as String? ?? 
                       userData['_id'] as String? ?? 
                       userData['id'] as String? ?? 
                       '';
        
        if (userId.isEmpty) {
          print('❌ ERROR: User ID is empty! Cannot save session.');
          print('❌ Available fields in userData: ${userData.keys.toList()}');
          throw Exception('User ID is missing from registration response');
        }

        print('💾 Saving user session with ID: $userId');

        // Save user session after registration with isInfluencer flag
        await _userSessionService.saveUserSession(
          userId: userId,
          email: registeredUser.email,
          fullName: registeredUser.fullName,
          profilePicture: registeredUser.profilePicture,
          isInfluencer: registeredUser.isInfluencer,
        );
        
        // Verify session was saved
        final savedUserId = _userSessionService.getCurrentUserId();
        print('✅ Verified saved user ID: $savedUserId');

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
        ApiEndpoints.profile,
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
