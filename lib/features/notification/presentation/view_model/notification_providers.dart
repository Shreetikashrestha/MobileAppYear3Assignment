import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:influcollb_app/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:influcollb_app/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:influcollb_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:influcollb_app/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:influcollb_app/features/notification/domain/usecases/mark_read_usecase.dart';
import 'package:influcollb_app/features/notification/domain/usecases/delete_notification_usecase.dart';
import 'package:influcollb_app/features/notification/presentation/view_model/notification_view_model.dart';

// Data Source Provider
final notificationRemoteDataSourceProvider =
    Provider<INotificationRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return NotificationRemoteDataSource(apiClient: dio);
});

// Repository Provider
final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  final remoteDataSource = ref.read(notificationRemoteDataSourceProvider);
  return NotificationRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Case Providers
final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return GetNotificationsUseCase(repository: repository);
});

final markReadUseCaseProvider = Provider<MarkReadUseCase>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return MarkReadUseCase(repository: repository);
});

final markAllReadUseCaseProvider = Provider<MarkAllReadUseCase>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return MarkAllReadUseCase(repository: repository);
});

final deleteNotificationUseCaseProvider =
    Provider<DeleteNotificationUseCase>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return DeleteNotificationUseCase(repository: repository);
});

// ViewModel Provider
final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
  return NotificationViewModel(
    getNotificationsUseCase: ref.read(getNotificationsUseCaseProvider),
    markReadUseCase: ref.read(markReadUseCaseProvider),
    markAllReadUseCase: ref.read(markAllReadUseCaseProvider),
    deleteNotificationUseCase: ref.read(deleteNotificationUseCaseProvider),
  );
});
