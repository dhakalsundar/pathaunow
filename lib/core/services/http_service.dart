import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';
import 'package:pathau_now/config/app_config.dart';

class HttpService {
  /// Uses centralized configuration from AppConfig
  /// Automatically handles platform-specific URLs (Android emulator, iOS, web, etc.)
  static String get baseUrl => AppConfig.apiBaseUrl;

  static String? _token;

  static void setToken(String token) {
    _token = token;
    debugPrint('🔐 HttpService: Token set');
  }

  static void clearToken() {
    _token = null;
    debugPrint('🔐 HttpService: Token cleared');
  }

  static String? getToken() => _token;

  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('📡 GET: $url');

      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ HTTP GET Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('📡 POST: $url');
      debugPrint('📦 Body: $body');

      final response = await http
          .post(url, headers: _getHeaders(), body: jsonEncode(body))
          .timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ HTTP POST Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('📡 PUT: $url');

      final response = await http
          .put(url, headers: _getHeaders(), body: jsonEncode(body))
          .timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ HTTP PUT Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('📡 DELETE: $url');

      final response = await http
          .delete(url, headers: _getHeaders())
          .timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ HTTP DELETE Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> multipartPost(
    String endpoint, {
    required File file,
    String fileField = 'image',
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('📡 MULTIPART POST: $url');
      debugPrint('📦 File: ${file.path}');
      debugPrint('🔐 Token set: ${_token != null ? '✅ Yes' : '❌ No'}');
      if (_token != null) {
        debugPrint('🔐 Token: ${_token!.substring(0, 20)}...');
      }

      final request = http.MultipartRequest('POST', url);

      // Add Authorization header
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
        debugPrint('📋 Headers: Authorization header added');
      } else {
        debugPrint('⚠️ WARNING: No token available for upload!');
      }

      // Detect image MIME type from file extension
      final fileExtension = file.path.toLowerCase().split('.').last;
      final mimeType = _getMimeType(fileExtension);
      debugPrint('📸 File extension: $fileExtension, MIME type: $mimeType');

      request.files.add(
        await http.MultipartFile.fromPath(
          fileField,
          file.path,
          contentType: mimeType,
        ),
      );

      final streamed = await request.send().timeout(
        AppConfig.connectionTimeout,
      );
      final response = await http.Response.fromStream(streamed);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ HTTP MULTIPART POST Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static MediaType _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg'); // Default to JPEG
    }
  }

  static dynamic _handleResponse(http.Response response) {
    debugPrint('📥 Response Status: ${response.statusCode}');
    final bodyPreview = response.body.length > 200
        ? response.body.substring(0, 200)
        : response.body;
    debugPrint('📥 Response Body: $bodyPreview...');

    // Check if response is HTML (error page)
    if (response.body.trim().startsWith('<!DOCTYPE') ||
        response.body.trim().startsWith('<html')) {
      debugPrint('❌ HTML Error Response detected');
      debugPrint('📥 Full HTML: ${response.body}');
      throw Exception(
        'Server error: ${response.statusCode} - Backend returned HTML error',
      );
    }

    try {
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else if (response.statusCode == 401) {
        _token = null;
        debugPrint('🔒 Unauthorized - Token cleared');
        throw Exception(
          'Unauthorized: ${jsonResponse['message'] ?? 'Please login again'}',
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'Not found: ${jsonResponse['message'] ?? 'Resource not found'}',
        );
      } else {
        throw Exception(jsonResponse['message'] ?? 'An error occurred');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      debugPrint('❌ JSON Parse Error: $e');
      throw Exception('Failed to parse response: ${response.body}');
    }
  }
}
