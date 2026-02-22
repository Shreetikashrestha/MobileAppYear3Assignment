import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request photo library permission
  Future<bool> requestPhotoLibraryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Check if photo library permission is granted
  Future<bool> isPhotoLibraryPermissionGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  /// Take photo from camera
  Future<File?> takePhoto() async {
    try {
      // Check and request permission
      final hasPermission = await isCameraPermissionGranted();
      if (!hasPermission) {
        final granted = await requestCameraPermission();
        if (!granted) {
          throw Exception('Camera permission denied');
        }
      }

      // Take photo
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      rethrow;
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      // Check and request permission
      final hasPermission = await isPhotoLibraryPermissionGranted();
      if (!hasPermission) {
        final granted = await requestPhotoLibraryPermission();
        if (!granted) {
          throw Exception('Photo library permission denied');
        }
      }

      // Pick image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      rethrow;
    }
  }

  /// Record video from camera
  Future<File?> recordVideo() async {
    try {
      // Check and request permission
      final hasPermission = await isCameraPermissionGranted();
      if (!hasPermission) {
        final granted = await requestCameraPermission();
        if (!granted) {
          throw Exception('Camera permission denied');
        }
      }

      // Record video
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      print('Error recording video: $e');
      rethrow;
    }
  }

  /// Pick video from gallery
  Future<File?> pickVideoFromGallery() async {
    try {
      // Check and request permission
      final hasPermission = await isPhotoLibraryPermissionGranted();
      if (!hasPermission) {
        final granted = await requestPhotoLibraryPermission();
        if (!granted) {
          throw Exception('Photo library permission denied');
        }
      }

      // Pick video
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      print('Error picking video: $e');
      rethrow;
    }
  }

  /// Show image source selection dialog
  Future<File?> pickImage({required ImageSource source}) async {
    if (source == ImageSource.camera) {
      return await takePhoto();
    } else {
      return await pickImageFromGallery();
    }
  }
}
