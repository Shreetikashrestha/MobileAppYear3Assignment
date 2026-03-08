import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:influcollb_app/core/services/storage/user_session_service.dart';
import 'package:influcollb_app/core/services/sensor/biometric_auth_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:influcollb_app/core/api/api_endpoints.dart';
import 'package:influcollb_app/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:influcollb_app/features/profile/presentation/pages/insights_screen.dart';
import 'package:influcollb_app/features/profile/presentation/pages/portfolio_screen.dart';
import 'package:influcollb_app/features/campaign/presentation/pages/browse_campaigns_screen.dart';
import 'package:influcollb_app/features/application/presentation/pages/my_applications_screen.dart';
import 'package:influcollb_app/features/application/presentation/pages/application_history_screen.dart';
import 'package:influcollb_app/features/notification/presentation/pages/notifications_screen.dart';
import 'package:influcollb_app/features/application/presentation/view_model/application_providers.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:influcollb_app/features/auth/presentation/pages/login_screen.dart';
import 'package:influcollb_app/features/auth/presentation/view_model/auth_providers.dart';
import 'package:influcollb_app/core/usecases/usecase.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../view_model/profile_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with WidgetsBindingObserver {
  // Backend data (UserModel)
  String userName = 'Loading...';
  String userEmail = '';
  String? profilePicUrl;
  bool isInfluencer = false;

  // Local storage data (for fields not in backend)
  String userBio = '';
  List<String> categories = [];
  List<String> languages = [];
  Map<String, dynamic> socialChannels = {};

  // Brand stats (for own profile)
  int totalFollowers = 0; // Calculated from social accounts
  int campaigns = 0;

  // Application history data
  int pendingApplications = 0;
  int acceptedApplications = 0;
  int rejectedApplications = 0;

  // UI state
  File? _profileImage;
  bool _isUploading = false;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  final bool _isVisible = true;
  bool _showFullBio = false;
  double _profileCompletion = 0.0;

  // Biometric state
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isBiometricAvailable = false;
  bool _isBiometricEnrolled = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserProfile();
    _checkBiometricStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isVisible) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs: prefs);
      final currentUserId = userSessionService.getCurrentUserId();
      final targetUserId = widget.userId ?? currentUserId;

      if (targetUserId != null) {
        // Load from backend
        final apiService = ref.read(apiServiceProvider);
        final profileData =
            await apiService.getUserProfile(userId: targetUserId);

        // Load from local storage
        final bio = prefs.getString('profile_bio_$targetUserId') ?? '';
        final categoriesJson =
            prefs.getString('profile_categories_$targetUserId');
        final languagesJson =
            prefs.getString('profile_languages_$targetUserId');
        final socialChannelsJson =
            prefs.getString('profile_social_channels_$targetUserId');

        if (mounted) {
          debugPrint('📱 Backend - Full name: ${profileData['fullName']}');
          debugPrint('📱 Backend - Email: ${profileData['email']}');
          debugPrint(
              '📱 Backend - Profile picture: ${profileData['profilePicture']}');
          debugPrint('📱 Local - Bio: $bio');

          setState(() {
            // Backend data
            userName = profileData['fullName']?.toString().isNotEmpty == true
                ? profileData['fullName']
                : 'User';
            userEmail = profileData['email'] ?? '';
            isInfluencer = profileData['isInfluencer'] ?? false;

            // Profile picture
            if (profileData['profilePicture'] != null &&
                profileData['profilePicture'].toString().isNotEmpty) {
              final pic = profileData['profilePicture'].toString();
              if (pic.startsWith('http')) {
                profilePicUrl = pic;
              } else {
                profilePicUrl = ApiEndpoints.mediaBaseUrl + pic;
              }
              userSessionService.updateProfilePicture(profilePicUrl!);
            }

            // Local storage data
            userBio = bio;
            categories = categoriesJson != null
                ? List<String>.from(
                    categoriesJson.split(',').where((c) => c.isNotEmpty))
                : [];
            languages = languagesJson != null
                ? List<String>.from(
                    languagesJson.split(',').where((l) => l.isNotEmpty))
                : [];

            if (socialChannelsJson != null) {
              try {
                socialChannels = Map<String, dynamic>.from(
                    Uri.splitQueryString(socialChannelsJson));
                
                // Calculate total followers from all social accounts
                int calculatedFollowers = 0;
                
                // Sum up followers from all platforms
                final followerKeys = ['instagramFollowers', 'tiktokFollowers', 'facebookFollowers', 
                                     'youtubeFollowers', 'twitterFollowers', 'twitchFollowers'];
                
                for (var key in followerKeys) {
                  if (socialChannels.containsKey(key)) {
                    final value = socialChannels[key];
                    if (value != null && value.toString().isNotEmpty) {
                      try {
                        calculatedFollowers += int.parse(value.toString());
                      } catch (e) {
                        debugPrint('Error parsing $key: $e');
                      }
                    }
                  }
                }
                
                totalFollowers = calculatedFollowers;
                debugPrint('📊 Total followers calculated: $totalFollowers');
              } catch (e) {
                debugPrint('Error parsing social channels: $e');
                socialChannels = {};
                totalFollowers = 0;
              }
            } else {
              totalFollowers = 0;
            }
          });

          // Calculate profile completion percentage
          if (widget.userId == null) {
            int completedFields = 0;
            int totalFields =
                6; // name, email, picture, bio, categories, languages

            if (userName.isNotEmpty && userName != 'User') completedFields++;
            if (userEmail.isNotEmpty) completedFields++;
            if (profilePicUrl != null && profilePicUrl!.isNotEmpty)
              completedFields++;
            if (userBio.isNotEmpty) completedFields++;
            if (categories.isNotEmpty) completedFields++;
            if (languages.isNotEmpty) completedFields++;

            setState(() {
              _profileCompletion = completedFields / totalFields;
            });
          }
        }

        // Fetch brand stats if viewing own profile
        if (widget.userId == null) {
          try {
            final apiClient = ref.read(apiClientProvider);
            final statsResponse =
                await apiClient.get('/api/campaigns/brand-stats');
            if (statsResponse.statusCode == 200 &&
                statsResponse.data['success'] == true &&
                statsResponse.data['data'] != null) {
              final stats = statsResponse.data['data'];
              if (mounted) {
                setState(() {
                  campaigns = stats['totalCampaigns'] ?? 0;
                });
              }
            }
          } catch (e) {
            debugPrint('Error loading brand stats: $e');
          }

          // Load application history data
          _loadApplicationHistory();
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadApplicationHistory() async {
    try {
      // Load my applications to get counts
      await ref.read(applicationViewModelProvider.notifier).getMyApplications();

      final applicationState = ref.read(applicationViewModelProvider);
      final applications = applicationState.myApplications;

      if (mounted) {
        setState(() {
          pendingApplications = applications
              .where((app) => app.status.toLowerCase() == 'pending')
              .length;
          acceptedApplications = applications
              .where((app) => app.status.toLowerCase() == 'accepted')
              .length;
          rejectedApplications = applications
              .where((app) => app.status.toLowerCase() == 'rejected')
              .length;
        });
      }
    } catch (e) {
      debugPrint('Error loading application history: $e');
    }
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    PermissionStatus status;

    try {
      if (source == ImageSource.camera) {
        debugPrint('🎥 Requesting camera permission...');
        status = await Permission.camera.request();
        debugPrint('🎥 Camera permission status: $status');
      } else {
        if (Platform.isAndroid) {
          debugPrint('📱 Android: Requesting photos permission...');
          status = await Permission.photos.request();
          debugPrint('📱 Photos permission status: $status');

          if (status.isDenied) {
            debugPrint('📱 Photos denied, trying storage permission...');
            status = await Permission.storage.request();
            debugPrint('📱 Storage permission status: $status');
          }
        } else {
          debugPrint('🍎 iOS: Requesting photos permission...');
          status = await Permission.photos.request();
          debugPrint('🍎 Photos permission status: $status');
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
            setState(() => _profileImage = File(pickedFile.path));
            await _uploadImageToServer(File(pickedFile.path));
          } else {
            debugPrint('❌ No image selected (user cancelled)');
          }
        } catch (e) {
          debugPrint('❌ Error picking image: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to pick image.'),
                backgroundColor: Colors.red[400],
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else if (status.isPermanentlyDenied) {
        debugPrint('🚫 Permission permanently denied!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Permission denied permanently. Please enable it in Settings.',
              ),
              backgroundColor: Colors.red[400],
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: openAppSettings,
              ),
            ),
          );
        }
      } else {
        debugPrint('⚠️ Permission denied (status: $status)');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Permission denied. Cannot access photos.'),
              backgroundColor: Colors.orange[400],
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in image selection: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred.'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }

  Future<void> _uploadImageToServer(File imageFile) async {
    setState(() => _isUploading = true);

    try {
      debugPrint('📤 Starting image upload...');
      final result = await ref
          .read(profileViewModelProvider.notifier)
          .uploadProfile(imageFile);

      debugPrint('✅ Image uploaded successfully: $result');
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _profileImage = null);
      await _loadUserProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green[400],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to upload image. Please try again.'),
            backgroundColor: Colors.red[400],
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _uploadImageToServer(imageFile),
            ),
          ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('Take a Photo'),
                subtitle: const Text('Use your camera'),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageSelection(ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.photo_library, color: AppColors.primary),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select from your photos'),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageSelection(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
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

  Future<void> _handleRefresh() async {
    await _loadUserProfile();
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Call logout usecase
        final logoutUseCase = ref.read(logoutUseCaseProvider);
        final result = await logoutUseCase(NoParams());

        if (mounted) {
          // Close loading dialog
          Navigator.pop(context);

          result.fold(
            (failure) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logout failed: ${failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            (success) {
              // Navigate to login screen and clear navigation stack
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          );
        }
      } catch (e) {
        if (mounted) {
          // Close loading dialog if still open
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _checkBiometricStatus() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    final biometrics = await _biometricService.getAvailableBiometrics();
    final prefs = await SharedPreferences.getInstance();
    final enrolled = prefs.getBool('biometric_enrolled') ?? false;

    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable && biometrics.isNotEmpty;
        _isBiometricEnrolled = enrolled;
        _availableBiometrics = biometrics;
      });
    }
  }

  String _getBiometricName() {
    if (_availableBiometrics.isEmpty) return 'Biometric';
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    }
    return 'Biometric';
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.isEmpty) return Icons.fingerprint;
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    }
    return Icons.security;
  }

  Future<void> _toggleBiometric() async {
    if (_isBiometricEnrolled) {
      // Disable biometric
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Disable Biometric Login'),
          content: Text(
              'Are you sure you want to disable ${_getBiometricName()} login?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Disable'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_enrolled', false);
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');

        if (mounted) {
          setState(() => _isBiometricEnrolled = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getBiometricName()} login disabled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } else {
      // Enable biometric - authenticate first
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate to enable ${_getBiometricName()} login',
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('saved_email');
        final savedPassword = prefs.getString('saved_password');

        // Check if we have credentials to save
        if (savedEmail != null && savedPassword != null) {
          await prefs.setBool('biometric_enrolled', true);
          if (mounted) {
            setState(() => _isBiometricEnrolled = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_getBiometricName()} login enabled!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Need to save credentials first
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Please log in with your password first, then enable biometric login'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getBiometricName()} authentication failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _copyProfileLink() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs: prefs);
      final userId = userSessionService.getCurrentUserId();

      if (userId != null) {
        final profileLink = 'https://influcollab.com/profile/$userId';
        await Share.share('Check out my profile on InfluCollab: $profileLink');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to generate profile link'),
            backgroundColor: Colors.orange[400],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to share profile'),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  Future<void> _copyToClipboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs: prefs);
      final userId = userSessionService.getCurrentUserId();

      if (userId != null) {
        final profileLink = 'https://influcollab.com/profile/$userId';
        // Using Share.share as a workaround for clipboard
        await Share.share(profileLink);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to copy profile link'),
            backgroundColor: Colors.orange[400],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error copying to clipboard: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to copy profile link'),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.share, color: Colors.green[700]),
                ),
                title: const Text('Share Profile'),
                subtitle: const Text('Share your profile link with others'),
                onTap: () {
                  Navigator.pop(context);
                  _copyProfileLink();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.content_copy, color: Colors.blue[700]),
                ),
                title: const Text('Copy Profile Link'),
                subtitle: const Text('Copy link to clipboard'),
                onTap: () {
                  Navigator.pop(context);
                  _copyToClipboard();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? const Color(0xFF1E1033) : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF2D1B4E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.userId == null ? 'My Profile' : 'Profile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (widget.userId == null)
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: textColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
          if (widget.userId == null)
            IconButton(
              icon: Icon(Icons.refresh, color: textColor),
              onPressed: _handleRefresh,
            ),
          if (widget.userId == null)
            IconButton(
              icon: Icon(Icons.share, color: textColor),
              onPressed: _showShareOptions,
            ),
          if (widget.userId == null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              tooltip: 'Logout',
              onPressed: _handleLogout,
            ),
        ],
      ),
      floatingActionButton: widget.userId == null
          ? FloatingActionButton(
              onPressed: _showShareOptions,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.share),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primary,
              backgroundColor: cardColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 16),
                    if (widget.userId == null) _buildStatsSection(),
                    if (widget.userId == null) const SizedBox(height: 16),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 16),
                    if (userBio.isNotEmpty) _buildBioSection(),
                    if (userBio.isNotEmpty) const SizedBox(height: 16),
                    if (widget.userId == null && _profileCompletion < 0.8)
                      _buildProfileTipsSection(),
                    if (widget.userId == null && _profileCompletion < 0.8)
                      const SizedBox(height: 16),
                    if (categories.isNotEmpty) _buildCategoriesSection(),
                    if (categories.isNotEmpty) const SizedBox(height: 16),
                    if (languages.isNotEmpty) _buildLanguagesSection(),
                    if (languages.isNotEmpty) const SizedBox(height: 16),
                    if (socialChannels.isNotEmpty)
                      _buildSocialChannelsSection(),
                    if (socialChannels.isNotEmpty) const SizedBox(height: 16),
                    if (widget.userId == null) _buildActionButtons(),
                    if (widget.userId == null) const SizedBox(height: 16),
                    if (widget.userId == null)
                      _buildApplicationHistorySection(),
                    if (widget.userId == null) const SizedBox(height: 16),
                    if (widget.userId == null) _buildBiometricSection(),
                    if (widget.userId == null) const SizedBox(height: 16),
                    if (widget.userId == null) _buildShakeToToggleSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2D1B4E) : Colors.white;
    final dividerColor = isDark ? Colors.white24 : Colors.grey[200];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('$totalFollowers', 'Followers', Icons.people),
          Container(
            width: 1,
            height: 60,
            color: dividerColor,
          ),
          _buildStatItem('$campaigns', 'Campaigns', Icons.campaign),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white70 : Colors.grey[600];

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2D1B4E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withValues(alpha: 0.1), cardColor],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Profile Picture Container
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 4,
                  ),
                  color: Colors.grey[200],
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: widget.userId == null ? _showPickerOptions : null,
                  child: _profileImage != null
                      ? ClipOval(
                          child: Image.file(_profileImage!, fit: BoxFit.cover),
                        )
                      : (profilePicUrl != null && profilePicUrl!.isNotEmpty)
                          ? ClipOval(
                              child: Image.network(
                                profilePicUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.person,
                                        size: 70, color: Colors.grey),
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Icon(Icons.person,
                              size: 70, color: Colors.grey),
                ),
              ),
              // Upload Progress Overlay
              if (_isUploading)
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ),
              // Edit Button (Own Profile Only)
              if (widget.userId == null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showPickerOptions,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // User Name
          Text(
            userName,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          // Influencer Badge
          if (isInfluencer)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Influencer',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Profile completion indicator
          if (widget.userId == null && _profileCompletion > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _profileCompletion,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _profileCompletion >= 0.8
                                ? Colors.green
                                : _profileCompletion >= 0.5
                                    ? Colors.orange
                                    : Colors.orangeAccent,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(_profileCompletion * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Profile ${(_profileCompletion * 100).toInt()}% complete',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2D1B4E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final labelColor = isDark ? Colors.white70 : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Information',
              style: AppTextStyles.heading4.copyWith(color: textColor)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.email, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email',
                        style: TextStyle(
                            color: labelColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(userEmail,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTipsSection() {
    final tips = <Map<String, dynamic>>[];

    if (userBio.isEmpty) {
      tips.add({
        'icon': Icons.description,
        'title': 'Add a Bio',
        'description': 'Tell brands about yourself and your content',
        'action': 'Add Bio',
        'color': Colors.blue,
      });
    }

    if (categories.isEmpty) {
      tips.add({
        'icon': Icons.category,
        'title': 'Add Categories',
        'description': 'Select content categories to attract relevant brands',
        'action': 'Add Categories',
        'color': Colors.green,
      });
    }

    if (languages.isEmpty) {
      tips.add({
        'icon': Icons.language,
        'title': 'Add Languages',
        'description': 'List languages you speak for better matching',
        'action': 'Add Languages',
        'color': Colors.purple,
      });
    }

    if (socialChannels.isEmpty) {
      tips.add({
        'icon': Icons.share,
        'title': 'Add Social Media',
        'description': 'Connect your social accounts to showcase your reach',
        'action': 'Add Social',
        'color': Colors.orange,
      });
    }

    if (tips.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb,
                  color: Colors.amber[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Profile Tips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Complete your profile to get more brand opportunities:',
            style: TextStyle(
              color: Colors.amber.shade700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tip['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      tip['icon'],
                      color: tip['color'],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: tip['color'],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tip['description'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tip['color'],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      tip['action'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2D1B4E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final bodyColor = isDark ? Colors.white70 : Colors.grey[700];

    final isBioLong = userBio.length > 150;
    final displayBio = _showFullBio
        ? userBio
        : (isBioLong ? userBio.substring(0, 150) + '...' : userBio);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About',
              style: AppTextStyles.heading4.copyWith(color: textColor)),
          const SizedBox(height: 12),
          Text(displayBio, style: TextStyle(color: bodyColor, height: 1.5)),
          if (isBioLong)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () => setState(() => _showFullBio = !_showFullBio),
                child: Text(
                  _showFullBio ? 'Show less' : 'Show more',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2D1B4E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.category,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('Content Categories',
                  style: AppTextStyles.heading4.copyWith(color: textColor)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map((category) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2D1B4E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.language,
                  color: Colors.blue[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('Languages',
                  style: AppTextStyles.heading4.copyWith(color: textColor)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: languages.map((language) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blue[200]!,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  language,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialChannelsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2D1B4E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.share,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('Social Media',
                  style: AppTextStyles.heading4.copyWith(color: textColor)),
            ],
          ),
          const SizedBox(height: 16),
          ...socialChannels.entries
              .where((e) =>
                  e.value != null &&
                  e.value.toString().isNotEmpty &&
                  !e.key.endsWith('Followers'))
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
            final followers = socialChannels[followersKey];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _launchUrl(entry.value.toString()),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: color,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              entry.value.toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (followers != null && followers.toString().isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              followers.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'followers',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildApplicationHistorySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2D1B4E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Application History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to application history
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ApplicationHistoryScreen(),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyApplicationsScreen(),
                ),
              );
            },
            child: _buildApplicationHistoryItem(
              'Pending',
              pendingApplications.toString(),
              Colors.orange,
              Icons.pending_actions,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyApplicationsScreen(),
                ),
              );
            },
            child: _buildApplicationHistoryItem(
              'Accepted',
              acceptedApplications.toString(),
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyApplicationsScreen(),
                ),
              );
            },
            child: _buildApplicationHistoryItem(
              'Rejected',
              rejectedApplications.toString(),
              Colors.red,
              Icons.cancel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationHistoryItem(
    String status,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2D1B4E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subBgColor = isDark ? const Color(0xFF1E1033) : Colors.grey[50];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB16CEA), Color(0xFFFF5E69)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getBiometricIcon(),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Security',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isBiometricAvailable)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Biometric authentication is not available on this device. Please enable Face ID or Touch ID in your device settings.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isBiometricEnrolled
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isBiometricEnrolled
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getBiometricIcon(),
                      color: _isBiometricEnrolled
                          ? Colors.green
                          : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getBiometricName()} Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isBiometricEnrolled
                              ? 'Enabled - Tap to disable'
                              : 'Tap to enable quick login',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isBiometricEnrolled,
                    onChanged: (_) => _toggleBiometric(),
                    activeColor: const Color(0xFFB16CEA),
                  ),
                ],
              ),
            ),
          if (!_isBiometricEnrolled) ...[
            const SizedBox(height: 12),
            Text(
              'Enable ${_getBiometricName()} to quickly and securely access your account without typing your password.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InsightsScreen(),
                      ),
                    );
                  },
                  icon:
                      const Icon(Icons.insights, size: 18, color: Colors.white),
                  label: const Text(
                    'Insights',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PortfolioScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.folder_shared,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Portfolio',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
                if (result == true) {
                  _loadUserProfile();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShakeToToggleSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1A1A2E), const Color(0xFF7B2CBF)]
                        : [const Color(0xFFFFB347), const Color(0xFF7B2CBF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Shake Gesture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.purple.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sensors,
                      size: 14,
                      color: isDark ? Colors.purple[300] : Colors.orange[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sensor',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.purple[300] : Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                        const Color(0xFF7B2CBF).withValues(alpha: 0.1)
                      ]
                    : [
                        const Color(0xFFFFB347).withValues(alpha: 0.1),
                        const Color(0xFF7B2CBF).withValues(alpha: 0.05)
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF7B2CBF).withValues(alpha: 0.3)
                    : const Color(0xFFFFB347).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Animated shake icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF7B2CBF).withValues(alpha: 0.2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark
                                    ? const Color(0xFF7B2CBF)
                                    : const Color(0xFFFFB347))
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.vibration,
                        color: isDark ? Colors.purple[300] : Colors.orange[700],
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shake 3 Times',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Toggle between Dark & Light mode by shaking your phone 3 times',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Current mode indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: isDark ? Colors.purple[300] : Colors.orange[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current Mode: ${isDark ? "Dark" : "Light"}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // How it works
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShakeStep('1', 'Shake', Icons.vibration),
                    Icon(
                      Icons.arrow_forward,
                      color: isDark ? Colors.white38 : Colors.grey[400],
                      size: 16,
                    ),
                    _buildShakeStep('2', 'Shake', Icons.vibration),
                    Icon(
                      Icons.arrow_forward,
                      color: isDark ? Colors.white38 : Colors.grey[400],
                      size: 16,
                    ),
                    _buildShakeStep('3', 'Shake', Icons.vibration),
                    Icon(
                      Icons.arrow_forward,
                      color: isDark ? Colors.white38 : Colors.grey[400],
                      size: 16,
                    ),
                    _buildShakeStep('✓', isDark ? 'Light' : 'Dark',
                        isDark ? Icons.light_mode : Icons.dark_mode),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShakeStep(String step, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF7B2CBF).withValues(alpha: 0.3)
                : const Color(0xFFFFB347).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: step == '✓'
                ? Icon(icon,
                    size: 18,
                    color: isDark ? Colors.purple[300] : Colors.orange[700])
                : Text(
                    step,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.purple[300] : Colors.orange[700],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isDark ? Colors.white54 : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
