# 🎨 Widget Tests

## Overview

Widget tests verify UI components and user interactions. These tests ensure:
- UI elements are displayed correctly
- User interactions work as expected
- Loading states are shown
- Error messages appear
- Navigation works

---

## 📁 Structure

```
widget_tests/
├── auth/
│   ├── login_screen_test.dart
│   └── signup_screen_test.dart
│
├── campaign/
├── application/
├── profile/
└── home/
```

---

## 🎨 Auth Widget Tests (40 Tests)

### LoginScreen (20 tests)

#### UI Elements (10 tests)
- ✅ Should display login title
- ✅ Should display email text field
- ✅ Should display password text field
- ✅ Should display login button
- ✅ Should display forgot password link
- ✅ Should display sign up link
- ✅ Should display role selection (Influencer and Brand)
- ✅ Should display email icon
- ✅ Should display lock icon for password
- ✅ Should have gradient background

#### Interactions (10 tests)
- ✅ Should toggle password visibility when icon is tapped
- ✅ Should allow entering email
- ✅ Should allow entering password
- ✅ Should select Influencer role
- ✅ Should select Brand role
- ✅ Should display person icon for Influencer
- ✅ Should display work icon for Brand
- ✅ Should have rounded corners on input fields
- ✅ Should display loading indicator when logging in
- ✅ Login button should be disabled when loading

### SignupScreen (20 tests)

#### UI Elements (10 tests)
- ✅ Should display signup title
- ✅ Should display full name text field
- ✅ Should display email text field
- ✅ Should display password text field
- ✅ Should display signup button
- ✅ Should display login link
- ✅ Should display role selection
- ✅ Should display person icon
- ✅ Should display email icon
- ✅ Should display lock icon

#### Interactions (10 tests)
- ✅ Should toggle password visibility
- ✅ Should allow entering full name
- ✅ Should allow entering email
- ✅ Should allow entering password
- ✅ Should select Influencer role
- ✅ Should select Brand role
- ✅ Should display work icon for Brand
- ✅ Should have rounded corners
- ✅ Should display loading indicator
- ✅ Signup button should be disabled when loading

---

## 🚀 Running Tests

### Run All Widget Tests
```bash
flutter test tests_organized/widget_tests/
```

### Run Auth Widget Tests
```bash
flutter test tests_organized/widget_tests/auth/
```

### Run Specific Test
```bash
flutter test tests_organized/widget_tests/auth/login_screen_test.dart
```

---

## 📝 Test Pattern

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockViewModel extends StateNotifier<AsyncValue<Data?>>
    with Mock
    implements YourViewModel {
  MockViewModel() : super(const AsyncValue.data(null));
}

void main() {
  late MockViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockViewModel();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        viewModelProvider.overrideWith((ref) => mockViewModel),
      ],
      child: const MaterialApp(
        home: YourScreen(),
      ),
    );
  }

  group('YourScreen Widget Tests', () {
    testWidgets('should display title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('should handle button tap', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockViewModel.action()).called(1);
    });

    testWidgets('should display loading indicator', (WidgetTester tester) async {
      // Arrange
      mockViewModel.state = const AsyncValue.loading();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

---

## 🎯 What to Test

### UI Elements
- ✅ Text widgets
- ✅ Buttons
- ✅ Input fields
- ✅ Icons
- ✅ Images
- ✅ Lists
- ✅ Cards

### User Interactions
- ✅ Button taps
- ✅ Text input
- ✅ Scrolling
- ✅ Gestures
- ✅ Navigation
- ✅ Form submission

### States
- ✅ Initial state
- ✅ Loading state
- ✅ Success state
- ✅ Error state
- ✅ Empty state

### Accessibility
- ✅ Semantic labels
- ✅ Screen reader support
- ✅ Touch targets
- ✅ Color contrast

---

## 🔍 Common Widget Finders

```dart
// Find by text
find.text('Login')

// Find by key
find.byKey(Key('login_button'))

// Find by type
find.byType(ElevatedButton)

// Find by icon
find.byIcon(Icons.email)

// Find by widget
find.byWidget(MyCustomWidget())

// Find descendant
find.descendant(
  of: find.byType(Container),
  matching: find.text('Text'),
)

// Find ancestor
find.ancestor(
  of: find.text('Text'),
  matching: find.byType(Container),
)
```

---

## 🎨 Widget Test Actions

```dart
// Tap
await tester.tap(find.byType(Button));

// Enter text
await tester.enterText(find.byType(TextField), 'text');

// Scroll
await tester.drag(find.byType(ListView), Offset(0, -200));

// Long press
await tester.longPress(find.byType(Button));

// Pump (rebuild widget)
await tester.pump();

// Pump and settle (wait for animations)
await tester.pumpAndSettle();

// Pump with duration
await tester.pump(Duration(seconds: 1));
```

---

## 🔧 Testing with Riverpod

### Basic Setup
```dart
Widget createWidgetUnderTest() {
  return ProviderScope(
    overrides: [
      viewModelProvider.overrideWith((ref) => mockViewModel),
    ],
    child: MaterialApp(
      home: YourScreen(),
    ),
  );
}
```

### Testing State Changes
```dart
testWidgets('should update UI when state changes', (tester) async {
  // Initial state
  mockViewModel.state = const AsyncValue.data(null);
  await tester.pumpWidget(createWidgetUnderTest());
  
  // Change state
  mockViewModel.state = AsyncValue.data(newData);
  await tester.pump();
  
  // Verify UI updated
  expect(find.text('New Data'), findsOneWidget);
});
```

---

## 🛠️ Useful Matchers

```dart
// Widget matchers
expect(find.text('Text'), findsOneWidget);
expect(find.text('Text'), findsNothing);
expect(find.text('Text'), findsNWidgets(2));
expect(find.text('Text'), findsAtLeast(1));

// Type matchers
expect(widget, isA<Button>());
expect(value, isNull);
expect(value, isNotNull);

// Value matchers
expect(value, equals(expected));
expect(value, isTrue);
expect(value, isFalse);
expect(list, contains(item));
expect(list, isEmpty);
```

---

## 🔧 Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  mocktail: ^1.0.4
```

---

## ✅ Best Practices

1. **Test User-Visible Behavior**
   - Focus on what users see and do
   - Don't test implementation details

2. **Use pumpAndSettle**
   - Wait for animations to complete
   - Ensures stable UI state

3. **Mock View Models**
   - Override providers with mocks
   - Control state for testing

4. **Test Accessibility**
   - Verify semantic labels
   - Check touch target sizes

5. **Keep Tests Fast**
   - Avoid unnecessary delays
   - Use pump() instead of pumpAndSettle() when possible

6. **Descriptive Test Names**
   - Format: `should_[expected]_when_[scenario]`
   - Example: `should_displayError_when_loginFails`

---

## 📚 Resources

- [Flutter Widget Testing](https://docs.flutter.dev/testing/widget-tests)
- [Riverpod Testing](https://riverpod.dev/docs/cookbooks/testing)
- [Flutter Test Package](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)

---

**Tests Created:** 40  
**Status:** Ready for Testing  
**Last Updated:** March 5, 2026
