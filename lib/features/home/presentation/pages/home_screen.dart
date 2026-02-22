import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'package:influcollb_app/features/campaign/presentation/view_model/campaign_view_model.dart';
import 'package:influcollb_app/features/campaign/presentation/widgets/campaign_card.dart' as dashboard_widgets;
import 'package:influcollb_app/features/campaign/presentation/pages/saved_campaigns_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
                  image: AssetImage('assets/images/splashbg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "INFLUCOLLABNEPAL",
                        style: AppTextStyles.appBarTitle,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            const Icon(Icons.notifications_outlined, size: 24),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.purpleGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.trending_up,
                                  color: Colors.white, size: 28),
                              SizedBox(height: 8),
                              Text("24", style: AppTextStyles.heading1),
                              Text("Active\nCollabs",
                                  style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.attach_money,
                                  color: Colors.white, size: 28),
                              SizedBox(height: 8),
                              Text("\$8.5K", style: AppTextStyles.heading1),
                              Text("This Month",
                                  style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.info,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.calendar_today,
                                  color: Colors.white, size: 28),
                              SizedBox(height: 8),
                              Text("12", style: AppTextStyles.heading1),
                              Text("Pending", style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Available Campaigns",
                          style: AppTextStyles.heading3),
                      TextButton(
                        onPressed: () {},
                        child: const Text("see all"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final state = ref.watch(campaignViewModelProvider);

                      if (state.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state.error != null) {
                        return Center(
                          child: Text(
                            state.error!,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (state.campaigns.isEmpty) {
                        return const Center(
                          child: Text(
                            'No campaigns available right now.',
                            style: AppTextStyles.bodyMedium,
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: state.campaigns.length,
                        itemBuilder: (context, index) {
                          final campaign = state.campaigns[index];
                          return dashboard_widgets.CampaignCard(
                            campaign: campaign,
                            isSaved: state.savedCampaigns.any((c) => c.id == campaign.id),
                            onSave: () async {
                              await ref.read(campaignViewModelProvider.notifier).toggleSave(campaign.id);
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SavedCampaignsScreen()),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          currentIndex: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: ''),
          ],
        ),
      ),
    );
  }
}