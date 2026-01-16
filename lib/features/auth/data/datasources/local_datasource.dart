import '../models/user_model.dart';
import '../../../../core/services/hive_service.dart';

class LocalDataSource {
  final HiveService hiveService;

  LocalDataSource({required this.hiveService});

  Future<void> saveUser(UserModel user) async {
    await hiveService.saveUser(user.email, user.toJson());
  }

  UserModel? getUserByEmail(String email) {
    final userData = hiveService.getUser(email);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  bool userExists(String email) {
    return hiveService.userExists(email);
  }

  bool validateCredentials(String email, String password) {
    return hiveService.validateCredentials(email, password);
  }

  Future<void> deleteUser(String email) async {
    await hiveService.deleteUser(email);
  }

  List<UserModel> getAllUsers() {
    final users = hiveService.getAllUsers();
    return users.map((userData) => UserModel.fromJson(userData)).toList();
  }

  Future<void> clearAll() async {
    await hiveService.clearAll();
  }
}
