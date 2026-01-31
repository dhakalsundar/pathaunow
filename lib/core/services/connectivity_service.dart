import 'dart:io';
import 'package:flutter/foundation.dart';

/// Simple connectivity checker without external dependencies
class ConnectivityService {
  /// Check if device has internet connectivity
  static Future<bool> hasConnection() async {
    try {
      // Try to lookup a reliable host
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        debugPrint('✅ ConnectivityService: Internet available');
        return true;
      }
      debugPrint('⚠️ ConnectivityService: No internet connection');
      return false;
    } on SocketException catch (_) {
      debugPrint('⚠️ ConnectivityService: No internet - SocketException');
      return false;
    } catch (e) {
      debugPrint('⚠️ ConnectivityService: Connection check failed - $e');
      return false;
    }
  }

  /// Quick check without DNS lookup (checks if we can create a socket)
  static Future<bool> hasConnectionFast() async {
    try {
      final socket = await Socket.connect(
        '8.8.8.8',
        53,
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
      debugPrint('✅ ConnectivityService: Fast check - Internet available');
      return true;
    } catch (e) {
      debugPrint('⚠️ ConnectivityService: Fast check - No internet');
      return false;
    }
  }
}
