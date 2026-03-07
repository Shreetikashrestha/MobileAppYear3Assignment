import 'package:dio/dio.dart';
import 'package:influcollb_app/features/analytics/data/models/analytics_model.dart';

abstract class IAnalyticsRemoteDataSource {
  Future<AnalyticsModel> getAnalytics();
}

class AnalyticsRemoteDataSource implements IAnalyticsRemoteDataSource {
  final Dio apiClient;

  AnalyticsRemoteDataSource({required this.apiClient});

  @override
  Future<AnalyticsModel> getAnalytics() async {
    try {
      final response = await apiClient.get('/api/analytics/dashboard');
      
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return AnalyticsModel.fromJson(data);
      }
      
      throw Exception('Failed to load analytics');
    } catch (e) {
      throw Exception('Error fetching analytics: $e');
    }
  }
}
