import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import 'package:influcollb_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:influcollb_app/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(authRepository: mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  final tAuthModel = AuthApiModel(
    id: '123',
    fullName: 'Test User',
    email: tEmail,
    username: 'testuser',
    isInfluencer: true,
  );

  group('LoginUseCase', () {
    test('should return AuthApiModel when login is successful', () async {
      // Arrange
      when(() => mockAuthRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => Right(tAuthModel));

      // Act
      final result = await loginUseCase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, Right(tAuthModel));
      verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Failure when login fails', () async {
      // Arrange
      final tFailure = ServerFailure('Invalid credentials');
      when(() => mockAuthRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await loginUseCase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, Left(tFailure));
      verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
    });

    test('should pass correct email and password to repository', () async {
      // Arrange
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => Right(tAuthModel));

      // Act
      await loginUseCase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // Assert
      verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
    });
  });
}
