import 'package:equatable/equatable.dart';

class AnalyticsEntity extends Equatable {
  final int totalCampaigns;
  final int activeCampaigns;
  final int completedCampaigns;
  final int totalApplications;
  final double totalBudget;
  final double spentBudget;
  final List<CategoryData> categoryBreakdown;
  final List<CampaignPerformance> campaignPerformance;

  const AnalyticsEntity({
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.completedCampaigns,
    required this.totalApplications,
    required this.totalBudget,
    required this.spentBudget,
    required this.categoryBreakdown,
    required this.campaignPerformance,
  });

  @override
  List<Object?> get props => [
        totalCampaigns,
        activeCampaigns,
        completedCampaigns,
        totalApplications,
        totalBudget,
        spentBudget,
        categoryBreakdown,
        campaignPerformance,
      ];
}

class CategoryData extends Equatable {
  final String category;
  final int count;
  final double percentage;

  const CategoryData({
    required this.category,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [category, count, percentage];
}

class CampaignPerformance extends Equatable {
  final String campaignId;
  final String campaignTitle;
  final int applicationsCount;
  final int acceptedCount;
  final double budget;
  final String status;

  const CampaignPerformance({
    required this.campaignId,
    required this.campaignTitle,
    required this.applicationsCount,
    required this.acceptedCount,
    required this.budget,
    required this.status,
  });

  @override
  List<Object?> get props => [
        campaignId,
        campaignTitle,
        applicationsCount,
        acceptedCount,
        budget,
        status,
      ];
}
