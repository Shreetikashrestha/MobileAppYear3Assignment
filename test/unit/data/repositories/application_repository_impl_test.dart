import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/features/application/data/datasources/application_remote_datasource.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';
import 'package:influcollb_app/features/application/data/repositories/application_repository_impl.dart';

class MockApplicationRemoteDataSource extends Mock
    implements IApplicationRemoteDataSource {}

void main() {
  late ApplicationRepositoryImpl repository;
  late MockApplicationRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockApplicationRemoteDataSource();
    repository =
        ApplicationRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('submitApplication', () {
    final tApplicationModel = ApplicationModel(
      id: '1',
      campaignId: 'campaign1',
      influencerId: 'influencer1',
      coverLetter: 'Test cover letter',
      proposedRate: '5000',
      portfolioLinks: const ['https://example.com'],
      status: 'pending',
      createdAt: DateTime(2025, 1, 1),
    );

    test('should return ApplicationModel when remote call is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.submitApplication(any()))
          .thenAnswer((_) async => tApplicationModel);

      // act
      final result = await repository.submitApplication(tApplicationModel);

      // assert
      expect(result, equals(Right(tApplicationModel)));
      verify(() => mockRemoteDataSource.submitApplication(tApplicationModel));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('should return Failure when remote call throws exception', () async {
      // arrange
      when(() => mockRemoteDataSource.submitApplication(any()))
          .thenThrow(Exception('Server error'));

      // act
      final result = await repository.submitApplication(tApplicationModel);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Should return failure'),
      );
      verify(() => mockRemoteDataSource.submitApplication(tApplicationModel));
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

    test(
        'should return list of ApplicationModel when remote call is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getMyApplications())
          .thenAnswer((_) async => tApplicationsList);

      // act
      final result = await repository.getMyApplications();

      // assert
      expect(result, equals(Right(tApplicationsList)));
      verify(() => mockRemoteDataSource.getMyApplications());
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('should return Failure when remote call throws exception', () async {
      // arrange
      when(() => mockRemoteDataSource.getMyApplications())
          .thenThrow(Exception('Server error'));

      // act
      final result = await repository.getMyApplications();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Should return failure'),
      );
      verify(() => mockRemoteDataSource.getMyApplications());
    });
  });

  group('getCampaignApplications', () {
    const tCampaignId = 'campaign1';
    final tApplicationsList = [
      ApplicationModel(
        id: '1',
        campaignId: tCampaignId,
        influencerId: 'influencer1',
        coverLetter: 'Test cover letter 1',
        proposedRate: '5000',
        portfolioLinks: const ['https://example.com'],
        status: 'pending',
        createdAt: DateTime(2025, 1, 1),
      ),
    ];

    test(
        'should return list of ApplicationModel when remote call is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getCampaignApplications(any()))
          .thenAnswer((_) async => tApplicationsList);

      // act
      final result = await repository.getCampaignApplications(tCampaignId);

      // assert
      expect(result, equals(Right(tApplicationsList)));
      verify(() => mockRemoteDataSource.getCampaignApplications(tCampaignId));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('should return Failure when remote call throws exception', () async {
      // arrange
      when(() => mockRemoteDataSource.getCampaignApplications(any()))
          .thenThrow(Exception('Server error'));

      // act
      final result = await repository.getCampaignApplications(tCampaignId);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Should return failure'),
      );
      verify(() => mockRemoteDataSource.getCampaignApplications(tCampaignId));
    });
  });
}
