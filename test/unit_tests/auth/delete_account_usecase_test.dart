import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class DeleteAccountUseCase {
  Future<bool> call();
}

class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

void main() {
  group('DeleteAccountUseCase', () {
    test('should delete account successfully', () async {
      final useCase = MockDeleteAccountUseCase();
      when(() => useCase()).thenAnswer((_) async => true);
      final result = await useCase();
      expect(result, true);
    });
    test('should handle failure', () async {
      final useCase = MockDeleteAccountUseCase();
      when(() => useCase()).thenThrow(Exception('Failed'));
      expect(() async => await useCase(), throwsException);
    });
  });
}
