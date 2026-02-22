import '../../domain/entities/profile_entity.dart';

class ProfileApiModel {
  final String userId;
  final String fullName;
  final String? bio;
  final String? gender;
  final String? dateOfBirth;
  final String? ethnicity;
  final String? language;
  final Map<String, dynamic>? socialChannels;
  final List<String>? contentCategories;
  final String? profilePicture;
  final String? coverPhoto;

  ProfileApiModel({
    required this.userId,
    required this.fullName,
    this.bio,
    this.gender,
    this.dateOfBirth,
    this.ethnicity,
    this.language,
    this.socialChannels,
    this.contentCategories,
    this.profilePicture,
    this.coverPhoto,
  });

  factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileApiModel(
      userId: json['_id'] ?? json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      bio: json['bio'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      ethnicity: json['ethnicity'],
      language: json['language'],
      socialChannels: json['socialChannels'],
      contentCategories: (json['contentCategories'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      profilePicture: json['profilePicture'],
      coverPhoto: json['coverPhoto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'bio': bio,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'ethnicity': ethnicity,
      'language': language,
      'socialChannels': socialChannels,
      'contentCategories': contentCategories,
      'profilePicture': profilePicture,
      'coverPhoto': coverPhoto,
    };
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      userId: userId,
      fullName: fullName,
      bio: bio,
      gender: gender,
      dateOfBirth: dateOfBirth,
      ethnicity: ethnicity,
      language: language,
      socialChannels: socialChannels,
      contentCategories: contentCategories ?? [],
      profilePicture: profilePicture,
      coverPhoto: coverPhoto,
    );
  }

  factory ProfileApiModel.fromEntity(ProfileEntity entity) {
    return ProfileApiModel(
      userId: entity.userId,
      fullName: entity.fullName,
      bio: entity.bio,
      gender: entity.gender,
      dateOfBirth: entity.dateOfBirth,
      ethnicity: entity.ethnicity,
      language: entity.language,
      socialChannels: entity.socialChannels,
      contentCategories: entity.contentCategories,
      profilePicture: entity.profilePicture,
      coverPhoto: entity.coverPhoto,
    );
  }
}
