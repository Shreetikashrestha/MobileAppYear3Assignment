import 'package:dio/dio.dart';
import 'package:influcollb_app/core/api/api_client.dart';
import 'package:influcollb_app/core/api/api_endpoints.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';

abstract class IApplicationRemoteDataSource {
  Future<ApplicationModel> submitApplication(ApplicationModel application);
  Future<List<ApplicationModel>> getMyApplications();
  Future<List<ApplicationModel>> getCampaignApplications(String campaignId);
  Future<ApplicationModel> getApplicationById(String id);
  Future<ApplicationModel> updateApplicationStatus(String id, String status);
}

class ApplicationRemoteDataSource implements IApplicationRemoteDataSource {
  final ApiClient _apiClient;

  ApplicationRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<ApplicationModel> submitApplication(
      ApplicationModel application) async {
    try {
      print('📤 Submitting application to: ${ApiEndpoints.applications}');
      print('📤 Application data: ${application.toJson()}');
      
      final response = await _apiClient.post(
        ApiEndpoints.applications,
        data: application.toJson(),
      );

      print('📤 Response status: ${response.statusCode}');
      print('📤 Response data: ${response.data}');

      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        print('✅ Application submitted: ${data['_id']}');
        return ApplicationModel.fromJson(data);
      }
      print('❌ Unexpected response: ${response.statusCode}');
      throw Exception('Failed to submit application');
    } catch (e, stackTrace) {
      print('❌ Error submitting application: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ApplicationModel>> getMyApplications() async {
    try {
      print('📋 Fetching my applications from: ${ApiEndpoints.myApplications}');
      final response = await _apiClient.get(
        ApiEndpoints.myApplications,
      );

      print('📋 Response status: ${response.statusCode}');
      print('📋 Response success: ${response.data['success']}');
      print('📋 Response data type: ${response.data.runtimeType}');
      print('📋 Full response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        print('📋 Data type: ${data.runtimeType}');
        print('📋 Data: $data');
        
        if (data is List) {
          print('📋 Found ${data.length} applications');
          final applications = data.map((json) {
            print('📋 Parsing application: $json');
            return ApplicationModel.fromJson(json);
          }).toList();
          print('📋 Parsed applications: ${applications.map((a) => a.id).toList()}');
          return applications;
        } else {
          print('❌ Data is not a list: ${data.runtimeType}');
          return [];
        }
      }
      print('📋 No applications found or success is false');
      return [];
    } catch (e, stackTrace) {
      print('❌ Error fetching applications: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ApplicationModel>> getCampaignApplications(
      String campaignId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.campaignApplications(campaignId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((json) => ApplicationModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ApplicationModel> getApplicationById(String id) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.applicationById(id),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ApplicationModel.fromJson(data);
      }
      throw Exception('Application not found');
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ApplicationModel> updateApplicationStatus(
      String id, String status) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.updateApplicationStatus(id),
        data: {'status': status},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ApplicationModel.fromJson(data);
      }
      throw Exception('Failed to update application status');
    } on DioException {
      rethrow;
    }
  }
}
