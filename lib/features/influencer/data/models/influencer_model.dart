import 'package:influcollb_app/features/influencer/domain/entities/influencer_entity.dart';

class InfluencerModel extends InfluencerEntity {
  const InfluencerModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.profilePicture,
    super.bio,
    super.niche,
    super.followersCount,
    super.engagementRate,
    super.platforms,
    super.socialLinks,
    super.isVerified,
  });

  factory InfluencerModel.fromJson(Map<String, dynamic> json) {
    return InfluencerModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
      bio: json['bio'],
      niche: json['niche'],
      followersCount: json['followersCount'],
      engagementRate: json['engagementRate']?.toDouble(),
      platforms: json['platforms'] != null
          ? List<String>.from(json['platforms'])
          : null,
      socialLinks: json['socialLinks'],
      isVerified: json['isVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'profilePicture': profilePicture,
      'bio': bio,
      'niche': niche,
      'followersCount': followersCount,
      'engagementRate': engagementRate,
      'platforms': platforms,
      'socialLinks': socialLinks,
      'isVerified': isVerified,
    };
  }
}
