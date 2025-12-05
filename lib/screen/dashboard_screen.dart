import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pathau Now Dashboard'),
        backgroundColor: const Color(0xFFF57C00),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF57C00).withOpacity(0.1),
              const Color(0xFFFFECDC),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 600 : double.infinity,
            ),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Dashboard',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}