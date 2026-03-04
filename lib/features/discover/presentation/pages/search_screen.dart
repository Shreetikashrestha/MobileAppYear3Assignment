import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/app/theme/app_colors.dart';
import 'package:influcollb_app/app/theme/app_text_styles.dart';
import 'package:influcollb_app/features/campaign/presentation/view_model/campaign_providers.dart';
import 'package:influcollb_app/features/campaign/presentation/widgets/campaign_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  List<String> recentSearches = [
    'Fashion',
    'Fitness',
    'Beauty',
    'Travel',
    'Technology'
  ];

  @override
  void initState() {
    super.initState();
    // Load campaigns on init if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(campaignViewModelProvider.notifier).loadCampaigns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(campaignViewModelProvider);
    final query = searchController.text.toLowerCase();

    final filteredCampaigns = state.campaigns.where((campaign) {
      return campaign.title.toLowerCase().contains(query) ||
          campaign.category.toLowerCase().contains(query) ||
          campaign.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.20,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/splashbg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Discover Campaigns',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.shadowColor.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search campaigns...',
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search,
                                color: AppColors.primary),
                            suffixIcon: searchController.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      searchController.clear();
                                      setState(() {});
                                    },
                                    child: const Icon(Icons.close),
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // CONTENT
                Expanded(
                  child: state.isLoading && state.campaigns.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : query.isEmpty && recentSearches.isNotEmpty
                          ? _buildRecentSearches()
                          : filteredCampaigns.isEmpty
                              ? _buildNoResults()
                              : RefreshIndicator(
                                  onRefresh: () => ref
                                      .read(campaignViewModelProvider.notifier)
                                      .loadCampaigns(),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    itemCount: filteredCampaigns.length,
                                    itemBuilder: (context, index) {
                                      final campaign = filteredCampaigns[index];
                                      final isSaved = state.savedCampaigns
                                          .any((c) => c.id == campaign.id);
                                      return CampaignCard(
                                        campaign: campaign,
                                        isSaved: isSaved,
                                        onSave: () => ref
                                            .read(campaignViewModelProvider
                                                .notifier)
                                            .toggleSave(campaign.id),
                                      );
                                    },
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Searches',
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches.map((search) {
              return GestureDetector(
                onTap: () {
                  searchController.text = search;
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor.withValues(alpha: 0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    search,
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No campaigns found for "${searchController.text}"',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
