import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import 'package:influcollb_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:influcollb_app/features/auth/presentation/view_model/login_view_model.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late LoginViewModel loginViewModel;
  late MockLoginUseCase mockLoginUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    loginViewModel = LoginViewModel(mockLoginUseCase);
  });

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
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

  group('LoginViewModel', () {
    test('initial state should have no data', () {
      // Assert
      expect(loginViewModel.state.hasValue, true);
      expect(loginViewModel.state.value, null);
    });

    test('should update state when login is successful', () async {
      // Arrange
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => Right(tAuthModel));

      // Act
      await loginViewModel.login(tEmail, tPassword);

      // Assert
      expect(loginViewModel.state.hasValue, true);
      expect(loginViewModel.state.value, tAuthModel);
      expect(loginViewModel.state.value?.email, tEmail);
      expect(loginViewModel.state.value?.fullName, 'Test User');
    });

    test('should update state with error when login fails', () async {
      // Arrange
      final tFailure = ServerFailure('Invalid credentials');
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      await loginViewModel.login(tEmail, tPassword);

      // Assert
      expect(loginViewModel.state is AsyncError, true);
      final errorState = loginViewModel.state as AsyncError;
      expect(errorState.error.toString(), contains('Invalid credentials'));
    });

    test('should call LoginUseCase with correct parameters', () async {
      // Arrange
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => Right(tAuthModel));

      // Act
      await loginViewModel.login(tEmail, tPassword);

      // Assert
      verify(() => mockLoginUseCase(
            const LoginParams(email: tEmail, password: tPassword),
          )).called(1);
    });

    test('should handle empty email', () async {
      // Arrange
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => Right(tAuthModel));

      // Act
      await loginViewModel.login('', tPassword);

      // Assert
      verify(() => mockLoginUseCase(
            const LoginParams(email: '', password: tPassword),
          )).called(1);
    });

    test('should handle empty password', () async {
      // Arrange
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => Right(tAuthModel));

      // Act
      await loginViewModel.login(tEmail, '');

      // Assert
      verify(() => mockLoginUseCase(
            const LoginParams(email: tEmail, password: ''),
          )).called(1);
    });

    test('should handle network failure', () async {
      // Arrange
      final tFailure = NetworkFailure('No internet connection');
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      await loginViewModel.login(tEmail, tPassword);

      // Assert
      expect(loginViewModel.state is AsyncError, true);
      final errorState = loginViewModel.state as AsyncError;
      expect(errorState.error.toString(), contains('No internet connection'));
    });

    test('should update state correctly on multiple login attempts', () async {
      // Arrange - First attempt succeeds
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => Right(tAuthModel));

      // Act - First login
      await loginViewModel.login(tEmail, tPassword);

      // Assert - First login success
      expect(loginViewModel.state.hasValue, true);
      expect(loginViewModel.state.value, tAuthModel);

      // Arrange - Second attempt fails
      final tFailure = ServerFailure('Server error');
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => Left(tFailure));

      // Act - Second login
      await loginViewModel.login(tEmail, 'wrongpassword');

      // Assert - Second login error
      expect(loginViewModel.state is AsyncError, true);
      final errorState = loginViewModel.state as AsyncError;
      expect(errorState.error.toString(), contains('Server error'));
    });
  });
}
