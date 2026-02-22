import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/usecases/usecase.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';
import 'package:influcollb_app/features/application/domain/usecases/get_campaign_applications_usecase.dart';
import 'package:influcollb_app/features/application/domain/usecases/get_my_applications_usecase.dart';
import 'package:influcollb_app/features/application/domain/usecases/submit_application_usecase.dart';
import 'package:influcollb_app/features/application/domain/usecases/update_application_status_usecase.dart';

class ApplicationState {
  final bool isLoading;
  final String? error;
  final List<ApplicationModel> myApplications;
  final List<ApplicationModel> campaignApplications;
  final ApplicationModel? currentApplication;
  final bool isSubmitting;
  final bool isUpdating;

  ApplicationState({
    this.isLoading = false,
    this.error,
    this.myApplications = const [],
    this.campaignApplications = const [],
    this.currentApplication,
    this.isSubmitting = false,
    this.isUpdating = false,
  });

  ApplicationState copyWith({
    bool? isLoading,
    String? error,
    List<ApplicationModel>? myApplications,
    List<ApplicationModel>? campaignApplications,
    ApplicationModel? currentApplication,
    bool? isSubmitting,
    bool? isUpdating,
  }) {
    return ApplicationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      myApplications: myApplications ?? this.myApplications,
      campaignApplications:
          campaignApplications ?? this.campaignApplications,
      currentApplication: currentApplication ?? this.currentApplication,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

class ApplicationViewModel extends StateNotifier<ApplicationState> {
  final SubmitApplicationUseCase submitApplicationUseCase;
  final GetMyApplicationsUseCase getMyApplicationsUseCase;
  final GetCampaignApplicationsUseCase getCampaignApplicationsUseCase;
  final UpdateApplicationStatusUseCase updateApplicationStatusUseCase;

  ApplicationViewModel({
    required this.submitApplicationUseCase,
    required this.getMyApplicationsUseCase,
    required this.getCampaignApplicationsUseCase,
    required this.updateApplicationStatusUseCase,
  }) : super(ApplicationState());

  Future<bool> submitApplication(ApplicationModel application) async {
    state = state.copyWith(isSubmitting: true, error: null);

    final result = await submitApplicationUseCase(application);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          error: failure.error,
        );
        return false;
      },
      (application) {
        state = state.copyWith(
          isSubmitting: false,
          currentApplication: application,
        );
        // Refresh my applications list
        getMyApplications();
        return true;
      },
    );
  }

  Future<void> getMyApplications() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getMyApplicationsUseCase(NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.error,
        );
      },
      (applications) {
        state = state.copyWith(
          isLoading: false,
          myApplications: applications,
        );
      },
    );
  }

  Future<void> getCampaignApplications(String campaignId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getCampaignApplicationsUseCase(campaignId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.error,
        );
      },
      (applications) {
        state = state.copyWith(
          isLoading: false,
          campaignApplications: applications,
        );
      },
    );
  }

  Future<bool> updateApplicationStatus(String applicationId, String status) async {
    state = state.copyWith(isUpdating: true, error: null);

    final params = UpdateApplicationStatusParams(
      applicationId: applicationId,
      status: status,
    );

    final result = await updateApplicationStatusUseCase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.error,
        );
        return false;
      },
      (application) {
        // Update the application in the list
        final updatedList = state.campaignApplications.map((app) {
          return app.id == applicationId ? application : app;
        }).toList();

        state = state.copyWith(
          isUpdating: false,
          campaignApplications: updatedList,
        );
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = ApplicationState();
  }
}
