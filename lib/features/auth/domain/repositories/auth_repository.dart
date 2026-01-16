import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<void> signUp(UserModel user);
  Future<bool> login(String email, String password);
  Future<UserModel?> getUserByEmail(String email);
  Future<bool> userExists(String email);
  Future<void> logout();
}
