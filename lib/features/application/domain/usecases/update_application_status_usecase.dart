import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/core/usecases/usecase.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';
import 'package:influcollb_app/features/application/domain/repositories/application_repository.dart';

class UpdateApplicationStatusParams {
  final String applicationId;
  final String status;

  UpdateApplicationStatusParams({
    required this.applicationId,
    required this.status,
  });
}

class UpdateApplicationStatusUseCase
    implements UseCase<ApplicationModel, UpdateApplicationStatusParams> {
  final IApplicationRepository repository;

  UpdateApplicationStatusUseCase({required this.repository});

  @override
  Future<Either<Failure, ApplicationModel>> call(
      UpdateApplicationStatusParams params) async {
    return await repository.updateApplicationStatus(
      params.applicationId,
      params.status,
    );
  }
}
