import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/app/theme/app_colors.dart';
import 'package:influcollb_app/app/theme/app_text_styles.dart';
import 'package:influcollb_app/features/campaign/presentation/view_model/campaign_providers.dart';
import 'package:influcollb_app/features/campaign/presentation/widgets/campaign_card.dart';

class SavedCampaignsScreen extends ConsumerStatefulWidget {
  const SavedCampaignsScreen({super.key});

  @override
  ConsumerState<SavedCampaignsScreen> createState() =>
      _SavedCampaignsScreenState();
}

class _SavedCampaignsScreenState extends ConsumerState<SavedCampaignsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh saved campaigns when screen opens to ensure sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(campaignViewModelProvider.notifier).loadSavedCampaigns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(campaignViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Saved Campaigns', style: AppTextStyles.heading3),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/splashbg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          state.savedCampaigns.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.savedCampaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = state.savedCampaigns[index];
                    return CampaignCard(
                      campaign: campaign,
                      isSaved: true, // Always true here
                      onSave: () {
                        ref
                            .read(campaignViewModelProvider.notifier)
                            .toggleSave(campaign.id);
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No saved campaigns yet',
            style: AppTextStyles.heading4.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'Campaigns you favorite will appear here.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
