import 'package:dio/dio.dart';

/// Instagram Graph API Service
/// Requires Instagram Business Account and Facebook App
class InstagramService {
  final Dio _dio = Dio();
  
  // Instagram Graph API base URL
  static const String _baseUrl = 'https://graph.instagram.com';
  
  // User needs to get their own access token from Facebook Developer Console
  String? _accessToken;

  /// Set access token
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// Get Instagram user profile
  Future<InstagramProfile?> getUserProfile(String userId) async {
    if (_accessToken == null) {
      throw Exception('Access token not set');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/$userId',
        queryParameters: {
          'fields': 'id,username,account_type,media_count,followers_count,follows_count',
          'access_token': _accessToken,
        },
      );

      if (response.statusCode == 200) {
        return InstagramProfile.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching Instagram profile: $e');
      return null;
    }
  }

  /// Get user's media (posts)
  Future<List<InstagramMedia>> getUserMedia(String userId, {int limit = 10}) async {
    if (_accessToken == null) {
      throw Exception('Access token not set');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/$userId/media',
        queryParameters: {
          'fields': 'id,caption,media_type,media_url,thumbnail_url,permalink,timestamp,like_count,comments_count',
          'limit': limit,
          'access_token': _accessToken,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => InstagramMedia.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching Instagram media: $e');
      return [];
    }
  }

  /// Get media insights (engagement)
  Future<InstagramInsights?> getMediaInsights(String mediaId) async {
    if (_accessToken == null) {
      throw Exception('Access token not set');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/$mediaId/insights',
        queryParameters: {
          'metric': 'engagement,impressions,reach,saved',
          'access_token': _accessToken,
        },
      );

      if (response.statusCode == 200) {
        return InstagramInsights.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching media insights: $e');
      return null;
    }
  }

  /// Calculate engagement rate
  double calculateEngagementRate({
    required int likes,
    required int comments,
    required int followers,
  }) {
    if (followers == 0) return 0.0;
    final engagement = likes + comments;
    return (engagement / followers) * 100;
  }

  /// Verify influencer authenticity
  Future<InfluencerVerification> verifyInfluencer(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      if (profile == null) {
        return InfluencerVerification(
          isVerified: false,
          reason: 'Could not fetch profile',
        );
      }

      final media = await getUserMedia(userId, limit: 20);
      if (media.isEmpty) {
        return InfluencerVerification(
          isVerified: false,
          reason: 'No posts found',
        );
      }

      // Calculate average engagement
      int totalLikes = 0;
      int totalComments = 0;
      for (final post in media) {
        totalLikes += post.likeCount;
        totalComments += post.commentsCount;
      }

      final avgEngagement = calculateEngagementRate(
        likes: totalLikes ~/ media.length,
        comments: totalComments ~/ media.length,
        followers: profile.followersCount,
      );

      // Verification criteria
      final hasEnoughFollowers = profile.followersCount >= 1000;
      final hasGoodEngagement = avgEngagement >= 1.0; // At least 1%
      final hasRecentPosts = media.length >= 10;

      final isVerified = hasEnoughFollowers && hasGoodEngagement && hasRecentPosts;

      return InfluencerVerification(
        isVerified: isVerified,
        followersCount: profile.followersCount,
        engagementRate: avgEngagement,
        postsCount: media.length,
        reason: isVerified ? 'Verified' : 'Does not meet criteria',
      );
    } catch (e) {
      return InfluencerVerification(
        isVerified: false,
        reason: 'Error: ${e.toString()}',
      );
    }
  }
}

/// Instagram Profile Model
class InstagramProfile {
  final String id;
  final String username;
  final String accountType;
  final int mediaCount;
  final int followersCount;
  final int followsCount;

  InstagramProfile({
    required this.id,
    required this.username,
    required this.accountType,
    required this.mediaCount,
    required this.followersCount,
    required this.followsCount,
  });

  factory InstagramProfile.fromJson(Map<String, dynamic> json) {
    return InstagramProfile(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      accountType: json['account_type'] ?? 'PERSONAL',
      mediaCount: json['media_count'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      followsCount: json['follows_count'] ?? 0,
    );
  }

  String get followersDisplay {
    if (followersCount >= 1000000) {
      return '${(followersCount / 1000000).toStringAsFixed(1)}M';
    } else if (followersCount >= 1000) {
      return '${(followersCount / 1000).toStringAsFixed(1)}K';
    }
    return followersCount.toString();
  }
}

/// Instagram Media Model
class InstagramMedia {
  final String id;
  final String? caption;
  final String mediaType;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String permalink;
  final DateTime timestamp;
  final int likeCount;
  final int commentsCount;

  InstagramMedia({
    required this.id,
    this.caption,
    required this.mediaType,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.permalink,
    required this.timestamp,
    required this.likeCount,
    required this.commentsCount,
  });

  factory InstagramMedia.fromJson(Map<String, dynamic> json) {
    return InstagramMedia(
      id: json['id'] ?? '',
      caption: json['caption'],
      mediaType: json['media_type'] ?? 'IMAGE',
      mediaUrl: json['media_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      permalink: json['permalink'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      likeCount: json['like_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
    );
  }
}

/// Instagram Insights Model
class InstagramInsights {
  final int engagement;
  final int impressions;
  final int reach;
  final int saved;

  InstagramInsights({
    required this.engagement,
    required this.impressions,
    required this.reach,
    required this.saved,
  });

  factory InstagramInsights.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] ?? [];
    
    int engagement = 0;
    int impressions = 0;
    int reach = 0;
    int saved = 0;

    for (final metric in data) {
      final name = metric['name'];
      final value = metric['values'][0]['value'];
      
      switch (name) {
        case 'engagement':
          engagement = value;
          break;
        case 'impressions':
          impressions = value;
          break;
        case 'reach':
          reach = value;
          break;
        case 'saved':
          saved = value;
          break;
      }
    }

    return InstagramInsights(
      engagement: engagement,
      impressions: impressions,
      reach: reach,
      saved: saved,
    );
  }
}

/// Influencer Verification Result
class InfluencerVerification {
  final bool isVerified;
  final int? followersCount;
  final double? engagementRate;
  final int? postsCount;
  final String reason;

  InfluencerVerification({
    required this.isVerified,
    this.followersCount,
    this.engagementRate,
    this.postsCount,
    required this.reason,
  });
}
