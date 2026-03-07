import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:influcollb_app/features/campaign/data/models/application_model.dart';
import 'package:influcollb_app/features/campaign/presentation/widgets/applicant_card.dart';

import 'package:influcollb_app/features/campaign/data/models/campaign_model.dart';
import 'package:influcollb_app/features/home/presentation/pages/create_campaign_screen.dart';

class CampaignApplicantsScreen extends ConsumerStatefulWidget {
  final Campaign campaign;

  const CampaignApplicantsScreen({
    super.key,
    required this.campaign,
  });

  @override
  ConsumerState<CampaignApplicantsScreen> createState() =>
      _CampaignApplicantsScreenState();
}

class _CampaignApplicantsScreenState
    extends ConsumerState<CampaignApplicantsScreen> {
  List<Application> _applications = [];
  bool _isLoading = false;
  String? _error;
  String _selectedFilter = 'all'; // all, pending, accepted, rejected

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final status = _selectedFilter == 'all' ? null : _selectedFilter;
      final data = await apiService.getCampaignApplications(
        campaignId: widget.campaign.id,
        status: status,
      );
      final applications = data.map((e) => Application.fromJson(e)).toList();

      setState(() {
        _applications = applications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String applicationId, String status) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Application ${status == 'accepted' ? 'accepted' : 'rejected'} successfully!'),
            backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
          ),
        );
      }

      // Reload applications
      _loadApplications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.campaign.title,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF8F00FF)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateCampaignScreen(
                    campaign: widget.campaign,
                  ),
                ),
              );
              if (result == true) {
                if (context.mounted) {
                  Navigator.pop(context, true); // Signal parent to refresh
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Accepted', 'accepted'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejected', 'rejected'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Applications list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadApplications,
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
                                onPressed: _loadApplications,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _applications.isEmpty
                          ? const Center(
                              child: Text('No applications found.'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _applications.length,
                              itemBuilder: (context, index) {
                                final application = _applications[index];
                                return ApplicantCard(
                                  application: application,
                                  onAccept: () =>
                                      _updateStatus(application.id, 'accepted'),
                                  onReject: () =>
                                      _updateStatus(application.id, 'rejected'),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        _loadApplications();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8F00FF) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
