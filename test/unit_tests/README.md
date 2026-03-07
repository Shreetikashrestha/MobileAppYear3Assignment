# 🧪 Unit Tests

## Overview

Unit tests focus on testing individual units of code in isolation. In this project, we test:
- Use Cases (Business Logic)
- Repositories
- Models
- Utilities

---

## 📁 Structure

```
unit_tests/
├── auth/
│   ├── login_usecase_test.dart
│   ├── register_usecase_test.dart
│   ├── logout_usecase_test.dart
│   └── get_current_user_usecase_test.dart
│
├── campaign/
├── application/
├── profile/
└── analytics/
```

---

## ✅ Auth Unit Tests (14 Tests - ALL PASSING)

### LoginUseCase (3 tests)
- ✅ Should return AuthApiModel when login is successful
- ✅ Should return Failure when login fails
- ✅ Should pass correct email and password to repository

### RegisterUseCase (3 tests)
- ✅ Should return AuthApiModel when registration is successful
- ✅ Should return Failure when registration fails
- ✅ Should pass all parameters correctly to repository

### LogoutUseCase (4 tests)
- ✅ Should return true when logout is successful
- ✅ Should return Failure when logout fails
- ✅ Should call repository logout method
- ✅ Should return false when logout is unsuccessful

### GetCurrentUserUseCase (4 tests)
- ✅ Should return AuthEntity when getting current user is successful
- ✅ Should return Failure when getting current user fails
- ✅ Should convert AuthApiModel to AuthEntity
- ✅ Should call repository getCurrentUser method

---

## 🚀 Running Tests

### Run All Unit Tests
```bash
flutter test tests_organized/unit_tests/
```

### Run Auth Tests Only
```bash
flutter test tests_organized/unit_tests/auth/
```

### Run Specific Test File
```bash
flutter test tests_organized/unit_tests/auth/login_usecase_test.dart
```

---

## 📝 Test Pattern

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

class MockRepository extends Mock implements IRepository {}

void main() {
  late UseCase useCase;
  late MockRepository mockRepository;

  setUp(() {
    mockRepository = MockRepository();
    useCase = UseCase(repository: mockRepository);
  });

  group('UseCase', () {
    test('should return success when operation succeeds', () async {
      // Arrange
      when(() => mockRepository.method(any()))
          .thenAnswer((_) async => Right(successData));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, Right(successData));
      verify(() => mockRepository.method(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when operation fails', () async {
      // Arrange
      final failure = ServerFailure('Error');
      when(() => mockRepository.method(any()))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.method(any())).called(1);
    });
  });
}
```

---

## 🎯 What to Test

### Use Cases
- ✅ Success scenarios
- ✅ Failure scenarios
- ✅ Parameter passing
- ✅ Repository interaction
- ✅ Error handling
- ✅ Edge cases

### Repositories
- ✅ Data source interaction
- ✅ Data transformation
- ✅ Error mapping
- ✅ Caching logic

### Models
- ✅ JSON serialization
- ✅ JSON deserialization
- ✅ Entity conversion
- ✅ Validation

---

## 🔧 Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
  dartz: ^0.10.1
```

---

## ✅ Best Practices

1. **Test One Thing**
   - Each test should verify one specific behavior
   - Keep tests focused and simple

2. **Use Descriptive Names**
   - Test name should describe what is being tested
   - Format: `[method]_[scenario]_[expected_result]`

3. **Arrange-Act-Assert**
   - Arrange: Set up test data
   - Act: Execute the code
   - Assert: Verify results

4. **Mock External Dependencies**
   - Mock repositories, not use cases
   - Use Mocktail for clean mocking

5. **Verify Interactions**
   - Use `verify()` to check method calls
   - Use `verifyNoMoreInteractions()` to ensure no unexpected calls

---

**Status:** ✅ 14/14 Tests Passing  
**Coverage:** Use Cases - 100%  
**Last Updated:** March 5, 2026
