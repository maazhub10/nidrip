import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _scale = 0.5; // initial scale
  @override
  void initState() {
    super.initState();

    // Animate logo scale after build
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _scale = 1.0; // final scale
      });
    });

    // Redirect after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFC2153), Color(0xFF0030FD)],
          ),
        ),
        child: Center(
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(seconds: 3),
            curve: Curves.easeOut,
            child: Image.asset("assets/nidrip.png", width: 220),
          ),
        ),
      ),
    );
  }
}
