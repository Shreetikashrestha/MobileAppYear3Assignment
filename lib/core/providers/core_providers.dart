import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'shared_preferences_provider.dart';
import '../services/storage/user_session_service.dart';
import '../services/storage/token_service.dart';
import '../services/connectivity/network_info.dart';

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenServiceProvider = Provider<TokenService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenService(storage: storage);
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});
