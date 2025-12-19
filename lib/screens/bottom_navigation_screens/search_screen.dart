import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  List<String> recentSearches = ['Fashion', 'Fitness', 'Beauty', 'Travel', 'Technology'];
  List<String> filteredSearches = [];

  @override
  void initState() {
    super.initState();
    filteredSearches = recentSearches;
  }

  void _filterSearches(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSearches = recentSearches;
      } else {
        filteredSearches = recentSearches
            .where((search) => search.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.20,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('/Users/shreetikashrestha/Desktop/influcollab_app/assets/images/splashbg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Discover Campaigns',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: _filterSearches,
                          decoration: InputDecoration(
                            hintText: 'Search campaigns...',
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                            suffixIcon: searchController.text.isNotEmpty
                                ? GestureDetector(
                              onTap: () {
                                searchController.clear();
                                _filterSearches('');
                              },
                              child: const Icon(Icons.close),
                            )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // SEARCH HISTORY
                if (searchController.text.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Searches',
                          style: AppTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: recentSearches.map((search) {
                            return GestureDetector(
                              onTap: () {
                                searchController.text = search;
                                _filterSearches(search);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowColor.withOpacity(0.05),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  search,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredSearches.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadowColor.withOpacity(0.08),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.purpleGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.trending_up,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        filteredSearches[index],
                                        style: AppTextStyles.bodyLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${index + 1} campaigns found',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.textLight,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
