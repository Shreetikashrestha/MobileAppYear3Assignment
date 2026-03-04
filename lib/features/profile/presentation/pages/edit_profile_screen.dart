import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:influcollb_app/core/services/storage/user_session_service.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:influcollb_app/features/profile/presentation/view_model/profile_view_model.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  File? _profileImage;
  String? _currentProfilePicUrl;
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _twitchController = TextEditingController();
  final TextEditingController _amazonController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  
  // Platform-specific followers controllers
  final TextEditingController _instagramFollowersController = TextEditingController();
  final TextEditingController _tiktokFollowersController = TextEditingController();
  final TextEditingController _facebookFollowersController = TextEditingController();

  // Portfolio items
  final List<Map<String, dynamic>> _portfolioItems = [];

  // Form data
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  String? _selectedEthnicity;
  String? _selectedLanguage;
  final Set<String> _selectedCategories = {};

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say'
  ];
  final List<String> _ethnicityOptions = [
    'Asian',
    'Black',
    'Hispanic',
    'White',
    'Mixed',
    'Other',
    'Prefer not to say'
  ];
  final List<String> _languageOptions = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Korean',
    'Other'
  ];
  final List<String> _contentCategories = [
    'Lifestyle',
    'Beauty',
    'Fashion',
    'Travel',
    'Health & Fitness',
    'Food & Drink',
    'Comedy & Entertainment',
    'Gaming',
    'Tech',
    'Education',
    'Music',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _facebookController.dispose();
    _youtubeController.dispose();
    _twitterController.dispose();
    _twitchController.dispose();
    _amazonController.dispose();
    _websiteController.dispose();
    _instagramFollowersController.dispose();
    _tiktokFollowersController.dispose();
    _facebookFollowersController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs: prefs);
      
      // Load basic data from session
      _bioController.text = userSessionService.getCurrentUserBio() ?? '';
      _currentProfilePicUrl = userSessionService.getProfilePicture();
      
      // Fetch full profile from backend
      final userId = userSessionService.getCurrentUserId();
      if (userId != null) {
        final apiService = ref.read(apiServiceProvider);
        final profileData = await apiService.getUserProfile(userId: userId);
        
        if (profileData != null) {
          // Convert socialAccounts array to socialChannels object
          Map<String, dynamic> socialChannels = {};
          final socialAccounts = profileData['socialAccounts'] as List<dynamic>?;
          if (socialAccounts != null) {
            for (final account in socialAccounts) {
              final platform = account['platform'];
              final handle = account['handle'];
              final followers = account['followers'];
              
              if (platform != null && handle != null) {
                socialChannels[platform] = handle;
                if (followers != null) {
                  socialChannels['${platform}Followers'] = followers.toString();
                }
              }
            }
          } else {
            // Fallback to old format if available
            socialChannels = profileData['socialChannels'] ?? {};
          }
          
          setState(() {
            _bioController.text = profileData['bio'] ?? '';
            _selectedGender = profileData['gender'];
            if (profileData['dateOfBirth'] != null) {
              _selectedDateOfBirth = DateTime.parse(profileData['dateOfBirth']);
            }
            _selectedEthnicity = profileData['ethnicity'];
            _selectedLanguage = profileData['language'];
            
            // Load social channels
            _instagramController.text = socialChannels['instagram'] ?? '';
            _tiktokController.text = socialChannels['tiktok'] ?? '';
            _facebookController.text = socialChannels['facebook'] ?? '';
            _youtubeController.text = socialChannels['youtube'] ?? '';
            _twitterController.text = socialChannels['twitter'] ?? '';
            _twitchController.text = socialChannels['twitch'] ?? '';
            _amazonController.text = socialChannels['amazonStorefront'] ?? '';
            _websiteController.text = socialChannels['website'] ?? '';
            _instagramFollowersController.text = socialChannels['instagramFollowers'] ?? '';
            _tiktokFollowersController.text = socialChannels['tiktokFollowers'] ?? '';
            _facebookFollowersController.text = socialChannels['facebookFollowers'] ?? '';
            
            // Load content categories
            final categories = profileData['categories'] ?? profileData['contentCategories'];
            if (categories != null) {
              _selectedCategories.addAll(List<String>.from(categories));
            }
            
            _currentProfilePicUrl = profileData['profilePicture'];
          });
        }
      }
    } catch (e) {
      print('Error loading profile data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return null;

    try {
      // Upload profile image using the profile view model
      final result = await ref
          .read(profileViewModelProvider.notifier)
          .uploadProfile(_profileImage!);
      
      debugPrint('Profile image uploaded successfully');
      // The upload returns the remote URL, not the local path
      return result;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  void _addPortfolioItem() {
    showDialog(
      context: context,
      builder: (context) => _PortfolioDialog(
        onSave: (item) {
          setState(() {
            _portfolioItems.add(item);
          });
        },
      ),
    );
  }

  void _editPortfolioItem(int index) {
    showDialog(
      context: context,
      builder: (context) => _PortfolioDialog(
        initialItem: _portfolioItems[index],
        onSave: (item) {
          setState(() {
            _portfolioItems[index] = item;
          });
        },
      ),
    );
  }

  void _deletePortfolioItem(int index) {
    setState(() {
      _portfolioItems.removeAt(index);
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs: prefs);
      final userId = userSessionService.getCurrentUserId();

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Upload profile image if changed
      String? profilePicUrl;
      if (_profileImage != null) {
        profilePicUrl = await _uploadProfileImage();
        if (profilePicUrl != null) {
          await userSessionService.updateProfilePicture(profilePicUrl);
        }
      }

      // Save to local storage (since backend doesn't have these fields)
      await prefs.setString('profile_bio_$userId', _bioController.text.trim());
      await prefs.setString(
          'profile_categories_$userId', _selectedCategories.join(','));
      await prefs.setString(
          'profile_languages_$userId', 
          _selectedLanguage != null ? _selectedLanguage! : '');

      // Save social channels
      final socialChannelsMap = {
        'instagram': _instagramController.text.trim(),
        'tiktok': _tiktokController.text.trim(),
        'facebook': _facebookController.text.trim(),
        'youtube': _youtubeController.text.trim(),
        'twitter': _twitterController.text.trim(),
        'twitch': _twitchController.text.trim(),
        'amazonStorefront': _amazonController.text.trim(),
        'website': _websiteController.text.trim(),
        'instagramFollowers': _instagramFollowersController.text.trim(),
        'tiktokFollowers': _tiktokFollowersController.text.trim(),
        'facebookFollowers': _facebookFollowersController.text.trim(),
      };
      
      // Convert map to query string for storage
      final socialChannelsQuery = socialChannelsMap.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      await prefs.setString('profile_social_channels_$userId', socialChannelsQuery);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        // Reload profile data to show updated values
        await _loadCurrentData();
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile', style: AppTextStyles.heading3),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    children: [
                      _buildProfileImageSection(),
                      _buildBioSection(),
                      _buildDemographicsSection(),
                      _buildSocialChannelsSection(),
                      _buildPortfolioSection(),
                      _buildContentCategoriesSection(),
                    ],
                  ),
                ),
                _buildNavigationButtons(),
              ],
            ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(6, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 5 ? 8 : 0),
              decoration: BoxDecoration(
                color: index <= _currentPage
                    ? AppColors.primary
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBioSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Describe yourself and your content',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _bioController,
              maxLines: 8,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
                hintText: "I'm a commercial model and content creator...",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Help Brands Discover You',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Share a few details about yourself so we can match you with the right brand opportunities',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildDropdown(
            label: 'Gender',
            value: _selectedGender,
            items: _genderOptions,
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
          const SizedBox(height: 16),
          _buildDatePicker(),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Ethnicity',
            value: _selectedEthnicity,
            items: _ethnicityOptions,
            onChanged: (value) => setState(() => _selectedEthnicity = value),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Language',
            value: _selectedLanguage,
            items: _languageOptions,
            onChanged: (value) => setState(() => _selectedLanguage = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialChannelsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add your social channels',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSocialInputWithFollowers(
            Icons.camera_alt,
            'Instagram Handle',
            _instagramController,
            _instagramFollowersController,
          ),
          const SizedBox(height: 12),
          _buildSocialInputWithFollowers(
            Icons.music_note,
            'TikTok Handle',
            _tiktokController,
            _tiktokFollowersController,
          ),
          const SizedBox(height: 12),
          _buildSocialInputWithFollowers(
            Icons.facebook,
            'Facebook Handle',
            _facebookController,
            _facebookFollowersController,
          ),
          const SizedBox(height: 12),
          _buildSocialInput(
              Icons.play_circle_outline, 'Add YouTube', _youtubeController),
          const SizedBox(height: 12),
          _buildSocialInput(
              Icons.flutter_dash, 'Add Twitter', _twitterController),
          const SizedBox(height: 12),
          _buildSocialInput(
              Icons.videogame_asset, 'Add Twitch', _twitchController),
          const SizedBox(height: 12),
          _buildSocialInput(
              Icons.shopping_bag, 'Add Amazon Storefront', _amazonController),
          const SizedBox(height: 12),
          _buildSocialInput(Icons.link, 'Add Website', _websiteController),
        ],
      ),
    );
  }

  Widget _buildSocialInputWithFollowers(
    IconData icon,
    String label,
    TextEditingController handleController,
    TextEditingController followersController,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: handleController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: label,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: followersController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              labelText: 'Followers Count',
              prefixIcon: const Icon(Icons.people),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCategoriesSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What kind of content do you post?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _contentCategories.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCategories.remove(category);
                    } else {
                      _selectedCategories.add(category);
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(label),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDateOfBirth ?? DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _selectedDateOfBirth = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDateOfBirth != null
                  ? '${_selectedDateOfBirth?.day}/${_selectedDateOfBirth?.month}/${_selectedDateOfBirth?.year}'
                  : 'Select a date from the date picker',
              style: TextStyle(
                color: _selectedDateOfBirth != null
                    ? Colors.black
                    : Colors.grey[600],
              ),
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialInput(
      IconData icon, String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Profile Picture',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                image: _profileImage != null
                    ? DecorationImage(
                        image: FileImage(_profileImage!),
                        fit: BoxFit.cover,
                      )
                    : (_currentProfilePicUrl != null && _currentProfilePicUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(_currentProfilePicUrl!),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              debugPrint('Error loading profile picture: $exception');
                            },
                          )
                        : null,
              ),
              child: _profileImage == null && (_currentProfilePicUrl == null || _currentProfilePicUrl!.isEmpty)
                  ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _pickProfileImage,
            icon: const Icon(Icons.edit),
            label: const Text('Change Profile Picture'),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Portfolio',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _addPortfolioItem,
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_portfolioItems.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.work_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No portfolio items yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _addPortfolioItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Portfolio Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _portfolioItems.length,
              itemBuilder: (context, index) {
                final item = _portfolioItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(item['title'] ?? ''),
                    subtitle: Text(item['description'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editPortfolioItem(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePortfolioItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
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
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentPage == 5 ? 'Save Profile' : 'Continue',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _PortfolioDialog extends StatefulWidget {
  final Map<String, dynamic>? initialItem;
  final Function(Map<String, dynamic>) onSave;

  const _PortfolioDialog({
    this.initialItem,
    required this.onSave,
  });

  @override
  State<_PortfolioDialog> createState() => _PortfolioDialogState();
}

class _PortfolioDialogState extends State<_PortfolioDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialItem?['title'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialItem?['description'] ?? '',
    );
    _tagsController = TextEditingController(
      text: (widget.initialItem?['tags'] as List?)?.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialItem == null ? 'Add Portfolio Item' : 'Edit Portfolio Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a title')),
              );
              return;
            }

            final tags = _tagsController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

            widget.onSave({
              'title': _titleController.text.trim(),
              'description': _descriptionController.text.trim(),
              'tags': tags,
            });

            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
