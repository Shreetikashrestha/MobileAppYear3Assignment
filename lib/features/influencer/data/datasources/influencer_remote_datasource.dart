import 'package:dio/dio.dart';
import 'package:influcollb_app/core/api/api_client.dart';
import 'package:influcollb_app/features/influencer/data/models/influencer_model.dart';

abstract class IInfluencerRemoteDataSource {
  Future<List<InfluencerModel>> getInfluencers();
  Future<List<InfluencerModel>> searchInfluencers(String query);
  Future<InfluencerModel> getInfluencerProfile(String id);
}

class InfluencerRemoteDataSource implements IInfluencerRemoteDataSource {
  final ApiClient apiClient;

  InfluencerRemoteDataSource({required this.apiClient});

  @override
  Future<List<InfluencerModel>> getInfluencers() async {
    try {
      final response = await apiClient.get('/users/influencers');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> influencers = data['data'] ?? data['influencers'] ?? [];
        return influencers.map((json) => InfluencerModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch influencers',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<InfluencerModel>> searchInfluencers(String query) async {
    try {
      final response = await apiClient.get(
        '/users/influencers/search',
        queryParameters: {'q': query},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> influencers = data['data'] ?? data['influencers'] ?? [];
        return influencers.map((json) => InfluencerModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to search influencers',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<InfluencerModel> getInfluencerProfile(String id) async {
    try {
      final response = await apiClient.get('/users/influencers/$id');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final influencer = data['data'] ?? data['influencer'];
        return InfluencerModel.fromJson(influencer);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch influencer profile',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
