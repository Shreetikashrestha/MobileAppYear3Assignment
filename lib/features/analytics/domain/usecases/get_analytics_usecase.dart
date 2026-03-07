import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/analytics/domain/entities/analytics_entity.dart';
import 'package:influcollb_app/features/analytics/domain/repositories/analytics_repository.dart';

class GetAnalyticsUseCase {
  final IAnalyticsRepository repository;

  GetAnalyticsUseCase({required this.repository});

  Future<Either<Failure, AnalyticsEntity>> call() async {
    return await repository.getAnalytics();
  }
}
