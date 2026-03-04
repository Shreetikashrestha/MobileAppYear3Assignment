import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/campaign/domain/entities/campaign_entity.dart';
import 'package:influcollb_app/features/campaign/domain/repositories/campaign_repository.dart';

class CreateCampaignUseCase {
  final ICampaignRepository repository;

  CreateCampaignUseCase({required this.repository});

  Future<Either<Failure, CampaignEntity>> call(Map<String, dynamic> campaignData) async {
    return await repository.createCampaign(campaignData);
  }
}
