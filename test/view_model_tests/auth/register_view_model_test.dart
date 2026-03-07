import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failure.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import 'package:influcollb_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:influcollb_app/features/auth/presentation/view_model/register_view_model.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late RegisterViewModel registerViewModel;
  late MockRegisterUseCase mockRegisterUseCase;

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    registerViewModel = RegisterViewModel(mockRegisterUseCase);
  });

  setUpAll(() {
    registerFallbackValue(const RegisterParams(
      email: '',
      fullName: '',
      username: '',
      password: '',
    ));
  });

  final tAuthModel = AuthApiModel(
    id: '456',
    fullName: 'New User',
    email: 'newuser@example.com',
    username: 'newuser',
    password: 'password123',
    isInfluencer: false,
  );

  group('RegisterViewModel', () {
    test('initial state should have no data', () {
      // Assert
      expect(registerViewModel.state.hasValue, true);
      expect(registerViewModel.state.value, null);
    });

    test('should update state when registration is successful', () async {
      // Arrange
      when(() => mockRegisterUseCase(any()))
          .thenAnswer((_) async => Right(tAuthModel));

      // Act
      await registerViewModel.register(tAuthModel);

      // Assert
      expect(registerViewModel.state.hasValue, true);
      expect(registerViewModel.state.value, tAuthModel);
      expect(registerViewModel.state.value?.email, 'newuser@example.com');
      expect(registerViewModel.state.value?.fullName, 'New User');
    });

    test('should update state with error when registration fails', () async {
      // Arrange
      final tFailure = ServerFailure('Email already exists');
      when(() => mockRegisterUseCase(any()))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      await registerViewModel.register(tAuthModel);

      // Assert
      expect(registerViewModel.state is AsyncError, true);
      final errorState = registerViewModel.state as AsyncError;
      expect(errorState.error.toString(), contains('Email already exists'));
    });

    test('should call RegisterUseCase with correct parameters', () async {
      // Arrange
      when(() => mockRegisterUseCase(any()))
          .thenAnswer((_) async => Right(tAuthModel));

      // Act
      await registerViewModel.register(tAuthModel);

      // Assert
      verify(() => mockRegisterUseCase(
            RegisterParams(
              email: tAuthModel.email,
              fullName: tAuthModel.fullName,
              username: tAuthModel.username,
              password: tAuthModel.password ?? '',
            ),
          )).called(1);
    });

    test('should handle validation failure', () async {
      // Arrange
      final tFailure = ValidationFailure('Invalid email format');
      when(() => mockRegisterUseCase(any()))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      await registerViewModel.register(tAuthModel);

      // Assert
      expect(registerViewModel.state is AsyncError, true);
      final errorState = registerViewModel.state as AsyncError;
      expect(errorState.error.toString(), contains('Invalid email format'));
    });

    test('should handle network failure', () async {
      // Arrange
      final tFailure = NetworkFailure('No internet connection');
      when(() => mockRegisterUseCase(any()))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      await registerViewModel.register(tAuthModel);

      // Assert
      expect(registerViewModel.state is AsyncError, true);
      final errorState = registerViewModel.state as AsyncError;
      expect(errorState.error.toString(), contains('No internet connection'));
    });

    test('should handle user with null password', () async {
      // Arrange
      final userWithoutPassword = AuthApiModel(
        id: '789',
        fullName: 'Test User',
        email: 'test@example.com',
        username: 'testuser',
        password: null,
        isInfluencer: true,
      );
      when(() => mockRegisterUseCase(any()))
          .thenAnswer((_) async => Right(userWithoutPassword));

      // Act
      await registerViewModel.register(userWithoutPassword);

      // Assert
      verify(() => mockRegisterUseCase(
            const RegisterParams(
              email: 'test@example.com',
              fullName: 'Test User',
              username: 'testuser',
              password: '',
            ),
          )).called(1);
    });

    test('should update state correctly on multiple registration attempts', () async {
      // Arrange - First attempt fails
      final tFailure = ServerFailure('Email already exists');
      when(() => mockRegisterUseCase(any()))
          .thenAnswer((_) async => Left(tFailure));

      // Act - First registration
      await registerViewModel.register(tAuthModel);

      // Assert - First registration error
      expect(registerViewModel.state is AsyncError, true);
      final errorState = registerViewModel.state as AsyncError;
      expect(errorState.error.toString(), contains('Email already exists'));

      // Arrange - Second attempt succeeds
      when(() => mockRegisterUseCase(any()))
          .thenAnswer((_) async => Right(tAuthModel));

      // Act - Second registration
      await registerViewModel.register(tAuthModel);

      // Assert - Second registration success
      expect(registerViewModel.state.hasValue, true);
      expect(registerViewModel.state.value, tAuthModel);
    });
  });
}
