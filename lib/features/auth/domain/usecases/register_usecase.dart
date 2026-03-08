import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import 'package:influcollb_app/features/auth/domain/repositories/auth_repository.dart';

class RegisterParams extends Equatable {
  final String email;
  final String fullName;
  final String username;
  final String password;
  final bool isInfluencer;

  const RegisterParams({
    required this.email,
    required this.fullName,
    required this.username,
    required this.password,
    required this.isInfluencer,
  });

  @override
  List<Object?> get props => [email, fullName, username, password, isInfluencer];
}

class RegisterUseCase {
  final IAuthRepository _authRepository;

  RegisterUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  Future<Either<Failure, AuthApiModel>> call(RegisterParams params) async {
    return await _authRepository.register(
      params.email,
      params.fullName,
      params.username,
      params.password,
      params.isInfluencer,
    );
  }
}
