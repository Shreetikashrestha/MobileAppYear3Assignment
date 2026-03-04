import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/influencer/domain/entities/influencer_entity.dart';
import 'package:influcollb_app/features/influencer/domain/repositories/influencer_repository.dart';

class GetInfluencerProfileUseCase {
  final IInfluencerRepository repository;

  GetInfluencerProfileUseCase({required this.repository});

  Future<Either<Failure, InfluencerEntity>> call(String id) async {
    return await repository.getInfluencerProfile(id);
  }
}
