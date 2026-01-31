import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../onboarding/presentation/pages/onboarding_screen.dart';
import '../../../dashboard/presentation/pages/dashboard_screen.dart';
import '../../../../../../core/services/hive/hive_service.dart';
import '../../../../../../features/auth/presentation/viewmodels/auth_viewmodel.dart';

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
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      final storedToken = authVm.getStoredToken();

      print(' SplashScreen: Checking for saved session...');
      print(
        ' SplashScreen: Stored token exists: ${storedToken != null && storedToken.isNotEmpty}',
      );
      print(' SplashScreen: User logged in: ${authVm.isLoggedIn}');

      if (!mounted) return;

      if (authVm.isLoggedIn && storedToken != null && storedToken.isNotEmpty) {
        print(' SplashScreen: User already logged in, going to Dashboard');
        Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
      } else {
        print(' SplashScreen: No logged-in user, going to Onboarding');
        Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
      }
    } catch (e) {
      print(' SplashScreen: Error checking session: $e');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    }
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
