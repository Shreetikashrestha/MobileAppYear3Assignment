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
      final response = await apiClient.get('/api/profiles/influencers');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> influencers =
            data['data'] ?? data['influencers'] ?? [];

        // Backend returns profiles with populated userId
        return influencers
            .map<InfluencerModel?>((profileData) {
              try {
                final user = profileData['userId'];
                if (user == null) return null;

                // Merge user and profile data
                final mergedData = <String, dynamic>{
                  'id': user['_id'],
                  'fullName': user['fullName'],
                  'email': user['email'],
                  'profilePicture': user['profilePicture'],
                  'bio': profileData['bio'],
                  'isVerified': profileData['isVerified'],
                };

                // Add niche if available
                if (profileData['niches'] != null && (profileData['niches'] as List).isNotEmpty) {
                  mergedData['niche'] = profileData['niches'][0];
                }

                // Add social account data if available
                if (profileData['socialAccounts'] != null && (profileData['socialAccounts'] as List).isNotEmpty) {
                  final socialAccounts = profileData['socialAccounts'] as List;
                  mergedData['followersCount'] = socialAccounts[0]['followers'];
                  mergedData['engagementRate'] = socialAccounts[0]['engagementRate'];

                  // Extract platforms
                  mergedData['platforms'] = socialAccounts.map((acc) => acc['platform'] as String).toList();

                  // Create socialLinks map
                  final socialLinks = <String, dynamic>{};
                  for (var acc in socialAccounts) {
                    socialLinks[acc['platform']] = acc['handle'];
                  }
                  mergedData['socialLinks'] = socialLinks;
                }

                return InfluencerModel.fromJson(mergedData);
              } catch (e) {
                print('Error parsing influencer: $e');
                return null;
              }
            })
            .whereType<InfluencerModel>()
            .toList();
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
      // Use the same endpoint with search query parameter
      final response = await apiClient.get(
        '/api/profiles/influencers',
        queryParameters: {'search': query},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> influencers =
            data['data'] ?? data['influencers'] ?? [];
        
        // Backend returns profiles with populated userId (same format as getInfluencers)
        return influencers
            .map<InfluencerModel?>((profileData) {
              try {
                final user = profileData['userId'];
                if (user == null) return null;

                // Merge user and profile data
                final mergedData = <String, dynamic>{
                  'id': user['_id'],
                  'fullName': user['fullName'],
                  'email': user['email'],
                  'profilePicture': user['profilePicture'],
                  'bio': profileData['bio'],
                  'isVerified': profileData['isVerified'],
                };

                // Add niche if available
                if (profileData['niches'] != null && (profileData['niches'] as List).isNotEmpty) {
                  mergedData['niche'] = profileData['niches'][0];
                }

                // Add social account data if available
                if (profileData['socialAccounts'] != null && (profileData['socialAccounts'] as List).isNotEmpty) {
                  final socialAccounts = profileData['socialAccounts'] as List;
                  mergedData['followersCount'] = socialAccounts[0]['followers'];
                  mergedData['engagementRate'] = socialAccounts[0]['engagementRate'];

                  // Extract platforms
                  mergedData['platforms'] = socialAccounts.map((acc) => acc['platform'] as String).toList();

                  // Create socialLinks map
                  final socialLinks = <String, dynamic>{};
                  for (var acc in socialAccounts) {
                    socialLinks[acc['platform']] = acc['handle'];
                  }
                  mergedData['socialLinks'] = socialLinks;
                }

                return InfluencerModel.fromJson(mergedData);
              } catch (e) {
                print('Error parsing influencer in search: $e');
                return null;
              }
            })
            .whereType<InfluencerModel>()
            .toList();
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
      final response = await apiClient.get('/api/profiles/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        // Backend returns both 'user' and 'profile' objects
        final user = data['user'];
        final profile = data['profile'] as Map<String, dynamic>?;

        if (user == null) {
          throw Exception('User data not found in response');
        }

        // Merge user and profile data for the model
        final Map<String, dynamic> mergedData = {
          'id': user['_id'],
          'fullName': user['fullName'],
          'email': user['email'],
          'profilePicture': user['profilePicture'],
          'isInfluencer': user['isInfluencer'],
        };

        // Add profile data if available
        if (profile != null) {
          mergedData['bio'] = profile['bio'];
          mergedData['isVerified'] = profile['isVerified'];
          
          // Add niche if available
          if (profile['niches'] != null && (profile['niches'] as List).isNotEmpty) {
            mergedData['niche'] = profile['niches'][0];
          }

          // Add social account data if available
          if (profile['socialAccounts'] != null && (profile['socialAccounts'] as List).isNotEmpty) {
            final socialAccounts = profile['socialAccounts'] as List;
            mergedData['followersCount'] = socialAccounts[0]['followers'];
            mergedData['engagementRate'] = socialAccounts[0]['engagementRate'];

            // Extract platforms
            mergedData['platforms'] = socialAccounts.map((acc) => acc['platform'] as String).toList();

            // Create socialLinks map
            final socialLinks = <String, dynamic>{};
            for (var acc in socialAccounts) {
              socialLinks[acc['platform']] = acc['handle'];
            }
            mergedData['socialLinks'] = socialLinks;
          }
        }

        return InfluencerModel.fromJson(mergedData);
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
