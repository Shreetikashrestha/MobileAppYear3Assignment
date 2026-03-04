import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/influencer/domain/entities/influencer_entity.dart';
import 'package:influcollb_app/features/influencer/domain/repositories/influencer_repository.dart';

class GetInfluencersUseCase {
  final IInfluencerRepository repository;

  GetInfluencersUseCase({required this.repository});

  Future<Either<Failure, List<InfluencerEntity>>> call() async {
    return await repository.getInfluencers();
  }
}
