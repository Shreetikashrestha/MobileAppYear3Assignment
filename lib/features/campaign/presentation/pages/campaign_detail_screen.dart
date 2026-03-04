import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/campaign_model.dart';
import '../view_model/campaign_providers.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../application/presentation/pages/application_form_screen.dart';
import '../../../application/presentation/view_model/application_providers.dart';

class CampaignDetailScreen extends ConsumerWidget {
  final Campaign campaign;

  const CampaignDetailScreen({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignState = ref.watch(campaignViewModelProvider);
    final applicationState = ref.watch(applicationViewModelProvider);
    final isApplying = campaignState.isApplying;
    
    // Check if user has already applied to this campaign
    final hasApplied = applicationState.myApplications.any(
      (app) => app.campaignId == campaign.id,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Campaign Details',
          style: AppTextStyles.heading3.copyWith(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                campaign.category.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              campaign.title,
              style: AppTextStyles.heading2
                  .copyWith(fontSize: 28, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              campaign.brandName,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'About the Campaign',
              style: AppTextStyles.heading3
                  .copyWith(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              campaign.description,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.6,
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailGrid(),
            const SizedBox(height: 32),
            if (campaign.requirements.isNotEmpty) ...[
              Text(
                'Requirements',
                style: AppTextStyles.heading3
                    .copyWith(fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 16),
              ...campaign.requirements.map((req) => _buildListItem(req)),
              const SizedBox(height: 32),
            ],
            if (campaign.deliverables.isNotEmpty) ...[
              Text(
                'Deliverables',
                style: AppTextStyles.heading3
                    .copyWith(fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 16),
              ...campaign.deliverables.map((del) => _buildListItem(del)),
              const SizedBox(height: 32),
            ],
            const SizedBox(height: 80), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E24AA), Color(0xFFD81B60)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD81B60).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: (isApplying || hasApplied) ? null : () => _handleApply(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isApplying
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        hasApplied ? 'Already Applied' : 'Apply Now',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(Icons.attach_money, 'Budget',
                    campaign.budgetRange, const Color(0xFF4CAF50)),
              ),
              Expanded(
                child: _buildDetailItem(Icons.calendar_today, 'Deadline',
                    campaign.formattedDeadline, const Color(0xFF2196F3)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(Icons.location_on_outlined, 'Location',
                    campaign.location, const Color(0xFF9C27B0)),
              ),
              Expanded(
                child: _buildDetailItem(Icons.people_outline, 'Applicants',
                    '${campaign.applicantsCount}', const Color(0xFFFF9800)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    AppTextStyles.bodySmall.copyWith(color: Colors.grey[500]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFD81B60),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApply(BuildContext context, WidgetRef ref) async {
    // Navigate to application form screen
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationFormScreen(
          campaignId: campaign.id,
          campaignTitle: campaign.title,
        ),
      ),
    );

    if (context.mounted && result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
