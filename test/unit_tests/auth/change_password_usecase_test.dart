import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class ChangePasswordUseCase {
  Future<bool> call();
}

class MockChangePasswordUseCase extends Mock implements ChangePasswordUseCase {}

void main() {
  group('ChangePasswordUseCase', () {
    test('should change password successfully', () async {
      final useCase = MockChangePasswordUseCase();
      when(() => useCase()).thenAnswer((_) async => true);
      final result = await useCase();
      expect(result, true);
    });
    test('should handle failure', () async {
      final useCase = MockChangePasswordUseCase();
      when(() => useCase()).thenThrow(Exception('Failed'));
      expect(() async => await useCase(), throwsException);
    });
  });
}
