import 'package:equatable/equatable.dart';

class InfluencerEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? profilePicture;
  final String? bio;
  final String? niche;
  final int? followersCount;
  final double? engagementRate;
  final List<String>? platforms;
  final Map<String, dynamic>? socialLinks;
  final bool? isVerified;

  const InfluencerEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.profilePicture,
    this.bio,
    this.niche,
    this.followersCount,
    this.engagementRate,
    this.platforms,
    this.socialLinks,
    this.isVerified,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        profilePicture,
        bio,
        niche,
        followersCount,
        engagementRate,
        platforms,
        socialLinks,
        isVerified,
      ];
}
