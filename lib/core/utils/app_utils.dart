import 'package:intl/intl.dart';
import 'dart:math';

class DateTimeUtils {
  static String formatDateTime(
    DateTime dateTime, {
    String format = 'MMM dd, yyyy HH:mm',
  }) {
    return DateFormat(format).format(dateTime);
  }

  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    return DateFormat(format).format(time);
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }

  static Duration getRemainingTime(DateTime targetTime) {
    return targetTime.difference(DateTime.now());
  }
}

class StringUtils {
  static String capitalize(String string) {
    if (string.isEmpty) return string;
    return string[0].toUpperCase() + string.substring(1).toLowerCase();
  }

  static String getInitials(String name) {
    final names = name.split(' ');
    if (names.isEmpty) return '?';
    if (names.length == 1) return names[0][0].toUpperCase();
    return (names[0][0] + names[names.length - 1][0]).toUpperCase();
  }

  static String maskPhone(String phone) {
    if (phone.length < 10) return phone;
    return '*' * (phone.length - 4) + phone.substring(phone.length - 4);
  }
}

class ValidationUtils {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(
      r'^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}$',
    );
    return phoneRegex.hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8;
  }
}

class LocationUtils {
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; // km
    final double dLat = (lat2 - lat1) * (3.141592653589793 / 180);
    final double dLng = (lng2 - lng1) * (3.141592653589793 / 180);
    final double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(lat1 * (3.141592653589793 / 180)) *
            cos(lat2 * (3.141592653589793 / 180)) *
            sin(dLng / 2) *
            sin(dLng / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static String formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)}m';
    }
    return '${distance.toStringAsFixed(1)}km';
  }

  static double toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }
}
