import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/core/usecases/usecase.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';
import 'package:influcollb_app/features/application/domain/repositories/application_repository.dart';

class SubmitApplicationUseCase
    implements UseCase<ApplicationModel, ApplicationModel> {
  final IApplicationRepository repository;

  SubmitApplicationUseCase({required this.repository});

  @override
  Future<Either<Failure, ApplicationModel>> call(
      ApplicationModel params) async {
    return await repository.submitApplication(params);
  }
}
