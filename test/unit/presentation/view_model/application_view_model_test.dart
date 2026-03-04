import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/core/usecases/usecase.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';
import 'package:influcollb_app/features/application/domain/usecases/submit_application_usecase.dart';
import 'package:influcollb_app/features/application/domain/usecases/get_my_applications_usecase.dart';
import 'package:influcollb_app/features/application/domain/usecases/get_campaign_applications_usecase.dart';
import 'package:influcollb_app/features/application/domain/usecases/update_application_status_usecase.dart';
import 'package:influcollb_app/features/application/presentation/view_model/application_view_model.dart';

class MockSubmitApplicationUseCase extends Mock
    implements SubmitApplicationUseCase {}

class MockGetMyApplicationsUseCase extends Mock
    implements GetMyApplicationsUseCase {}

class MockGetCampaignApplicationsUseCase extends Mock
    implements GetCampaignApplicationsUseCase {}

class MockUpdateApplicationStatusUseCase extends Mock
    implements UpdateApplicationStatusUseCase {}

class FakeApplicationModel extends Fake implements ApplicationModel {}

class FakeNoParams extends Fake implements NoParams {}

class FakeUpdateApplicationStatusParams extends Fake
    implements UpdateApplicationStatusParams {}

void main() {
  late ApplicationViewModel viewModel;
  late MockSubmitApplicationUseCase mockSubmitUseCase;
  late MockGetMyApplicationsUseCase mockGetMyApplicationsUseCase;
  late MockGetCampaignApplicationsUseCase mockGetCampaignApplicationsUseCase;
  late MockUpdateApplicationStatusUseCase mockUpdateStatusUseCase;

  setUpAll(() {
    registerFallbackValue(FakeApplicationModel());
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeUpdateApplicationStatusParams());
  });

  setUp(() {
    mockSubmitUseCase = MockSubmitApplicationUseCase();
    mockGetMyApplicationsUseCase = MockGetMyApplicationsUseCase();
    mockGetCampaignApplicationsUseCase = MockGetCampaignApplicationsUseCase();
    mockUpdateStatusUseCase = MockUpdateApplicationStatusUseCase();

    viewModel = ApplicationViewModel(
      submitApplicationUseCase: mockSubmitUseCase,
      getMyApplicationsUseCase: mockGetMyApplicationsUseCase,
      getCampaignApplicationsUseCase: mockGetCampaignApplicationsUseCase,
      updateApplicationStatusUseCase: mockUpdateStatusUseCase,
    );
  });

  group('submitApplication', () {
    final tApplication = ApplicationModel(
      id: '1',
      campaignId: 'campaign1',
      influencerId: 'influencer1',
      coverLetter: 'Test cover letter',
      proposedRate: '5000',
      portfolioLinks: const ['https://example.com'],
      status: 'pending',
      createdAt: DateTime(2025, 1, 1),
    );

    test('should return true when submission is successful', () async {
      // arrange
      when(() => mockSubmitUseCase(any()))
          .thenAnswer((_) async => Right(tApplication));
      when(() => mockGetMyApplicationsUseCase(any()))
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await viewModel.submitApplication(tApplication);

      // assert
      expect(result, true);
      expect(viewModel.state.isSubmitting, false);
      expect(viewModel.state.currentApplication, tApplication);
    });

    test('should return false and set error when submission fails', () async {
      // arrange
      when(() => mockSubmitUseCase(any())).thenAnswer(
          (_) async => const Left(ApiFailure(message: 'Server error')));

      // act
      final result = await viewModel.submitApplication(tApplication);

      // assert
      expect(result, false);
      expect(viewModel.state.isSubmitting, false);
      expect(viewModel.state.error, 'Server error');
    });
  });

  group('getMyApplications', () {
    final tApplicationsList = [
      ApplicationModel(
        id: '1',
        campaignId: 'campaign1',
        influencerId: 'influencer1',
        coverLetter: 'Test cover letter 1',
        proposedRate: '5000',
        portfolioLinks: const ['https://example.com'],
        status: 'pending',
        createdAt: DateTime(2025, 1, 1),
      ),
      ApplicationModel(
        id: '2',
        campaignId: 'campaign2',
        influencerId: 'influencer1',
        coverLetter: 'Test cover letter 2',
        proposedRate: '6000',
        portfolioLinks: const ['https://example2.com'],
        status: 'accepted',
        createdAt: DateTime(2025, 1, 2),
      ),
    ];

    test('should load applications successfully', () async {
      // arrange
      when(() => mockGetMyApplicationsUseCase(any()))
          .thenAnswer((_) async => Right(tApplicationsList));

      // act
      await viewModel.getMyApplications();

      // assert
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.myApplications, tApplicationsList);
    });

    test('should set error when loading fails', () async {
      // arrange
      when(() => mockGetMyApplicationsUseCase(any())).thenAnswer(
          (_) async => const Left(ApiFailure(message: 'Server error')));

      // act
      await viewModel.getMyApplications();

      // assert
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, 'Server error');
    });
  });

  group('getCampaignApplications', () {
    const tCampaignId = 'campaign1';
    final tApplicationsList = [
      ApplicationModel(
        id: '1',
        campaignId: tCampaignId,
        influencerId: 'influencer1',
        coverLetter: 'Test cover letter',
        proposedRate: '5000',
        portfolioLinks: const ['https://example.com'],
        status: 'pending',
        createdAt: DateTime(2025, 1, 1),
      ),
    ];

    test('should load campaign applications successfully', () async {
      // arrange
      when(() => mockGetCampaignApplicationsUseCase(any()))
          .thenAnswer((_) async => Right(tApplicationsList));

      // act
      await viewModel.getCampaignApplications(tCampaignId);

      // assert
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.campaignApplications, tApplicationsList);
    });

    test('should set error when loading fails', () async {
      // arrange
      when(() => mockGetCampaignApplicationsUseCase(any())).thenAnswer(
          (_) async => const Left(ApiFailure(message: 'Server error')));

      // act
      await viewModel.getCampaignApplications(tCampaignId);

      // assert
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, 'Server error');
    });
  });

  group('updateApplicationStatus', () {
    const tApplicationId = '1';
    const tStatus = 'accepted';
    final tUpdatedApplication = ApplicationModel(
      id: tApplicationId,
      campaignId: 'campaign1',
      influencerId: 'influencer1',
      coverLetter: 'Test cover letter',
      proposedRate: '5000',
      portfolioLinks: const ['https://example.com'],
      status: tStatus,
      createdAt: DateTime(2025, 1, 1),
    );

    test('should return true when update is successful', () async {
      // arrange
      when(() => mockUpdateStatusUseCase(any()))
          .thenAnswer((_) async => Right(tUpdatedApplication));

      // act
      final result =
          await viewModel.updateApplicationStatus(tApplicationId, tStatus);

      // assert
      expect(result, true);
      expect(viewModel.state.isUpdating, false);
    });

    test('should return false and set error when update fails', () async {
      // arrange
      when(() => mockUpdateStatusUseCase(any())).thenAnswer(
          (_) async => const Left(ApiFailure(message: 'Server error')));

      // act
      final result =
          await viewModel.updateApplicationStatus(tApplicationId, tStatus);

      // assert
      expect(result, false);
      expect(viewModel.state.isUpdating, false);
      expect(viewModel.state.error, 'Server error');
    });
  });
}
