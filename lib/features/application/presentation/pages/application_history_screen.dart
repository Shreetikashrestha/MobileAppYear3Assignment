import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/providers/core_providers.dart';
import 'package:influcollb_app/features/application/presentation/view_model/application_providers.dart';
import 'package:influcollb_app/features/campaign/presentation/view_model/campaign_providers.dart';
import 'package:influcollb_app/features/campaign/presentation/pages/campaign_detail_screen.dart';
import 'package:intl/intl.dart';

class ApplicationHistoryScreen extends ConsumerStatefulWidget {
  const ApplicationHistoryScreen({super.key});

  @override
  ConsumerState<ApplicationHistoryScreen> createState() =>
      _ApplicationHistoryScreenState();
}

class _ApplicationHistoryScreenState
    extends ConsumerState<ApplicationHistoryScreen> {
  String _selectedFilter = 'all'; // all, pending, accepted, rejected
  bool _isInfluencer = false;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    // Delay provider modifications until after build phase
    Future.microtask(() => _loadUserRoleAndApplications());
  }

  Future<void> _loadUserRoleAndApplications() async {
    final userSession = ref.read(userSessionServiceProvider);
    final isInfluencer = userSession.getIsInfluencer() ?? false;

    if (!mounted) return;

    setState(() {
      _isInfluencer = isInfluencer;
      _isLoadingRole = false;
    });

    // Load applications based on role
    if (_isInfluencer) {
      // Influencer: Load applications they sent
      if (mounted) {
        ref.read(applicationViewModelProvider.notifier).getMyApplications();
      }
    } else {
      // Brand: Load their campaigns first, then get all applications
      if (mounted) {
        await ref
            .read(campaignViewModelProvider.notifier)
            .loadMyBrandCampaigns();
        final campaigns = ref.read(campaignViewModelProvider).myBrandCampaigns;

        // Fetch applications for all brand campaigns using aggregate method
        if (campaigns.isNotEmpty && mounted) {
          final campaignIds = campaigns.map((c) => c.id).toList();
          await ref
              .read(applicationViewModelProvider.notifier)
              .getApplicationsForCampaigns(campaignIds);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Application History',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final state = ref.watch(applicationViewModelProvider);

    // Get applications based on role
    final applications = _isInfluencer
        ? state.myApplications // Influencer: applications they sent
        : state.campaignApplications; // Brand: applications received

    // Calculate statistics
    final totalApplications = applications.length;
    final pendingApplications =
        applications.where((a) => a.status == 'pending').length;
    final acceptedApplications =
        applications.where((a) => a.status == 'accepted').length;
    final rejectedApplications =
        applications.where((a) => a.status == 'rejected').length;

    // Filter applications
    final filteredApplications = _selectedFilter == 'all'
        ? applications
        : applications.where((a) => a.status == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application History',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              _isInfluencer ? 'Applications Sent' : 'Applications Received',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserRoleAndApplications();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            totalApplications.toString(),
                            Icons.apps,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Pending',
                            pendingApplications.toString(),
                            Icons.pending,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Accepted',
                            acceptedApplications.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Rejected',
                            rejectedApplications.toString(),
                            Icons.cancel,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Filter Tabs
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Applications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', 'all', totalApplications),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                              'Pending', 'pending', pendingApplications),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                              'Accepted', 'accepted', acceptedApplications),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                              'Rejected', 'rejected', rejectedApplications),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Applications List
              if (state.isLoading && applications.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state.error != null && applications.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          state.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUserRoleAndApplications,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filteredApplications.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_selectedFilter == 'all' ? '' : _selectedFilter} applications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isInfluencer
                              ? 'Apply to campaigns to see your history here'
                              : 'Applications from influencers will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredApplications.length,
                  itemBuilder: (context, index) {
                    final application = filteredApplications[index];
                    return _buildApplicationCard(context, application);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    Color chipColor;
    switch (value) {
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'accepted':
        chipColor = Colors.green;
        break;
      case 'rejected':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? chipColor : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, application) {
    final statusColor = application.status == 'accepted'
        ? Colors.green
        : application.status == 'rejected'
            ? Colors.red
            : Colors.orange;

    // Handle campaign as either object or map
    final campaign = application.campaign;
    final campaignTitle =
        campaign is Map ? campaign['title'] as String? : campaign?.title;
    final campaignDescription = campaign is Map
        ? campaign['description'] as String?
        : campaign?.description;
    final campaignCategory =
        campaign is Map ? campaign['category'] as String? : campaign?.category;
    final campaignBudgetMin =
        campaign is Map ? campaign['budgetMin'] as int? : campaign?.budgetMin;
    final campaignBudgetMax =
        campaign is Map ? campaign['budgetMax'] as int? : campaign?.budgetMax;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (campaign != null && _isInfluencer) {
              // Influencer: Navigate to campaign details
              // For now, just show a message since campaign might be a Map
              if (campaign is! Map) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CampaignDetailScreen(campaign: campaign),
                  ),
                );
              }
            }
            // Brand: Could show influencer profile or application details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Show avatar for brand (influencer who applied)
                    if (!_isInfluencer) ...[
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          (application.influencerName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isInfluencer
                                ? (campaignTitle ?? 'Campaign')
                                : (application.influencerName ?? 'Influencer'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_isInfluencer && campaign != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (campaignCategory != null) ...[
                                  Icon(Icons.category,
                                      size: 12, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    campaignCategory,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (campaignBudgetMin != null &&
                                    campaignBudgetMax != null) ...[
                                  Icon(Icons.attach_money,
                                      size: 12, color: Colors.grey[600]),
                                  const SizedBox(width: 2),
                                  Text(
                                    '\$$campaignBudgetMin-\$$campaignBudgetMax',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        application.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Application Details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // For Influencers: Show campaign details prominently
                      if (_isInfluencer && campaign != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.campaign,
                                      size: 14, color: Colors.blue[700]),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Campaign: ${campaignTitle ?? 'Campaign'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (campaignDescription != null &&
                                  campaignDescription!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  campaignDescription!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Icon(Icons.attach_money,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Proposed Rate: ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$${application.proposedRate ?? 0}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _isInfluencer ? 'Applied: ' : 'Received: ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            application.createdAt != null
                                ? DateFormat('MMM dd, yyyy')
                                    .format(application.createdAt!)
                                : 'N/A',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      if (!_isInfluencer && campaignTitle != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.campaign,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Campaign: ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                campaignTitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (application.coverLetter != null &&
                          application.coverLetter!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          _isInfluencer ? 'Your Message:' : 'Message:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.coverLetter!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (application.status == 'accepted') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isInfluencer
                                ? 'Congratulations! Your application was accepted.'
                                : 'Application accepted',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (application.status == 'rejected') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isInfluencer
                                ? 'Unfortunately, your application was not selected.'
                                : 'Application rejected',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Brand: Show accept/reject buttons for pending applications
                if (!_isInfluencer && application.status == 'pending') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleAcceptApplication(
                              context, ref, application),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleRejectApplication(
                              context, ref, application),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAcceptApplication(
      BuildContext context, WidgetRef ref, application) async {
    final success = await ref
        .read(applicationViewModelProvider.notifier)
        .updateApplicationStatus(application.id, 'accepted');

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application accepted!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh applications
        await _loadUserRoleAndApplications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRejectApplication(
      BuildContext context, WidgetRef ref, application) async {
    final success = await ref
        .read(applicationViewModelProvider.notifier)
        .updateApplicationStatus(application.id, 'rejected');

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application rejected!'),
            backgroundColor: Colors.red,
          ),
        );
        // Refresh applications
        await _loadUserRoleAndApplications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reject application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
