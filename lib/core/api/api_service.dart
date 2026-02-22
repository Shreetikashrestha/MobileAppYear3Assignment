import 'package:dio/dio.dart';
import 'package:influcollb_app/core/api/api_client.dart';
import 'package:influcollb_app/core/api/api_endpoints.dart';

class ApiService {
  final ApiClient _apiClient;

  ApiService(this._apiClient);

  Future<List<Map<String, dynamic>>> getCampaigns({String? status}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.campaigns,
        queryParameters: status != null ? {'status': status} : null,
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load campaigns: ${e.toString()}');
    }
  }

  Future<void> applyToCampaign({
    required String campaignId,
    required String token,
    String? message,
  }) async {
    try {
      final url = '${ApiEndpoints.campaigns}/$campaignId/join';
      await _apiClient.post(
        url,
        data: {'message': message},
      );
    } catch (e) {
      throw Exception('Failed to apply to campaign: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getSavedCampaigns(String token) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.campaigns}/saved');
       if (response.statusCode == 200 && response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      // If endpoint doesn't exist, return empty list for now to prevent crash
      print('Error getting saved campaigns: $e');
      return [];
    }
  }

  Future<void> toggleFavorite({required String campaignId, required String token}) async {
     try {
       await _apiClient.post('${ApiEndpoints.campaigns}/$campaignId/save');
     } catch (e) {
       throw Exception('Failed to toggle favorite');
     }
  }

  Future<Map<String, dynamic>> getUserProfile({required String userId}) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
       if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
       throw Exception('Failed to fetch user profile');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
          return {};
      }
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? bio,
    String? gender,
    String? dateOfBirth,
    String? ethnicity,
    String? language,
    Map<String, dynamic>? socialChannels,
    List<String>? contentCategories,
  }) async {
    try {
      final data = {
        'bio': bio,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'ethnicity': ethnicity,
        'language': language,
        'socialChannels': socialChannels,
        'contentCategories': contentCategories,
      };
      
      // Remove null values
      data.removeWhere((key, value) => value == null);

      await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Get applications submitted by the logged-in influencer
  Future<List<Map<String, dynamic>>> getMyApplications({String? status}) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.baseUrl}/applications/my',
        queryParameters: status != null ? {'status': status} : null,
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting my applications: $e');
      return [];
    }
  }

  // Get applications for a specific campaign (Brand only)
  Future<List<Map<String, dynamic>>> getCampaignApplications({
    required String campaignId,
    String? status,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.baseUrl}/applications/campaign/$campaignId',
        queryParameters: status != null ? {'status': status} : null,
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting campaign applications: $e');
      throw Exception('Failed to load campaign applications: ${e.toString()}');
    }
  }

  // Update application status (Brand accepts/rejects)
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status, // 'accepted' or 'rejected'
  }) async {
    try {
      await _apiClient.patch(
        '${ApiEndpoints.baseUrl}/applications/$applicationId/status',
        data: {'status': status},
      );
    } catch (e) {
      throw Exception('Failed to update application status: ${e.toString()}');
    }
  }

  // Get campaigns created by the logged-in brand
  Future<List<Map<String, dynamic>>> getMyCampaigns() async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.campaigns}/my');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting my campaigns: $e');
      return [];
    }
  }
  // Get all influencers
  Future<List<Map<String, dynamic>>> getInfluencers({String? search}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getInfluencers,
        queryParameters: search != null ? {'search': search} : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting influencers: $e');
      return [];
    }
  }

  // Create a new campaign (Brand only)
  Future<void> createCampaign({
    required Map<String, dynamic> data,
  }) async {
    try {
      await _apiClient.post(
        ApiEndpoints.campaigns,
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to create campaign: ${e.toString()}');
    }
  }

  // Update an existing campaign (Brand only)
  Future<void> updateCampaign({
    required String campaignId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _apiClient.put(
        '${ApiEndpoints.campaigns}/$campaignId',
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to update campaign: ${e.toString()}');
    }
  }
}
