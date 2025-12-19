import 'package:flutter/material.dart';
import 'screen/splash_screen.dart';
import 'screen/onboarding_screen.dart';
import 'screen/login_screen.dart';
import 'screen/signup_screen.dart';
import 'screen/dashboard_screen.dart';
// import 'theme/theme_data.dart';

class PathauNowApp extends StatelessWidget {
  const PathauNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pathau Now',
      debugShowCheckedModeBanner: false,

      // theme: AppTheme.lightTheme,
      // theme: ThemeData(
      //   useMaterial3: true,
      //   fontFamily: "OpenSans",
      //   colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF57C00)),
      //   primaryColor: const Color(0xFFF57C00),
      //   scaffoldBackgroundColor: const Color(0xFFF8F9FB),
      // ),
      initialRoute: SplashScreen.routeName,
      routes: <String, WidgetBuilder>{
        SplashScreen.routeName: (_) => const SplashScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignupScreen.routeName: (_) => const SignupScreen(),
        DashboardScreen.routeName: (_) => const DashboardScreen(),
      },
    );
  }
}
