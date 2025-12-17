import 'package:flutter/material.dart';
import '../services/mistral_service.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Mistral _mistral = Mistral();
  final TextEditingController _questionController = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  Future<void> _ask() async {
    if (_questionController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final response = await _mistral.askMistral(_questionController.text);
      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'An error occurred. Please try again later.';
        _isLoading = false;
      });
    }
  }

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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ask Mistral a Question',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter your question',
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Text(
                        _response,
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _ask,
        child: const Icon(Icons.send),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
