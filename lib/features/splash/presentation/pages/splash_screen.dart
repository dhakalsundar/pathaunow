import 'dart:async';
import 'package:flutter/material.dart';
import '../../../onboarding/presentation/pages/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF57C00),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFFFE0B2), width: 10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/pathau_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pathau Now',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track your courier & parcels\nin real time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
