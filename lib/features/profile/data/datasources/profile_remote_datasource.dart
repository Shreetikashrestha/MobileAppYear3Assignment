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
    final response = await _apiClient.get('/api/profiles/me');
    
    // Backend returns { success: true, profile: {...}, user: {...} }
    // Merge both user and profile data
    if (response.statusCode == 200 && response.data['success'] == true) {
      final userData = response.data['user'] as Map<String, dynamic>? ?? {};
      final profileData = response.data['profile'] as Map<String, dynamic>? ?? {};
      
      // Combine both for complete profile
      final completeProfile = {
        ...userData,
        ...profileData,
      };
      
      return ProfileApiModel.fromJson(completeProfile);
    }
    throw Exception('Failed to fetch profile');
  }

  @override
  Future<ProfileApiModel> updateProfile(ProfileApiModel profile) async {
    try {
      // Convert socialChannels to socialAccounts format expected by backend
      List<Map<String, dynamic>>? socialAccounts;
      if (profile.socialChannels != null && profile.socialChannels!.isNotEmpty) {
        socialAccounts = [];
        
        // Map platform handles to socialAccounts
        final platforms = ['instagram', 'tiktok', 'facebook', 'youtube', 'twitter', 'twitch'];
        for (final platform in platforms) {
          final handle = profile.socialChannels![platform];
          final followersKey = '${platform}Followers';
          final followers = profile.socialChannels![followersKey];
          
          if (handle != null && handle.toString().isNotEmpty) {
            socialAccounts.add({
              'platform': platform,
              'handle': handle.toString(),
              'followers': followers != null ? int.tryParse(followers.toString()) ?? 0 : 0,
              'isPrimary': platform == 'instagram',
            });
          }
        }
      }

      // Prepare extended profile data for /api/profiles/update
      final updateData = {
        'bio': profile.bio,
        'categories': profile.contentCategories,
        'languages': profile.language != null ? [profile.language] : [],
        'socialAccounts': socialAccounts ?? [],
      };

      // Remove null/empty values
      updateData.removeWhere((key, value) => value == null || (value is List && value.isEmpty));

      // Update extended profile via /api/profiles/update (PATCH)
      final response = await _apiClient.patch(
        '/api/profiles/update',
        data: updateData,
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        // Return the updated profile
        return ProfileApiModel.fromJson(response.data['profile']);
      }
      throw Exception('Failed to update profile');
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
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

    // Use PUT /api/users/update endpoint for profile picture upload
    final response = await _apiClient.put(
      '/api/users/update',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    // Backend returns { success: true, data: { ...updatedUser }, message: "..." }
    // The profilePicture is in the data object
    if (response.data['success'] == true && response.data['data'] != null) {
      final profilePicture = response.data['data']['profilePicture'];
      if (profilePicture != null && profilePicture.toString().isNotEmpty) {
        return profilePicture.toString();
      }
    }
    return '';
  }
}
