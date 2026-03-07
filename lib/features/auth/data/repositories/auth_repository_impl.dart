  import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import 'package:influcollb_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required IAuthRemoteDataSource remoteDataSource,
    required IAuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, AuthApiModel>> getCurrentUser() async {
    try {
      final result = await _localDataSource.getCurrentUser();
      if (result != null) {
        return Right(AuthApiModel.fromEntity(result.toEntity()));
      }
      return const Left(ApiFailure(message: 'No current user found'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthApiModel>> register(
    String email,
    String fullName,
    String username,
    String password,
  ) async {
    try {
      final user = AuthApiModel(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
      );

      final result = await _remoteDataSource.register(user);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
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

  @override
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

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _localDataSource.logout();
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
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
