import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/features/auth/domain/entities/auth_entity.dart';
import 'package:influcollb_app/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final IAuthRepository _authRepository;

  GetCurrentUserUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  Future<Either<Failure, AuthEntity>> call() async {
    final result = await _authRepository.getCurrentUser();
    return result.map((r) => r.toEntity());
  }
}