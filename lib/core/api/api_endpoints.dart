import 'package:pathau_now/config/app_config.dart';

class ApiEndpoints {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Auth endpoints
  static const String login = "/auth/login";
  static const String signup = "/auth/signup";
  static const String getCurrentUser = "/auth/me";
  static const String updateProfile = "/auth/profile";
  static const String uploadProfileImage = "/auth/profile/upload";
  static const String logout = "/auth/logout";

  // Media endpoints
  static const String uploadImage = "/media/upload";
  static const String listImages = "/media";

  // Parcel endpoints
  static const String createParcel = "/parcels";
  static const String getUserParcels = "/parcels/user";
  static const String trackParcel = "/parcels/track";

  // Address endpoints
  static const String getAddresses = "/addresses";
  static const String createAddress = "/addresses";
}
