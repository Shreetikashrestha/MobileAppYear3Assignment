import 'package:flutter/material.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/hive_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isInfluencer = true;
  bool isSignUpTab = false;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late AuthRepository authRepository;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
  }

  void _initializeRepository() {
    final hiveService = HiveService();
    final localDataSource = LocalDataSource(hiveService: hiveService);
    authRepository = AuthRepositoryImpl(localDataSource: localDataSource);
  }

  void _handleAuth() async {
    if (isSignUpTab) {
      // SIGN UP LOGIC
      if (nameController.text.isEmpty) {
        _showMessage("Please enter your full name");
        return;
      }
      if (emailController.text.isEmpty) {
        _showMessage("Please enter your email");
        return;
      }
      if (passwordController.text.isEmpty) {
        _showMessage("Please enter a password");
        return;
      }
      if (passwordController.text.length < 6) {
        _showMessage("Password must be at least 6 characters");
        return;
      }

      try {
        setState(() => isLoading = true);

        // Check if user already exists
        final userExists =
            await authRepository.userExists(emailController.text.trim());
        if (userExists) {
          _showMessage("Email already registered!");
          setState(() => isLoading = false);
          return;
        }

        // Create user model
        final user = UserModel(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          isInfluencer: isInfluencer,
        );

        // Save to Hive
        await authRepository.signUp(user);

        _showMessage("Account created! Please login to continue");

        // Clear fields and switch to login tab
        nameController.clear();
        emailController.clear();
        passwordController.clear();

        setState(() {
          isSignUpTab = false;
          isLoading = false;
        });
      } catch (e) {
        _showMessage("Error: ${e.toString()}");
        setState(() => isLoading = false);
      }
    } else {
      // LOGIN LOGIC
      if (emailController.text.isEmpty) {
        _showMessage("Please enter your email");
        return;
      }
      if (passwordController.text.isEmpty) {
        _showMessage("Please enter your password");
        return;
      }

      try {
        setState(() => isLoading = true);

        // Validate credentials
        final isValid = await authRepository.login(
          emailController.text.trim(),
          passwordController.text,
        );

        if (!isValid) {
          _showMessage("Invalid email or password");
          setState(() => isLoading = false);
          return;
        }

        // Get user data
        final user =
            await authRepository.getUserByEmail(emailController.text.trim());

        _showMessage("Welcome back, ${user?.name}!");

        // Navigate to home after successful login
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        _showMessage("Error: ${e.toString()}");
        setState(() => isLoading = false);
      }
    }
  }

  void _handleSocialLogin(String provider) {
    _showMessage("Logging in with $provider...");
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF9F7AEA),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E4F3),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.20,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/splashbg.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          "assets/images/logo.png",
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "I am a",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isInfluencer = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: isInfluencer
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFB798F0),
                                          Color(0xFF9F7AEA),
                                        ],
                                      )
                                    : null,
                                color: isInfluencer ? null : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Text(
                                  "INFLUENCER",
                                  style: TextStyle(
                                    color: isInfluencer
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isInfluencer = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: !isInfluencer
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFB798F0),
                                          Color(0xFF9F7AEA),
                                        ],
                                      )
                                    : null,
                                color: !isInfluencer ? null : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Text(
                                  "BRAND",
                                  style: TextStyle(
                                    color: !isInfluencer
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignUpTab = false;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isSignUpTab
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: !isSignUpTab
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      color: !isSignUpTab
                                          ? Colors.black
                                          : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignUpTab = true;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSignUpTab
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: isSignUpTab
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    "SIGN UP",
                                    style: TextStyle(
                                      color: isSignUpTab
                                          ? Colors.black
                                          : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (isSignUpTab) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Full name",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_outline),
                                hintText: "Ram Shrestha",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined),
                              hintText: "your@email.com",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "password",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              hintText: "password",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isSignUpTab) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            _showMessage(
                                "Password reset link sent to your email!");
                          },
                          child: const Text(
                            "FORGET PASSWORD?",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9F7AEA),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFB798F0),
                            Color(0xFF9F7AEA),
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      child: TextButton(
                        onPressed: isLoading ? null : _handleAuth,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isSignUpTab ? "Sign Up" : "LOG IN",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "or continue with",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _handleSocialLogin("Google"),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.g_mobiledata,
                                      size: 28, color: Colors.red),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Google",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _handleSocialLogin("Facebook"),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.facebook,
                                      size: 24, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Facebook",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
