import 'package:flutter/material.dart';
import '../../../../core/widgets/my_button.dart';
import '../../../../core/widgets/my_textfield.dart';
import 'signup_screen.dart';
import '../../../dashboard/presentation/pages/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:pathau_now/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args['prefillEmail'] != null) {
          _emailController.text = args['prefillEmail'].toString();
        }
        if (args['prefillPassword'] != null) {
          // Prefill password only when passed explicitly from signup flow
          _passwordController.text = args['prefillPassword'].toString();
        }
        if (args['message'] != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(args['message'].toString())),
              );
            }
          });
        }
      }
      _initialized = true;
    }
  }

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    print('📱 LoginScreen: Starting login process...');
    print('📱 LoginScreen: Email: $email');

    final authVm = Provider.of<AuthViewModel>(context, listen: false);

    try {
      await authVm.login(email: email, password: password);
      if (!mounted) return;

      if (authVm.error == null) {
        print('✅ LoginScreen: Login successful');
        print(
          '📱 LoginScreen: User data - Name: ${authVm.user?.name}, Email: ${authVm.user?.email}',
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful')));

        print('📱 LoginScreen: Navigating to dashboard...');
        // Navigate to dashboard with home tab (index 0)
        Navigator.pushReplacementNamed(
          context,
          DashboardScreen.routeName,
          arguments: {'initialIndex': 0}, // Home tab
        );
      } else {
        print('❌ LoginScreen: Login failed - ${authVm.error}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authVm.error!)));
      }
    } catch (e) {
      print('❌ LoginScreen: Exception during login: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login - Pathau Now'),
        backgroundColor: const Color(0xFFF57C00),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromRGBO(245, 124, 0, 0.1), const Color(0xFFFFECDC)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 500 : double.infinity,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFFFE0B2),
                            width: 8,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/pathau_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Welcome back to Pathau Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    MyTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 24),
                    MyButton(text: 'Login', onPressed: _login),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              SignupScreen.routeName,
                            );
                          },
                          child: const Text('Sign up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
