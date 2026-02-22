import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import '../entities/profile_entity.dart';

abstract class IProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile(String userId);
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity profile);
  Future<Either<Failure, String>> uploadProfilePicture(File file);
}
