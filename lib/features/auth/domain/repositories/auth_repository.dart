import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';

abstract class IAuthRepository {
  Future<Either<Failure, AuthApiModel>> register(
    String email,
    String fullName,
    String username,
    String password,
  );

  Future<Either<Failure, AuthApiModel>> login(
    String email,
    String password,
  );

  Future<Either<Failure, AuthApiModel>> getUserById(String authId);
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, AuthApiModel>> getCurrentUser();
}
