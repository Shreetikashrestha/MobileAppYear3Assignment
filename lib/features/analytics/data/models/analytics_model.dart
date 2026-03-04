import 'package:influcollb_app/features/analytics/domain/entities/analytics_entity.dart';

class AnalyticsModel extends AnalyticsEntity {
  const AnalyticsModel({
    required super.totalCampaigns,
    required super.activeCampaigns,
    required super.completedCampaigns,
    required super.totalApplications,
    required super.totalBudget,
    required super.spentBudget,
    required super.categoryBreakdown,
    required super.campaignPerformance,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      totalCampaigns: json['totalCampaigns'] ?? 0,
      activeCampaigns: json['activeCampaigns'] ?? 0,
      completedCampaigns: json['completedCampaigns'] ?? 0,
      totalApplications: json['totalApplications'] ?? 0,
      totalBudget: (json['totalBudget'] ?? 0).toDouble(),
      spentBudget: (json['spentBudget'] ?? 0).toDouble(),
      categoryBreakdown: (json['categoryBreakdown'] as List<dynamic>?)
              ?.map((e) => CategoryDataModel.fromJson(e))
              .toList() ??
          [],
      campaignPerformance: (json['campaignPerformance'] as List<dynamic>?)
              ?.map((e) => CampaignPerformanceModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CategoryDataModel extends CategoryData {
  const CategoryDataModel({
    required super.category,
    required super.count,
    required super.percentage,
  });

  factory CategoryDataModel.fromJson(Map<String, dynamic> json) {
    return CategoryDataModel(
      category: json['category'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class CampaignPerformanceModel extends CampaignPerformance {
  const CampaignPerformanceModel({
    required super.campaignId,
    required super.campaignTitle,
    required super.applicationsCount,
    required super.acceptedCount,
    required super.budget,
    required super.status,
  });

  factory CampaignPerformanceModel.fromJson(Map<String, dynamic> json) {
    return CampaignPerformanceModel(
      campaignId: json['campaignId'] ?? json['_id'] ?? '',
      campaignTitle: json['campaignTitle'] ?? json['title'] ?? '',
      applicationsCount: json['applicationsCount'] ?? 0,
      acceptedCount: json['acceptedCount'] ?? 0,
      budget: (json['budget'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
    );
  }
}
