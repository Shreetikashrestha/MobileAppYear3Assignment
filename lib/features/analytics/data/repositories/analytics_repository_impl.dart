import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/analytics/domain/entities/analytics_entity.dart';
import 'package:influcollb_app/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:influcollb_app/features/analytics/data/datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements IAnalyticsRepository {
  final IAnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AnalyticsEntity>> getAnalytics() async {
    try {
      final analytics = await remoteDataSource.getAnalytics();
      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
