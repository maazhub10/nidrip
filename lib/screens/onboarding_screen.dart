import 'package:flutter/material.dart';
import 'login_signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    // Start animation after build
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _animate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),

            // Image animation
            AnimatedSlide(
              offset: _animate ? Offset.zero : const Offset(0, 0.2),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage("assets/onboarding.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80),

            // Text animation
            AnimatedSlide(
              offset: _animate ? Offset.zero : const Offset(0, 0.2),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,
              child: Column(
                children: [
                  const Text(
                    "Own the trendiest items",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Affordable Home Appliances,\nDelivered Fast Across Belfast",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Button animation
            AnimatedSlide(
              offset: _animate ? Offset.zero : const Offset(0, 0.2),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginSignupScreen(),
                    ),
                  );
                },
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
                      "Get Started",
                      style: TextStyle(
                        color: Color.fromARGB(255, 250, 97, 138),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
