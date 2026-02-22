import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/core/usecases/usecase.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';
import 'package:influcollb_app/features/application/domain/repositories/application_repository.dart';

class GetCampaignApplicationsUseCase
    implements UseCase<List<ApplicationModel>, String> {
  final IApplicationRepository repository;

  GetCampaignApplicationsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<ApplicationModel>>> call(String params) async {
    return await repository.getCampaignApplications(params);
  }
}
