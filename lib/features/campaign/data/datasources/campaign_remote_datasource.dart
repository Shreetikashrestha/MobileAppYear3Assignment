import 'package:dio/dio.dart';
import 'package:influcollb_app/features/campaign/data/models/campaign_model.dart';

abstract class ICampaignRemoteDataSource {
  Future<List<Campaign>> getAllCampaigns();
  Future<Campaign> getCampaignById(String id);
  Future<List<Campaign>> getMyBrandCampaigns();
  Future<Campaign> createCampaign(Map<String, dynamic> campaignData);
  Future<Campaign> updateCampaign(String id, Map<String, dynamic> campaignData);
  Future<bool> deleteCampaign(String id);
  Future<Map<String, dynamic>> getBrandStats();
}

class CampaignRemoteDataSource implements ICampaignRemoteDataSource {
  final Dio apiClient;

  CampaignRemoteDataSource({required this.apiClient});

  @override
  Future<List<Campaign>> getAllCampaigns() async {
    try {
      final response = await apiClient.get('/api/campaigns');
      
      if (response.statusCode == 200) {
        final data = response.data;
        // Backend returns 'campaigns' field, not 'data'
        final campaigns = data['campaigns'] ?? data['data'] ?? [];
        return (campaigns as List).map((json) => Campaign.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch campaigns');
    } catch (e) {
      throw Exception('Failed to fetch campaigns: $e');
    }
  }

  @override
  Future<Campaign> getCampaignById(String id) async {
    try {
      final response = await apiClient.get('/api/campaigns/$id');
      
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data['campaign'];
        return Campaign.fromJson(data);
      }
      throw Exception('Failed to fetch campaign details');
    } catch (e) {
      throw Exception('Failed to fetch campaign details: $e');
    }
  }

  @override
  Future<List<Campaign>> getMyBrandCampaigns() async {
    try {
      final response = await apiClient.get('/api/campaigns/my');
      
      if (response.statusCode == 200) {
        final data = response.data;
        // Backend returns 'campaigns' field, not 'data'
        final campaigns = data['campaigns'] ?? data['data'] ?? [];
        return (campaigns as List).map((json) => Campaign.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch brand campaigns');
    } catch (e) {
      throw Exception('Failed to fetch brand campaigns: $e');
    }
  }

  @override
  Future<Campaign> createCampaign(Map<String, dynamic> campaignData) async {
    try {
      final response = await apiClient.post('/api/campaigns', data: campaignData);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data['data'] ?? response.data['campaign'];
        return Campaign.fromJson(data);
      }
      throw Exception('Failed to create campaign');
    } catch (e) {
      throw Exception('Failed to create campaign: $e');
    }
  }

  @override
  Future<Campaign> updateCampaign(String id, Map<String, dynamic> campaignData) async {
    try {
      final response = await apiClient.patch('/api/campaigns/$id', data: campaignData);
      
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data['campaign'];
        return Campaign.fromJson(data);
      }
      throw Exception('Failed to update campaign');
    } catch (e) {
      throw Exception('Failed to update campaign: $e');
    }
  }

  @override
  Future<bool> deleteCampaign(String id) async {
    try {
      final response = await apiClient.delete('/api/campaigns/$id');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw Exception('Failed to delete campaign');
    } catch (e) {
      throw Exception('Failed to delete campaign: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getBrandStats() async {
    try {
      final response = await apiClient.get('/api/campaigns/brand-stats');
      
      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw Exception('Failed to fetch brand stats');
    } catch (e) {
      throw Exception('Failed to fetch brand stats: $e');
    }
  }
}
