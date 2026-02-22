import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/core/usecases/usecase.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';
import 'package:influcollb_app/features/application/domain/repositories/application_repository.dart';

class GetMyApplicationsUseCase
    implements UseCase<List<ApplicationModel>, NoParams> {
  final IApplicationRepository repository;

  GetMyApplicationsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<ApplicationModel>>> call(NoParams params) async {
    return await repository.getMyApplications();
  }
}
