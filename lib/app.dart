import 'package:flutter/material.dart';
import 'screen/splash_screen.dart';
import 'screen/onboarding_screen.dart';
import 'screen/login_screen.dart';
import 'screen/signup_screen.dart';
import 'screen/dashboard_screen.dart';

class PathauNowApp extends StatelessWidget {
  const PathauNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pathau Now',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
        primaryColor: const Color(0xFFF57C00),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF57C00),

        ),
        useMaterial3: true,
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignupScreen.routeName: (_) => const SignupScreen(),
        DashboardScreen.routeName: (_) => const DashboardScreen(),
      },
    );
  }
}
