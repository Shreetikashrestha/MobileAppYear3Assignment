class Application {
  final String id;
  final String campaignId;
  final String influencerId;
  final String brandId;
  final String status;
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Populated fields from backend
  final Map<String, dynamic>? influencerProfile;
  final Map<String, dynamic>? campaignData;
  final Map<String, dynamic>? brandProfile;

  Application({
    required this.id,
    required this.campaignId,
    required this.influencerId,
    required this.brandId,
    required this.status,
    this.message,
    required this.createdAt,
    required this.updatedAt,
    this.influencerProfile,
    this.campaignData,
    this.brandProfile,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['_id'] ?? '',
      campaignId: json['campaignId'] is Map
          ? (json['campaignId']['_id'] ?? '')
          : (json['campaignId'] ?? ''),
      influencerId: json['influencerId'] is Map
          ? (json['influencerId']['_id'] ?? '')
          : (json['influencerId'] ?? ''),
      brandId: json['brandId'] is Map
          ? (json['brandId']['_id'] ?? '')
          : (json['brandId'] ?? ''),
      status: json['status'] ?? 'pending',
      message: json['proposalMessage'] ?? json['message'],
      createdAt: json['appliedAt'] != null 
          ? DateTime.parse(json['appliedAt'])
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      influencerProfile: json['influencerId'] is Map
          ? Map<String, dynamic>.from(json['influencerId'])
          : null,
      campaignData: json['campaignId'] is Map
          ? Map<String, dynamic>.from(json['campaignId'])
          : null,
      brandProfile: json['brandId'] is Map
          ? Map<String, dynamic>.from(json['brandId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'campaignId': campaignId,
      'influencerId': influencerId,
      'brandId': brandId,
      'status': status,
      'proposalMessage': message,
      'appliedAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  
  String get statusDisplay {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'pending':
      default:
        return 'Pending';
    }
  }
}

