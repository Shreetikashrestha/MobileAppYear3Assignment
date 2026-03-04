import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/notification/domain/repositories/notification_repository.dart';

class MarkReadUseCase {
  final INotificationRepository repository;

  MarkReadUseCase({required this.repository});

  Future<Either<Failure, void>> call(String notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}

class MarkAllReadUseCase {
  final INotificationRepository repository;

  MarkAllReadUseCase({required this.repository});

  Future<Either<Failure, void>> call() async {
    return await repository.markAllAsRead();
  }
}
