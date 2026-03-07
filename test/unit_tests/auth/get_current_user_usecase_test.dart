import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import 'package:influcollb_app/features/auth/domain/entities/auth_entity.dart';
import 'package:influcollb_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:influcollb_app/features/auth/domain/usecases/get_current_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late GetCurrentUserUseCase getCurrentUserUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    getCurrentUserUseCase = GetCurrentUserUseCase(authRepository: mockAuthRepository);
  });

  final tAuthModel = AuthApiModel(
    id: '789',
    fullName: 'Current User',
    email: 'current@example.com',
    username: 'currentuser',
    isInfluencer: true,
  );

  final tAuthEntity = AuthEntity(
    authId: '789',
    fullName: 'Current User',
    email: 'current@example.com',
    username: 'currentuser',
    isInfluencer: true,
  );

  group('GetCurrentUserUseCase', () {
    test('should return AuthEntity when getting current user is successful', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(tAuthModel));

      // Act
      final result = await getCurrentUserUseCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (entity) {
          expect(entity.authId, tAuthEntity.authId);
          expect(entity.fullName, tAuthEntity.fullName);
          expect(entity.email, tAuthEntity.email);
          expect(entity.username, tAuthEntity.username);
          expect(entity.isInfluencer, tAuthEntity.isInfluencer);
        },
      );
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Failure when getting current user fails', () async {
      // Arrange
      final tFailure = ServerFailure('User not found');
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await getCurrentUserUseCase();

      // Assert
      expect(result, Left(tFailure));
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
    });

    test('should convert AuthApiModel to AuthEntity', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(tAuthModel));

      // Act
      final result = await getCurrentUserUseCase();

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (entity) {
          expect(entity, isA<AuthEntity>());
          expect(entity.authId, tAuthModel.id);
        },
      );
    });

    test('should call repository getCurrentUser method', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(tAuthModel));

      // Act
      await getCurrentUserUseCase();

      // Assert
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
    });
  });
}
