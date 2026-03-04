import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:influcollb_app/features/application/data/datasources/application_remote_datasource.dart';
import 'package:influcollb_app/features/application/data/repositories/application_repository_impl.dart';
import 'package:influcollb_app/features/application/domain/repositories/application_repository.dart';
import 'package:influcollb_app/features/application/domain/usecases/get_campaign_applications_usecase.dart';
import 'package:influcollb_app/features/application/domain/usecases/get_my_applications_usecase.dart';
import 'package:influcollb_app/features/application/domain/usecases/submit_application_usecase.dart';
import 'package:influcollb_app/features/application/domain/usecases/update_application_status_usecase.dart';
import 'package:influcollb_app/features/application/presentation/view_model/application_view_model.dart';

// Datasource Provider
final applicationRemoteDataSourceProvider =
    Provider<IApplicationRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ApplicationRemoteDataSource(apiClient: apiClient);
});

// Repository Provider
final applicationRepositoryProvider = Provider<IApplicationRepository>((ref) {
  final remoteDataSource = ref.read(applicationRemoteDataSourceProvider);
  return ApplicationRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Case Providers
final submitApplicationUseCaseProvider = Provider<SubmitApplicationUseCase>((ref) {
  final repository = ref.read(applicationRepositoryProvider);
  return SubmitApplicationUseCase(repository: repository);
});

final getMyApplicationsUseCaseProvider =
    Provider<GetMyApplicationsUseCase>((ref) {
  final repository = ref.read(applicationRepositoryProvider);
  return GetMyApplicationsUseCase(repository: repository);
});

final getCampaignApplicationsUseCaseProvider =
    Provider<GetCampaignApplicationsUseCase>((ref) {
  final repository = ref.read(applicationRepositoryProvider);
  return GetCampaignApplicationsUseCase(repository: repository);
});

final updateApplicationStatusUseCaseProvider =
    Provider<UpdateApplicationStatusUseCase>((ref) {
  final repository = ref.read(applicationRepositoryProvider);
  return UpdateApplicationStatusUseCase(repository: repository);
});

// View Model Provider
final applicationViewModelProvider =
    StateNotifierProvider<ApplicationViewModel, ApplicationState>((ref) {
  final submitUseCase = ref.read(submitApplicationUseCaseProvider);
  final getMyApplicationsUseCase = ref.read(getMyApplicationsUseCaseProvider);
  final getCampaignApplicationsUseCase =
      ref.read(getCampaignApplicationsUseCaseProvider);
  final updateStatusUseCase = ref.read(updateApplicationStatusUseCaseProvider);

  return ApplicationViewModel(
    submitApplicationUseCase: submitUseCase,
    getMyApplicationsUseCase: getMyApplicationsUseCase,
    getCampaignApplicationsUseCase: getCampaignApplicationsUseCase,
    updateApplicationStatusUseCase: updateStatusUseCase,
  );
});
