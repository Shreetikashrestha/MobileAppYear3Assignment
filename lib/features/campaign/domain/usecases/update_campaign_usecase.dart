import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/campaign/domain/entities/campaign_entity.dart';
import 'package:influcollb_app/features/campaign/domain/repositories/campaign_repository.dart';

class UpdateCampaignUseCase {
  final ICampaignRepository repository;

  UpdateCampaignUseCase({required this.repository});

  Future<Either<Failure, CampaignEntity>> call(String id, Map<String, dynamic> campaignData) async {
    return await repository.updateCampaign(id, campaignData);
  }
}
