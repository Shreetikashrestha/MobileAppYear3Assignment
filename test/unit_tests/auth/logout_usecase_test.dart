import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/core/usecases/usecase.dart';
import 'package:influcollb_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:influcollb_app/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUseCase logoutUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    logoutUseCase = LogoutUseCase(authRepository: mockAuthRepository);
  });

  group('LogoutUseCase', () {
    test('should return true when logout is successful', () async {
      // Arrange
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await logoutUseCase(NoParams());

      // Assert
      expect(result, const Right(true));
      verify(() => mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Failure when logout fails', () async {
      // Arrange
      final tFailure = ServerFailure('Logout failed');
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await logoutUseCase(NoParams());

      // Assert
      expect(result, Left(tFailure));
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('should call repository logout method', () async {
      // Arrange
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(true));

      // Act
      await logoutUseCase(NoParams());

      // Assert
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('should return false when logout is unsuccessful', () async {
      // Arrange
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(false));

      // Act
      final result = await logoutUseCase(NoParams());

      // Assert
      expect(result, const Right(false));
      verify(() => mockAuthRepository.logout()).called(1);
    });
  });
}
