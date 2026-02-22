import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import 'package:influcollb_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:influcollb_app/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUseCase(authRepository: mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  final tUser = AuthApiModel(
    id: '1',
    fullName: 'Test User',
    email: tEmail,
    username: 'testuser',
  );

  group('LoginUseCase', () {
    test('should return AuthApiModel when login is successful', () async {
      // Arrange
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => Right(tUser));

      // Act
      final result = await usecase(const LoginParams(email: tEmail, password: tPassword));

      // Assert
      expect(result, Right(tUser));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when login fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Invalid credentials');
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(const LoginParams(email: tEmail, password: tPassword));

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
