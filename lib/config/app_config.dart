import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'PathauNow';
  static const String appVersion = '1.0.0';

  // API Configuration - with platform-specific fallbacks
  static String get apiBaseUrl {
    // Try to get from .env first (with safe access)
    try {
      if (dotenv.isInitialized) {
        final env = dotenv.env['API_BASE_URL'];
        if (env != null && env.isNotEmpty) {
          return env;
        }
      }
    } catch (e) {
      // dotenv not initialized, use platform defaults
      debugPrint(
        '⚠️ AppConfig: dotenv not initialized, using platform defaults',
      );
    }

    // Platform-specific defaults if .env not configured
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static String get socketBaseUrl {
    // Try to get from .env first (with safe access)
    try {
      if (dotenv.isInitialized) {
        final env = dotenv.env['SOCKET_BASE_URL'];
        if (env != null && env.isNotEmpty) {
          return env;
        }
      }
    } catch (e) {
      // dotenv not initialized, use platform defaults
      debugPrint(
        '⚠️ AppConfig: dotenv not initialized, using platform defaults',
      );
    }

    // Platform-specific defaults if .env not configured
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static const String socketNamespace = '/tracking';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Location
  static const double defaultLocationRadius = 10.0; // km
  static const int locationUpdateInterval = 5000; // milliseconds

  // Debug mode
  static bool get isDebugMode =>
      const bool.fromEnvironment('DEBUG', defaultValue: false);
}
