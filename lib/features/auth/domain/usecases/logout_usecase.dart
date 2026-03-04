import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/core/usecases/usecase.dart';
import 'package:influcollb_app/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<bool, NoParams> {
  final IAuthRepository _authRepository;

  LogoutUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await _authRepository.logout();
  }
}
