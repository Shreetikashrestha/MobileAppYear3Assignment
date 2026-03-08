import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class RefreshTokenUseCase {
  Future<String> call();
}

class MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}

void main() {
  group('RefreshTokenUseCase', () {
    test('should refresh token successfully', () async {
      final useCase = MockRefreshTokenUseCase();
      when(() => useCase()).thenAnswer((_) async => 'new_token');
      final result = await useCase();
      expect(result, 'new_token');
    });
    test('should handle failure', () async {
      final useCase = MockRefreshTokenUseCase();
      when(() => useCase()).thenThrow(Exception('Failed'));
      expect(() async => await useCase(), throwsException);
    });
  });
}
