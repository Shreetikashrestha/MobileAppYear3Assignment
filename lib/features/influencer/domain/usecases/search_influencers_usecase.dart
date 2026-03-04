import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/influencer/domain/entities/influencer_entity.dart';
import 'package:influcollb_app/features/influencer/domain/repositories/influencer_repository.dart';

class SearchInfluencersUseCase {
  final IInfluencerRepository repository;

  SearchInfluencersUseCase({required this.repository});

  Future<Either<Failure, List<InfluencerEntity>>> call(String query) async {
    return await repository.searchInfluencers(query);
  }
}
