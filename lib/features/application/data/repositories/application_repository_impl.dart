import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/features/application/data/datasources/application_remote_datasource.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';
import 'package:influcollb_app/features/application/domain/repositories/application_repository.dart';

class ApplicationRepositoryImpl implements IApplicationRepository {
  final IApplicationRemoteDataSource remoteDataSource;

  ApplicationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ApplicationModel>> submitApplication(
      ApplicationModel application) async {
    try {
      final result = await remoteDataSource.submitApplication(application);
      return Right(result);
    } on DioException catch (e) {
      return Left(Failure(
        error: e.response?.data['message'] ?? 'Failed to submit application',
        statusCode: e.response?.statusCode.toString() ?? '500',
      ));
    } catch (e) {
      return Left(Failure(
        error: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  Future<Either<Failure, List<ApplicationModel>>> getMyApplications() async {
    try {
      final result = await remoteDataSource.getMyApplications();
      return Right(result);
    } on DioException catch (e) {
      return Left(Failure(
        error: e.response?.data['message'] ?? 'Failed to get applications',
        statusCode: e.response?.statusCode.toString() ?? '500',
      ));
    } catch (e) {
      return Left(Failure(
        error: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  Future<Either<Failure, List<ApplicationModel>>> getCampaignApplications(
      String campaignId) async {
    try {
      final result = await remoteDataSource.getCampaignApplications(campaignId);
      return Right(result);
    } on DioException catch (e) {
      return Left(Failure(
        error: e.response?.data['message'] ?? 'Failed to get applications',
        statusCode: e.response?.statusCode.toString() ?? '500',
      ));
    } catch (e) {
      return Left(Failure(
        error: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  Future<Either<Failure, ApplicationModel>> getApplicationById(
      String id) async {
    try {
      final result = await remoteDataSource.getApplicationById(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(Failure(
        error: e.response?.data['message'] ?? 'Application not found',
        statusCode: e.response?.statusCode.toString() ?? '500',
      ));
    } catch (e) {
      return Left(Failure(
        error: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  Future<Either<Failure, ApplicationModel>> updateApplicationStatus(
      String id, String status) async {
    try {
      final result =
          await remoteDataSource.updateApplicationStatus(id, status);
      return Right(result);
    } on DioException catch (e) {
      return Left(Failure(
        error: e.response?.data['message'] ?? 'Failed to update status',
        statusCode: e.response?.statusCode.toString() ?? '500',
      ));
    } catch (e) {
      return Left(Failure(
        error: e.toString(),
        statusCode: '500',
      ));
    }
  }
}
