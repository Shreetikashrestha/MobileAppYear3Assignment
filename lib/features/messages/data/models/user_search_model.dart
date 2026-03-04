class UserSearchModel {
  final String id;
  final String fullName;
  final String email;
  final String? profilePicture;
  final bool isInfluencer;
  final String role;

  const UserSearchModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.profilePicture,
    required this.isInfluencer,
    required this.role,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    return UserSearchModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'] ?? json['avatar'],
      isInfluencer: json['isInfluencer'] ?? false,
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'profilePicture': profilePicture,
      'isInfluencer': isInfluencer,
      'role': role,
    };
  }
}
