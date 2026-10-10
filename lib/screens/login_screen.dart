import 'dart:ui';
import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

import '../api/api_service.dart';
import '../widgets/loading_dialog.dart';
import '../utils/validators.dart';
import '../models/auth/verify_email_response.dart';
import '../services/auth_storage.dart';
import 'home_screen.dart';
import 'verify_otp_screen.dart';

class LoginScreenPage extends StatefulWidget {
  const LoginScreenPage({super.key});

  @override
  State<LoginScreenPage> createState() => _LoginScreenPageState();
}

class _LoginScreenPageState extends State<LoginScreenPage> {
  bool _rememberMe = false;
  bool _loading = false;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController(
    text: 'hiuser@yopmail.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '12345678',
  );

  // ─── Brand Colors ───────────────────────────────────────────────────
  // static const Color _pink = Color(0xFFFD215C);
  // static const Color _magenta = Color(0xFFFD22C4);

  static const Color _pink = Color.fromARGB(255, 250, 97, 138); // #FA618A
  static const Color _magenta = Color.fromARGB(255, 210, 77, 175);

  // ─── Glassmorphism field decoration ─────────────────────────────────
  InputDecoration _fieldDecoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 1),
      ),
    );
  }

  Widget _buildGlassyTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: Colors.white,
          decoration: _fieldDecoration(hint: hint, suffix: suffix),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No appBar — full gradient background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_pink, _magenta],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 48),

                Center(child: SizedBox(height: 50, child: _buildLogo())),

                const SizedBox(height: 40),

                // ── Welcome text ───────────────────────────────────────
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sign in to your dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Email Field ────────────────────────────────────────
                _buildLabel('Email Address'),
                const SizedBox(height: 8),
                _buildGlassyTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  hint: 'admin@nidrip.com',
                ),

                const SizedBox(height: 20),

                // ── Password Field ─────────────────────────────────────
                _buildLabel('Password'),
                const SizedBox(height: 8),
                _buildGlassyTextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  hint: '••••••••',
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Remember me + Forgot password ──────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged:
                                (v) => setState(() => _rememberMe = v ?? false),
                            activeColor: Colors.white,
                            checkColor: _pink,
                            side: const BorderSide(
                              color: Colors.white70,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Remember me',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Login Button ───────────────────────────────────────
                _buildLoginButton(),

                const SizedBox(height: 36),

                // ── Or Separator ───────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white.withOpacity(0.35),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'Or',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white.withOpacity(0.35),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Continue with Google ───────────────────────────────
                _buildSocialButton(
                  assetPath: 'assets/google.png',
                  label: 'Continue with Google',
                  onTap: () {},
                ),

                const SizedBox(height: 12),

                // ── Continue with Facebook ─────────────────────────────
                _buildSocialButton(
                  assetPath: 'assets/facebook.png',
                  label: 'Continue with Facebook',
                  onTap: () {},
                ),

                const SizedBox(height: 32),

                // ── Register ───────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
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
    );
  }

  // ─── Logo Widget ───────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return ClipRRect(
      child: Image.asset(
        'assets/logo.png',
        height: 32,
        fit: BoxFit.contain,
        errorBuilder:
            (_, __, ___) =>
                const Icon(Icons.water_drop, color: Colors.white, size: 32),
      ),
    );
  }

  // ─── Label Widget ──────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ─── Login Button ──────────────────────────────────────────────────────────
  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _loading ? null : _login,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: const Text(
            'Sign In →',
            style: TextStyle(
              color: _pink,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Social Button ─────────────────────────────────────────────────────────
  Widget _buildSocialButton({
    required String assetPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(assetPath, width: 22, height: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Login Logic ───────────────────────────────────────────────────────────
  void _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty && password.isEmpty) {
      _showSnack('Email and password required');
      return;
    }
    if (email.isEmpty) {
      _showSnack('Please enter your email');
      return;
    }
    if (!Validators.isValidEmail(email)) {
      _showSnack('Invalid email format');
      return;
    }
    if (password.isEmpty) {
      _showSnack('Please enter your password');
      return;
    }

    setState(() => _loading = true);
    showLoadingDialog(context);

    bool navigateToHome = false;
    bool navigateToVerify = false;
    String? verifyEmail;
    String? successMessage;
    String? errorMessage;

    try {
      final result = await ApiService.login(email: email, password: password);

      if (!mounted) return;

      final response = VerifyEmailResponse.fromJson(result);

      if (response.isSuccess) {
        if (response.token.isEmpty) {
          errorMessage = 'Logged in but no token received';
        } else {
          await AuthStorage.saveSession(
            token: response.token,
            userId: response.data?.id,
            userEmail: response.data?.email,
          );
          successMessage =
              response.message.isNotEmpty
                  ? response.message
                  : 'Logged in successfully';
          navigateToHome = true;
        }
      } else if (response.status == 403 || result['status'] == 403) {
        errorMessage =
            response.message.isNotEmpty
                ? response.message
                : 'Please verify your email first';

        verifyEmail = email;
        if (result['data'] != null &&
            result['data'] is Map &&
            result['data']['email'] != null) {
          verifyEmail = result['data']['email'];
        } else if (response.data?.email != null &&
            response.data!.email!.isNotEmpty) {
          verifyEmail = response.data!.email;
        }

        navigateToVerify = true;
      } else {
        errorMessage =
            response.message.isNotEmpty ? response.message : 'Login failed';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    } finally {
      if (mounted) {
        hideLoadingDialog(context);
        setState(() => _loading = false);

        if (navigateToHome) {
          _showSnack(successMessage!);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
          );
        } else if (navigateToVerify) {
          _showSnack(errorMessage!);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerifyOtpScreen(email: verifyEmail!),
            ),
          );
        } else if (errorMessage != null) {
          _showSnack(errorMessage);
        }
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
