import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class UpdateProfileUseCase {
  Future<bool> call();
}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

void main() {
  group('UpdateProfileUseCase', () {
    test('should update profile successfully', () async {
      final useCase = MockUpdateProfileUseCase();
      when(() => useCase()).thenAnswer((_) async => true);
      final result = await useCase();
      expect(result, true);
    });
    test('should handle failure', () async {
      final useCase = MockUpdateProfileUseCase();
      when(() => useCase()).thenThrow(Exception('Failed'));
      expect(() async => await useCase(), throwsException);
    });
  });
}
