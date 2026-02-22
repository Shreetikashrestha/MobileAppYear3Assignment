import 'package:shared_preferences/shared_preferences.dart';

class UserSessionService {
  final SharedPreferences _prefs;

  // Keys for storing user data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserProfilePicture = 'user_profile_picture';
  static const String _keyUserSummary = 'user_summary';
  static const String _keyUserBio = 'user_bio';
  static const String _keyUserRole = 'userRole'; // Matches key used in SplashScreen

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Save user session after login/register
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    String? profilePicture,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserFullName, fullName);
    if (profilePicture != null) {
      await _prefs.setString(_keyUserProfilePicture, profilePicture);
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

  // Save onboarding data
  Future<void> saveOnboardingData({
    String? summary,
    String? bio,
  }) async {
    if (summary != null) await _prefs.setString(_keyUserSummary, summary);
    if (bio != null) await _prefs.setString(_keyUserBio, bio);
  }

  // Get current user summary
  String? getCurrentUserSummary() {
    return _prefs.getString(_keyUserSummary);
  }

  // Get current user bio
  String? getCurrentUserBio() {
    return _prefs.getString(_keyUserBio);
  }

  // Get user role
  String? getUserRole() {
    return _prefs.getString(_keyUserRole);
  }

  // Clear user session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserFullName);
    await _prefs.remove(_keyUserProfilePicture);
  }

  // Update profile picture URL
  Future<void> updateProfilePicture(String url) async {
    await _prefs.setString(_keyUserProfilePicture, url);
  }

  // Get profile picture URL
  String? getProfilePicture() {
    return _prefs.getString(_keyUserProfilePicture);
  }
}
