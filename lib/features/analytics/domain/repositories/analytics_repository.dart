import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/analytics/domain/entities/analytics_entity.dart';

abstract class IAnalyticsRepository {
  Future<Either<Failure, AnalyticsEntity>> getAnalytics();
}
