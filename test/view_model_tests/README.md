# 🎯 View Model Tests (Riverpod)

## Overview

View Model tests focus on testing state management logic using **Flutter Riverpod**. These tests verify:
- State transitions
- User interactions
- Error handling
- Loading states
- Data updates

---

## 📁 Structure

```
view_model_tests/
├── auth/
│   ├── login_view_model_test.dart
│   └── register_view_model_test.dart
│
├── campaign/
├── application/
├── profile/
└── analytics/
```

---

## 🎨 Auth View Model Tests (16 Tests)

### LoginViewModel (8 tests)
- Initial state should have no data
- Should update state when login is successful
- Should update state with error when login fails
- Should call LoginUseCase with correct parameters
- Should handle empty email
- Should handle empty password
- Should handle network failure
- Should update state correctly on multiple login attempts

### RegisterViewModel (8 tests)
- Initial state should have no data
- Should update state when registration is successful
- Should update state with error when registration fails
- Should call RegisterUseCase with correct parameters
- Should handle validation failure
- Should handle network failure
- Should handle user with null password
- Should update state correctly on multiple registration attempts

---

## 🚀 Running Tests

### Run All View Model Tests
```bash
flutter test tests_organized/view_model_tests/
```

### Run Auth View Model Tests
```bash
flutter test tests_organized/view_model_tests/auth/
```

### Run Specific Test
```bash
flutter test tests_organized/view_model_tests/auth/login_view_model_test.dart
```

---

## 📝 Test Pattern with Riverpod

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockUseCase extends Mock implements YourUseCase {}

void main() {
  late ProviderContainer container;
  late MockUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockUseCase();
    container = ProviderContainer(
      overrides: [
        useCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  setUpAll(() {
    registerFallbackValue(YourParams());
  });

  group('YourViewModel', () {
    test('should update state on success', () async {
      // Arrange
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(data));

      // Act
      final viewModel = container.read(viewModelProvider.notifier);
      await viewModel.action();

      // Assert
      final state = container.read(viewModelProvider);
      expect(state.hasValue, true);
      expect(state.value, data);
      verify(() => mockUseCase(any())).called(1);
    });

    test('should update state on error', () async {
      // Arrange
      final failure = ServerFailure('Error');
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Left(failure));

      // Act
      final viewModel = container.read(viewModelProvider.notifier);
      await viewModel.action();

      // Assert
      final state = container.read(viewModelProvider);
      expect(state.hasError, true);
      expect(state.error.toString(), contains('Error'));
    });
  });
}
```

---

## 🎯 What to Test

### State Management
- ✅ Initial state
- ✅ Loading state
- ✅ Success state
- ✅ Error state
- ✅ State transitions

### User Actions
- ✅ Button clicks
- ✅ Form submissions
- ✅ Data refresh
- ✅ Navigation triggers

### Error Handling
- ✅ Network errors
- ✅ Validation errors
- ✅ Server errors
- ✅ Timeout errors

### Edge Cases
- ✅ Empty inputs
- ✅ Null values
- ✅ Multiple rapid calls
- ✅ Concurrent operations

---

## 🔄 Testing AsyncValue States

### AsyncValue States
```dart
// AsyncData - Success with data
final state = AsyncValue.data(user);
expect(state.hasValue, true);
expect(state.value, user);

// AsyncLoading - Loading state
final state = AsyncValue.loading();
expect(state.isLoading, true);

// AsyncError - Error state
final state = AsyncValue.error('Error', StackTrace.current);
expect(state.hasError, true);
expect(state.error, 'Error');
```

### Testing State Transitions
```dart
test('should transition through states', () async {
  final states = <AsyncValue>[];
  
  // Listen to state changes
  container.listen(
    viewModelProvider,
    (previous, next) => states.add(next),
  );

  // Trigger action
  when(() => mockUseCase(any()))
      .thenAnswer((_) async => Right(data));
  
  final viewModel = container.read(viewModelProvider.notifier);
  await viewModel.loadData();

  // Verify transitions
  expect(states.length, greaterThan(0));
  expect(states.last.hasValue, true);
});
```

---

## 🛠️ Riverpod Testing Tools

### ProviderContainer
```dart
// Create container with overrides
final container = ProviderContainer(
  overrides: [
    useCaseProvider.overrideWithValue(mockUseCase),
    repositoryProvider.overrideWithValue(mockRepository),
  ],
);

// Read provider
final state = container.read(viewModelProvider);

// Read notifier
final viewModel = container.read(viewModelProvider.notifier);

// Dispose container
container.dispose();
```

### Provider Overrides
```dart
// Override with value
useCaseProvider.overrideWithValue(mockUseCase)

// Override with provider
dataProvider.overrideWith((ref) => customData)

// Override with notifier
viewModelProvider.overrideWith(() => CustomViewModel())
```

---

## 🔧 Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  mocktail: ^1.0.4
  dartz: ^0.10.1
```

---

## ✅ Best Practices

1. **Always Dispose Container**
   ```dart
   tearDown(() {
     container.dispose();
   });
   ```

2. **Register Fallback Values**
   ```dart
   setUpAll(() {
     registerFallbackValue(YourParams());
   });
   ```

3. **Test State, Not Implementation**
   - Focus on observable behavior
   - Don't test internal methods
   - Verify state changes

4. **Use Descriptive Test Names**
   - Format: `[action]_[scenario]_[expected_state]`
   - Example: `login_withValidCredentials_emitsDataState`

5. **Mock Use Cases, Not Repositories**
   - View models depend on use cases
   - Keep tests focused on view model logic

---

## 📚 Resources

- [Riverpod Testing Guide](https://riverpod.dev/docs/cookbooks/testing)
- [RIVERPOD_TESTING.md](../RIVERPOD_TESTING.md)
- [Flutter Testing](https://docs.flutter.dev/testing)

---

**State Management:** Flutter Riverpod 2.6.1  
**Tests Created:** 16  
**Status:** Ready for Testing  
**Last Updated:** March 5, 2026
