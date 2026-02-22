import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:influcollb_app/core/services/storage/user_session_service.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';

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

  // Controllers
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _twitchController = TextEditingController();
  final TextEditingController _amazonController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

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
    _youtubeController.dispose();
    _twitterController.dispose();
    _twitchController.dispose();
    _amazonController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userSessionService = UserSessionService(prefs: prefs);

    setState(() {
      _bioController.text = userSessionService.getCurrentUserBio() ?? '';
      _isLoading = false;
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

      final apiService = ref.read(apiServiceProvider);

      await apiService.updateUserProfile(
        userId: userId,
        bio: _bioController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDateOfBirth?.toIso8601String(),
        ethnicity: _selectedEthnicity,
        language: _selectedLanguage,
        socialChannels: {
          'instagram': _instagramController.text.trim(),
          'tiktok': _tiktokController.text.trim(),
          'youtube': _youtubeController.text.trim(),
          'twitter': _twitterController.text.trim(),
          'twitch': _twitchController.text.trim(),
          'amazonStorefront': _amazonController.text.trim(),
          'website': _websiteController.text.trim(),
        },
        contentCategories: _selectedCategories.toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
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
    if (_currentPage < 3) {
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
                      _buildBioSection(),
                      _buildDemographicsSection(),
                      _buildSocialChannelsSection(),
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
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
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
          _buildSocialInput(
              Icons.camera_alt, 'Add Instagram', _instagramController),
          const SizedBox(height: 12),
          _buildSocialInput(Icons.music_note, 'Add Tiktok', _tiktokController),
          const SizedBox(height: 12),
          _buildSocialInput(
              Icons.play_circle_outline, 'Add Youtube', _youtubeController),
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
                  ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
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

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                _currentPage == 3 ? 'Save Profile' : 'Continue',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
