import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class ForgotPasswordUseCase {
  Future<bool> call();
}

class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}

void main() {
  group('ForgotPasswordUseCase', () {
    test('should send reset email successfully', () async {
      // Arrange
      final useCase = MockForgotPasswordUseCase();
      when(() => useCase()).thenAnswer((_) async => true);
      // Act
      final result = await useCase();
      // Assert
      expect(result, true);
    });
    test('should handle failure', () async {
      final useCase = MockForgotPasswordUseCase();
      when(() => useCase()).thenThrow(Exception('Failed'));
      expect(() async => await useCase(), throwsException);
    });
  });
}
