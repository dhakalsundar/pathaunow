import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pathau_now/core/services/hive_auth_service.dart';
import 'package:pathau_now/core/models/user.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AuthResponse {
  final bool success;
  final String? token;
  final Map<String, dynamic>? user;
  final String? message;

  AuthResponse({required this.success, this.token, this.user, this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      token: json['token'],
      user: json['user'],
      message: json['message'],
    );
  }
}

class AuthService {
  /// Get base URL based on platform and target
  static String get baseUrl {
    // For web (Chrome, Edge, Firefox)
    if (kIsWeb) {
      return 'http://localhost:3000/api/auth';
    }

    // For Android/iOS physical devices (same WiFi)
    // CHANGE THIS to your computer's IP address if running on physical device
    // Find with: ipconfig (Windows) or ifconfig (Mac/Linux)
    // Example: 'http://192.168.1.100:3000/api/auth'
    if (Platform.isAndroid || Platform.isIOS) {
      // Option 1: Physical Device on same WiFi (UPDATE THIS IP)
      return 'http://localhost:3000/api';

      // Option 2: Uncomment for Android Emulator
      // return 'http://10.0.2.2:3000/api/auth';

      // Option 3: Uncomment for iOS Simulator
      // return 'http://localhost:3000/api/auth';
    }

    // Fallback
    return 'http://localhost:3000/api';
  }

  static Future<AuthResponse> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
        return AuthResponse(success: false, message: 'All fields are required');
      }

      final uri = Uri.parse('$baseUrl/signup');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);

        // Save user to Hive
        if (authResponse.user != null) {
          final hiveUser = User(
            name: authResponse.user!['name'] ?? name,
            email: authResponse.user!['email'] ?? email,
            password: password,
          );
          await HiveAuthService().setCurrentUser(hiveUser);
        }

        return authResponse;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Signup failed',
        );
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'Error: $e');
    }
  }

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return AuthResponse(
          success: false,
          message: 'Email and password are required',
        );
      }

      final uri = Uri.parse('$baseUrl/login');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);

        // Save user to Hive
        if (authResponse.user != null) {
          final hiveUser = User(
            name: authResponse.user!['name'] ?? '',
            email: authResponse.user!['email'] ?? email,
            password: password,
          );
          await HiveAuthService().setCurrentUser(hiveUser);
        }

        return authResponse;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'Error: $e');
    }
  }

  static Future<bool> logout() async {
    try {
      await HiveAuthService().logout();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getToken() async {
    try {
      final user = await getCurrentUser();
      return user != null ? 'token_exists' : null;
    } catch (e) {
      return null;
    }
  }

  static Future<User?> getCurrentUser() async {
    try {
      return await Future.value(HiveAuthService().getCurrentUser());
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
