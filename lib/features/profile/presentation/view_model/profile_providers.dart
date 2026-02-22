import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/upload_image_usecase.dart';

final profileRemoteDataSourceProvider = Provider<IProfileRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRemoteDataSource(apiClient: apiClient);
});

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource: remoteDataSource);
});

final uploadImageUseCaseProvider = Provider<UploadImageUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UploadImageUseCase(repository: repository);
});
