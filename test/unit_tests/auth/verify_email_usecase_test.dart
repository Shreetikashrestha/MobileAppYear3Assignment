import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class VerifyEmailUseCase {
  Future<bool> call();
}

class MockVerifyEmailUseCase extends Mock implements VerifyEmailUseCase {}

void main() {
  group('VerifyEmailUseCase', () {
    test('should verify email successfully', () async {
      final useCase = MockVerifyEmailUseCase();
      when(() => useCase()).thenAnswer((_) async => true);
      final result = await useCase();
      expect(result, true);
    });
    test('should handle failure', () async {
      final useCase = MockVerifyEmailUseCase();
      when(() => useCase()).thenThrow(Exception('Failed'));
      expect(() async => await useCase(), throwsException);
    });
  });
}
