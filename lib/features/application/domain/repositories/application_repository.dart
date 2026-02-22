import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';

abstract class IApplicationRepository {
  Future<Either<Failure, ApplicationModel>> submitApplication(
      ApplicationModel application);
  Future<Either<Failure, List<ApplicationModel>>> getMyApplications();
  Future<Either<Failure, List<ApplicationModel>>> getCampaignApplications(
      String campaignId);
  Future<Either<Failure, ApplicationModel>> getApplicationById(String id);
  Future<Either<Failure, ApplicationModel>> updateApplicationStatus(
      String id, String status);
}
