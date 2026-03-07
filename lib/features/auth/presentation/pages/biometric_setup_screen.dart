import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:influcollb_app/core/services/sensor/biometric_auth_service.dart';
import 'package:influcollb_app/core/utils/snackbar_utils.dart';
import 'package:influcollb_app/features/home/presentation/pages/influencer_bottom_nav.dart';
import 'package:influcollb_app/features/home/presentation/pages/brand_bottom_nav.dart';

/// Screen to set up biometric authentication after first login
class BiometricSetupScreen extends StatefulWidget {
  final String email;
  final String password;
  final bool isInfluencer;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const BiometricSetupScreen({
    super.key,
    required this.email,
    required this.password,
    required this.isInfluencer,
    this.onComplete,
    this.onSkip,
  });

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

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
        _availableBiometrics = biometrics;
      });

      if (!_isBiometricAvailable) {
        SnackbarUtils.showWarning(
          context,
          'Biometric authentication not available on this device',
        );
      }
    }
  }

  Future<void> _setupBiometric() async {
    if (!_isBiometricAvailable) {
      SnackbarUtils.showError(
          context, 'Biometric authentication not available');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Authenticate to enroll biometric
      final authenticated = await _biometricService.authenticate(
        reason: 'Scan your fingerprint to set up biometric login',
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (authenticated) {
        // Save credentials for biometric login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', widget.email);
        await prefs.setString('saved_password', widget.password);
        await prefs.setBool('biometric_enrolled', true);

        if (mounted) {
          SnackbarUtils.showSuccess(
            context,
            'Biometric authentication set up successfully!',
          );
          _navigateToDashboard();
        }
      } else {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            'Biometric authentication failed. Please try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Error setting up biometric: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    if (widget.isInfluencer) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InfluencerBottomNav()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BrandBottomNav()),
      );
    }
  }

  Future<void> _skipSetup() async {
    // Don't mark as permanently skipped - will ask again on next login
    if (mounted) {
      _navigateToDashboard();
    }
  }

  Future<void> _neverAskAgain() async {
    // Mark as permanently skipped so we don't show this again
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_setup_skipped', true);
    if (mounted) {
      _navigateToDashboard();
    }
  }

  String _getBiometricName() {
    if (_availableBiometrics.isEmpty) return 'Biometric';

    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    }
    return 'Biometric';
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.isEmpty) return Icons.fingerprint;

    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    }
    return Icons.security;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _isLoading ? null : _skipSetup,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB16CEA), Color(0xFFFF5E69)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getBiometricIcon(),
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Set Up ${_getBiometricName()}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Use your ${_getBiometricName().toLowerCase()} to quickly and securely log in to your account',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Benefits
              _buildBenefit(
                Icons.speed,
                'Faster Login',
                'No need to type your password',
              ),
              const SizedBox(height: 16),
              _buildBenefit(
                Icons.security,
                'More Secure',
                'Your biometric data stays on your device',
              ),
              const SizedBox(height: 16),
              _buildBenefit(
                Icons.check_circle,
                'Easy to Use',
                'Just scan and you\'re in',
              ),

              const Spacer(),

              // Setup button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading || !_isBiometricAvailable
                      ? null
                      : _setupBiometric,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB16CEA), Color(0xFFFF5E69)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_getBiometricIcon(), color: Colors.white),
                                const SizedBox(width: 12),
                                Text(
                                  'Set Up ${_getBiometricName()}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip for now button
              TextButton(
                onPressed: _isLoading ? null : _skipSetup,
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
              ),

              // Never ask again button
              TextButton(
                onPressed: _isLoading ? null : _neverAskAgain,
                child: const Text(
                  'Never ask again',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFB16CEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFB16CEA),
            size: 24,
          ),
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
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
