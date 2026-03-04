import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/campaign/data/models/campaign_model.dart';
import 'package:influcollb_app/features/campaign/domain/usecases/create_campaign_usecase.dart';
import 'package:influcollb_app/features/campaign/domain/usecases/delete_campaign_usecase.dart';
import 'package:influcollb_app/features/campaign/domain/usecases/get_all_campaigns_usecase.dart';
import 'package:influcollb_app/features/campaign/domain/usecases/get_my_brand_campaigns_usecase.dart';
import 'package:influcollb_app/features/campaign/domain/usecases/update_campaign_usecase.dart';

class CampaignState {
  final List<Campaign> campaigns;
  final List<Campaign> myBrandCampaigns;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool isApplying;
  final String? error;
  final bool createSuccess;
  final bool updateSuccess;
  final bool deleteSuccess;
  final List<Campaign> savedCampaigns;

  CampaignState({
    this.campaigns = const [],
    this.myBrandCampaigns = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isApplying = false,
    this.error,
    this.createSuccess = false,
    this.updateSuccess = false,
    this.deleteSuccess = false,
    this.savedCampaigns = const [],
  });

  CampaignState copyWith({
    List<Campaign>? campaigns,
    List<Campaign>? myBrandCampaigns,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isApplying,
    String? error,
    bool? createSuccess,
    bool? updateSuccess,
    bool? deleteSuccess,
    List<Campaign>? savedCampaigns,
  }) {
    return CampaignState(
      campaigns: campaigns ?? this.campaigns,
      myBrandCampaigns: myBrandCampaigns ?? this.myBrandCampaigns,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isApplying: isApplying ?? this.isApplying,
      error: error,
      createSuccess: createSuccess ?? this.createSuccess,
      updateSuccess: updateSuccess ?? this.updateSuccess,
      deleteSuccess: deleteSuccess ?? this.deleteSuccess,
      savedCampaigns: savedCampaigns ?? this.savedCampaigns,
    );
  }
}

class CampaignViewModel extends StateNotifier<CampaignState> {
  final GetAllCampaignsUseCase getAllCampaignsUseCase;
  final GetMyBrandCampaignsUseCase getMyBrandCampaignsUseCase;
  final CreateCampaignUseCase createCampaignUseCase;
  final UpdateCampaignUseCase updateCampaignUseCase;
  final DeleteCampaignUseCase deleteCampaignUseCase;

  CampaignViewModel({
    required this.getAllCampaignsUseCase,
    required this.getMyBrandCampaignsUseCase,
    required this.createCampaignUseCase,
    required this.updateCampaignUseCase,
    required this.deleteCampaignUseCase,
  }) : super(CampaignState());

  Future<void> loadAllCampaigns() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getAllCampaignsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (campaigns) {
        state = state.copyWith(
          isLoading: false,
          campaigns: campaigns as List<Campaign>,
          error: null,
        );
      },
    );
  }

  Future<void> loadMyBrandCampaigns() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getMyBrandCampaignsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (campaigns) {
        state = state.copyWith(
          isLoading: false,
          myBrandCampaigns: campaigns as List<Campaign>,
          error: null,
        );
      },
    );
  }

  Future<bool> createCampaign(Map<String, dynamic> campaignData) async {
    state = state.copyWith(isCreating: true, error: null, createSuccess: false);

    final result = await createCampaignUseCase(campaignData);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          error: failure.message,
          createSuccess: false,
        );
        return false;
      },
      (campaign) {
        state = state.copyWith(
          isCreating: false,
          createSuccess: true,
          error: null,
        );
        // Reload campaigns
        loadMyBrandCampaigns();
        return true;
      },
    );
  }

  Future<bool> updateCampaign(
      String id, Map<String, dynamic> campaignData) async {
    state = state.copyWith(isUpdating: true, error: null, updateSuccess: false);

    final result = await updateCampaignUseCase(id, campaignData);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
          updateSuccess: false,
        );
        return false;
      },
      (campaign) {
        state = state.copyWith(
          isUpdating: false,
          updateSuccess: true,
          error: null,
        );
        // Reload campaigns
        loadMyBrandCampaigns();
        return true;
      },
    );
  }

  Future<bool> deleteCampaign(String id) async {
    state = state.copyWith(isDeleting: true, error: null, deleteSuccess: false);

    final result = await deleteCampaignUseCase(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          error: failure.message,
          deleteSuccess: false,
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          isDeleting: false,
          deleteSuccess: true,
          error: null,
        );
        // Reload campaigns
        loadMyBrandCampaigns();
        return true;
      },
    );
  }

  /// Alias for loadAllCampaigns - used by influencer/discover screens
  Future<void> loadCampaigns() async {
    await loadAllCampaigns();
  }

  /// Load saved campaigns (managed locally in state)
  void loadSavedCampaigns() {
    // Saved campaigns are already tracked in state, no-op refresh
  }

  /// Toggle save/unsave a campaign locally
  void toggleSave(String campaignId) {
    final currentSaved = List<Campaign>.from(state.savedCampaigns);
    final alreadySaved = currentSaved.any((c) => c.id == campaignId);

    if (alreadySaved) {
      currentSaved.removeWhere((c) => c.id == campaignId);
    } else {
      final campaign = state.campaigns.firstWhere(
        (c) => c.id == campaignId,
        orElse: () =>
            state.myBrandCampaigns.firstWhere((c) => c.id == campaignId),
      );
      currentSaved.add(campaign);
    }

    state = state.copyWith(savedCampaigns: currentSaved);
  }

  /// Apply to a campaign
  Future<bool> applyToCampaign(String campaignId) async {
    state = state.copyWith(isApplying: true, error: null);

    try {
      // Simulate API call for applying
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isApplying: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isApplying: false,
        error: 'Failed to apply: ${e.toString()}',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetSuccessFlags() {
    state = state.copyWith(
      createSuccess: false,
      updateSuccess: false,
      deleteSuccess: false,
    );
  }
}
