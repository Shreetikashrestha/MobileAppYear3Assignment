import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/campaign/presentation/view_model/campaign_providers.dart';
import 'package:influcollb_app/features/campaign/presentation/pages/comprehensive_campaign_detail_screen.dart';
import 'package:influcollb_app/features/campaign/data/models/campaign_model.dart';
import 'package:intl/intl.dart';
import 'package:influcollb_app/core/services/sensor/shake_detector_service.dart';

class BrowseCampaignsScreen extends ConsumerStatefulWidget {
  const BrowseCampaignsScreen({super.key});

  @override
  ConsumerState<BrowseCampaignsScreen> createState() =>
      _BrowseCampaignsScreenState();
}

class _BrowseCampaignsScreenState extends ConsumerState<BrowseCampaignsScreen>
    with ShakeDetectorMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String _categoryFilter = 'all';
  String _locationFilter = 'all';
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    // Start shake detection
    startShakeDetection();
    Future.microtask(() {
      ref.read(campaignViewModelProvider.notifier).loadAllCampaigns();
    });
  }

  @override
  void onShakeDetected() {
    // Refresh campaigns when shake is detected
    debugPrint('📳 Shake detected! Refreshing campaigns...');
    ref.read(campaignViewModelProvider.notifier).loadAllCampaigns();
    
    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 8),
            Text('Refreshing campaigns...'),
          ],
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Campaign> get _filteredCampaigns {
    final state = ref.watch(campaignViewModelProvider);
    var campaigns = state.campaigns.toList();

    // Apply search filter
    if (_searchTerm.isNotEmpty) {
      campaigns = campaigns.where((c) {
        return c.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
            (c.description?.toLowerCase().contains(_searchTerm.toLowerCase()) ??
                false) ||
            (c.category?.toLowerCase().contains(_searchTerm.toLowerCase()) ??
                false);
      }).toList();
    }

    // Apply category filter
    if (_categoryFilter != 'all') {
      campaigns = campaigns
          .where((c) => c.category?.toLowerCase() == _categoryFilter.toLowerCase())
          .toList();
    }

    // Apply location filter
    if (_locationFilter != 'all') {
      campaigns = campaigns
          .where((c) => c.location?.toLowerCase() == _locationFilter.toLowerCase())
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'newest':
        campaigns.sort((a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
        break;
      case 'budget_high':
        campaigns.sort((a, b) => (b.budgetMax ?? 0).compareTo(a.budgetMax ?? 0));
        break;
      case 'budget_low':
        campaigns.sort((a, b) => (a.budgetMax ?? 0).compareTo(b.budgetMax ?? 0));
        break;
      case 'deadline':
        campaigns.sort((a, b) => (a.deadline ?? DateTime.now())
            .compareTo(b.deadline ?? DateTime.now()));
        break;
    }

    return campaigns;
  }

  Set<String> get _availableCategories {
    final state = ref.watch(campaignViewModelProvider);
    return state.campaigns
        .where((c) => c.category != null)
        .map((c) => c.category!)
        .toSet();
  }

  Set<String> get _availableLocations {
    final state = ref.watch(campaignViewModelProvider);
    return state.campaigns
        .where((c) => c.location != null)
        .map((c) => c.location!)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(campaignViewModelProvider);
    final filteredCampaigns = _filteredCampaigns;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Browse Campaigns',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(campaignViewModelProvider.notifier).loadAllCampaigns();
        },
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discover Campaigns',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${filteredCampaigns.length} campaigns available',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search and Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() => _searchTerm = value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search campaigns...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF94A3B8).withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filters Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            'Category',
                            _categoryFilter,
                            Icons.category,
                            () => _showCategoryFilter(),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Location',
                            _locationFilter,
                            Icons.location_on,
                            () => _showLocationFilter(),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Sort',
                            _getSortLabel(),
                            Icons.sort,
                            () => _showSortOptions(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Campaigns Grid
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filteredCampaigns.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No campaigns found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final campaign = filteredCampaigns[index];
                      return _buildCampaignCard(campaign);
                    },
                    childCount: filteredCampaigns.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, String value, IconData icon, VoidCallback onTap) {
    final isActive = value != 'all' && value != 'newest';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ComprehensiveCampaignDetailScreen(campaignId: campaign.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: Icon(
                  Icons.campaign,
                  size: 40,
                  color: Color(0xFFCBD5E1),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    if (campaign.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEEBFF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          campaign.category!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      campaign.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // Budget
                    if (campaign.budgetMax != null)
                      Text(
                        'NPR ${NumberFormat('#,###').format(campaign.budgetMax)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    const SizedBox(height: 4),

                    // Location
                    if (campaign.location != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              campaign.location!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'newest':
        return 'Newest';
      case 'budget_high':
        return 'Highest Budget';
      case 'budget_low':
        return 'Lowest Budget';
      case 'deadline':
        return 'Deadline';
      default:
        return 'Sort';
    }
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('All Categories'),
                trailing: _categoryFilter == 'all'
                    ? const Icon(Icons.check, color: Color(0xFF2563EB))
                    : null,
                onTap: () {
                  setState(() => _categoryFilter = 'all');
                  Navigator.pop(context);
                },
              ),
              ..._availableCategories.map((category) {
                return ListTile(
                  title: Text(category),
                  trailing: _categoryFilter == category
                      ? const Icon(Icons.check, color: Color(0xFF2563EB))
                      : null,
                  onTap: () {
                    setState(() => _categoryFilter = category);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showLocationFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('All Locations'),
                trailing: _locationFilter == 'all'
                    ? const Icon(Icons.check, color: Color(0xFF2563EB))
                    : null,
                onTap: () {
                  setState(() => _locationFilter = 'all');
                  Navigator.pop(context);
                },
              ),
              ..._availableLocations.map((location) {
                return ListTile(
                  title: Text(location),
                  trailing: _locationFilter == location
                      ? const Icon(Icons.check, color: Color(0xFF2563EB))
                      : null,
                  onTap: () {
                    setState(() => _locationFilter = location);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Newest First'),
                trailing: _sortBy == 'newest'
                    ? const Icon(Icons.check, color: Color(0xFF2563EB))
                    : null,
                onTap: () {
                  setState(() => _sortBy = 'newest');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Highest Budget'),
                trailing: _sortBy == 'budget_high'
                    ? const Icon(Icons.check, color: Color(0xFF2563EB))
                    : null,
                onTap: () {
                  setState(() => _sortBy = 'budget_high');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Lowest Budget'),
                trailing: _sortBy == 'budget_low'
                    ? const Icon(Icons.check, color: Color(0xFF2563EB))
                    : null,
                onTap: () {
                  setState(() => _sortBy = 'budget_low');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Deadline (Soonest)'),
                trailing: _sortBy == 'deadline'
                    ? const Icon(Icons.check, color: Color(0xFF2563EB))
                    : null,
                onTap: () {
                  setState(() => _sortBy = 'deadline');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
