import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  List<dynamic> _completedCampaigns = [];
  List<dynamic> _acceptedApplications = [];
  bool _isVisible = true;
  
  // Profile highlights from local storage
  String _bio = '';
  List<String> _categories = [];
  List<String> _languages = [];
  Map<String, dynamic> _socialChannels = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPortfolio();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isVisible) {
      _loadPortfolio();
    }
  }

  Future<void> _loadPortfolio() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiClient = ref.read(apiClientProvider);
      
      // Get current user ID from session
      final userIdKey = prefs.getKeys().firstWhere(
        (key) => key.startsWith('user_id_'),
        orElse: () => '',
      );
      final userId = (userIdKey?.isNotEmpty ?? false)
          ? prefs.getString(userIdKey!) 
          : '';
      
      // Load profile highlights from local storage
      if (userId?.isNotEmpty ?? false) {
        _bio = prefs.getString('profile_bio_$userId') ?? '';
        
        final categoriesJson = prefs.getString('profile_categories_$userId');
        _categories = categoriesJson != null 
            ? List<String>.from(categoriesJson.split(',').where((c) => c.isNotEmpty))
            : [];
        
        final languagesJson = prefs.getString('profile_languages_$userId');
        _languages = languagesJson != null && languagesJson.isNotEmpty
            ? [languagesJson]
            : [];
        
        final socialChannelsJson = prefs.getString('profile_social_channels_$userId');
        if (socialChannelsJson != null && socialChannelsJson.isNotEmpty) {
          try {
            _socialChannels = Uri.splitQueryString(socialChannelsJson);
          } catch (e) {
            _socialChannels = {};
          }
        }
      }
      
      // Load completed campaigns (for brands)
      try {
        final campaignsResponse = await apiClient.get('/api/campaigns/my-campaigns');
        if (campaignsResponse.data['success'] == true) {
          final campaigns = campaignsResponse.data['data'] as List? ?? [];
          _completedCampaigns = campaigns.where((c) => c['status'] == 'completed').toList();
        }
      } catch (e) {
        // User might be influencer, not brand
      }
      
      // Load accepted applications (for influencers)
      try {
        final applicationsResponse = await apiClient.get('/api/applications/my-applications');
        if (applicationsResponse.data['success'] == true) {
          final applications = applicationsResponse.data['data'] as List? ?? [];
          _acceptedApplications = applications.where((a) => a['status'] == 'accepted').toList();
        }
      } catch (e) {
        // User might be brand, not influencer
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load portfolio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Portfolio', style: AppTextStyles.heading3),
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
              onRefresh: _loadPortfolio,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Highlights Section
                    if (_bio.isNotEmpty || _categories.isNotEmpty || _languages.isNotEmpty || _socialChannels.isNotEmpty)
                      _buildProfileHighlights(),
                    if (_bio.isNotEmpty || _categories.isNotEmpty || _languages.isNotEmpty || _socialChannels.isNotEmpty)
                      const SizedBox(height: 24),
                    
                    // Portfolio Items
                    if (_completedCampaigns.isNotEmpty) ...[
                      _buildSectionHeader('Completed Campaigns', _completedCampaigns.length),
                      const SizedBox(height: 16),
                      ..._completedCampaigns.map((campaign) => _buildCampaignCard(campaign)),
                      const SizedBox(height: 24),
                    ],
                    if (_acceptedApplications.isNotEmpty) ...[
                      _buildSectionHeader('Accepted Collaborations', _acceptedApplications.length),
                      const SizedBox(height: 16),
                      ..._acceptedApplications.map((application) => _buildApplicationCard(application)),
                    ],
                    if (_completedCampaigns.isEmpty && _acceptedApplications.isEmpty && _bio.isEmpty && _categories.isEmpty)
                      _buildEmptyState(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHighlights() {
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
          const Text('Profile Highlights', style: AppTextStyles.heading4),
          const SizedBox(height: 16),
          
          // Bio
          if (_bio.isNotEmpty) ...[
            Text('About', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
            const SizedBox(height: 6),
            Text(_bio, style: TextStyle(color: Colors.grey[600], height: 1.4)),
            const SizedBox(height: 12),
          ],
          
          // Categories
          if (_categories.isNotEmpty) ...[
            Text('Content Categories', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          
          // Languages
          if (_languages.isNotEmpty) ...[
            Text('Languages', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _languages.map((language) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    language,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          
          // Social Channels
          if (_socialChannels.isNotEmpty) ...[
            Text('Social Media', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
            const SizedBox(height: 8),
            ..._socialChannels.entries
                .where((e) => e.value != null && e.value.toString().isNotEmpty && !e.key.endsWith('Followers'))
                .map((entry) {
              IconData icon;
              Color color;
              String label;

              switch (entry.key) {
                case 'instagram':
                  icon = Icons.camera_alt;
                  color = Colors.pink;
                  label = 'Instagram';
                  break;
                case 'tiktok':
                  icon = Icons.music_note;
                  color = Colors.black;
                  label = 'TikTok';
                  break;
                case 'facebook':
                  icon = Icons.facebook;
                  color = Colors.blue;
                  label = 'Facebook';
                  break;
                case 'youtube':
                  icon = Icons.play_circle_outline;
                  color = Colors.red;
                  label = 'YouTube';
                  break;
                case 'twitter':
                  icon = Icons.flutter_dash;
                  color = Colors.lightBlue;
                  label = 'Twitter';
                  break;
                case 'twitch':
                  icon = Icons.videogame_asset;
                  color = Colors.purple;
                  label = 'Twitch';
                  break;
                default:
                  icon = Icons.link;
                  color = Colors.grey;
                  label = entry.key;
              }

              final followersKey = '${entry.key}Followers';
              final followers = _socialChannels[followersKey];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: color,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              entry.value.toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (followers != null && followers.toString().isNotEmpty)
                        Text(
                          followers.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.heading3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign) {
    final title = campaign['title'] ?? 'Untitled Campaign';
    final description = campaign['description'] ?? '';
    final category = campaign['category'] ?? 'General';
    final applicantsCount = campaign['applicantsCount'] ?? 0;
    final budgetMin = campaign['budgetMin'] ?? 0;
    final budgetMax = campaign['budgetMax'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.category, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                category,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '$applicantsCount applicants',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'NPR ${NumberFormat('#,###').format(budgetMin)} - ${NumberFormat('#,###').format(budgetMax)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final campaignTitle = application['campaignTitle'] ?? 'Untitled Campaign';
    final proposedRate = application['proposedRate'] ?? 0;
    final coverLetter = application['coverLetter'] ?? '';
    final createdAt = application['createdAt'] != null
        ? DateTime.parse(application['createdAt'])
        : DateTime.now();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  campaignTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Accepted',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'NPR ${NumberFormat('#,###').format(proposedRate)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                DateFormat('MMM dd, yyyy').format(createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          if (coverLetter.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                coverLetter,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No Portfolio Items Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete campaigns or get accepted to collaborations to build your portfolio',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
