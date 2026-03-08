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
      print('🔍 [InfluencerDataSource] Fetching influencers from /api/profiles/influencers');
      final response = await apiClient.get('/api/profiles/influencers');

      print('📊 [InfluencerDataSource] Response status: ${response.statusCode}');
      print('📊 [InfluencerDataSource] Response data type: ${response.data.runtimeType}');
      print('📊 [InfluencerDataSource] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> influencers =
            data['data'] ?? data['influencers'] ?? [];

        print('📊 [InfluencerDataSource] Found ${influencers.length} influencers in response');
        
        if (influencers.isEmpty) {
          print('⚠️ [InfluencerDataSource] No influencers found in database');
          return [];
        }

        print('📊 [InfluencerDataSource] First influencer data: ${influencers.isNotEmpty ? influencers[0] : "none"}');

        // Backend returns profiles with populated userId
        final parsedInfluencers = influencers
            .map<InfluencerModel?>((profileData) {
              try {
                print('🔄 [InfluencerDataSource] Parsing influencer profile');
                print('🔄 [InfluencerDataSource] Profile _id: ${profileData['_id']}');
                
                final user = profileData['userId'];
                if (user == null) {
                  print('❌ [InfluencerDataSource] userId is null for profile: ${profileData['_id']}');
                  return null;
                }

                print('✅ [InfluencerDataSource] User _id: ${user['_id']}');
                print('✅ [InfluencerDataSource] User fullName: ${user['fullName']}');
                print('✅ [InfluencerDataSource] Profile bio: ${profileData['bio']}');

                // IMPORTANT: Use user._id as the ID, NOT profile._id
                // The profile._id is the MongoDB ID of the profile document
                // The user._id is what we need to fetch the profile later
                final mergedData = <String, dynamic>{
                  'id': user['_id'],  // Use USER ID, not profile ID
                  '_id': user['_id'], // Ensure both id and _id are set to user ID
                  'fullName': user['fullName'],
                  'email': user['email'],
                  'profilePicture': user['profilePicture'],
                  'bio': profileData['bio'],
                  'isVerified': profileData['isVerified'],
                };

                print('📦 [InfluencerDataSource] Merged data ID: ${mergedData['id']}');
                print('📦 [InfluencerDataSource] Merged data _id: ${mergedData['_id']}');

                // Add niche if available
                if (profileData['niches'] != null && (profileData['niches'] as List).isNotEmpty) {
                  mergedData['niche'] = profileData['niches'][0];
                  print('✅ [InfluencerDataSource] Added niche: ${mergedData['niche']}');
                }

                // Add social account data if available
                if (profileData['socialAccounts'] != null && (profileData['socialAccounts'] as List).isNotEmpty) {
                  final socialAccounts = profileData['socialAccounts'] as List;
                  print('📱 [InfluencerDataSource] Processing ${socialAccounts.length} social accounts');
                  
                  mergedData['followersCount'] = socialAccounts[0]['followers'];
                  mergedData['engagementRate'] = socialAccounts[0]['engagementRate'];

                  print('✅ [InfluencerDataSource] Followers: ${mergedData['followersCount']}');
                  print('✅ [InfluencerDataSource] Engagement: ${mergedData['engagementRate']}');

                  // Extract platforms
                  mergedData['platforms'] = socialAccounts.map((acc) => acc['platform'] as String).toList();

                  // Create socialLinks map
                  final socialLinks = <String, dynamic>{};
                  for (var acc in socialAccounts) {
                    socialLinks[acc['platform']] = acc['handle'];
                  }
                  mergedData['socialLinks'] = socialLinks;
                  
                  print('✅ [InfluencerDataSource] Platforms: ${mergedData['platforms']}');
                }

                print('📦 [InfluencerDataSource] Final merged data: $mergedData');

                final model = InfluencerModel.fromJson(mergedData);
                print('✅ [InfluencerDataSource] Successfully parsed: ${model.fullName}');
                print('✅ [InfluencerDataSource] Model details - Bio: ${model.bio}, Niche: ${model.niche}, Followers: ${model.followersCount}');
                return model;
              } catch (e, stackTrace) {
                print('❌ [InfluencerDataSource] Error parsing influencer: $e');
                print('❌ [InfluencerDataSource] Stack trace: $stackTrace');
                print('❌ [InfluencerDataSource] Profile data: $profileData');
                return null;
              }
            })
            .whereType<InfluencerModel>()
            .toList();

        print('✅ [InfluencerDataSource] Successfully parsed ${parsedInfluencers.length} influencers');
        return parsedInfluencers;
      } else {
        print('❌ [InfluencerDataSource] Failed with status: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch influencers',
        );
      }
    } catch (e, stackTrace) {
      print('❌ [InfluencerDataSource] Exception: $e');
      print('❌ [InfluencerDataSource] Stack trace: $stackTrace');
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

                // IMPORTANT: Use user._id as the ID, NOT profile._id
                final mergedData = <String, dynamic>{
                  'id': user['_id'],  // Use USER ID, not profile ID
                  '_id': user['_id'], // Ensure both id and _id are set to user ID
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
      print('🔍 [InfluencerDataSource] Fetching profile for user ID: $id');
      final response = await apiClient.get('/api/profiles/$id');

      print('📊 [InfluencerDataSource] Profile response status: ${response.statusCode}');
      print('📊 [InfluencerDataSource] Profile response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        // Backend returns both 'user' and 'profile' objects
        final user = data['user'];
        final profile = data['profile'] as Map<String, dynamic>?;

        if (user == null) {
          print('❌ [InfluencerDataSource] User data not found in response');
          throw Exception('User data not found in response');
        }

        print('✅ [InfluencerDataSource] User data: $user');
        print('✅ [InfluencerDataSource] Profile data: $profile');

        // Merge user and profile data for the model
        final Map<String, dynamic> mergedData = {
          'id': user['_id'],
          '_id': user['_id'],
          'fullName': user['fullName'] ?? 'Unknown User',
          'email': user['email'] ?? '',
          'profilePicture': user['profilePicture'],
          'isInfluencer': user['isInfluencer'] ?? true,
        };

        // Add profile data if available
        if (profile != null) {
          mergedData['bio'] = profile['bio'];
          mergedData['isVerified'] = profile['isVerified'] ?? false;
          
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
        } else {
          print('⚠️ [InfluencerDataSource] Profile is null, using user data only');
        }

        print('📦 [InfluencerDataSource] Final merged profile data: $mergedData');

        return InfluencerModel.fromJson(mergedData);
      } else {
        print('❌ [InfluencerDataSource] Failed with status: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch influencer profile',
        );
      }
    } catch (e, stackTrace) {
      print('❌ [InfluencerDataSource] Exception in getInfluencerProfile: $e');
      print('❌ [InfluencerDataSource] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
