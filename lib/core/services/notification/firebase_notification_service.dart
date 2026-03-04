// Firebase notification service - temporarily disabled
// TODO: Re-enable when Firebase packages are added back

import 'package:flutter/foundation.dart';

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();

  factory FirebaseNotificationService() {
    return _instance;
  }

  FirebaseNotificationService._internal();

  Future<void> initialize() async {
    // Stub - Firebase disabled
    debugPrint('Firebase notifications disabled');
  }

  Future<String?> getToken() async {
    // Stub - Firebase disabled
    return null;
  }

  Future<void> requestPermission() async {
    // Stub - Firebase disabled
  }

  void dispose() {
    // Stub - Firebase disabled
  }
}
