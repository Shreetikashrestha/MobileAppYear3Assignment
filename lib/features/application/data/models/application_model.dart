class ApplicationModel {
  final String? id;
  final String campaignId;
  final String influencerId;
  final String coverLetter;
  final String proposedRate;
  final List<String> portfolioLinks;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? campaign;
  final Map<String, dynamic>? influencer;

  ApplicationModel({
    this.id,
    required this.campaignId,
    required this.influencerId,
    required this.coverLetter,
    required this.proposedRate,
    required this.portfolioLinks,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
    this.campaign,
    this.influencer,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['_id'] ?? json['id'],
      campaignId: json['campaignId'] is Map
          ? (json['campaignId']['_id'] ?? '')
          : (json['campaignId'] ?? ''),
      influencerId: json['influencerId'] is Map
          ? (json['influencerId']['_id'] ?? '')
          : (json['influencerId'] ?? ''),
      coverLetter: json['coverLetter'] ?? '',
      proposedRate: json['proposedRate']?.toString() ?? '0',
      portfolioLinks: json['portfolioLinks'] != null
          ? List<String>.from(json['portfolioLinks'])
          : [],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      campaign: json['campaignId'] is Map
          ? Map<String, dynamic>.from(json['campaignId'])
          : null,
      influencer: json['influencerId'] is Map
          ? Map<String, dynamic>.from(json['influencerId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'campaignId': campaignId,
      'influencerId': influencerId,
      'coverLetter': coverLetter,
      'proposedRate': proposedRate,
      'portfolioLinks': portfolioLinks,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  ApplicationModel copyWith({
    String? id,
    String? campaignId,
    String? influencerId,
    String? coverLetter,
    String? proposedRate,
    List<String>? portfolioLinks,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? campaign,
    Map<String, dynamic>? influencer,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      influencerId: influencerId ?? this.influencerId,
      coverLetter: coverLetter ?? this.coverLetter,
      proposedRate: proposedRate ?? this.proposedRate,
      portfolioLinks: portfolioLinks ?? this.portfolioLinks,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      campaign: campaign ?? this.campaign,
      influencer: influencer ?? this.influencer,
    );
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  String get campaignTitle {
    return campaign?['title'] ?? 'Unknown Campaign';
  }

  String get influencerName {
    return influencer?['fullName'] ?? 'Unknown Influencer';
  }
}
