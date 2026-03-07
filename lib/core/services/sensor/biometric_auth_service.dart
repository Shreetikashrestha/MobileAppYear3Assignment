import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Service to handle biometric authentication (Fingerprint, Face ID, etc.)
class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('❌ Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('❌ Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate user with biometrics
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final bool isAvailable = await isBiometricAvailable();

      if (!isAvailable) {
        debugPrint('⚠️ Biometric authentication not available');
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow PIN/Pattern as fallback
        ),
      );

      if (didAuthenticate) {
        debugPrint('✅ Biometric authentication successful');
      } else {
        debugPrint('❌ Biometric authentication failed');
      }

      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('❌ Biometric authentication error: ${e.message}');
      return false;
    }
  }

  /// Authenticate for login
  Future<bool> authenticateForLogin() async {
    return await authenticate(
      reason: 'Authenticate to login to your account',
      useErrorDialogs: true,
      stickyAuth: true,
    );
  }

  /// Authenticate for sensitive action
  Future<bool> authenticateForSensitiveAction(String action) async {
    return await authenticate(
      reason: 'Authenticate to $action',
      useErrorDialogs: true,
      stickyAuth: false,
    );
  }

  /// Get biometric type name for display
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Biometric';
    }
  }

  /// Get icon for biometric type
  IconData getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return Icons.face;
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.iris:
        return Icons.remove_red_eye;
      case BiometricType.strong:
      case BiometricType.weak:
        return Icons.security;
    }
  }

  /// Check if biometric is enrolled
  Future<bool> isBiometricEnrolled() async {
    try {
      final List<BiometricType> availableBiometrics =
          await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking biometric enrollment: $e');
      return false;
    }
  }

  /// Get user-friendly message about available biometrics
  Future<String> getBiometricStatusMessage() async {
    final bool isAvailable = await isBiometricAvailable();

    if (!isAvailable) {
      return 'Biometric authentication is not available on this device';
    }

    final List<BiometricType> biometrics = await getAvailableBiometrics();

    if (biometrics.isEmpty) {
      return 'No biometric authentication is set up. Please set up fingerprint or face recognition in your device settings.';
    }

    final List<String> biometricNames =
        biometrics.map((b) => getBiometricTypeName(b)).toList();

    if (biometricNames.length == 1) {
      return '${biometricNames[0]} is available for authentication';
    } else {
      return '${biometricNames.join(", ")} are available for authentication';
    }
  }
}

/// Widget to show biometric authentication button
class BiometricAuthButton extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback? onFailure;
  final String reason;
  final String buttonText;
  final IconData? icon;
  final Color? color;

  const BiometricAuthButton({
    super.key,
    required this.onSuccess,
    this.onFailure,
    this.reason = 'Authenticate to continue',
    this.buttonText = 'Use Biometric',
    this.icon,
    this.color,
  });

  @override
  State<BiometricAuthButton> createState() => _BiometricAuthButtonState();
}

class _BiometricAuthButtonState extends State<BiometricAuthButton> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isAuthenticating = false;
  bool _isBiometricAvailable = false;
  BiometricType? _primaryBiometric;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    final biometrics = await _biometricService.getAvailableBiometrics();

    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable && biometrics.isNotEmpty;
        _primaryBiometric = biometrics.isNotEmpty ? biometrics.first : null;
      });
    }
  }

  Future<void> _handleAuthentication() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    try {
      final success = await _biometricService.authenticate(
        reason: widget.reason,
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (mounted) {
        if (success) {
          widget.onSuccess();
        } else {
          widget.onFailure?.call();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBiometricAvailable) {
      return const SizedBox.shrink();
    }

    final icon = widget.icon ??
        (_primaryBiometric != null
            ? _biometricService.getBiometricIcon(_primaryBiometric!)
            : Icons.fingerprint);

    return ElevatedButton.icon(
      onPressed: _isAuthenticating ? null : _handleAuthentication,
      icon: _isAuthenticating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : Icon(icon),
      label: Text(widget.buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.color ?? Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Widget to show biometric status and setup guide
class BiometricStatusCard extends StatefulWidget {
  const BiometricStatusCard({super.key});

  @override
  State<BiometricStatusCard> createState() => _BiometricStatusCardState();
}

class _BiometricStatusCardState extends State<BiometricStatusCard> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  String _statusMessage = 'Checking biometric availability...';
  bool _isAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final message = await _biometricService.getBiometricStatusMessage();
    final isAvailable = await _biometricService.isBiometricAvailable();
    final biometrics = await _biometricService.getAvailableBiometrics();

    if (mounted) {
      setState(() {
        _statusMessage = message;
        _isAvailable = isAvailable;
        _availableBiometrics = biometrics;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isAvailable
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isAvailable ? Icons.fingerprint : Icons.security,
                    color: _isAvailable ? Colors.green : Colors.grey,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biometric Authentication',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_availableBiometrics.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _availableBiometrics.map((type) {
                  return Chip(
                    avatar: Icon(
                      _biometricService.getBiometricIcon(type),
                      size: 18,
                      color: Colors.blue,
                    ),
                    label: Text(_biometricService.getBiometricTypeName(type)),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
