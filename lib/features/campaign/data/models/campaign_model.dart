import 'package:intl/intl.dart';
import 'package:influcollb_app/features/campaign/domain/entities/campaign_entity.dart';

class Campaign extends CampaignEntity {
  const Campaign({
    required super.id,
    required super.title,
    required super.description,
    required super.brandName,
    required super.category,
    required super.budgetMin,
    required super.budgetMax,
    required super.deadline,
    required super.location,
    required super.requirements,
    required super.deliverables,
    required super.creatorId,
    required super.applicantsCount,
    required super.status,
    required super.createdAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      brandName: json['brandName'] ?? '',
      category: json['category'] ?? '',
      budgetMin: (json['budgetMin'] ?? 0).toDouble(),
      budgetMax: (json['budgetMax'] ?? 0).toDouble(),
      deadline: DateTime.parse(json['deadline']),
      location: json['location'] ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
      deliverables: List<String>.from(json['deliverables'] ?? []),
      creatorId: json['creatorId'] is Map
          ? (json['creatorId']['_id'] ?? '')
          : (json['creatorId'] ?? ''),
      applicantsCount: json['applicantsCount'] ?? 0,
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'brandName': brandName,
      'category': category,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'deadline': deadline.toIso8601String(),
      'location': location,
      'requirements': requirements,
      'deliverables': deliverables,
      'creatorId': creatorId,
      'applicantsCount': applicantsCount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get budgetRange {
    final formatter = NumberFormat('#,###');
    return 'NPR ${formatter.format(budgetMin)} - ${formatter.format(budgetMax)}';
  }

  String get formattedDeadline {
    return '${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}';
  }
}
