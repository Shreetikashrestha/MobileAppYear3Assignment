import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';
import 'package:influcollb_app/features/application/presentation/view_model/application_providers.dart';
import 'package:influcollb_app/features/application/presentation/widgets/application_card.dart';

class CampaignApplicationsScreen extends ConsumerStatefulWidget {
  final String campaignId;
  final String campaignTitle;

  const CampaignApplicationsScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
  });

  @override
  ConsumerState<CampaignApplicationsScreen> createState() =>
      _CampaignApplicationsScreenState();
}

class _CampaignApplicationsScreenState
    extends ConsumerState<CampaignApplicationsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Load applications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(applicationViewModelProvider.notifier)
          .getCampaignApplications(widget.campaignId);
    });
  }

  Future<void> _showApplicationDetail(ApplicationModel application) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ApplicationDetailSheet(application: application),
    );

    // Refresh if status was updated
    if (result == true && mounted) {
      ref
          .read(applicationViewModelProvider.notifier)
          .getCampaignApplications(widget.campaignId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationState = ref.watch(applicationViewModelProvider);
    final applications = applicationState.campaignApplications;

    // Filter applications
    final filteredApplications = _selectedFilter == 'all'
        ? applications
        : applications
            .where((app) =>
                app.status.toLowerCase() == _selectedFilter.toLowerCase())
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Applications', style: TextStyle(fontSize: 18)),
            Text(
              widget.campaignTitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(applicationViewModelProvider.notifier)
                  .getCampaignApplications(widget.campaignId);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', applications.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    'pending',
                    applications
                        .where((app) => app.status.toLowerCase() == 'pending')
                        .length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Accepted',
                    'accepted',
                    applications
                        .where((app) => app.status.toLowerCase() == 'accepted')
                        .length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Rejected',
                    'rejected',
                    applications
                        .where((app) => app.status.toLowerCase() == 'rejected')
                        .length,
                  ),
                ],
              ),
            ),
          ),

          // Applications List
          Expanded(
            child: applicationState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : applicationState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              applicationState.error!,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                ref
                                    .read(applicationViewModelProvider.notifier)
                                    .getCampaignApplications(widget.campaignId);
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredApplications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedFilter == 'all'
                                      ? 'No applications yet'
                                      : 'No $_selectedFilter applications',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(applicationViewModelProvider.notifier)
                                  .getCampaignApplications(widget.campaignId);
                            },
                            child: ListView.builder(
                              itemCount: filteredApplications.length,
                              padding: const EdgeInsets.only(bottom: 16),
                              itemBuilder: (context, index) {
                                final application = filteredApplications[index];
                                return ApplicationCard(
                                  application: application,
                                  showCampaignInfo: false,
                                  onTap: () =>
                                      _showApplicationDetail(application),
                                );
                              },
                            ),
                          ),
          ),
        ],
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
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _ApplicationDetailSheet extends ConsumerWidget {
  final ApplicationModel application;

  const _ApplicationDetailSheet({required this.application});

  Future<void> _updateStatus(
      BuildContext context, WidgetRef ref, String status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${status == 'accepted' ? 'Accept' : 'Reject'} Application'),
        content: Text(
          'Are you sure you want to ${status == 'accepted' ? 'accept' : 'reject'} this application from ${application.influencerName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  status == 'accepted' ? Colors.green : Colors.red,
            ),
            child: Text(status == 'accepted' ? 'Accept' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(applicationViewModelProvider.notifier)
          .updateApplicationStatus(application.id!, status);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Application ${status == 'accepted' ? 'accepted' : 'rejected'} successfully'),
              backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
            ),
          );
          Navigator.pop(context, true);
        } else {
          final error = ref.read(applicationViewModelProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to update status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationState = ref.watch(applicationViewModelProvider);
    final isPending = application.status.toLowerCase() == 'pending';

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(
                      application.influencerName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.influencerName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Status: ${application.statusDisplay}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildSection(
                      'Proposed Rate',
                      'NPR ${application.proposedRate}',
                      Icons.attach_money,
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      'Cover Letter',
                      application.coverLetter,
                      Icons.description,
                    ),
                    if (application.portfolioLinks.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildPortfolioSection(application.portfolioLinks),
                    ],
                  ],
                ),
              ),

              // Action Buttons (only for pending applications)
              if (isPending) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: applicationState.isUpdating
                            ? null
                            : () => _updateStatus(context, ref, 'rejected'),
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: applicationState.isUpdating
                            ? null
                            : () => _updateStatus(context, ref, 'accepted'),
                        icon: const Icon(Icons.check),
                        label: applicationState.isUpdating
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioSection(List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.link, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            const Text(
              'Portfolio Links',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  // TODO: Open link in browser
                },
                child: Text(
                  link,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
