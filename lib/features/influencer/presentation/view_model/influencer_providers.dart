import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:influcollb_app/features/influencer/data/datasources/influencer_remote_datasource.dart';
import 'package:influcollb_app/features/influencer/data/repositories/influencer_repository_impl.dart';
import 'package:influcollb_app/features/influencer/domain/repositories/influencer_repository.dart';
import 'package:influcollb_app/features/influencer/domain/usecases/get_influencers_usecase.dart';
import 'package:influcollb_app/features/influencer/domain/usecases/search_influencers_usecase.dart';
import 'package:influcollb_app/features/influencer/domain/usecases/get_influencer_profile_usecase.dart';
import 'package:influcollb_app/features/influencer/presentation/view_model/influencer_view_model.dart';

// Data Source Provider
final influencerRemoteDataSourceProvider =
    Provider<IInfluencerRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return InfluencerRemoteDataSource(apiClient: apiClient);
});

// Repository Provider
final influencerRepositoryProvider = Provider<IInfluencerRepository>((ref) {
  final remoteDataSource = ref.read(influencerRemoteDataSourceProvider);
  return InfluencerRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Case Providers
final getInfluencersUseCaseProvider = Provider<GetInfluencersUseCase>((ref) {
  final repository = ref.read(influencerRepositoryProvider);
  return GetInfluencersUseCase(repository: repository);
});

final searchInfluencersUseCaseProvider =
    Provider<SearchInfluencersUseCase>((ref) {
  final repository = ref.read(influencerRepositoryProvider);
  return SearchInfluencersUseCase(repository: repository);
});

final getInfluencerProfileUseCaseProvider =
    Provider<GetInfluencerProfileUseCase>((ref) {
  final repository = ref.read(influencerRepositoryProvider);
  return GetInfluencerProfileUseCase(repository: repository);
});

// ViewModel Provider
final influencerViewModelProvider =
    StateNotifierProvider<InfluencerViewModel, InfluencerState>((ref) {
  final getInfluencersUseCase = ref.read(getInfluencersUseCaseProvider);
  final searchInfluencersUseCase = ref.read(searchInfluencersUseCaseProvider);
  final getInfluencerProfileUseCase =
      ref.read(getInfluencerProfileUseCaseProvider);

  return InfluencerViewModel(
    getInfluencersUseCase: getInfluencersUseCase,
    searchInfluencersUseCase: searchInfluencersUseCase,
    getInfluencerProfileUseCase: getInfluencerProfileUseCase,
  );
});
