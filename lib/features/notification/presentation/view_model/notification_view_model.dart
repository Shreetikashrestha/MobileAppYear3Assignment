import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/notification/domain/entities/notification_entity.dart';
import 'package:influcollb_app/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:influcollb_app/features/notification/domain/usecases/mark_read_usecase.dart';
import 'package:influcollb_app/features/notification/domain/usecases/delete_notification_usecase.dart';

class NotificationState {
  final List<NotificationEntity> notifications;
  final bool isLoading;
  final String? error;
  final String selectedFilter; // all, unread, read

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.selectedFilter = 'all',
  });

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    bool? isLoading,
    String? error,
    String? selectedFilter,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;

  List<NotificationEntity> get filteredNotifications {
    if (selectedFilter == 'unread') {
      return notifications.where((n) => !n.isRead).toList();
    } else if (selectedFilter == 'read') {
      return notifications.where((n) => n.isRead).toList();
    }
    return notifications;
  }
}

class NotificationViewModel extends StateNotifier<NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkReadUseCase markReadUseCase;
  final MarkAllReadUseCase markAllReadUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;

  NotificationViewModel({
    required this.getNotificationsUseCase,
    required this.markReadUseCase,
    required this.markAllReadUseCase,
    required this.deleteNotificationUseCase,
  }) : super(NotificationState());

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getNotificationsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (notifications) {
        state = state.copyWith(
          notifications: notifications,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  Future<bool> markAsRead(String notificationId) async {
    final result = await markReadUseCase(notificationId);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        // Update local state
        final updatedNotifications = state.notifications.map((n) {
          if (n.id == notificationId) {
            return NotificationEntity(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              message: n.message,
              data: n.data,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();

        state = state.copyWith(notifications: updatedNotifications);
        return true;
      },
    );
  }

  Future<bool> markAllAsRead() async {
    final result = await markAllReadUseCase();

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        // Update local state
        final updatedNotifications = state.notifications.map((n) {
          return NotificationEntity(
            id: n.id,
            userId: n.userId,
            type: n.type,
            title: n.title,
            message: n.message,
            data: n.data,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();

        state = state.copyWith(notifications: updatedNotifications);
        return true;
      },
    );
  }

  Future<bool> deleteNotification(String notificationId) async {
    final result = await deleteNotificationUseCase(notificationId);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        // Remove from local state
        final updatedNotifications = state.notifications
            .where((n) => n.id != notificationId)
            .toList();

        state = state.copyWith(notifications: updatedNotifications);
        return true;
      },
    );
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}
