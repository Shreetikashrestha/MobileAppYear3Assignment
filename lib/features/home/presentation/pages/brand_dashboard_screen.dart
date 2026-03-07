import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/campaign/presentation/view_model/campaign_providers.dart';
import 'package:influcollb_app/features/campaign/presentation/pages/create_campaign_screen.dart';
import 'package:influcollb_app/features/campaign/presentation/pages/comprehensive_campaign_detail_screen.dart';
import 'package:influcollb_app/features/notification/presentation/pages/notifications_screen.dart';
import 'package:influcollb_app/features/application/presentation/pages/all_brand_applications_screen.dart';
import 'package:influcollb_app/core/providers/core_providers.dart';
import 'package:intl/intl.dart';

class BrandDashboardScreen extends ConsumerStatefulWidget {
  const BrandDashboardScreen({super.key});

  @override
  ConsumerState<BrandDashboardScreen> createState() =>
      _BrandDashboardScreenState();
}

class _BrandDashboardScreenState extends ConsumerState<BrandDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all';
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(campaignViewModelProvider.notifier).loadMyBrandCampaigns();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(campaignViewModelProvider);
    final campaigns = state.myBrandCampaigns;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1033) : const Color(0xFFFCFCFD);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardColor = isDark ? const Color(0xFF2D1B4E) : Colors.white;

    // Calculate stats
    final activeCampaigns = campaigns.where((c) => c.status == 'active').length;
    final totalApplicants =
        campaigns.fold<int>(0, (sum, c) => sum + c.applicantsCount);
    final totalBudget =
        campaigns.fold<int>(0, (sum, c) => sum + (c.budgetMax?.toInt() ?? 0));

    // Filter campaigns
    final filteredCampaigns = campaigns.where((c) {
      final matchSearch = _searchTerm.isEmpty ||
          c.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          (c.category?.toLowerCase().contains(_searchTerm.toLowerCase()) ??
              false);
      final matchStatus = _statusFilter == 'all' || c.status == _statusFilter;
      return matchSearch && matchStatus;
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(campaignViewModelProvider.notifier)
                .loadMyBrandCampaigns();
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
                      // Title and Actions Row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Campaign Dashboard',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          // Notification Bell
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_outlined,
                                      size: 20),
                                  color: const Color(0xFF94A3B8),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // New Campaign Button
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateCampaignScreen(),
                                ),
                              ).then((_) {
                                ref
                                    .read(campaignViewModelProvider.notifier)
                                    .loadMyBrandCampaigns();
                              });
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text(
                              'New Campaign',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9333EA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              shadowColor:
                                  const Color(0xFF9333EA).withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Overview Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        'Active Campaigns',
                        state.isLoading ? '—' : activeCampaigns.toString(),
                        '${campaigns.length} total',
                        Icons.campaign,
                        const Color(0xFF9333EA),
                        const Color(0xFFF3E8FF),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AllBrandApplicationsScreen(),
                            ),
                          );
                        },
                        child: _buildStatCard(
                          'Total Applicants',
                          state.isLoading ? '—' : totalApplicants.toString(),
                          'across all campaigns',
                          Icons.people,
                          const Color(0xFF2563EB),
                          const Color(0xFFDEEBFF),
                          showArrow: true,
                        ),
                      ),
                      _buildStatCard(
                        'Budget Allocated',
                        state.isLoading
                            ? '—'
                            : 'NPR ${NumberFormat('#,###').format(totalBudget)}',
                        'combined max budget',
                        Icons.attach_money,
                        const Color(0xFF16A34A),
                        const Color(0xFFDCFCE7),
                      ),
                      _buildStatCard(
                        'Campaigns Trend',
                        activeCampaigns > 0 ? 'Active' : 'No Active',
                        'current status',
                        Icons.trending_up,
                        const Color(0xFFEA580C),
                        const Color(0xFFFFEDD5),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Campaign Management Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Campaigns',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${campaigns.length} campaign${campaigns.length != 1 ? 's' : ''} created',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          // Status Filter
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButton<String>(
                              value: _statusFilter,
                              underline: const SizedBox(),
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'all', child: Text('All Campaigns')),
                                DropdownMenuItem(
                                    value: 'active', child: Text('Active')),
                                DropdownMenuItem(
                                    value: 'completed',
                                    child: Text('Completed')),
                              ],
                              onChanged: (value) {
                                setState(() => _statusFilter = value!);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Campaign List
              if (state.isLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: List.generate(
                        3,
                        (index) => Container(
                          height: 96,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else if (filteredCampaigns.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildEmptyState(),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final campaign = filteredCampaigns[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 8),
                        child: _buildCampaignCard(campaign),
                      );
                    },
                    childCount: filteredCampaigns.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color iconColor,
    Color bgColor, {
    bool showArrow = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (showArrow)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(96),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 2,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.campaign,
              size: 32,
              color: Color(0xFFE2E8F0),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchTerm.isNotEmpty
                ? 'No matching campaigns'
                : "You haven't created any campaigns yet",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchTerm.isNotEmpty
                ? 'Try a different search term'
                : 'Launch your first campaign to start connecting with top influencers.',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchTerm.isEmpty) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCampaignScreen(),
                  ),
                ).then((_) {
                  ref
                      .read(campaignViewModelProvider.notifier)
                      .loadMyBrandCampaigns();
                });
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Create Your First Campaign',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: const Color(0xFF9333EA).withOpacity(0.3),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCampaignCard(campaign) {
    final statusColor = campaign.status == 'active'
        ? const Color(0xFF16A34A)
        : campaign.status == 'completed'
            ? const Color(0xFF2563EB)
            : const Color(0xFFEAB308);

    final statusBg = campaign.status == 'active'
        ? const Color(0xFFDCFCE7)
        : campaign.status == 'completed'
            ? const Color(0xFFDEEBFF)
            : const Color(0xFFFEF3C7);

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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        campaign.description ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    campaign.status == 'active'
                        ? 'Active'
                        : campaign.status == 'completed'
                            ? 'Completed'
                            : 'Draft',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  Icons.attach_money,
                  'NPR ${NumberFormat('#,###').format(campaign.budgetMin ?? 0)} – ${NumberFormat('#,###').format(campaign.budgetMax ?? 0)}',
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  Icons.calendar_today,
                  campaign.deadline != null
                      ? DateFormat('dd MMM yyyy').format(campaign.deadline!)
                      : '—',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                    Icons.location_on, campaign.location ?? 'Remote'),
                const SizedBox(width: 12),
                _buildInfoChip(Icons.category, campaign.category ?? 'General'),
              ],
            ),
            const SizedBox(height: 16),
            // Only show applicants count (dynamic data from backend)
            Row(
              children: [
                _buildMetric(Icons.people, campaign.applicantsCount.toString(),
                    'Applicants'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
