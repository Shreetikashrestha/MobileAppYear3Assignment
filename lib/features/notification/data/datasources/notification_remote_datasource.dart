import 'package:dio/dio.dart';
import 'package:influcollb_app/features/notification/data/models/notification_model.dart';

abstract class INotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
}

class NotificationRemoteDataSource implements INotificationRemoteDataSource {
  final Dio apiClient;

  NotificationRemoteDataSource({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await apiClient.get('/api/notifications');
      
      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        
        // Backend returns { success: true, notifications: [...] }
        if (responseData is Map) {
          if (responseData.containsKey('notifications')) {
            final List<dynamic> data = responseData['notifications'] ?? [];
            return data.map((json) => NotificationModel.fromJson(json)).toList();
          }
          
          // Fallback: check for 'data' field
          if (responseData.containsKey('data')) {
            final dataField = responseData['data'];
            if (dataField is List) {
              return dataField.map((json) => NotificationModel.fromJson(json)).toList();
            }
          }
        }
        
        // If response is directly an array
        if (responseData is List) {
          return responseData.map((json) => NotificationModel.fromJson(json)).toList();
        }
        
        // Return empty list if no notifications found
        return [];
      }
      
      throw Exception('Failed to load notifications: Status ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // No notifications found - return empty list
        return [];
      }
      throw Exception('Error fetching notifications: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await apiClient.patch('/api/notifications/$notificationId/read');
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await apiClient.patch('/api/notifications/read-all');
    } catch (e) {
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await apiClient.delete('/api/notifications/$notificationId');
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }
}
