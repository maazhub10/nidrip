import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nidrip/widgets/custom_app_bar.dart';
import '../api/api_service.dart';
import '../models/auth/verify_email_response.dart';
import '../services/auth_storage.dart';
import '../widgets/loading_dialog.dart';
import 'home_screen.dart';
import 'reset_password_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final bool isForgotPassword;

  const VerifyOtpScreen({
    super.key,
    required this.email,
    this.isForgotPassword = false,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final int _otpLength = 6;

  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  int _secondsRemaining = 59;
  Timer? _timer;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _startTimer();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    setState(() => loading = true);
    showLoadingDialog(context);

    try {
      var result = await ApiService.resendOtp(email: widget.email.trim());

      if (!mounted) return;

      final ok =
          result["ok"] == true ||
          result["status"] == 200 ||
          result["status"] == "success";

      if (ok) {
        // Clear all text fields
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();

        _startTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"] ??
                  "A new verification code was sent to your email",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Failed to resend OTP")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        hideLoadingDialog(context);
        setState(() => loading = false);
      }
    }
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45,
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < _otpLength - 1) {
            _focusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  Future<void> verifyOtp() async {
    String otp = _controllers.map((c) => c.text).join();

    if (otp.length < _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter complete OTP")),
      );
      return;
    }

    setState(() => loading = true);
    showLoadingDialog(context);

    bool navigateToHome = false;
    bool navigateToReset = false;
    String? successMessage;
    String? errorMessage;

    try {
      var result = await ApiService.verifyEmail(
        email: widget.email.trim(),
        otp: otp,
      );

      if (!mounted) return;

      final response = VerifyEmailResponse.fromJson(result);

      if (response.isSuccess) {
        if (widget.isForgotPassword) {
          successMessage =
              response.message.isNotEmpty
                  ? response.message
                  : "OTP verified successfully";
          navigateToReset = true;
        } else {
          if (response.token.isEmpty) {
            errorMessage = "Verified but no token received";
          } else {
            await AuthStorage.saveSession(
              token: response.token,
              userId: response.data?.id,
              userEmail: response.data?.email,
            );
            successMessage =
                response.message.isNotEmpty
                    ? response.message
                    : "Email verified successfully";
            navigateToHome = true;
          }
        }
      } else {
        errorMessage =
            response.message.isNotEmpty
                ? response.message
                : "OTP verification failed";
      }
    } catch (e) {
      errorMessage = "Error: $e";
    } finally {
      if (mounted) {
        hideLoadingDialog(context);
        setState(() => loading = false);

        if (navigateToReset) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(successMessage!)));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(email: widget.email.trim()),
            ),
          );
        } else if (navigateToHome) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(successMessage!)));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
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
      appBar: const CustomAppBar(title: "Verify OTP"),
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
              const SizedBox(height: 150),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "OTP sent to\n${widget.email}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _otpLength,
                  (index) => _buildOtpBox(index),
                ),
              ),
              const SizedBox(height: 20),
              if (_secondsRemaining > 0)
                Text(
                  "Resend in 00:${_secondsRemaining.toString().padLeft(2, '0')}",
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                )
              else
                const SizedBox(height: 16), // keep spacing decent when hidden

              if (_secondsRemaining > 0)
                const SizedBox(height: 50)
              else
                const SizedBox(height: 30),

              GestureDetector(
                onTap: loading ? null : verifyOtp,
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
                      "Confirm",
                      style: TextStyle(
                        color: Color.fromARGB(255, 250, 97, 138),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              if (_secondsRemaining == 0) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: loading ? null : _resendOtp,
                  child: const Text(
                    "Resend Code",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}
