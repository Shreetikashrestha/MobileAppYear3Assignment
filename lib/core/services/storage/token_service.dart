import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';
  final FlutterSecureStorage _storage;

  TokenService({required FlutterSecureStorage storage}) : _storage = storage;

  // Save token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Get token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Remove token (for logout)
  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
