import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/api/api_service.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:influcollb_app/features/campaign/data/models/campaign_model.dart';
import 'brand_applications_screen.dart';

class BrandDashboardScreen extends ConsumerStatefulWidget {
  const BrandDashboardScreen({super.key});

  @override
  ConsumerState<BrandDashboardScreen> createState() => _BrandDashboardScreenState();
}

class _BrandDashboardScreenState extends ConsumerState<BrandDashboardScreen> {
  int _selectedTab = 0; // 0: All, 1: Active, 2: Completed
  List<Campaign> _campaigns = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final data = await apiService.getMyCampaigns();
      final campaigns = data.map((e) => Campaign.fromJson(e)).toList();

      setState(() {
        _campaigns = campaigns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Campaign> get _filteredCampaigns {
    if (_selectedTab == 0) return _campaigns; // All
    if (_selectedTab == 1) return _campaigns.where((c) => c.status == 'active').toList(); // Active
    if (_selectedTab == 2) return _campaigns.where((c) => c.status == 'completed').toList(); // Completed
    return _campaigns;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Campaigns',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt, color: Color(0xFF8F00FF)),
            tooltip: 'View Applications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BrandApplicationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTab('All', 0),
                const SizedBox(width: 8),
                _buildTab('Active', 1),
                const SizedBox(width: 8),
                _buildTab('Completed', 2),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $_error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadCampaigns,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredCampaigns.isEmpty
                        ? const Center(
                            child: Text('No campaigns found.'),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadCampaigns,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredCampaigns.length,
                              itemBuilder: (context, index) {
                                final campaign = _filteredCampaigns[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFB16CEA), Color(0xFFFF5E69)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: const Icon(Icons.campaign, color: Colors.white, size: 24),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(campaign.title,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text(campaign.category,
                                                style: const TextStyle(color: Colors.blueGrey)),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF3E8FF),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(campaign.status.toUpperCase(),
                                                      style: const TextStyle(
                                                          color: Color(0xFF8F00FF),
                                                          fontWeight: FontWeight.w500)),
                                                ),
                                                const SizedBox(width: 16),
                                                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text('${campaign.applicantsCount}',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final bool selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8F00FF) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

