import 'package:flutter/material.dart';
import 'package:influcollb_app/core/services/permission/video_call_permission_service.dart';

/// Example widget demonstrating how to use VideoCallPermissionService
/// This can be used as a reference for implementing permissions in other screens
class PermissionExampleWidget extends StatelessWidget {
  const PermissionExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Examples'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Video Call Permissions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Example 1: Request both camera and microphone
            ElevatedButton.icon(
              onPressed: () async {
                final granted = await VideoCallPermissionService.requestVideoCallPermissions(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(granted 
                        ? 'Permissions granted!' 
                        : 'Permissions denied'),
                      backgroundColor: granted ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.videocam),
              label: const Text('Request Video Call Permissions'),
            ),
            
            const SizedBox(height: 16),
            
            // Example 2: Request only camera
            ElevatedButton.icon(
              onPressed: () async {
                final granted = await VideoCallPermissionService.requestCameraPermission(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(granted 
                        ? 'Camera permission granted!' 
                        : 'Camera permission denied'),
                      backgroundColor: granted ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Request Camera Permission'),
            ),
            
            const SizedBox(height: 16),
            
            // Example 3: Request only microphone
            ElevatedButton.icon(
              onPressed: () async {
                final granted = await VideoCallPermissionService.requestMicrophonePermission(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(granted 
                        ? 'Microphone permission granted!' 
                        : 'Microphone permission denied'),
                      backgroundColor: granted ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.mic),
              label: const Text('Request Microphone Permission'),
            ),
            
            const SizedBox(height: 16),
            
            // Example 4: Check permissions status
            ElevatedButton.icon(
              onPressed: () async {
                final hasVideoCall = await VideoCallPermissionService.hasVideoCallPermissions();
                final hasCamera = await VideoCallPermissionService.hasCameraPermission();
                final hasMicrophone = await VideoCallPermissionService.hasMicrophonePermission();
                
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Permission Status'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusRow('Video Call', hasVideoCall),
                          _buildStatusRow('Camera', hasCamera),
                          _buildStatusRow('Microphone', hasMicrophone),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('Check Permission Status'),
            ),
            
            const SizedBox(height: 16),
            
            // Example 5: Show explanation before requesting
            ElevatedButton.icon(
              onPressed: () async {
                final shouldContinue = await VideoCallPermissionService.showPermissionExplanation(context);
                
                if (shouldContinue == true && context.mounted) {
                  final granted = await VideoCallPermissionService.requestVideoCallPermissions(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(granted 
                          ? 'Ready for video calls!' 
                          : 'Permissions needed for video calls'),
                        backgroundColor: granted ? Colors.green : Colors.orange,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.help_outline),
              label: const Text('Show Explanation & Request'),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Usage Tips:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Always show explanation before requesting permissions\n'
              '• Check permission status before starting video calls\n'
              '• Handle permission denial gracefully\n'
              '• Guide users to settings if permissions are permanently denied',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  static Widget _buildStatusRow(String label, bool granted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text('$label: ${granted ? "Granted" : "Denied"}'),
        ],
      ),
    );
  }
}
