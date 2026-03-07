import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/campaign/domain/repositories/campaign_repository.dart';

class DeleteCampaignUseCase {
  final ICampaignRepository repository;

  DeleteCampaignUseCase({required this.repository});

  Future<Either<Failure, bool>> call(String id) async {
    return await repository.deleteCampaign(id);
  }
}
