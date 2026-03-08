import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/influencer/presentation/view_model/influencer_providers.dart';

class InfluencerProfileScreen extends ConsumerStatefulWidget {
  final String influencerId;

  const InfluencerProfileScreen({
    super.key,
    required this.influencerId,
  });

  @override
  ConsumerState<InfluencerProfileScreen> createState() =>
      _InfluencerProfileScreenState();
}

class _InfluencerProfileScreenState
    extends ConsumerState<InfluencerProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load influencer profile
    Future.microtask(() {
      ref
          .read(influencerViewModelProvider.notifier)
          .loadInfluencerProfile(widget.influencerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(influencerViewModelProvider);
    final influencer = state.selectedInfluencer;

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.error != null || influencer == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.error ?? 'Failed to load profile',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(influencerViewModelProvider.notifier)
                      .loadInfluencerProfile(widget.influencerId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Picture
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.blue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[400]!, Colors.purple[400]!],
                  ),
                ),
                child: Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: (influencer.profilePicture != null &&
                                         influencer.profilePicture!.isNotEmpty &&
                                         influencer.profilePicture!.startsWith('http'))
                            ? NetworkImage(influencer.profilePicture!)
                            : null,
                        child: (influencer.profilePicture == null ||
                                influencer.profilePicture!.isEmpty ||
                                !influencer.profilePicture!.startsWith('http'))
                            ? Text(
                                influencer.fullName.isNotEmpty
                                    ? influencer.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              )
                            : null,
                      ),
                      if (influencer.isVerified ?? false)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Niche
                  Center(
                    child: Column(
                      children: [
                        Text(
                          influencer.fullName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (influencer.niche != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              influencer.niche!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.purple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (influencer.followersCount != null)
                        _buildStatItem(
                          'Followers',
                          _formatNumber(influencer.followersCount!),
                          Icons.people,
                        ),
                      if (influencer.engagementRate != null)
                        _buildStatItem(
                          'Engagement',
                          '${influencer.engagementRate!.toStringAsFixed(1)}%',
                          Icons.trending_up,
                        ),
                      if (influencer.platforms != null)
                        _buildStatItem(
                          'Platforms',
                          influencer.platforms!.length.toString(),
                          Icons.devices,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Bio
                  if (influencer.bio != null) ...[
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      influencer.bio!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Platforms
                  if (influencer.platforms != null &&
                      influencer.platforms!.isNotEmpty) ...[
                    const Text(
                      'Platforms',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: influencer.platforms!
                          .map((platform) => Chip(
                                label: Text(platform),
                                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                                labelStyle: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Social Links
                  if (influencer.socialLinks != null &&
                      influencer.socialLinks!.isNotEmpty) ...[
                    const Text(
                      'Social Links',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...influencer.socialLinks!.entries.map((entry) {
                      return _buildSocialLink(
                          entry.key, entry.value.toString());
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLink(String platform, String link) {
    IconData icon;
    Color color;

    switch (platform.toLowerCase()) {
      case 'instagram':
        icon = Icons.camera_alt;
        color = Colors.pink;
        break;
      case 'twitter':
      case 'x':
        icon = Icons.alternate_email;
        color = Colors.blue;
        break;
      case 'facebook':
        icon = Icons.facebook;
        color = Colors.blue[800]!;
        break;
      case 'youtube':
        icon = Icons.play_circle;
        color = Colors.red;
        break;
      case 'tiktok':
        icon = Icons.music_note;
        color = Colors.black;
        break;
      default:
        icon = Icons.link;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  link,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
