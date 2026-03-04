import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/campaign/data/datasources/campaign_remote_datasource.dart';
import 'package:influcollb_app/features/campaign/domain/entities/campaign_entity.dart';
import 'package:influcollb_app/features/campaign/domain/repositories/campaign_repository.dart';

class CampaignRepositoryImpl implements ICampaignRepository {
  final ICampaignRemoteDataSource remoteDataSource;

  CampaignRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CampaignEntity>>> getAllCampaigns() async {
    try {
      final campaigns = await remoteDataSource.getAllCampaigns();
      return Right(campaigns);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CampaignEntity>> getCampaignById(String id) async {
    try {
      final campaign = await remoteDataSource.getCampaignById(id);
      return Right(campaign);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CampaignEntity>>> getMyBrandCampaigns() async {
    try {
      final campaigns = await remoteDataSource.getMyBrandCampaigns();
      return Right(campaigns);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CampaignEntity>> createCampaign(Map<String, dynamic> campaignData) async {
    try {
      final campaign = await remoteDataSource.createCampaign(campaignData);
      return Right(campaign);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CampaignEntity>> updateCampaign(String id, Map<String, dynamic> campaignData) async {
    try {
      final campaign = await remoteDataSource.updateCampaign(id, campaignData);
      return Right(campaign);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCampaign(String id) async {
    try {
      final result = await remoteDataSource.deleteCampaign(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBrandStats() async {
    try {
      final stats = await remoteDataSource.getBrandStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
