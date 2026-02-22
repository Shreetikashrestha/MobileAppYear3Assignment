import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/profile_api_model.dart';

abstract class IProfileRemoteDataSource {
  Future<ProfileApiModel> getProfile(String userId);
  Future<ProfileApiModel> updateProfile(ProfileApiModel profile);
  Future<String> uploadProfilePicture(File file);
}

class ProfileRemoteDataSource implements IProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ProfileApiModel> getProfile(String userId) async {
    final response = await _apiClient.get('/admin/users/$userId');
    return ProfileApiModel.fromJson(response.data['data']);
  }

  @override
  Future<ProfileApiModel> updateProfile(ProfileApiModel profile) async {
    final response = await _apiClient.put(
      '/users/${profile.userId}',
      data: profile.toJson(),
    );
    return ProfileApiModel.fromJson(response.data['data']);
  }

  @override
  Future<String> uploadProfilePicture(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      'profilePicture': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _apiClient.post(
      '/users/upload-profile',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    return response.data['data']['profilePicture'] ?? '';
  }
}
