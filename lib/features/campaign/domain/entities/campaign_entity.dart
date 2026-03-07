import 'package:equatable/equatable.dart';

class CampaignEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String brandName;
  final String category;
  final double budgetMin;
  final double budgetMax;
  final DateTime deadline;
  final String location;
  final List<String> requirements;
  final List<String> deliverables;
  final String creatorId;
  final int applicantsCount;
  final String status;
  final DateTime createdAt;

  const CampaignEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.brandName,
    required this.category,
    required this.budgetMin,
    required this.budgetMax,
    required this.deadline,
    required this.location,
    required this.requirements,
    required this.deliverables,
    required this.creatorId,
    required this.applicantsCount,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        brandName,
        category,
        budgetMin,
        budgetMax,
        deadline,
        location,
        requirements,
        deliverables,
        creatorId,
        applicantsCount,
        status,
        createdAt,
      ];
}
