import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:influcollb_app/features/auth/presentation/pages/signup_screen.dart';
import 'package:influcollb_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:influcollb_app/features/auth/presentation/view_model/auth_providers.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late MockRegisterUseCase mockRegisterUseCase;

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    registerFallbackValue(const RegisterParams(
      email: '',
      fullName: '',
      username: '',
      password: '',
    ));
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        registerUseCaseProvider.overrideWithValue(mockRegisterUseCase),
      ],
      child: const MaterialApp(home: SignupScreen()),
    );
  }

  group('SignupScreen UI Elements', () {
    testWidgets('should display signup elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('should display role selection', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Influencer'), findsOneWidget);
      expect(find.text('Brand'), findsOneWidget);
    });
   group('SignupScreen Form Submission', () {
    testWidgets('should show loading and success', (tester) async {
       when(() => mockRegisterUseCase.call(any())).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return Right(AuthApiModel(
            email: 'test@test.com',
            fullName: 'Test User',
            username: 'testuser',
          ));
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle();
      expect(find.text('Signup successful. Please log in.'), findsOneWidget);
    });
  });
});
}
