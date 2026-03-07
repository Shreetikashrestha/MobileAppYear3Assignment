import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import 'package:influcollb_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:influcollb_app/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUseCase registerUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerUseCase = RegisterUseCase(authRepository: mockAuthRepository);
  });

  const tEmail = 'newuser@example.com';
  const tFullName = 'New User';
  const tUsername = 'newuser';
  const tPassword = 'password123';
  final tAuthModel = AuthApiModel(
    id: '456',
    fullName: tFullName,
    email: tEmail,
    username: tUsername,
    isInfluencer: false,
  );

  group('RegisterUseCase', () {
    test('should return AuthApiModel when registration is successful', () async {
      // Arrange
      when(() => mockAuthRepository.register(
            tEmail,
            tFullName,
            tUsername,
            tPassword,
          )).thenAnswer((_) async => Right(tAuthModel));

      // Act
      final result = await registerUseCase(
        const RegisterParams(
          email: tEmail,
          fullName: tFullName,
          username: tUsername,
          password: tPassword,
        ),
      );

      // Assert
      expect(result, Right(tAuthModel));
      verify(() => mockAuthRepository.register(
            tEmail,
            tFullName,
            tUsername,
            tPassword,
          )).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Failure when registration fails', () async {
      // Arrange
      final tFailure = ServerFailure('Email already exists');
      when(() => mockAuthRepository.register(
            tEmail,
            tFullName,
            tUsername,
            tPassword,
          )).thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await registerUseCase(
        const RegisterParams(
          email: tEmail,
          fullName: tFullName,
          username: tUsername,
          password: tPassword,
        ),
      );

      // Assert
      expect(result, Left(tFailure));
      verify(() => mockAuthRepository.register(
            tEmail,
            tFullName,
            tUsername,
            tPassword,
          )).called(1);
    });

    test('should pass all parameters correctly to repository', () async {
      // Arrange
      when(() => mockAuthRepository.register(
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => Right(tAuthModel));

      // Act
      await registerUseCase(
        const RegisterParams(
          email: tEmail,
          fullName: tFullName,
          username: tUsername,
          password: tPassword,
        ),
      );

      // Assert
      verify(() => mockAuthRepository.register(
            tEmail,
            tFullName,
            tUsername,
            tPassword,
          )).called(1);
    });
  });
}
