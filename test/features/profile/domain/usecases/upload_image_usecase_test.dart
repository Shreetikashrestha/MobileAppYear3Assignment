import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:influcollb_app/features/profile/domain/usecases/upload_image_usecase.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

class FakeFile extends Fake implements File {}

void main() {
  late UploadImageUseCase usecase;
  late MockProfileRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = UploadImageUseCase(repository: mockRepository);
  });

  final tFile = File('test_path');
  const tImageUrl = 'https://example.com/image.jpg';

  group('UploadImageUseCase', () {
    test('should return image URL when upload is successful', () async {
      // Arrange
      when(() => mockRepository.uploadProfilePicture(any()))
          .thenAnswer((_) async => const Right(tImageUrl));

      // Act
      final result = await usecase(tFile);

      // Assert
      expect(result, const Right(tImageUrl));
      verify(() => mockRepository.uploadProfilePicture(tFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when upload fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Upload failed');
      when(() => mockRepository.uploadProfilePicture(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tFile);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.uploadProfilePicture(tFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}