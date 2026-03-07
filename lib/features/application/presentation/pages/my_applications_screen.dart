import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/application/presentation/view_model/application_providers.dart';
import 'package:influcollb_app/features/application/presentation/widgets/application_card.dart';

class MyApplicationsScreen extends ConsumerStatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  ConsumerState<MyApplicationsScreen> createState() =>
      _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Load applications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(applicationViewModelProvider.notifier).getMyApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final applicationState = ref.watch(applicationViewModelProvider);
    final applications = applicationState.myApplications;

    // Filter applications based on selected filter
    final filteredApplications = _selectedFilter == 'all'
        ? applications
        : applications
            .where((app) =>
                app.status.toLowerCase() == _selectedFilter.toLowerCase())
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(applicationViewModelProvider.notifier).getMyApplications();
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
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
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
                                    .getMyApplications();
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
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedFilter == 'all'
                                      ? 'No applications yet'
                                      : 'No $_selectedFilter applications',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start applying to campaigns!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(applicationViewModelProvider.notifier)
                                  .getMyApplications();
                            },
                            child: ListView.builder(
                              itemCount: filteredApplications.length,
                              padding: const EdgeInsets.only(bottom: 16),
                              itemBuilder: (context, index) {
                                final application = filteredApplications[index];
                                return ApplicationCard(
                                  application: application,
                                  showCampaignInfo: true,
                                  onTap: () {
                                    // Show application details in a bottom sheet
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      builder: (context) => DraggableScrollableSheet(
                                        initialChildSize: 0.6,
                                        minChildSize: 0.4,
                                        maxChildSize: 0.9,
                                        expand: false,
                                        builder: (context, scrollController) {
                                          return Container(
                                            padding: const EdgeInsets.all(24),
                                            child: ListView(
                                              controller: scrollController,
                                              children: [
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
                                                Text(
                                                  'Application Details',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                _buildDetailRow('Campaign', application.campaignTitle ?? 'N/A'),
                                                const SizedBox(height: 16),
                                                _buildDetailRow('Status', application.statusDisplay),
                                                const SizedBox(height: 16),
                                                _buildDetailRow('Proposed Rate', 'NPR ${application.proposedRate}'),
                                                const SizedBox(height: 16),
                                                _buildDetailRow('Cover Letter', application.coverLetter),
                                                if (application.portfolioLinks.isNotEmpty) ...[
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    'Portfolio Links',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  ...application.portfolioLinks.map((link) => Padding(
                                                    padding: const EdgeInsets.only(bottom: 8),
                                                    child: Text(
                                                      link,
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        decoration: TextDecoration.underline,
                                                      ),
                                                    ),
                                                  )),
                                                ],
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
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
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
