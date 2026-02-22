import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/campaign/presentation/widgets/campaign_card.dart';
import 'package:influcollb_app/features/campaign/presentation/view_model/campaign_view_model.dart';
import 'package:influcollb_app/features/campaign/data/models/campaign_model.dart';

class InfluencerDashboardScreen extends ConsumerStatefulWidget {
  const InfluencerDashboardScreen({super.key});

  @override
  ConsumerState<InfluencerDashboardScreen> createState() =>
      _InfluencerDashboardScreenState();
}

class _InfluencerDashboardScreenState
    extends ConsumerState<InfluencerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch campaigns on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(campaignViewModelProvider.notifier).loadCampaigns();
    });
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(campaignViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Dashboard',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(campaignViewModelProvider.notifier).loadCampaigns(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search campaigns...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              // Stats
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8F00FF), Color(0xFFDA22FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Active Campaigns',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Text('${state.campaigns.length}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5E69), Color(0xFFB16CEA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Total Earnings',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 8),
                          Text('NPR 0',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Available Campaigns',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              // Campaign list
              Expanded(
                child: state.isLoading && state.campaigns.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.error != null && state.campaigns.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Error: ${state.error}'),
                                ElevatedButton(
                                  onPressed: () => ref
                                      .read(campaignViewModelProvider.notifier)
                                      .loadCampaigns(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : state.campaigns.isEmpty
                            ? const Center(
                                child: Text('No active campaigns found.'),
                              )
                            : ListView.builder(
                                itemCount: state.campaigns.length,
                                itemBuilder: (context, index) {
                                  final campaign = state.campaigns[index];
                                  final isSaved = state.savedCampaigns.any((c) => c.id == campaign.id);
                                  
                                  return CampaignCard(
                                    campaign: campaign,
                                    isSaved: isSaved,
                                    onSave: () {
                                      ref.read(campaignViewModelProvider.notifier).toggleSave(campaign.id);
                                    },
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
