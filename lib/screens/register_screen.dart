import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nidrip/widgets/custom_app_bar.dart';
import 'login_screen.dart';
import 'verify_otp_screen.dart';
import '../api/api_service.dart';
import '../widgets/loading_dialog.dart';
import '../utils/validators.dart';
import '../models/auth/signup_response.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool loading = false;

  void _signup() async {
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirm = confirmController.text;

    if (email.isEmpty && password.isEmpty && confirm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your email")));
      return;
    }

    if (!Validators.isValidEmail(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid email format")));
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your password")),
      );
      return;
    }

    if (confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please confirm your password")),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 8 characters")),
      );
      return;
    }

    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => loading = true);
    showLoadingDialog(context);

    bool navigateToOtp = false;
    String? successMessage;
    String? errorMessage;

    try {
      var result = await ApiService.signup(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      debugPrint('📦 Signup Result: $result');

      final response = SignupResponse.fromJson(result);

      if (response.isSuccess) {
        successMessage =
            response.message.isNotEmpty
                ? response.message
                : "Account created successfully";
        navigateToOtp = true;
      } else {
        errorMessage =
            response.message.isNotEmpty ? response.message : "Signup failed";
      }
    } catch (e) {
      errorMessage = "Error: $e";
    } finally {
      if (mounted) {
        hideLoadingDialog(context);
        setState(() => loading = false);

        if (navigateToOtp) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(successMessage!)));

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => VerifyOtpScreen(email: emailController.text.trim()),
            ),
          );
        } else if (errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Sign Up"),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 250, 97, 138),
              Color.fromARGB(255, 210, 77, 175),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),

              _buildTextField(
                "Email",
                emailController,
                false,
                "Enter your email",
              ),
              const SizedBox(height: 5),

              _buildTextField(
                "Password",
                passwordController,
                true,
                "Enter password",
              ),
              const SizedBox(height: 5),

              _buildTextField(
                "Confirm Password",
                confirmController,
                true,
                "Confirm password",
              ),
              const SizedBox(height: 25),

              GestureDetector(
                onTap: loading ? null : _signup,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  height: 50,
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
                  child: const Center(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Color.fromARGB(255, 250, 97, 138),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have account?", style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreenPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool obscure,
    String hint,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: TextField(
                controller: controller,
                obscureText: obscure,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),

                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),

                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                  ),

                  isDense: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
