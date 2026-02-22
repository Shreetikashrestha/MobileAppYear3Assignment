import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import 'package:influcollb_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:influcollb_app/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUseCase(authRepository: mockRepository);
  });

  const tEmail = 'test@example.com';
  const tFullName = 'Test User';
  const tUsername = 'testuser';
  const tPassword = 'password123';

  final tUser = AuthApiModel(
    id: '1',
    fullName: tFullName,
    email: tEmail,
    username: tUsername,
  );

  group('RegisterUseCase', () {
    test('should return AuthApiModel when register is successful', () async {
      // Arrange
      when(() => mockRepository.register(tEmail, tFullName, tUsername, tPassword))
          .thenAnswer((_) async => Right(tUser));

      // Act
      final result = await usecase(
        const RegisterParams(
          email: tEmail,
          fullName: tFullName,
          username: tUsername,
          password: tPassword,
        ),
      );

      // Assert
      expect(result, Right(tUser));
      verify(() => mockRepository.register(tEmail, tFullName, tUsername, tPassword))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when register fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Registration failed');
      when(() => mockRepository.register(tEmail, tFullName, tUsername, tPassword))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const RegisterParams(
          email: tEmail,
          fullName: tFullName,
          username: tUsername,
          password: tPassword,
        ),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.register(tEmail, tFullName, tUsername, tPassword))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
