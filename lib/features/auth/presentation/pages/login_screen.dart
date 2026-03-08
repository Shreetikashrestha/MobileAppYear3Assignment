import 'package:flutter/material.dart';
import 'package:influcollb_app/features/home/presentation/pages/influencer_bottom_nav.dart';
import 'package:influcollb_app/features/home/presentation/pages/brand_bottom_nav.dart';
import 'package:influcollb_app/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:influcollb_app/features/auth/presentation/pages/biometric_setup_screen.dart';
import 'package:influcollb_app/core/utils/snackbar_utils.dart';
import 'package:influcollb_app/core/services/sensor/biometric_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/auth/presentation/view_model/login_view_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  int _selectedRole = 0; // 0: Influencer, 1: Brand
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isBiometricAvailable = false;
  bool _hasSavedCredentials = false;
  bool _isLoginInProgress = false; // Prevent multiple login calls

  @override
  void initState() {
    super.initState();
    _checkBiometricAndCredentials();
  }

  Future<void> _checkBiometricAndCredentials() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final biometricEnrolled = prefs.getBool('biometric_enrolled') ?? false;

    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
        _hasSavedCredentials =
            savedEmail != null && savedPassword != null && biometricEnrolled;
        if (_hasSavedCredentials) {
          emailController.text = savedEmail!;
          passwordController.text = savedPassword!;
        }
      });
    }
  }

  Future<void> _handleBiometricLogin() async {
    if (!_hasSavedCredentials) {
      SnackbarUtils.showWarning(context,
          'Please login with password first to enable biometric login');
      return;
    }

    final authenticated = await _biometricService.authenticateForLogin();

    if (authenticated && mounted) {
      // Auto-fill and login
      _handleLogin();
    } else if (mounted) {
      SnackbarUtils.showError(context, 'Biometric authentication failed');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // Prevent multiple login attempts
    if (_isLoginInProgress) return;

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      SnackbarUtils.showWarning(context, 'Please fill all fields');
      return;
    }

    setState(() => _isLoginInProgress = true);

    // Note: The role selector in UI is just for display
    // The actual user role comes from the backend API response
    ref.read(loginViewModelProvider.notifier).login(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
  }

  void _navigateToHome(bool isInfluencer) {
    if (!mounted) return;
    if (isInfluencer) {
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

  Future<void> _handleLoginSuccess(bool isInfluencer) async {
    if (!mounted) return;

    // Show user which role they're logging in as
    final roleText = isInfluencer ? 'Influencer' : 'Brand';
    SnackbarUtils.showSuccess(context, 'Welcome back! Logging in as $roleText');

    try {
      // Check if biometric setup is needed
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final biometricEnrolled = prefs.getBool('biometric_enrolled') ?? false;
      final biometricSkipped =
          prefs.getBool('biometric_setup_skipped') ?? false;
      final isAvailable = await _biometricService.isBiometricAvailable();

      if (!mounted) return;

      // Show biometric setup if not enrolled, not skipped, and device supports it
      if (!biometricEnrolled && !biometricSkipped && isAvailable) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BiometricSetupScreen(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
              isInfluencer: isInfluencer,
            ),
          ),
        );
      } else {
        // Navigate directly to home
        _navigateToHome(isInfluencer);
      }
    } catch (e) {
      // If any error occurs, just navigate to home
      if (mounted) {
        _navigateToHome(isInfluencer);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);
    final isLoading = loginState is AsyncLoading;

    ref.listen(loginViewModelProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            _handleLoginSuccess(user.isInfluencer);
          } else {
            // Reset login flag if login returned null
            if (mounted) setState(() => _isLoginInProgress = false);
          }
        },
        error: (error, _) {
          if (mounted) {
            setState(() => _isLoginInProgress = false);
            SnackbarUtils.showError(context, error.toString());
          }
        },
        loading: () {},
      );
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8F6FF), Color(0xFFFDE6F6)],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Login',
                    key: const Key('loginTitle'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4C1D95),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text("Don't have an account?",
                          style: TextStyle(color: Color(0xFF4C1D95))),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/signup'),
                        child: const Text('Sign up',
                            style: TextStyle(color: Color(0xFF7C3AED))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('I am a:',
                      style: TextStyle(color: Color(0xFF4C1D95))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedRole == 0
                                    ? const Color(0xFF7C3AED)
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.person_outline,
                                    color: _selectedRole == 0
                                        ? const Color(0xFF7C3AED)
                                        : Colors.grey),
                                const SizedBox(height: 4),
                                Text('Influencer',
                                    style: TextStyle(
                                        color: _selectedRole == 0
                                            ? const Color(0xFF4C1D95)
                                            : Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedRole == 1
                                    ? const Color(0xFF7C3AED)
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.work_outline,
                                    color: _selectedRole == 1
                                        ? const Color(0xFF7C3AED)
                                        : Colors.grey),
                                const SizedBox(height: 4),
                                Text('Brand',
                                    style: TextStyle(
                                        color: _selectedRole == 1
                                            ? const Color(0xFF4C1D95)
                                            : Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    style: const TextStyle(color: Color(0xFF4C1D95)),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(
                          color: const Color(0xFF4C1D95).withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Color(0xFF7C3AED)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Color(0xFF4C1D95)),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                          color: const Color(0xFF4C1D95).withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: Color(0xFF7C3AED)),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF7C3AED)),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text('Forgot password?',
                          style: TextStyle(color: Colors.purple)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  key: Key('loginButtonText'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  // Biometric Login Button
                  if (_isBiometricAvailable && _hasSavedCredentials) ...[
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : _handleBiometricLogin,
                        icon: const Icon(Icons.fingerprint, size: 28),
                        label: const Text(
                          'Login with Biometric',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB16CEA),
                          side: const BorderSide(
                              color: Color(0xFFB16CEA), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
