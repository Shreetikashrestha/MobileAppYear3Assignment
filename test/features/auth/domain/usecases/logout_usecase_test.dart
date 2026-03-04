import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/core/usecases/usecase.dart';
import 'package:influcollb_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:influcollb_app/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LogoutUseCase(authRepository: mockRepository);
  });

  group('LogoutUseCase', () {
    test('should return true when logout is successful', () async {
      // Arrange
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.logout()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when logout fails', () async {
      // Arrange
      const failure = LocalDatabaseFailure(message: 'Logout failed');
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.logout()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
