import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String userId;
  final String fullName;
  final String? bio;
  final String? gender;
  final String? dateOfBirth;
  final String? ethnicity;
  final String? language;
  final Map<String, dynamic>? socialChannels;
  final List<String> contentCategories;
  final String? profilePicture;
  final String? coverPhoto;

  const ProfileEntity({
    required this.userId,
    required this.fullName,
    this.bio,
    this.gender,
    this.dateOfBirth,
    this.ethnicity,
    this.language,
    this.socialChannels,
    this.contentCategories = const [],
    this.profilePicture,
    this.coverPhoto,
  });

  @override
  List<Object?> get props => [
        userId,
        fullName,
        bio,
        gender,
        dateOfBirth,
        ethnicity,
        language,
        socialChannels,
        contentCategories,
        profilePicture,
        coverPhoto,
      ];
}
