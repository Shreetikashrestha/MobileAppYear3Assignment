import 'package:shared_preferences/shared_preferences.dart';

class UserSessionService {
  final SharedPreferences _prefs;

  // Keys for storing user data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserProfilePicture = 'user_profile_picture';
  static const String _keyAuthToken = 'auth_token';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Save user session after login/register
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    String? profilePicture,
    String? token,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserFullName, fullName);
    if (profilePicture != null) {
      await _prefs.setString(_keyUserProfilePicture, profilePicture);
    }
    if (token != null) {
      await _prefs.setString(_keyAuthToken, token);
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  // Get current user full name
  String? getCurrentUserFullName() {
    return _prefs.getString(_keyUserFullName);
  }


  // Get current user profile picture
  String? getCurrentUserProfilePicture() {
    return _prefs.getString(_keyUserProfilePicture);
  }

  // Get auth token
  String? getAuthToken() {
    return _prefs.getString(_keyAuthToken);
  }

  // Clear user session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserFullName);
    await _prefs.remove(_keyUserProfilePicture);
    await _prefs.remove(_keyAuthToken);
  }
}
