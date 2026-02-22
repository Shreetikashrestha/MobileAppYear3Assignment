import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:influcollb_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:influcollb_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:influcollb_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:influcollb_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:influcollb_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:influcollb_app/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:influcollb_app/core/providers/core_providers.dart';

import 'package:influcollb_app/core/providers/api_provider.dart';

// Auth Data Source provider
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final sessionService = ref.watch(userSessionServiceProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  return AuthRemoteDatasource(
    apiClient: apiClient,
    userSessionService: sessionService,
    tokenService: tokenService,
  );
});

// Auth Repository provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDatasourceProvider);
  final localDataSource = ref.watch(authLocalDatasourceProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// Use Case providers
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(authRepository: repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(authRepository: repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(authRepository: repository);
});
