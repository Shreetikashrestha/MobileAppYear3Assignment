# 🧪 Organized Test Suite

## 📁 Test Structure

This folder contains all organized tests for the InfluCollab mobile application.

```
tests_organized/
├── unit_tests/              # Unit tests (Use Cases, Repositories, Models)
│   ├── auth/
│   ├── campaign/
│   ├── application/
│   ├── profile/
│   └── analytics/
│
├── view_model_tests/        # View Model tests (Riverpod State Management)
│   ├── auth/
│   ├── campaign/
│   ├── application/
│   ├── profile/
│   └── analytics/
│
├── widget_tests/            # Widget/UI tests
│   ├── auth/
│   ├── campaign/
│   ├── application/
│   ├── profile/
│   └── home/
│
├── integration_tests/       # Integration tests (optional)
│
└── mocks/                   # Shared mock classes
    ├── mock_repositories.dart
    ├── mock_usecases.dart
    └── mock_services.dart
```

---

## 🎯 State Management: Riverpod

This project uses **Flutter Riverpod** for state management.

### Riverpod Features Used:
- ✅ StateNotifierProvider
- ✅ FutureProvider
- ✅ StreamProvider
- ✅ Provider
- ✅ AsyncValue for loading/error states

---

## 📊 Test Coverage

### Unit Tests (Use Cases)
- ✅ LoginUseCase (3 tests)
- ✅ RegisterUseCase (3 tests)
- ✅ LogoutUseCase (4 tests)
- ✅ GetCurrentUserUseCase (4 tests)

### View Model Tests (Riverpod)
- LoginViewModel (8 tests)
- RegisterViewModel (8 tests)

### Widget Tests
- LoginScreen (20 tests)
- SignupScreen (20 tests)

**Total: 70 tests**

---

## 🚀 Running Tests

### Run All Tests
```bash
cd MobileAppYear3Assignment
flutter test tests_organized/
```

### Run Specific Category
```bash
# Unit tests only
flutter test tests_organized/unit_tests/

# View model tests only
flutter test tests_organized/view_model_tests/

# Widget tests only
flutter test tests_organized/widget_tests/
```

### Run Specific Feature
```bash
# Auth tests
flutter test tests_organized/unit_tests/auth/
flutter test tests_organized/view_model_tests/auth/
flutter test tests_organized/widget_tests/auth/
```

### Run with Coverage
```bash
flutter test --coverage tests_organized/
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📝 Test Naming Convention

### Unit Tests
```dart
// Format: [method]_[scenario]_[expected_result]
test('login_withValidCredentials_returnsAuthModel', () { ... });
test('login_withInvalidCredentials_returnsFailure', () { ... });
```

### View Model Tests
```dart
// Format: [action]_[scenario]_[expected_state]
test('login_successful_emitsDataState', () { ... });
test('login_failed_emitsErrorState', () { ... });
```

### Widget Tests
```dart
// Format: should_[expected_behavior]_when_[scenario]
testWidgets('should_displayLoginButton_when_screenLoads', () { ... });
testWidgets('should_showError_when_loginFails', () { ... });
```

---

## 🔧 Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
  flutter_riverpod: ^2.6.1
```

---

## ✅ Best Practices

1. **Arrange-Act-Assert Pattern**
   - Arrange: Set up test data and mocks
   - Act: Execute the code under test
   - Assert: Verify the results

2. **Mock External Dependencies**
   - Use Mocktail for mocking
   - Mock repositories, not use cases
   - Mock services, not view models

3. **Test Isolation**
   - Each test should be independent
   - Use setUp() and tearDown()
   - Don't share state between tests

4. **Riverpod Testing**
   - Use ProviderContainer for testing
   - Override providers with mocks
   - Test state transitions

---

## 📚 Documentation

- [Unit Tests Guide](./unit_tests/README.md)
- [View Model Tests Guide](./view_model_tests/README.md)
- [Widget Tests Guide](./widget_tests/README.md)
- [Riverpod Testing Guide](./RIVERPOD_TESTING.md)

---

**Last Updated:** March 5, 2026  
**State Management:** Flutter Riverpod 2.6.1  
**Test Framework:** Flutter Test + Mocktail
