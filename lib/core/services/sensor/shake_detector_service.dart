import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

/// Service to detect shake gestures and trigger actions
class ShakeDetectorService {
  ShakeDetector? _detector;
  VoidCallback? _onShake;
  bool _isListening = false;

  /// Start listening for shake gestures
  void startListening({
    required VoidCallback onShake,
    int shakeThresholdGravity = 2,
    int shakeSlopTimeMS = 500,
    int shakeCountResetTime = 3000,
    int minimumShakeCount = 1,
  }) {
    if (_isListening) {
      debugPrint('🔔 Shake detector already listening');
      return;
    }

    _onShake = onShake;
    
    // Temporarily disabled to fix sensor plugin crash
    // TODO: Re-enable after flutter clean && flutter run
    try {
      _detector = ShakeDetector.autoStart(
        onPhoneShake: () {
          debugPrint('📳 Shake detected! (count: $minimumShakeCount)');
          _onShake?.call();
        },
        minimumShakeCount: minimumShakeCount,
        shakeSlopTimeMS: shakeSlopTimeMS,
        shakeCountResetTime: shakeCountResetTime,
        shakeThresholdGravity: shakeThresholdGravity.toDouble(),
      );
      _isListening = true;
      debugPrint('✅ Shake detector started (requires $minimumShakeCount shakes)');
    } catch (e) {
      debugPrint('⚠️ Shake detector failed to start: $e');
      debugPrint('💡 Run: flutter clean && flutter run to fix');
    }
  }

  /// Stop listening for shake gestures
  void stopListening() {
    if (_detector != null) {
      _detector!.stopListening();
      _detector = null;
      _onShake = null;
      _isListening = false;
      debugPrint('🛑 Shake detector stopped');
    }
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Dispose the detector
  void dispose() {
    stopListening();
  }
}

/// Mixin to easily add shake detection to any StatefulWidget
mixin ShakeDetectorMixin<T extends StatefulWidget> on State<T> {
  final ShakeDetectorService _shakeService = ShakeDetectorService();

  /// Override this method to handle shake events
  void onShakeDetected();

  /// Start shake detection (call in initState)
  void startShakeDetection({
    int shakeThresholdGravity = 2,
    int shakeSlopTimeMS = 500,
    int shakeCountResetTime = 3000,
    int minimumShakeCount = 1,
  }) {
    _shakeService.startListening(
      onShake: () {
        if (mounted) {
          onShakeDetected();
        }
      },
      shakeThresholdGravity: shakeThresholdGravity,
      shakeSlopTimeMS: shakeSlopTimeMS,
      shakeCountResetTime: shakeCountResetTime,
      minimumShakeCount: minimumShakeCount,
    );
  }

  /// Stop shake detection (call in dispose)
  void stopShakeDetection() {
    _shakeService.stopListening();
  }

  @override
  void dispose() {
    stopShakeDetection();
    super.dispose();
  }
}
