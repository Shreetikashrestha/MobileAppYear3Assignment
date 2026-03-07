import '../../domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String username;
  final String? password;
  final String? profilePicture;
  final bool isInfluencer;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.username = '',
    this.password,
    this.profilePicture,
    this.isInfluencer = false,
  });

  //toJson - For registration
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'isInfluencer': isInfluencer,
    };
  }

  //toJsonWithUsername
  Map<String, dynamic> toJsonWithUsername() {
    return {
      'name': fullName,
      'email': email,
      'username': username,
      'password': password,
      'profilePicture': profilePicture,
      'isInfluencer': isInfluencer,
    };
  }

  //fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    // Extract ID with multiple fallbacks - handle both null and type casting
    String? extractedId;
    if (json['_id'] != null) {
      extractedId = json['_id'].toString();
    } else if (json['userId'] != null) {
      extractedId = json['userId'].toString();
    } else if (json['id'] != null) {
      extractedId = json['id'].toString();
    }
    
    return AuthApiModel(
      id: extractedId,
      fullName: json['name'] as String? ?? json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      profilePicture: json['profilePicture'],
      isInfluencer: json['isInfluencer'] as bool? ?? false,
    );
  }

  //toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      username: username,
      profilePicture: profilePicture,
      isInfluencer: isInfluencer,
    );
  }

  //fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      username: entity.username,
      password: entity.password,
      profilePicture: entity.profilePicture,
      isInfluencer: entity.isInfluencer,
    );
  }

  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
