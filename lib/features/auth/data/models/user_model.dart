class UserModel {
  final String? userId;
  final String fullName;
  final String email;
  final String username;
  final String password;
  final String? profilePicture;
  final bool isInfluencer;
  final DateTime createdAt;

  UserModel({
    this.userId,
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
    this.profilePicture,
    required this.isInfluencer,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to JSON for Hive storage
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'username': username,
      'password': password,
      'profilePicture': profilePicture,
      'isInfluencer': isInfluencer,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      profilePicture: json['profilePicture'],
      isInfluencer: json['isInfluencer'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  @override
  String toString() {
    return 'UserModel(fullName: $fullName, email: $email, username: $username, isInfluencer: $isInfluencer)';
  }
}
