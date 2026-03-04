import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:influcollb_app/features/auth/presentation/pages/login_screen.dart';
import 'package:influcollb_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:influcollb_app/features/auth/presentation/view_model/auth_providers.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import 'package:influcollb_app/core/error/failure.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    registerFallbackValue(const LoginParams(email: '', password: ''));
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  group('LoginScreen UI Elements', () {
    testWidgets('should display login text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.byKey(const Key('loginTitle')), findsOneWidget);
      expect(find.byKey(const Key('loginButtonText')), findsOneWidget);
    });

    testWidgets('should display role selection', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('I am a:'), findsOneWidget);
      expect(find.text('Influencer'), findsOneWidget);
      expect(find.text('Brand'), findsOneWidget);
    });

    testWidgets('should display email and password fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  group('LoginScreen Form Validation', () {
    testWidgets('should show error for empty fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Login').last);
      await tester.pump();
      expect(find.text('Please fill all fields'), findsOneWidget);
    });
  });

  group('LoginScreen Form Submission', () {
    testWidgets('should show loading indicator when login is in progress',
        (tester) async {
      when(() => mockLoginUseCase.call(any())).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return Right(AuthApiModel(
              email: 'test@test.com', fullName: 'Test', username: 'test'));
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Start the build
      await tester.pump(const Duration(milliseconds: 50)); // Wait for animation frame
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle(); // Complete the login and navigation
    });

    testWidgets('should show snackbar on login failure', (tester) async {
      when(() => mockLoginUseCase.call(any())).thenAnswer(
        (_) async => const Left(ApiFailure(message: 'Invalid credentials')),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrong_password');
      
      await tester.tap(find.text('Login').last);
      await tester.pumpAndSettle();
      
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
