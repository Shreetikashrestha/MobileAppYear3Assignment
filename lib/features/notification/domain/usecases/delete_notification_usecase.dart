import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/notification/domain/repositories/notification_repository.dart';

class DeleteNotificationUseCase {
  final INotificationRepository repository;

  DeleteNotificationUseCase({required this.repository});

  Future<Either<Failure, void>> call(String notificationId) async {
    return await repository.deleteNotification(notificationId);
  }
}
