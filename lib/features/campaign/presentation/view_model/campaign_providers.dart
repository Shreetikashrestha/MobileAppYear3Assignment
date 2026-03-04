import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:influcollb_app/features/campaign/data/datasources/campaign_remote_datasource.dart';
import 'package:influcollb_app/features/campaign/data/repositories/campaign_repository_impl.dart';
import 'package:influcollb_app/features/campaign/domain/repositories/campaign_repository.dart';
import 'package:influcollb_app/features/campaign/domain/usecases/create_campaign_usecase.dart';
import 'package:influcollb_app/features/campaign/domain/usecases/delete_campaign_usecase.dart';
import 'package:influcollb_app/features/campaign/domain/usecases/get_all_campaigns_usecase.dart';
import 'package:influcollb_app/features/campaign/domain/usecases/get_my_brand_campaigns_usecase.dart';
import 'package:influcollb_app/features/campaign/domain/usecases/update_campaign_usecase.dart';
import 'package:influcollb_app/features/campaign/presentation/view_model/campaign_view_model.dart';

// Data Source Provider
final campaignRemoteDataSourceProvider = Provider<ICampaignRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return CampaignRemoteDataSource(apiClient: dio);
});

// Repository Provider
final campaignRepositoryProvider = Provider<ICampaignRepository>((ref) {
  final remoteDataSource = ref.read(campaignRemoteDataSourceProvider);
  return CampaignRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Case Providers
final getAllCampaignsUseCaseProvider = Provider<GetAllCampaignsUseCase>((ref) {
  final repository = ref.read(campaignRepositoryProvider);
  return GetAllCampaignsUseCase(repository: repository);
});

final getMyBrandCampaignsUseCaseProvider = Provider<GetMyBrandCampaignsUseCase>((ref) {
  final repository = ref.read(campaignRepositoryProvider);
  return GetMyBrandCampaignsUseCase(repository: repository);
});

final createCampaignUseCaseProvider = Provider<CreateCampaignUseCase>((ref) {
  final repository = ref.read(campaignRepositoryProvider);
  return CreateCampaignUseCase(repository: repository);
});

final updateCampaignUseCaseProvider = Provider<UpdateCampaignUseCase>((ref) {
  final repository = ref.read(campaignRepositoryProvider);
  return UpdateCampaignUseCase(repository: repository);
});

final deleteCampaignUseCaseProvider = Provider<DeleteCampaignUseCase>((ref) {
  final repository = ref.read(campaignRepositoryProvider);
  return DeleteCampaignUseCase(repository: repository);
});

// ViewModel Provider
final campaignViewModelProvider = StateNotifierProvider<CampaignViewModel, CampaignState>((ref) {
  final getAllCampaignsUseCase = ref.read(getAllCampaignsUseCaseProvider);
  final getMyBrandCampaignsUseCase = ref.read(getMyBrandCampaignsUseCaseProvider);
  final createCampaignUseCase = ref.read(createCampaignUseCaseProvider);
  final updateCampaignUseCase = ref.read(updateCampaignUseCaseProvider);
  final deleteCampaignUseCase = ref.read(deleteCampaignUseCaseProvider);

  return CampaignViewModel(
    getAllCampaignsUseCase: getAllCampaignsUseCase,
    getMyBrandCampaignsUseCase: getMyBrandCampaignsUseCase,
    createCampaignUseCase: createCampaignUseCase,
    updateCampaignUseCase: updateCampaignUseCase,
    deleteCampaignUseCase: deleteCampaignUseCase,
  );
});
