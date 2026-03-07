import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallPermissionService {
  /// Request camera and microphone permissions for video calls
  static Future<bool> requestVideoCallPermissions(BuildContext context) async {
    // Request both camera and microphone permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    bool cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    bool microphoneGranted = statuses[Permission.microphone]?.isGranted ?? false;

    if (cameraGranted && microphoneGranted) {
      return true;
    }

    // Check if any permission was permanently denied
    bool cameraDenied = statuses[Permission.camera]?.isPermanentlyDenied ?? false;
    bool microphoneDenied = statuses[Permission.microphone]?.isPermanentlyDenied ?? false;

    if (cameraDenied || microphoneDenied) {
      if (context.mounted) {
        _showPermissionDeniedDialog(
          context,
          cameraDenied: cameraDenied,
          microphoneDenied: microphoneDenied,
        );
      }
    } else {
      if (context.mounted) {
        _showPermissionRequiredDialog(
          context,
          cameraGranted: cameraGranted,
          microphoneGranted: microphoneGranted,
        );
      }
    }

    return false;
  }

  /// Request only camera permission
  static Future<bool> requestCameraPermission(BuildContext context) async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showCameraPermissionDeniedDialog(context);
      }
    }

    return false;
  }

  /// Request only microphone permission
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    PermissionStatus status = await Permission.microphone.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showMicrophonePermissionDeniedDialog(context);
      }
    }

    return false;
  }

  /// Check if video call permissions are granted
  static Future<bool> hasVideoCallPermissions() async {
    bool cameraGranted = await Permission.camera.isGranted;
    bool microphoneGranted = await Permission.microphone.isGranted;
    return cameraGranted && microphoneGranted;
  }

  /// Check camera permission status
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  /// Check microphone permission status
  static Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  /// Show dialog when permissions are permanently denied
  static void _showPermissionDeniedDialog(
    BuildContext context, {
    required bool cameraDenied,
    required bool microphoneDenied,
  }) {
    String message = 'To make video calls, you need to enable ';
    if (cameraDenied && microphoneDenied) {
      message += 'camera and microphone permissions';
    } else if (cameraDenied) {
      message += 'camera permission';
    } else {
      message += 'microphone permission';
    }
    message += ' in your device settings.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show dialog when camera permission is permanently denied
  static void _showCameraPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'To use the camera, you need to enable camera permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show dialog when microphone permission is permanently denied
  static void _showMicrophonePermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'To use the microphone, you need to enable microphone permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show dialog when permissions are required but not permanently denied
  static void _showPermissionRequiredDialog(
    BuildContext context, {
    required bool cameraGranted,
    required bool microphoneGranted,
  }) {
    String message = 'Video calls require ';
    if (!cameraGranted && !microphoneGranted) {
      message += 'camera and microphone permissions';
    } else if (!cameraGranted) {
      message += 'camera permission';
    } else {
      message += 'microphone permission';
    }
    message += '. Please grant the permissions to continue.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show a bottom sheet with permission explanation before requesting
  static Future<bool?> showPermissionExplanation(BuildContext context) async {
    return await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Video Call Permissions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'To make video calls, we need access to:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildPermissionItem(
              Icons.videocam,
              'Camera',
              'To show your video during calls',
            ),
            const SizedBox(height: 12),
            _buildPermissionItem(
              Icons.mic,
              'Microphone',
              'To transmit your audio during calls',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPermissionItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
