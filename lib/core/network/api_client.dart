import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pathau_now/core/error/exceptions.dart';
import 'package:pathau_now/config/app_config.dart';

class ApiClient {
  final String baseUrl;
  String? authToken;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  void setAuthToken(String token) {
    authToken = token;
  }

  void clearAuthToken() {
    authToken = null;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(uri, headers: _getHeaders(), body: jsonEncode(body))
          .timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(uri, headers: _getHeaders(), body: jsonEncode(body))
          .timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .delete(uri, headers: _getHeaders())
          .timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    try {
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonResponse['data'] ?? jsonResponse;
      } else if (response.statusCode == 404) {
        throw NotFoundException(
          message: jsonResponse['message'] ?? 'Not found',
        );
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          message: jsonResponse['message'] ?? 'Unauthorized',
        );
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw ValidationException(
          message: jsonResponse['message'] ?? 'Validation error',
        );
      } else {
        throw ServerException(
          message: jsonResponse['message'] ?? 'Server error',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  void _handleException(dynamic error) {
    if (error is NetworkException || error is AppException) {
      throw error;
    }
    throw NetworkException(message: error.toString());
  }
}
