class UserModel {
  final String name;
  final String email;
  final String password;
  final bool isInfluencer;
  final DateTime createdAt;

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.isInfluencer,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to JSON for Hive storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'isInfluencer': isInfluencer,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      isInfluencer: json['isInfluencer'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, isInfluencer: $isInfluencer)';
  }
}
