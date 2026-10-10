import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe
  Stripe.publishableKey =
      'pk_test_51TVEIWPwxxxI3C8fVFAtv6MdH2BBlzTBpySgF5cZp8lbEjnuVGNJV9cRPKYnURLya9GYldZev6gqNgM4xJeGxrzy00gmvClbtT';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const Placeholder(), // temporary home
      },
    );
  }
}
