import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/services/storage/user_session_service.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';
import 'package:influcollb_app/features/application/presentation/view_model/application_providers.dart';

class ApplicationFormScreen extends ConsumerStatefulWidget {
  final String campaignId;
  final String campaignTitle;

  const ApplicationFormScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
  });

  @override
  ConsumerState<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState
    extends ConsumerState<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();
  final _proposedRateController = TextEditingController();
  final _portfolioLinkController = TextEditingController();
  final List<String> _portfolioLinks = [];

  @override
  void dispose() {
    _coverLetterController.dispose();
    _proposedRateController.dispose();
    _portfolioLinkController.dispose();
    super.dispose();
  }

  void _addPortfolioLink() {
    final link = _portfolioLinkController.text.trim();
    if (link.isNotEmpty) {
      setState(() {
        _portfolioLinks.add(link);
        _portfolioLinkController.clear();
      });
    }
  }

  void _removePortfolioLink(int index) {
    setState(() {
      _portfolioLinks.removeAt(index);
    });
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get current user ID
    final userSession = ref.read(userSessionServiceProvider);
    final userId = await userSession.getUserId();

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
      }
      return;
    }

    final application = ApplicationModel(
      campaignId: widget.campaignId,
      influencerId: userId,
      coverLetter: _coverLetterController.text.trim(),
      proposedRate: _proposedRateController.text.trim(),
      portfolioLinks: _portfolioLinks,
    );

    final success = await ref
        .read(applicationViewModelProvider.notifier)
        .submitApplication(application);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final error = ref.read(applicationViewModelProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to submit application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationState = ref.watch(applicationViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply to Campaign'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign Info
              Card(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.campaign,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Applying to:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.campaignTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Cover Letter
              const Text(
                'Cover Letter *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _coverLetterController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText:
                      'Tell the brand why you\'re the perfect fit for this campaign...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a cover letter';
                  }
                  if (value.trim().length < 50) {
                    return 'Cover letter must be at least 50 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Proposed Rate
              const Text(
                'Proposed Rate (NPR) *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _proposedRateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter your proposed rate',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your proposed rate';
                  }
                  final rate = double.tryParse(value.trim());
                  if (rate == null || rate <= 0) {
                    return 'Please enter a valid rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Portfolio Links
              const Text(
                'Portfolio Links',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _portfolioLinkController,
                      decoration: InputDecoration(
                        hintText: 'Add portfolio link (optional)',
                        prefixIcon: const Icon(Icons.link),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addPortfolioLink,
                    icon: const Icon(Icons.add_circle),
                    color: Theme.of(context).primaryColor,
                    iconSize: 32,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Portfolio Links List
              if (_portfolioLinks.isNotEmpty)
                ...List.generate(_portfolioLinks.length, (index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.link, size: 20),
                      title: Text(
                        _portfolioLinks[index],
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removePortfolioLink(index),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: applicationState.isSubmitting
                      ? null
                      : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: applicationState.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit Application',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
