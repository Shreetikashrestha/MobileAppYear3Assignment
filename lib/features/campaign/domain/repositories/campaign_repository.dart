import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/campaign/domain/entities/campaign_entity.dart';

abstract class ICampaignRepository {
  Future<Either<Failure, List<CampaignEntity>>> getAllCampaigns();
  Future<Either<Failure, CampaignEntity>> getCampaignById(String id);
  Future<Either<Failure, List<CampaignEntity>>> getMyBrandCampaigns();
  Future<Either<Failure, CampaignEntity>> createCampaign(Map<String, dynamic> campaignData);
  Future<Either<Failure, CampaignEntity>> updateCampaign(String id, Map<String, dynamic> campaignData);
  Future<Either<Failure, bool>> deleteCampaign(String id);
  Future<Either<Failure, Map<String, dynamic>>> getBrandStats();
}
