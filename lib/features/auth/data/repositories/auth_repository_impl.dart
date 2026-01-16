import '../models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<void> signUp(UserModel user) async {
    await localDataSource.saveUser(user);
  }

  @override
  Future<bool> login(String email, String password) async {
    return localDataSource.validateCredentials(email, password);
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    return localDataSource.getUserByEmail(email);
  }

  @override
  Future<bool> userExists(String email) async {
    return localDataSource.userExists(email);
  }

  @override
  Future<void> logout() async {
    // Can add more logout logic here
  }
}
