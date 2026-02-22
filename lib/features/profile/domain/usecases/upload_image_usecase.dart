import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UploadImageUseCase implements UseCase<String, File> {
  final IProfileRepository _repository;

  UploadImageUseCase({required IProfileRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, String>> call(File params) {
    return _repository.uploadProfilePicture(params);
  }
}
