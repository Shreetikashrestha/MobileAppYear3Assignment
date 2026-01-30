import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';

class AuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;

  AuthRepository({required IAuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<Either<Failure, AuthApiModel>> register(
    String email,
    String fullName,
    String username,
    String password,
  ) async {
    try {
      final user = AuthApiModel(
        email: email,
        fullName: fullName,
        username: username,
      );

      final result = await _remoteDataSource.register(user);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, AuthApiModel>> login(
    String email,
    String password,
  ) async {
    try {
      final result = await _remoteDataSource.login(email, password);
      if (result != null) {
        return Right(result);
      }
      return const Left(ApiFailure(message: 'Invalid email or password'));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, AuthApiModel>> getUserById(String authId) async {
    try {
      final result = await _remoteDataSource.getUserById(authId);
      if (result != null) {
        return Right(result);
      }
      return const Left(ApiFailure(message: 'User not found'));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Failure _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ApiFailure(message: 'Connection timeout');
    } else if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data['message'] ?? 'Server error';
      return ApiFailure(
          message: 'Error $statusCode: $message', statusCode: statusCode);
    } else if (e.type == DioExceptionType.connectionError) {
      return const ApiFailure(message: 'No internet connection');
    }
    return ApiFailure(message: e.message ?? 'Unknown error');
  }
}
