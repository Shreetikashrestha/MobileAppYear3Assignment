import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/api/api_service.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:influcollb_app/core/services/storage/token_service.dart';
import 'package:influcollb_app/core/providers/core_providers.dart';
import '../../data/models/campaign_model.dart';

final campaignViewModelProvider = StateNotifierProvider<CampaignViewModel, CampaignState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  return CampaignViewModel(apiService, tokenService);
});

class CampaignState {
  final List<Campaign> campaigns;
  final bool isLoading;
  final String? error;
  final bool isApplying;
  final List<Campaign> savedCampaigns;

  CampaignState({
    required this.campaigns,
    required this.isLoading,
    this.error,
    this.isApplying = false,
    this.savedCampaigns = const [],
  });

  CampaignState copyWith({
    List<Campaign>? campaigns,
    bool? isLoading,
    String? error,
    bool? isApplying,
    List<Campaign>? savedCampaigns,
  }) {
    return CampaignState(
      campaigns: campaigns ?? this.campaigns,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isApplying: isApplying ?? this.isApplying,
      savedCampaigns: savedCampaigns ?? this.savedCampaigns,
    );
  }
}

class CampaignViewModel extends StateNotifier<CampaignState> {
  final ApiService _apiService;
  final TokenService _tokenService;

  CampaignViewModel(this._apiService, this._tokenService)
      : super(CampaignState(campaigns: [], isLoading: false)) {
    loadCampaigns();
    loadSavedCampaigns();
  }

  Future<void> loadCampaigns() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      print('Fetching campaigns...');
      final data = await _apiService.getCampaigns(status: 'active');
      print('Successfully fetched ${data.length} campaigns from API.');
      final campaigns = data.map((e) => Campaign.fromJson(e)).toList();
      print('Successfully parsed ${campaigns.length} campaigns.');
      state = state.copyWith(campaigns: campaigns, isLoading: false);
    } catch (e) {
      print('Error loading campaigns: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> applyToCampaign(String campaignId, {String? message}) async {
    state = state.copyWith(isApplying: true);
    try {
      final token = _tokenService.getToken();

      if (token == null) {
        state = state.copyWith(isApplying: false, error: 'Not authenticated');
        return false;
      }

      await _apiService.applyToCampaign(
        campaignId: campaignId,
        token: token,
        message: message,
      );
      
      // Refresh campaigns to update applicant count
      await loadCampaigns();
      
      state = state.copyWith(isApplying: false);
      return true;
    } catch (e) {
      state = state.copyWith(isApplying: false, error: e.toString());
      return false;
    }
  }

  Future<void> loadSavedCampaigns() async {
    try {
      final token = _tokenService.getToken();

      if (token == null) return;

      final data = await _apiService.getSavedCampaigns(token);
      final savedCampaigns = data.map((e) => Campaign.fromJson(e)).toList();
      state = state.copyWith(savedCampaigns: savedCampaigns);
    } catch (e) {
      print('Error loading saved campaigns: $e');
    }
  }

  Future<bool> toggleSave(String campaignId) async {
    try {
      final token = _tokenService.getToken();

      if (token == null) {
        state = state.copyWith(error: 'Not authenticated');
        return false;
      }

      await _apiService.toggleFavorite(
        campaignId: campaignId,
        token: token,
      );

      // Refresh saved campaigns list
      await loadSavedCampaigns();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  bool isSaved(String campaignId) {
    return state.savedCampaigns.any((c) => c.id == campaignId);
  }
}
