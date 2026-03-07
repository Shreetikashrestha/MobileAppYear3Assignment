import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/campaign/data/datasources/campaign_remote_datasource.dart';
import 'package:influcollb_app/features/campaign/presentation/view_model/campaign_providers.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:influcollb_app/core/providers/core_providers.dart';
import 'package:influcollb_app/features/campaign/presentation/pages/edit_campaign_screen.dart';
import 'package:influcollb_app/features/campaign/presentation/widgets/application_modal.dart';
import 'package:influcollb_app/features/campaign/presentation/widgets/applicants_modal.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ComprehensiveCampaignDetailScreen extends ConsumerStatefulWidget {
  final String campaignId;

  const ComprehensiveCampaignDetailScreen({
    super.key,
    required this.campaignId,
  });

  @override
  ConsumerState<ComprehensiveCampaignDetailScreen> createState() =>
      _ComprehensiveCampaignDetailScreenState();
}

class _ComprehensiveCampaignDetailScreenState
    extends ConsumerState<ComprehensiveCampaignDetailScreen> {
  bool _isLoading = true;
  bool _isApplying = false;
  Map<String, dynamic>? _campaign;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _brandProfile;
  bool _alreadyApplied = false;
  bool _showApplicationModal = false;
  bool _showApplicantsModal = false;
  final TextEditingController _applicationMessageController = TextEditingController();
  List<Map<String, dynamic>> _applicants = [];
  bool _loadingApplicants = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _applicationMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final dio = ref.read(dioProvider);
      final campaignDataSource = CampaignRemoteDataSource(apiClient: dio);
      final sessionService = ref.read(userSessionServiceProvider);
      
      // Fetch campaign details - returns Campaign model
      final campaignModel = await campaignDataSource.getCampaignById(widget.campaignId);
      final userId = sessionService.getCurrentUserId();
      
      // Convert Campaign model to Map for easier access
      setState(() {
        _campaign = {
          '_id': campaignModel.id,
          'title': campaignModel.title,
          'description': campaignModel.description,
          'category': campaignModel.category,
          'deadline': campaignModel.deadline,
          'location': campaignModel.location,
          'applicants': [], // Will be populated from applicants count
          'requirements': campaignModel.requirements,
          'deliverables': campaignModel.deliverables,
          'creatorId': {'_id': campaignModel.creatorId},
          'budgetMin': campaignModel.budgetMin,
          'budgetMax': campaignModel.budgetMax,
        };
        _user = {'_id': userId, 'role': sessionService.getUserRole()};
        _alreadyApplied = false; // Will check via applications API
      });
      
      // Fetch brand profile if available
      if (campaignModel.creatorId != null) {
        try {
          // Fetch brand profile directly from API
          final profileResponse = await dio.get('/api/users/${campaignModel.creatorId}');
          if (profileResponse.data['success'] == true) {
            setState(() => _brandProfile = profileResponse.data['data']);
          }
        } catch (e) {
          // Profile fetch failed, continue without it
          print('Failed to fetch brand profile: $e');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load campaign: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _submitApplication(String message) async {
    setState(() => _isApplying = true);
    
    try {
      final dio = ref.read(dioProvider);
      
      // Call the API directly since ApplicationRemoteDataSource expects ApplicationModel
      final response = await dio.post('/api/applications', data: {
        'campaignId': widget.campaignId,
        'message': message,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _showApplicationModal = false;
          _alreadyApplied = true;
        });
        _loadData(); // Reload to update applicants count
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit application: $e')),
        );
      }
    } finally {
      setState(() => _isApplying = false);
    }
  }

  Future<void> _loadApplicants() async {
    setState(() => _loadingApplicants = true);
    
    try {
      final dio = ref.read(dioProvider);
      
      // Call API directly - backend returns {success, data: [applications]}
      final response = await dio.get('/api/applications/campaign/${widget.campaignId}');
      
      if (response.data['success'] == true) {
        final applicationsData = response.data['data'] as List;
        setState(() => _applicants = List<Map<String, dynamic>>.from(applicationsData));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load applicants: $e')),
        );
      }
    } finally {
      setState(() => _loadingApplicants = false);
    }
  }

  Future<void> _updateApplicationStatus(String applicationId, String status) async {
    try {
      final dio = ref.read(dioProvider);
      
      // Call API directly - backend expects {status} and returns {success, message, data}
      final response = await dio.patch('/api/applications/$applicationId/status', data: {
        'status': status,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application $status successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadApplicants(); // Reload applicants
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update application: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_campaign == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Campaign not found'),
        ),
      );
    }

    final isBrand = _user?['role'] == 'brand';
    final isOwnCampaign = isBrand && _campaign?['creatorId']?['_id'] == _user?['_id'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image AppBar
              SliverAppBar(
                expandedHeight: 264,
                pinned: true,
                backgroundColor: Colors.white,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _campaign?['image'] != null
                      ? Image.network(
                          _campaign!['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 64,
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Center(
                            child: Icon(
                              Icons.campaign,
                              size: 64,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEEBFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _campaign?['category'] ?? 'General',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Title and Actions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _campaign?['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (!isBrand) ...[
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _alreadyApplied
                                  ? null
                                  : () => setState(() => _showApplicationModal = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _alreadyApplied
                                    ? const Color(0xFFF1F5F9)
                                    : const Color(0xFF2563EB),
                                foregroundColor: _alreadyApplied
                                    ? const Color(0xFF94A3B8)
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                _alreadyApplied ? 'Already Applied' : 'Apply Now',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          if (isOwnCampaign) ...[
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() => _showApplicantsModal = true);
                                _loadApplicants();
                              },
                              icon: const Icon(Icons.people, size: 20),
                              label: Text(
                                'View Applicants (${(_campaign?['applicants'] as List?)?.length ?? 0})',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () async {
                                // Fetch the campaign model first
                                try {
                                  final campaignDataSource = ref.read(campaignRemoteDataSourceProvider);
                                  final campaign = await campaignDataSource.getCampaignById(widget.campaignId);
                                  
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditCampaignScreen(
                                          campaign: campaign,
                                        ),
                                      ),
                                    ).then((_) => _loadData());
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to load campaign: $e')),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.edit),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                                foregroundColor: const Color(0xFF64748B),
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ],
                        ],
                      ),

                      
                      const SizedBox(height: 32),
                      
                      // Info Grid
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFF8FAFC)),
                            bottom: BorderSide(color: Color(0xFFF8FAFC)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                Icons.calendar_today,
                                'DEADLINE',
                                _formatDate(_campaign?['deadline']),
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                Icons.location_on,
                                'LOCATION',
                                _campaign?['location'] ?? 'Remote',
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                Icons.people,
                                'APPLICANTS',
                                '${(_campaign?['applicants'] as List?)?.length ?? 0} People',
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Description Section
                      _buildSection(
                        Icons.work,
                        'Description',
                        const Color(0xFF2563EB),
                        Text(
                          _campaign?['description'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                            height: 1.6,
                          ),
                        ),
                      ),
                      
                      // Requirements Section
                      if (_campaign?['requirements'] != null &&
                          (_campaign!['requirements'] as List).isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _buildSection(
                          Icons.check_circle,
                          'Requirements',
                          const Color(0xFF16A34A),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (_campaign!['requirements'] as List)
                                .map((req) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ', style: TextStyle(fontSize: 16)),
                                          Expanded(
                                            child: Text(
                                              req.toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                      
                      // Deliverables Section
                      if (_campaign?['deliverables'] != null &&
                          (_campaign!['deliverables'] as List).isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _buildSection(
                          Icons.local_offer,
                          'Deliverables',
                          const Color(0xFF9333EA),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (_campaign!['deliverables'] as List)
                                .map((del) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ', style: TextStyle(fontSize: 16)),
                                          Expanded(
                                            child: Text(
                                              del.toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                      
                      // Brand Social Presence
                      if (_brandProfile?['socialLinks'] != null) ...[
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Brand Social Presence',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (isOwnCampaign)
                                    TextButton(
                                      onPressed: () {
                                        // Navigate to profile edit
                                      },
                                      child: const Text(
                                        'Edit Links',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildSocialLinks(),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Modals
          if (_showApplicationModal)
            ApplicationModal(
              onSubmit: _submitApplication,
              onCancel: () => setState(() => _showApplicationModal = false),
              isSubmitting: _isApplying,
            ),
          
          if (_showApplicantsModal)
            ApplicantsModal(
              applicants: _applicants,
              isLoading: _loadingApplicants,
              onUpdateStatus: _updateApplicationStatus,
              onClose: () => setState(() => _showApplicantsModal = false),
            ),
        ],
      ),
    );
  }


  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(IconData icon, String title, Color iconColor, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildSocialLinks() {
    final socialLinks = _brandProfile?['socialLinks'] as Map<String, dynamic>?;
    if (socialLinks == null) return const SizedBox();

    final links = [
      if (socialLinks['instagram'] != null)
        {'name': 'Instagram', 'icon': Icons.camera_alt, 'color': const Color(0xFFE1306C), 'link': socialLinks['instagram']},
      if (socialLinks['tiktok'] != null)
        {'name': 'TikTok', 'icon': Icons.music_note, 'color': Colors.black, 'link': socialLinks['tiktok']},
      if (socialLinks['facebook'] != null)
        {'name': 'Facebook', 'icon': Icons.facebook, 'color': const Color(0xFF1877F2), 'link': socialLinks['facebook']},
    ];

    return Column(
      children: links.map((social) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () async {
              final url = social['link'] as String;
              final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(
                    social['icon'] as IconData,
                    color: social['color'] as Color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          social['name'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (social['link'] as String)
                              .replaceAll(RegExp(r'https?://'), '')
                              .replaceAll(RegExp(r'/$'), ''),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      final dateTime = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('MMMM d, yyyy').format(dateTime);
    } catch (e) {
      return '—';
    }
  }
}
