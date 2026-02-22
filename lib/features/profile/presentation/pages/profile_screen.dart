import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:influcollb_app/core/services/storage/user_session_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:influcollb_app/core/api/api_endpoints.dart';
import 'package:influcollb_app/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:influcollb_app/app/routes/app_routes.dart';
import 'package:influcollb_app/features/campaign/presentation/pages/saved_campaigns_screen.dart';
import '../../payment/presentation/pages/billing_screen.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:influcollb_app/core/providers/core_providers.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../view_model/profile_view_model.dart';
// ... (lines 20-56 are mostly unchanged, just context for ReplacementContent if I were replacing whole file, but I will use chunks)

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String userName = 'Loading...';
  String userBio = '';
  final int followers = 125600;
  final int following = 340;
  final int campaigns = 24;

  // Profile data
  String? gender;
  String? dateOfBirth;
  String? ethnicity;
  String? language;
  Map<String, dynamic>? socialChannels;
  List<String> contentCategories = [];

  File? _profileImage;
  String? _remoteProfilePic;
  bool _isUploading = false;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs: prefs);
      final currentUserId = userSessionService.getCurrentUserId();
      final targetUserId = widget.userId ?? currentUserId;

      if (targetUserId != null) {
        // Fetch from API
        final apiService = ref.read(apiServiceProvider);
        final userSessionService = ref.read(userSessionServiceProvider);
        
        // Note: updateUserProfile fetches profile
        final profileData = await apiService.getUserProfile(userId: targetUserId);

        if (mounted) {
          setState(() {
            userName = profileData['fullName'] ?? 'User';
            userBio = profileData['bio'] ?? '';
            gender = profileData['gender'];
            ethnicity = profileData['ethnicity'];
            language = profileData['language'];
            socialChannels = profileData['socialChannels'];
            contentCategories =
                (profileData['contentCategories'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [];

            if (profileData['profilePicture'] != null) {
              final pic = profileData['profilePicture'];
              if (pic.startsWith('http')) {
                _remoteProfilePic = pic;
              } else {
                _remoteProfilePic = ApiEndpoints.mediaBaseUrl + pic;
              }
              // Update session storage
              userSessionService.updateProfilePicture(_remoteProfilePic!);
            }

            if (profileData['dateOfBirth'] != null) {
              dateOfBirth = profileData['dateOfBirth'];
            }
          });
        }
      } else {
        // Fallback to local storage
        final storedName = userSessionService.getCurrentUserFullName();
        final storedBio = userSessionService.getCurrentUserBio();

        if (mounted) {
          setState(() {
            if (storedName != null && storedName.isNotEmpty) {
              userName = storedName;
            }
            if (storedBio != null && storedBio.isNotEmpty) {
              userBio = storedBio;
            }
            _remoteProfilePic = userSessionService.getProfilePicture();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      // Fallback to local storage on error
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs: prefs);
      final storedName = userSessionService.getCurrentUserFullName();
      final storedBio = userSessionService.getCurrentUserBio();

      if (mounted) {
        setState(() {
          if (storedName != null && storedName.isNotEmpty) {
            userName = storedName;
          }
          if (storedBio != null && storedBio.isNotEmpty) {
            userBio = storedBio;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    debugPrint(
        '📸 Starting image selection for: ${source == ImageSource.camera ? "Camera" : "Gallery"}');
    debugPrint('📱 Platform: ${Platform.isAndroid ? "Android" : "iOS"}');

    PermissionStatus status;

    if (source == ImageSource.camera) {
      debugPrint('🎥 Requesting camera permission...');
      status = await Permission.camera.request();
      debugPrint('🎥 Camera permission status: $status');
    } else {
      // Photo Library / Gallery
      if (Platform.isAndroid) {
        debugPrint(
            '🖼️ Android: Requesting photos permission (Android 13+)...');
        status = await Permission.photos.request();
        debugPrint('🖼️ Photos permission status: $status');

        // If denied, it might be due to being on an older Android version (< 13)
        // where 'storage' permission is required instead.
        if (status.isDenied) {
          debugPrint(
              '🖼️ Photos denied, trying storage permission (Android < 13)...');
          status = await Permission.storage.request();
          debugPrint('🖼️ Storage permission status: $status');
        }
      } else {
        // iOS handling
        debugPrint('🖼️ iOS: Requesting photos permission...');
        status = await Permission.photos.request();
        debugPrint('🖼️ Photos permission status: $status');
      }
    }

    if (status.isGranted || status.isLimited) {
      debugPrint('✅ Permission granted! Opening image picker...');
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 70,
        );

        if (pickedFile != null) {
          debugPrint('✅ Image selected: ${pickedFile.path}');
          setState(() {
            _profileImage = File(pickedFile.path);
          });
          await _uploadImageToServer(File(pickedFile.path));
        } else {
          debugPrint('❌ No image selected (user cancelled)');
        }
      } catch (e) {
        debugPrint("❌ Error picking image: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to pick image.')),
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      debugPrint('🚫 Permission permanently denied!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Permission denied permanently. Please enable it in Settings.'),
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
    } else {
      debugPrint('⚠️ Permission denied (status: $status)');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Action cancelled: Permission not granted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _uploadImageToServer(File imageFile) async {
    setState(() => _isUploading = true);

    try {
      await ref
          .read(profileViewModelProvider.notifier)
          .uploadProfile(imageFile);

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _handleImageSelection(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _handleImageSelection(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildProfileCard(),
                        const SizedBox(height: 16),
                        if (gender != null ||
                            ethnicity != null ||
                            language != null)
                          _buildDemographicsSection(),
                        if (socialChannels != null &&
                            socialChannels!.isNotEmpty)
                          _buildSocialLinksSection(),
                        if (contentCategories.isNotEmpty)
                          _buildContentCategoriesSection(),
                        _buildPortfolioSection(),
                        const SizedBox(height: 16),
                        _buildMenuSection(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowColor.withValues(alpha: 0.1),
              blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 3),
                  color: Colors.grey[200],
                ),
                child: GestureDetector(
                  onTap: _showPickerOptions,
                  child: _profileImage != null
                      ? ClipOval(
                          child: Image.file(_profileImage!, fit: BoxFit.cover),
                        )
                      : _remoteProfilePic != null
                          ? ClipOval(
                              child: Image.network(
                                _remoteProfilePic!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.person,
                                        size: 60, color: Colors.grey),
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2));
                                },
                              ),
                            )
                          : const Icon(Icons.person,
                              size: 60, color: Colors.grey),
                ),
              ),
              if (_isUploading)
                const SizedBox(
                  width: 110,
                  height: 110,
                  child: CircularProgressIndicator(
                      strokeWidth: 3, color: AppColors.primary),
                ),
              if (widget.userId == null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showPickerOptions,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child:
                          const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(userName, style: AppTextStyles.heading3),
          if (userBio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(userBio,
                  textAlign: TextAlign.center, style: AppTextStyles.bodySmall),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('$followers', 'Followers'),
              _buildStatItem('$following', 'Following'),
              _buildStatItem('$campaigns', 'Campaigns'),
            ],
          ),
          const SizedBox(height: 24),
          if (widget.userId == null)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Insights feature coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.insights, size: 18, color: Colors.white),
                    label: const Text('Insights', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Portfolio update coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.folder_shared, size: 18, color: AppColors.primary),
                    label: const Text('Portfolio', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          if (widget.userId == null)
            const SizedBox(height: 16),
          if (widget.userId == null)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfileScreen()),
                  );
                  if (result == true) {
                    _loadUserProfile();
                  }
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Edit Account Details',
                    style: TextStyle(color: AppColors.textLight, fontSize: 13)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDemographicsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowColor.withValues(alpha: 0.1),
              blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About', style: AppTextStyles.heading4),
          const SizedBox(height: 16),
          if (gender != null) _buildInfoRow(Icons.person, 'Gender', gender!),
          if (ethnicity != null)
            _buildInfoRow(Icons.public, 'Ethnicity', ethnicity!),
          if (language != null)
            _buildInfoRow(Icons.language, 'Language', language!),
        ],
      ),
    );
  }

  Widget _buildSocialLinksSection() {
    final validSocials = socialChannels!.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .toList();

    if (validSocials.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowColor.withValues(alpha: 0.1),
              blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Social Media', style: AppTextStyles.heading4),
          const SizedBox(height: 16),
          ...validSocials.map((entry) {
            IconData icon;
            String label;

            switch (entry.key) {
              case 'instagram':
                icon = Icons.camera_alt;
                label = 'Instagram';
                break;
              case 'tiktok':
                icon = Icons.music_note;
                label = 'TikTok';
                break;
              case 'youtube':
                icon = Icons.play_circle_outline;
                label = 'YouTube';
                break;
              case 'twitter':
                icon = Icons.flutter_dash;
                label = 'Twitter';
                break;
              case 'twitch':
                icon = Icons.videogame_asset;
                label = 'Twitch';
                break;
              case 'amazonStorefront':
                icon = Icons.shopping_bag;
                label = 'Amazon';
                break;
              case 'website':
                icon = Icons.link;
                label = 'Website';
                break;
              default:
                icon = Icons.link;
                label = entry.key;
            }

            return _buildSocialLink(icon, label, entry.value.toString());
          }),
        ],
      ),
    );
  }

  Widget _buildContentCategoriesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowColor.withValues(alpha: 0.1),
              blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Content Categories', style: AppTextStyles.heading4),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: contentCategories.map((category) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowColor.withValues(alpha: 0.1),
              blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Portfolio Highlights', style: AppTextStyles.heading4),
              Icon(Icons.stars, color: Colors.amber[600], size: 20),
            ],
          ),
          const SizedBox(height: 16),
          // Placeholder for portfolio items
          Row(
            children: [
              _buildPortfolioItemPlaceholder('Campaign A'),
              const SizedBox(width: 12),
              _buildPortfolioItemPlaceholder('Campaign B'),
              const SizedBox(width: 12),
              _buildPortfolioItemPlaceholder('Campaign C'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Keep your portfolio updated to attract high-value brand collaborations.',
            style: TextStyle(color: AppColors.textLight, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioItemPlaceholder(String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, color: Colors.grey, size: 30),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildSocialLink(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _launchUrl(value),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Icon(Icons.open_in_new, size: 16, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.heading3),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildBackground() => Opacity(
      opacity: 0.2,
      child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/splashbg.jpg'),
                  fit: BoxFit.cover))));

  Widget _buildHeader() => Padding(
      padding: const EdgeInsets.all(20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        if (widget.userId != null)
           IconButton(
             icon: const Icon(Icons.arrow_back),
             onPressed: () => Navigator.pop(context),
           ),
        Text(widget.userId != null ? 'Influencer Profile' : 'Profile', style: AppTextStyles.heading2),
        if (widget.userId == null)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.settings,
              color: AppColors.primary,
              size: 20,
            ),
          ),
      ]));

  Widget _buildMenuSection() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        _buildMenuItem(
          icon: Icons.bookmark_border,
          label: 'Saved Campaigns',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SavedCampaignsScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Billing & Payments',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BillingScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.history,
          label: 'Application History',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          label: 'Help & Support',
          onTap: () {},
        ),
        if (widget.userId == null)
          _buildMenuItem(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final userSessionService = UserSessionService(prefs: prefs);
              await userSessionService.clearSession();

              // Also clear token using TokenService
              final tokenService = ref.read(tokenServiceProvider);
              await tokenService.removeToken();

              // Clear role-specific login state as well
              await prefs.remove('isLoggedIn');

              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            isLast: true,
          )
      ]));

  Widget _buildMenuItem(
          {required IconData icon,
          required String label,
          required VoidCallback onTap,
          bool isLast = false}) =>
      Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor.withValues(alpha: 0.05),
                  blurRadius: 5,
                ),
              ],
            ),
            child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Icon(icon, color: AppColors.primary, size: 24),
                title: Text(label, style: AppTextStyles.bodyLarge),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: AppColors.textLight),
                onTap: onTap),
          ),
          if (!isLast) const SizedBox(height: 12),
        ],
      );
}
