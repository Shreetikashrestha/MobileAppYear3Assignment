import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/influencer/presentation/view_model/influencer_view_model.dart';
import 'package:influcollb_app/features/influencer/presentation/view_model/influencer_providers.dart';
import 'package:influcollb_app/features/influencer/presentation/pages/influencer_profile_screen.dart';
import 'package:influcollb_app/features/influencer/presentation/widgets/influencer_card.dart';

class FindInfluencerScreen extends ConsumerStatefulWidget {
  const FindInfluencerScreen({super.key});

  @override
  ConsumerState<FindInfluencerScreen> createState() => _FindInfluencerScreenState();
}

class _FindInfluencerScreenState extends ConsumerState<FindInfluencerScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Load influencers when screen opens
    Future.microtask(() {
      ref.read(influencerViewModelProvider.notifier).loadInfluencers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    ref.read(influencerViewModelProvider.notifier).searchInfluencers(query);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(influencerViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Find Influencers',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(influencerViewModelProvider.notifier).loadInfluencers();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {});
                if (value.isEmpty) {
                  ref.read(influencerViewModelProvider.notifier).loadInfluencers();
                }
              },
              onSubmitted: _performSearch,
            ),
          ),
          const SizedBox(height: 8),
          // Results Count
          if (state.influencers.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${state.influencers.length} influencer${state.influencers.length != 1 ? 's' : ''} found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          // Influencers List
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(InfluencerState state) {
    if (state.isLoading && state.influencers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.influencers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                state.error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(influencerViewModelProvider.notifier).loadInfluencers();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.influencers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'No influencers found'
                  : 'No influencers available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Check back later for new influencers',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (state.searchQuery.isNotEmpty) {
          await ref
              .read(influencerViewModelProvider.notifier)
              .searchInfluencers(state.searchQuery);
        } else {
          await ref.read(influencerViewModelProvider.notifier).loadInfluencers();
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.influencers.length,
        itemBuilder: (context, index) {
          final influencer = state.influencers[index];
          return InfluencerCard(
            influencer: influencer,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfluencerProfileScreen(
                    influencerId: influencer.id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
