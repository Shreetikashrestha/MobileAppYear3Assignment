import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:influcollb_app/core/api/api_client.dart';
import 'package:influcollb_app/core/api/api_endpoints.dart';
import 'package:path/path.dart' as path;

class ImageUploadService {
  final ApiClient _apiClient;

  ImageUploadService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Upload profile picture
  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final fileName = path.basename(imageFile.path);
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        '${ApiEndpoints.updateProfile}/picture',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final imageUrl = response.data['data']['profilePicture'] as String;
        return imageUrl;
      }

      throw Exception('Failed to upload profile picture');
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      rethrow;
    }
  }

  /// Upload campaign image
  Future<String> uploadCampaignImage(File imageFile) async {
    try {
      final fileName = path.basename(imageFile.path);
      final formData = FormData.fromMap({
        'campaignImage': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        '${ApiEndpoints.campaigns}/upload-image',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final imageUrl = response.data['data']['imageUrl'] as String;
        return imageUrl;
      }

      throw Exception('Failed to upload campaign image');
    } catch (e) {
      debugPrint('Error uploading campaign image: $e');
      rethrow;
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    try {
      final uploadedUrls = <String>[];

      for (final imageFile in imageFiles) {
        final fileName = path.basename(imageFile.path);
        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
          ),
        });

        final response = await _apiClient.post(
          '${ApiEndpoints.baseUrl}/upload',
          data: formData,
          options: Options(
            headers: {
              'Content-Type': 'multipart/form-data',
            },
          ),
        );

        if (response.statusCode == 200 && response.data['success'] == true) {
          final imageUrl = response.data['data']['imageUrl'] as String;
          uploadedUrls.add(imageUrl);
        }
      }

      return uploadedUrls;
    } catch (e) {
      debugPrint('Error uploading multiple images: $e');
      rethrow;
    }
  }

  /// Upload video
  Future<String> uploadVideo(File videoFile) async {
    try {
      final fileName = path.basename(videoFile.path);
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(
          videoFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        '${ApiEndpoints.baseUrl}/upload-video',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final videoUrl = response.data['data']['videoUrl'] as String;
        return videoUrl;
      }

      throw Exception('Failed to upload video');
    } catch (e) {
      debugPrint('Error uploading video: $e');
      rethrow;
    }
  }

  /// Get file size in MB
  double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  /// Validate image file
  bool validateImageFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];

    if (!validExtensions.contains(extension)) {
      return false;
    }

    final sizeInMB = getFileSizeInMB(file);
    if (sizeInMB > 10) {
      // Max 10MB
      return false;
    }

    return true;
  }

  /// Validate video file
  bool validateVideoFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    final validExtensions = ['.mp4', '.mov', '.avi', '.mkv'];

    if (!validExtensions.contains(extension)) {
      return false;
    }

    final sizeInMB = getFileSizeInMB(file);
    if (sizeInMB > 100) {
      // Max 100MB
      return false;
    }

    return true;
  }
}
