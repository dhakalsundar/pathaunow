import 'package:flutter/material.dart';
import '../../../../core/widgets/my_button.dart';
import '../../../../core/widgets/my_textfield.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import 'package:pathau_now/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class SignupScreen extends StatefulWidget {
  static const String routeName = '/signup';
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    print('📱 SignupScreen: Starting signup process...');
    print('📱 SignupScreen: Name: $name, Email: $email, Phone: $phone');

    final authVm = Provider.of<AuthViewModel>(context, listen: false);

    try {
      print('📱 SignupScreen: Calling AuthViewModel.signup()...');
      await authVm.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (!mounted) return;

      print('📱 SignupScreen: Signup completed. Error: ${authVm.error}');

      if (authVm.error == null) {
        print('✅ SignupScreen: Signup successful, redirecting to login...');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created — please login')),
        );
        // After signup, redirect user to login so they authenticate — prefill email & password
        Navigator.pushReplacementNamed(
          context,
          LoginScreen.routeName,
          arguments: {
            'prefillEmail': email,
            'prefillPassword': password,
            'message': 'Account created. Please login.',
          },
        );
      } else {
        print('❌ SignupScreen: Signup failed with error: ${authVm.error}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${authVm.error!}')));
      }
    } catch (e) {
      print('❌ SignupScreen: Exception caught: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up - Pathau Now'),
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
                        width: 110,
                        height: 110,
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
                        'Create your Pathau Now account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    MyTextField(
                      controller: _nameController,
                      hintText: 'Full Name',
                      keyboardType: TextInputType.name,
                      obscureText: false,
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      controller: _phoneController,
                      hintText: 'Phone Number',
                      keyboardType: TextInputType.phone,
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
                    Consumer<AuthViewModel>(
                      builder: (context, authVm, _) => MyButton(
                        text: authVm.isLoading ? 'Signing Up...' : 'Sign Up',
                        onPressed: () {
                          if (authVm.isLoading) return;
                          _signup();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              LoginScreen.routeName,
                            );
                          },
                          child: const Text('Login'),
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
