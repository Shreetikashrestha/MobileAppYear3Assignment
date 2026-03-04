import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';
import 'package:influcollb_app/features/application/domain/usecases/submit_application_usecase.dart';
import '../../../mocks/mock_providers.dart';

void main() {
  late SubmitApplicationUseCase useCase;
  late MockApplicationRepository mockRepository;

  setUp(() {
    mockRepository = MockApplicationRepository();
    useCase = SubmitApplicationUseCase(repository: mockRepository);
  });

  final testApplication = ApplicationModel(
    campaignId: 'campaign123',
    influencerId: 'influencer123',
    coverLetter: 'Test cover letter',
    proposedRate: '5000',
    portfolioLinks: ['https://portfolio.com'],
  );

  final submittedApplication = testApplication.copyWith(
    id: 'app123',
    status: 'pending',
    createdAt: DateTime.now(),
  );

  group('SubmitApplicationUseCase', () {
    test('should submit application successfully', () async {
      // Arrange
      when(() => mockRepository.submitApplication(testApplication))
          .thenAnswer((_) async => Right(submittedApplication));

      // Act
      final result = await useCase(testApplication);

      // Assert
      expect(result, Right(submittedApplication));
      verify(() => mockRepository.submitApplication(testApplication)).called(1);
    });

    test('should return failure when submission fails', () async {
      // Arrange
      const failure = ServerFailure('Submission failed');
      when(() => mockRepository.submitApplication(testApplication))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testApplication);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.submitApplication(testApplication)).called(1);
    });

    test('should return failure when network error occurs', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(() => mockRepository.submitApplication(testApplication))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testApplication);

      // Assert
      expect(result, const Left(failure));
      expect(result.fold((l) => l.error, (r) => ''), 'No internet connection');
    });
  });
}
