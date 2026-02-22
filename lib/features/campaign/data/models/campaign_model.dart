import 'package:intl/intl.dart';

class Campaign {
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

  Campaign({
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
