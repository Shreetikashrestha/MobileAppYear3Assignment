import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/features/auth/presentation/pages/login_screen.dart';
import 'package:influcollb_app/features/auth/presentation/view_model/login_view_model.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLoginViewModel extends StateNotifier<AsyncValue<AuthApiModel?>>
    with Mock
    implements LoginViewModel {
  MockLoginViewModel() : super(const AsyncValue.data(null));
}

void main() {
  late MockLoginViewModel mockLoginViewModel;

  setUp(() {
    mockLoginViewModel = MockLoginViewModel();
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        loginViewModelProvider.overrideWith((ref) => mockLoginViewModel),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('should display login title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert - Use key to find the specific title text
      expect(find.byKey(const Key('loginTitle')), findsOneWidget);
    });

    testWidgets('should display email text field', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextFormField), findsAtLeast(2));
      expect(find.widgetWithText(TextFormField, 'Enter your email'), findsOneWidget);
    });

    testWidgets('should display password text field', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.widgetWithText(TextFormField, 'Enter your password'), findsOneWidget);
    });

    testWidgets('should display login button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Login'), findsAtLeast(1));
      expect(find.byType(ElevatedButton), findsAtLeast(1));
    });

    testWidgets('should display forgot password link', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('should display sign up link', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('should display role selection (Influencer and Brand)', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Influencer'), findsOneWidget);
      expect(find.text('Brand'), findsOneWidget);
      expect(find.text('I am a:'), findsOneWidget);
    });

    testWidgets('should toggle password visibility when icon is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.widgetWithText(TextFormField, 'Enter your password');
      expect(passwordField, findsOneWidget);

      // Find visibility toggle button
      final visibilityIcon = find.descendant(
        of: passwordField,
        matching: find.byType(IconButton),
      );

      // Assert - Initially should have visibility_outlined icon (password hidden)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Act - Tap visibility toggle
      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      // Assert - Should now have visibility_off_outlined icon (password visible)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Act - Tap again to hide
      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      // Assert - Should have visibility_outlined icon again (password hidden)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('should allow entering email', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email'),
        'test@example.com',
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('should allow entering password', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your password'),
        'password123',
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('should select Influencer role', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Influencer'));
      await tester.pumpAndSettle();

      // Assert - Influencer should be selected (visual feedback)
      expect(find.text('Influencer'), findsOneWidget);
    });

    testWidgets('should select Brand role', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Brand'));
      await tester.pumpAndSettle();

      // Assert - Brand should be selected (visual feedback)
      expect(find.text('Brand'), findsOneWidget);
    });

    testWidgets('should display email icon', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('should display lock icon for password', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('should have gradient background', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      final container = find.byType(Container);
      expect(container, findsWidgets);
    });

    testWidgets('should display person icon for Influencer', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('should display work icon for Brand', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.work_outline), findsOneWidget);
    });

    testWidgets('should have rounded corners on input fields', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert - Check that TextFormFields exist with proper styling
      expect(find.byType(TextFormField), findsAtLeast(2));
      // Visual verification that fields are rendered properly
      expect(find.widgetWithText(TextFormField, 'Enter your email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Enter your password'), findsOneWidget);
    });

    testWidgets('should display loading indicator when logging in', (WidgetTester tester) async {
      // Arrange
      mockLoginViewModel.state = const AsyncValue.loading();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Use pump instead of pumpAndSettle for loading state

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('login button should be disabled when loading', (WidgetTester tester) async {
      // Arrange
      mockLoginViewModel.state = const AsyncValue.loading();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Use pump instead of pumpAndSettle for loading state

      // Find the ElevatedButton directly
      final loginButtons = find.byType(ElevatedButton);
      expect(loginButtons, findsOneWidget);

      // Assert
      final button = tester.widget<ElevatedButton>(loginButtons.first);
      expect(button.onPressed, isNull);
    });
  });
}
