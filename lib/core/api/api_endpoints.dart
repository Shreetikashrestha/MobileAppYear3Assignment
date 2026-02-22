import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiEndpoints {
  ApiEndpoints._();
  /// Set to true when running on a physical device. Then set compIpAddress to your computer's IP (same WiFi).
  static const bool isPhysicalDevice = false;
  /// Your computer's IP for physical device testing (e.g. from ifconfig). Only used when isPhysicalDevice is true.
  static const String compIpAddress = "192.168.1.1";

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api';
    }
    //yadi android
    if (kIsWeb) {
      return 'http://localhost:5050/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:5050/api';
    } else {
      return 'http://localhost:5050/api';
    }
  }

  static String get mediaBaseUrl {
    return baseUrl.replaceAll('/api', '');
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ==================== AUTH ENDPOINTS ====================
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get logout => '$baseUrl/auth/logout';

  // ==================== PROFILE ENDPOINTS ====================
  static String get profile => '$baseUrl/user/profile';
  static String get updateProfile => '$baseUrl/user/profile';

  // ==================== CAMPAIGN ENDPOINTS ====================
  static String get campaigns => '$baseUrl/campaigns';
  static String campaignById(String id) => '$baseUrl/campaigns/$id';
  static String get createCampaign => '$baseUrl/campaigns';
  static String updateCampaign(String id) => '$baseUrl/campaigns/$id';
  static String deleteCampaign(String id) => '$baseUrl/campaigns/$id';
  static String get myCampaigns => '$baseUrl/campaigns/my-campaigns';

  // ==================== APPLICATION ENDPOINTS ====================
  static String get applications => '$baseUrl/applications';
  static String applicationById(String id) => '$baseUrl/applications/$id';
  static String get myApplications => '$baseUrl/applications/my-applications';
  static String campaignApplications(String campaignId) => '$baseUrl/applications/campaign/$campaignId';
  static String updateApplicationStatus(String id) => '$baseUrl/applications/$id/status';

  // ==================== NOTIFICATION ENDPOINTS ====================
  static String get notifications => '$baseUrl/notifications';
  static String notificationById(String id) => '$baseUrl/notifications/$id';
  static String markAsRead(String id) => '$baseUrl/notifications/$id/read';
  static String get markAllAsRead => '$baseUrl/notifications/read-all';
  static String get unreadCount => '$baseUrl/notifications/unread-count';

  // ==================== MESSAGE ENDPOINTS ====================
  static String get conversations => '$baseUrl/messages/conversations';
  static String conversationWith(String userId) => '$baseUrl/messages/$userId';
  static String sendMessage(String userId) => '$baseUrl/messages/$userId';

  // ==================== INFLUENCER ENDPOINTS ====================
  static String get influencers => '$baseUrl/users/influencers';
  static String influencerById(String id) => '$baseUrl/users/influencers/$id';

  // ==================== ADMIN ENDPOINTS ====================
  static String get adminUsers => '$baseUrl/admin/users';
  static String adminUserById(String id) => '$baseUrl/admin/users/$id';
  static String get adminCampaigns => '$baseUrl/admin/campaigns';
  static String get adminApplications => '$baseUrl/admin/applications';
}
