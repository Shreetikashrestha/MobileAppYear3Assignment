import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:influcollb_app/features/home/presentation/widgets/influencer_card.dart';
import 'package:influcollb_app/features/influencer/presentation/pages/influencer_profile_screen.dart';

class FindInfluencerScreen extends ConsumerStatefulWidget {
  const FindInfluencerScreen({super.key});

  @override
  ConsumerState<FindInfluencerScreen> createState() => _FindInfluencerScreenState();
}

class _FindInfluencerScreenState extends ConsumerState<FindInfluencerScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _influencers = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInfluencers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInfluencers({String? search}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final influencers = await apiService.getInfluencers(search: search);

      setState(() {
        _influencers = influencers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Find Influencers',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, bio, or category...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _loadInfluencers();
                  },
                ),
              ),
              onSubmitted: (value) => _loadInfluencers(search: value),
            ),
          ),
          
          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $_error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _loadInfluencers(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _influencers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'No influencers found',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadInfluencers(
                                search: _searchController.text.isNotEmpty
                                    ? _searchController.text
                                    : null),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _influencers.length,
                              itemBuilder: (context, index) {
                                final influencer = _influencers[index];
                                return InfluencerCard(
                                  influencer: influencer,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InfluencerProfileScreen(
                                          influencerId: influencer['_id'] ?? influencer['id'] ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
