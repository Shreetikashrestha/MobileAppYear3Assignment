import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:influcollb_app/core/services/storage/user_session_service.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  Map<String, dynamic> _insights = {};
  bool _isVisible = true;
  bool _isInfluencer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInsights();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isVisible) {
      _loadInsights();
    }
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);
    
    try {
      // Check user role
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs: prefs);
      final isInfluencer = userSessionService.getIsInfluencer() ?? false;
      
      setState(() => _isInfluencer = isInfluencer);
      
      final apiClient = ref.read(apiClientProvider);
      
      if (isInfluencer) {
        // For influencers: Load their applications
        final applicationsResponse = await apiClient.get('/api/applications/my-applications');
        final applications = applicationsResponse.data['data'] as List? ?? [];
        
        // Calculate stats from applications
        final acceptedCount = applications.where((a) => a['status'] == 'accepted').length;
        final pendingCount = applications.where((a) => a['status'] == 'pending').length;
        final rejectedCount = applications.where((a) => a['status'] == 'rejected').length;
        
        if (mounted) {
          setState(() {
            _insights = {
              'stats': {
                'totalApplications': applications.length,
                'acceptedApplications': acceptedCount,
                'pendingApplications': pendingCount,
                'rejectedApplications': rejectedCount,
              },
              'applications': applications,
            };
            _isLoading = false;
          });
        }
      } else {
        // For brands: Load campaign stats
        final statsResponse = await apiClient.get('/api/campaigns/brand-stats');
        final campaignsResponse = await apiClient.get('/api/campaigns/my-campaigns');
        
        if (mounted) {
          setState(() {
            _insights = {
              'stats': statsResponse.data['data'] ?? {},
              'campaigns': campaignsResponse.data['data'] ?? [],
            };
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load insights: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isInfluencer ? 'My Collaborations' : 'Insights',
          style: AppTextStyles.heading3,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInsights,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: _isInfluencer
                    ? _buildInfluencerInsights()
                    : _buildBrandInsights(),
              ),
            ),
    );
  }

  Widget _buildInfluencerInsights() {
    final stats = _insights['stats'] ?? {};
    final applications = _insights['applications'] as List? ?? [];
    
    final totalApplications = stats['totalApplications'] ?? 0;
    final acceptedApplications = stats['acceptedApplications'] ?? 0;
    final pendingApplications = stats['pendingApplications'] ?? 0;
    final rejectedApplications = stats['rejectedApplications'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview', style: AppTextStyles.heading3),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Applications',
                totalApplications.toString(),
                Icons.apps,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Accepted',
                acceptedApplications.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pending',
                pendingApplications.toString(),
                Icons.pending,
                Colors.orange,
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
        const SizedBox(height: 24),
        _buildApplicationStats(acceptedApplications, totalApplications, pendingApplications),
        const SizedBox(height: 24),
        if (applications.isNotEmpty)
          _buildRecentApplications(applications),
      ],
    );
  }

  Widget _buildBrandInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverviewCards(),
        const SizedBox(height: 24),
        _buildCampaignPerformance(),
        const SizedBox(height: 24),
        _buildApplicationStats(),
        const SizedBox(height: 24),
        _buildEngagementChart(),
      ],
    );
  }

  Widget _buildRecentApplications(List applications) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Applications', style: AppTextStyles.heading4),
          const SizedBox(height: 16),
          ...applications.take(5).map((app) {
            final campaign = app['campaignId'] is Map ? app['campaignId'] : {};
            final campaignTitle = campaign is Map ? campaign['title'] ?? 'Campaign' : 'Campaign';
            final status = app['status'] ?? 'pending';
            final statusColor = status == 'accepted'
                ? Colors.green
                : status == 'rejected'
                    ? Colors.red
                    : Colors.orange;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaignTitle,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      status == 'accepted'
                          ? Icons.check_circle
                          : status == 'rejected'
                              ? Icons.cancel
                              : Icons.pending,
                      color: statusColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final stats = _insights['stats'] ?? {};
    final campaigns = _insights['campaigns'] as List? ?? [];
    
    final totalCampaigns = stats['totalCampaigns'] ?? 0;
    final totalApplicants = stats['totalApplicants'] ?? 0;
    final acceptedInfluencers = stats['acceptedInfluencers'] ?? 0;
    final activeCampaigns = campaigns.where((c) => c['status'] == 'active').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview', style: AppTextStyles.heading3),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Campaigns',
                totalCampaigns.toString(),
                Icons.campaign,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Active',
                activeCampaigns.toString(),
                Icons.trending_up,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Applicants',
                totalApplicants.toString(),
                Icons.people,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Hired',
                acceptedInfluencers.toString(),
                Icons.check_circle,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignPerformance() {
    final campaigns = _insights['campaigns'] as List? ?? [];
    
    if (campaigns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Campaign Performance', style: AppTextStyles.heading4),
          const SizedBox(height: 16),
          ...campaigns.take(5).map((campaign) {
            final applicantsCount = campaign['applicantsCount'] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign['title'] ?? 'Untitled',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$applicantsCount applicants',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: campaign['status'] == 'active'
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      campaign['status'] ?? 'unknown',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: campaign['status'] == 'active'
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildApplicationStats([int? acceptedCount, int? totalCount, int? pendingCount]) {
    if (_isInfluencer && acceptedCount != null && totalCount != null && pendingCount != null) {
      // Influencer view
      final rejectedCount = totalCount - acceptedCount - pendingCount;
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Application Status', style: AppTextStyles.heading4),
            const SizedBox(height: 20),
            _buildProgressBar('Accepted', acceptedCount, totalCount, Colors.green),
            const SizedBox(height: 16),
            _buildProgressBar('Pending', pendingCount, totalCount, Colors.orange),
            const SizedBox(height: 16),
            _buildProgressBar('Rejected', rejectedCount, totalCount, Colors.red),
          ],
        ),
      );
    } else {
      // Brand view
      final stats = _insights['stats'] ?? {};
      final totalApplicants = stats['totalApplicants'] ?? 0;
      final acceptedInfluencers = stats['acceptedInfluencers'] ?? 0;
      final pending = totalApplicants - acceptedInfluencers;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Application Stats', style: AppTextStyles.heading4),
            const SizedBox(height: 20),
            _buildProgressBar('Accepted', acceptedInfluencers, totalApplicants, Colors.green),
            const SizedBox(height: 16),
            _buildProgressBar('Pending', pending, totalApplicants, Colors.orange),
          ],
        ),
      );
    }
  }

  Widget _buildProgressBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total * 100).toInt() : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('$value / $total ($percentage%)', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? value / total : 0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildEngagementChart() {
    final campaigns = _insights['campaigns'] as List? ?? [];
    
    if (campaigns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Engagement Overview', style: AppTextStyles.heading4),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: campaigns.map((c) => (c['applicantsCount'] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b) + 5,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= campaigns.length) return const Text('');
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'C${value.toInt() + 1}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                ),
                borderData: FlBorderData(show: false),
                barGroups: campaigns.take(10).toList().asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: (entry.value['applicantsCount'] ?? 0).toDouble(),
                        color: AppColors.primary,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
