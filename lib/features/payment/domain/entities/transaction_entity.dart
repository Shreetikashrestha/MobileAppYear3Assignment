import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String? campaignTitle;
  final String brandName;
  final String? influencerName;
  final double amount;
  final double netAmount;
  final String type;
  final String status;
  final String? description;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    this.campaignTitle,
    required this.brandName,
    this.influencerName,
    required this.amount,
    required this.netAmount,
    required this.type,
    required this.status,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        campaignTitle,
        brandName,
        influencerName,
        amount,
        netAmount,
        type,
        status,
        description,
        createdAt,
      ];
}
