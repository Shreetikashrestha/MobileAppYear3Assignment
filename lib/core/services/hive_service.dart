import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();

  factory HiveService() {
    return _instance;
  }

  HiveService._internal();

  static const String usersBoxName = 'users';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(usersBoxName);
  }

  Box getUsersBox() {
    return Hive.box(usersBoxName);
  }

  // Save user data
  Future<void> saveUser(String email, Map<String, dynamic> userData) async {
    final box = getUsersBox();
    await box.put(email, userData);
  }

  // Get user by email
  Map<String, dynamic>? getUser(String email) {
    final box = getUsersBox();
    final user = box.get(email);
    if (user is Map) {
      return Map<String, dynamic>.from(user);
    }
    return null;
  }

  // Check if user exists
  bool userExists(String email) {
    final box = getUsersBox();
    return box.containsKey(email);
  }

  // Validate user credentials
  bool validateCredentials(String email, String password) {
    final user = getUser(email);
    if (user == null) return false;
    return user['password'] == password;
  }

  // Delete user
  Future<void> deleteUser(String email) async {
    final box = getUsersBox();
    await box.delete(email);
  }

  // Get all users
  List<Map<String, dynamic>> getAllUsers() {
    final box = getUsersBox();
    return List<Map<String, dynamic>>.from(
      box.values
          .map((user) => user is Map ? Map<String, dynamic>.from(user) : {}),
    );
  }

  // Clear all users
  Future<void> clearAll() async {
    final box = getUsersBox();
    await box.clear();
  }
}
