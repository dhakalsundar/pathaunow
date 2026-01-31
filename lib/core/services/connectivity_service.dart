import 'dart:io';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        debugPrint(' ConnectivityService: Internet available');
        return true;
      }
      debugPrint(' ConnectivityService: No internet connection');
      return false;
    } on SocketException catch (_) {
      debugPrint(' ConnectivityService: No internet - SocketException');
      return false;
    } catch (e) {
      debugPrint(' ConnectivityService: Connection check failed - $e');
      return false;
    }
  }

  static Future<bool> hasConnectionFast() async {
    try {
      final socket = await Socket.connect(
        '8.8.8.8',
        53,
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
      debugPrint(' ConnectivityService: Fast check - Internet available');
      return true;
    } catch (e) {
      debugPrint(' ConnectivityService: Fast check - No internet');
      return false;
    }
  }
}
