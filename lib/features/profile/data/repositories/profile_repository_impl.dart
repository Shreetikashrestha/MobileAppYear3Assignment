import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_api_model.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({required IProfileRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(String userId) async {
    try {
      final model = await _remoteDataSource.getProfile(userId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(message: e.response?.data['message'] ?? 'Failed to get profile'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity profile) async {
    try {
      final model = ProfileApiModel.fromEntity(profile);
      final resultModel = await _remoteDataSource.updateProfile(model);
      return Right(resultModel.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(message: e.response?.data['message'] ?? 'Failed to update profile'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(File file) async {
    try {
      final imageUrl = await _remoteDataSource.uploadProfilePicture(file);
      return Right(imageUrl);
    } on DioException catch (e) {
      return Left(ApiFailure(message: e.response?.data['message'] ?? 'Failed to upload picture'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
