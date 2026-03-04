import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalCampaigns;
  final int activeCampaigns;
  final int completedCampaigns;
  final int draftCampaigns;
  final int totalApplications;
  final int pendingApplications;
  final int acceptedApplications;
  final int rejectedApplications;
  final int totalReach;
  final double engagementRate;

  const DashboardStats({
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.completedCampaigns,
    required this.draftCampaigns,
    required this.totalApplications,
    required this.pendingApplications,
    required this.acceptedApplications,
    required this.rejectedApplications,
    required this.totalReach,
    required this.engagementRate,
  });

  @override
  List<Object?> get props => [
        totalCampaigns,
        activeCampaigns,
        completedCampaigns,
        draftCampaigns,
        totalApplications,
        pendingApplications,
        acceptedApplications,
        rejectedApplications,
        totalReach,
        engagementRate,
      ];
}
