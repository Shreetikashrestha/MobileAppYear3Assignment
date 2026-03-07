import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/influencer/data/datasources/influencer_remote_datasource.dart';
import 'package:influcollb_app/features/influencer/domain/entities/influencer_entity.dart';
import 'package:influcollb_app/features/influencer/domain/repositories/influencer_repository.dart';

class InfluencerRepositoryImpl implements IInfluencerRepository {
  final IInfluencerRemoteDataSource remoteDataSource;

  InfluencerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<InfluencerEntity>>> getInfluencers() async {
    try {
      final influencers = await remoteDataSource.getInfluencers();
      return Right(influencers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InfluencerEntity>>> searchInfluencers(
      String query) async {
    try {
      final influencers = await remoteDataSource.searchInfluencers(query);
      return Right(influencers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InfluencerEntity>> getInfluencerProfile(
      String id) async {
    try {
      final influencer = await remoteDataSource.getInfluencerProfile(id);
      return Right(influencer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
