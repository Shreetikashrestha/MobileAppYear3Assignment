import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/core/usecases/usecase.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';
import 'package:influcollb_app/features/application/domain/usecases/get_my_applications_usecase.dart';
import '../../../mocks/mock_providers.dart';

void main() {
  late GetMyApplicationsUseCase useCase;
  late MockApplicationRepository mockRepository;

  setUp(() {
    mockRepository = MockApplicationRepository();
    useCase = GetMyApplicationsUseCase(repository: mockRepository);
  });

  final testApplications = [
    ApplicationModel(
      id: 'app1',
      campaignId: 'campaign1',
      influencerId: 'influencer1',
      coverLetter: 'Cover letter 1',
      proposedRate: '5000',
      portfolioLinks: [],
      status: 'pending',
    ),
    ApplicationModel(
      id: 'app2',
      campaignId: 'campaign2',
      influencerId: 'influencer1',
      coverLetter: 'Cover letter 2',
      proposedRate: '6000',
      portfolioLinks: [],
      status: 'accepted',
    ),
  ];

  group('GetMyApplicationsUseCase', () {
    test('should get list of applications successfully', () async {
      // Arrange
      when(() => mockRepository.getMyApplications())
          .thenAnswer((_) async => Right(testApplications));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, Right(testApplications));
      expect(result.fold((l) => [], (r) => r).length, 2);
      verify(() => mockRepository.getMyApplications()).called(1);
    });

    test('should return empty list when no applications exist', () async {
      // Arrange
      when(() => mockRepository.getMyApplications())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, const Right([]));
      expect(result.fold((l) => [], (r) => r), isEmpty);
    });

    test('should return failure when fetching fails', () async {
      // Arrange
      const failure = ServerFailure('Failed to fetch applications');
      when(() => mockRepository.getMyApplications())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getMyApplications()).called(1);
    });
  });
}
