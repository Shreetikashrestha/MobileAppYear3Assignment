import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/services/hive/hive_service.dart';
import 'package:influcollb_app/core/services/storage/user_session_service.dart';
import 'package:influcollb_app/core/providers/core_providers.dart';
import '../../models/auth_hive_model.dart';
import '../auth_datasource.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final userSessionService = ref.watch(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  })  : _hiveService = hiveService,
        _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    return await _hiveService.register(user);
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = _hiveService.login(email, password);
      if (user != null && user.authId != null) {
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: user.email,
          fullName: user.fullName,
          profilePicture: user.profilePicture,
        );
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      if (!_userSessionService.isLoggedIn()) {
        return null;
      }
      final userId = _userSessionService.getCurrentUserId();
      if (userId == null) {
        return null;
      }
      return _hiveService.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _userSessionService.clearSession();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId) async {
    return _hiveService.getUserById(authId);
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    return _hiveService.getUserByEmail(email);
  }

  @override
  Future<bool> updateUser(AuthHiveModel user) async {
    return await _hiveService.updateUser(user);
  }

  @override
  Future<bool> deleteUser(String authId) async {
    try {
      await _hiveService.deleteUser(authId);
      final currentUserId = _userSessionService.getCurrentUserId();
      if (currentUserId == authId) {
        await _userSessionService.clearSession();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
