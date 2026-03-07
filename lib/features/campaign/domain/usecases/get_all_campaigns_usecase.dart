import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/campaign/domain/entities/campaign_entity.dart';
import 'package:influcollb_app/features/campaign/domain/repositories/campaign_repository.dart';

class GetAllCampaignsUseCase {
  final ICampaignRepository repository;

  GetAllCampaignsUseCase({required this.repository});

  Future<Either<Failure, List<CampaignEntity>>> call() async {
    return await repository.getAllCampaigns();
  }
}
