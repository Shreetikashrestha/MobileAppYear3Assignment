import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/influencer/domain/entities/influencer_entity.dart';

abstract class IInfluencerRepository {
  Future<Either<Failure, List<InfluencerEntity>>> getInfluencers();
  Future<Either<Failure, List<InfluencerEntity>>> searchInfluencers(String query);
  Future<Either<Failure, InfluencerEntity>> getInfluencerProfile(String id);
}
