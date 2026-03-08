import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/influencer/data/models/influencer_model.dart';
import 'package:influcollb_app/features/influencer/domain/usecases/get_influencers_usecase.dart';
import 'package:influcollb_app/features/influencer/domain/usecases/search_influencers_usecase.dart';
import 'package:influcollb_app/features/influencer/domain/usecases/get_influencer_profile_usecase.dart';

class InfluencerState {
  final List<InfluencerModel> influencers;
  final InfluencerModel? selectedInfluencer;
  final bool isLoading;
  final bool isSearching;
  final String? error;
  final String searchQuery;

  InfluencerState({
    this.influencers = const [],
    this.selectedInfluencer,
    this.isLoading = false,
    this.isSearching = false,
    this.error,
    this.searchQuery = '',
  });

  InfluencerState copyWith({
    List<InfluencerModel>? influencers,
    InfluencerModel? selectedInfluencer,
    bool? isLoading,
    bool? isSearching,
    String? error,
    String? searchQuery,
  }) {
    return InfluencerState(
      influencers: influencers ?? this.influencers,
      selectedInfluencer: selectedInfluencer ?? this.selectedInfluencer,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class InfluencerViewModel extends StateNotifier<InfluencerState> {
  final GetInfluencersUseCase getInfluencersUseCase;
  final SearchInfluencersUseCase searchInfluencersUseCase;
  final GetInfluencerProfileUseCase getInfluencerProfileUseCase;

  InfluencerViewModel({
    required this.getInfluencersUseCase,
    required this.searchInfluencersUseCase,
    required this.getInfluencerProfileUseCase,
  }) : super(InfluencerState());

  Future<void> loadInfluencers() async {
    print('🔄 [InfluencerViewModel] Starting to load influencers');
    state = state.copyWith(isLoading: true, error: null);

    final result = await getInfluencersUseCase();

    result.fold(
      (failure) {
        print('❌ [InfluencerViewModel] Failed to load influencers: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (influencers) {
        print('✅ [InfluencerViewModel] Successfully loaded ${influencers.length} influencers');
        state = state.copyWith(
          isLoading: false,
          influencers: influencers as List<InfluencerModel>,
          error: null,
        );
      },
    );
  }

  Future<void> searchInfluencers(String query) async {
    state = state.copyWith(
      isSearching: true,
      error: null,
      searchQuery: query,
    );

    if (query.isEmpty) {
      await loadInfluencers();
      return;
    }

    final result = await searchInfluencersUseCase(query);

    result.fold(
      (failure) {
        state = state.copyWith(
          isSearching: false,
          error: failure.message,
        );
      },
      (influencers) {
        state = state.copyWith(
          isSearching: false,
          influencers: influencers as List<InfluencerModel>,
          error: null,
        );
      },
    );
  }

  Future<void> loadInfluencerProfile(String id) async {
    print('🔄 [InfluencerViewModel] Loading profile for ID: $id');
    state = state.copyWith(isLoading: true, error: null);

    final result = await getInfluencerProfileUseCase(id);

    result.fold(
      (failure) {
        print('❌ [InfluencerViewModel] Failed to load profile: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (influencer) {
        print('✅ [InfluencerViewModel] Successfully loaded profile: ${influencer.fullName}');
        print('✅ [InfluencerViewModel] Profile details - Bio: ${influencer.bio}, Niche: ${influencer.niche}, Followers: ${influencer.followersCount}');
        state = state.copyWith(
          isLoading: false,
          selectedInfluencer: influencer as InfluencerModel,
          error: null,
        );
      },
    );
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      influencers: [],
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
