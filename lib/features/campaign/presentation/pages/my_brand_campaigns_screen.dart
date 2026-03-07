import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/campaign/data/models/campaign_model.dart';
import 'package:influcollb_app/features/campaign/presentation/pages/create_campaign_screen.dart';
import 'package:influcollb_app/features/campaign/presentation/pages/edit_campaign_screen.dart';
import 'package:influcollb_app/features/campaign/presentation/pages/campaign_detail_screen.dart';
import 'package:influcollb_app/features/campaign/presentation/view_model/campaign_providers.dart';
import 'package:intl/intl.dart';

class MyBrandCampaignsScreen extends ConsumerStatefulWidget {
  const MyBrandCampaignsScreen({super.key});

  @override
  ConsumerState<MyBrandCampaignsScreen> createState() => _MyBrandCampaignsScreenState();
}

class _MyBrandCampaignsScreenState extends ConsumerState<MyBrandCampaignsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Load campaigns when screen opens
    Future.microtask(() {
      ref.read(campaignViewModelProvider.notifier).loadMyBrandCampaigns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(campaignViewModelProvider);
    final campaigns = _filterCampaigns(state.myBrandCampaigns);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Campaigns'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(campaignViewModelProvider.notifier).loadMyBrandCampaigns();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', state.myBrandCampaigns.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Active',
                    'active',
                    state.myBrandCampaigns.where((c) => c.status == 'active').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Completed',
                    'completed',
                    state.myBrandCampaigns.where((c) => c.status == 'completed').length,
                  ),
                ],
              ),
            ),
          ),

          // Campaigns List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(state.error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(campaignViewModelProvider.notifier).loadMyBrandCampaigns();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : campaigns.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.campaign, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedFilter == 'all'
                                      ? 'No campaigns yet'
                                      : 'No $_selectedFilter campaigns',
                                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Create your first campaign to get started',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref.read(campaignViewModelProvider.notifier).loadMyBrandCampaigns();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: campaigns.length,
                              itemBuilder: (context, index) {
                                final campaign = campaigns[index];
                                return _buildCampaignCard(campaign);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateCampaignScreen(),
            ),
          );
          if (result == true) {
            ref.read(campaignViewModelProvider.notifier).loadMyBrandCampaigns();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Campaign'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  List<Campaign> _filterCampaigns(List<Campaign> campaigns) {
    if (_selectedFilter == 'all') {
      return campaigns;
    }
    return campaigns.where((c) => c.status == _selectedFilter).toList();
  }

  Widget _buildCampaignCard(Campaign campaign) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CampaignDetailScreen(campaign: campaign),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      campaign.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(campaign.status),
                ],
              ),
              const SizedBox(height: 8),

              // Category
              Row(
                children: [
                  const Icon(Icons.category, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    campaign.category,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                campaign.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),

              // Stats Row
              Row(
                children: [
                  _buildStatItem(
                    Icons.people,
                    '${campaign.applicantsCount} Applicants',
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    Icons.attach_money,
                    campaign.budgetRange,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Deadline
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Deadline: ${DateFormat('MMM dd, yyyy').format(campaign.deadline)}',
                    style: TextStyle(
                      color: campaign.deadline.isBefore(DateTime.now())
                          ? Colors.red
                          : Colors.grey,
                      fontWeight: campaign.deadline.isBefore(DateTime.now())
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CampaignDetailScreen(campaign: campaign),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditCampaignScreen(campaign: campaign),
                        ),
                      );
                      if (result == true) {
                        ref.read(campaignViewModelProvider.notifier).loadMyBrandCampaigns();
                      }
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'draft':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
