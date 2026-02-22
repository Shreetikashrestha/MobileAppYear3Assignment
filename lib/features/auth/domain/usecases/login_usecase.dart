import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import 'package:influcollb_app/features/auth/domain/repositories/auth_repository.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginUseCase {
  final IAuthRepository _authRepository;

  LoginUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  Future<Either<Failure, AuthApiModel>> call(LoginParams params) async {
    return await _authRepository.login(params.email, params.password);
  }
}
