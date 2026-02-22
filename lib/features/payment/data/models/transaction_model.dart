import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required String id,
    String? campaignTitle,
    required String brandName,
    String? influencerName,
    required double amount,
    required double netAmount,
    required String type,
    required String status,
    String? description,
    required DateTime createdAt,
  }) : super(
          id: id,
          campaignTitle: campaignTitle,
          brandName: brandName,
          influencerName: influencerName,
          amount: amount,
          netAmount: netAmount,
          type: type,
          status: status,
          description: description,
          createdAt: createdAt,
        );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'],
      campaignTitle: json['campaignId'] != null && json['campaignId'] is Map
          ? json['campaignId']['title']
          : null, // Handle populated field
      brandName: json['brandId'] != null && json['brandId'] is Map
          ? json['brandId']['fullName']
          : 'Unknown Brand',
      influencerName: json['influencerId'] != null && json['influencerId'] is Map
          ? json['influencerId']['fullName']
          : null,
      amount: (json['amount'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      type: json['type'],
      status: json['status'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'campaignTitle': campaignTitle,
      'brandName': brandName,
      'influencerName': influencerName,
      'amount': amount,
      'netAmount': netAmount,
      'type': type,
      'status': status,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
