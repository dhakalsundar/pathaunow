import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse("$baseUrl$path");

    final res = await _client.post(
      uri,
      headers: {"Content-Type": "application/json", ...?headers},
      body: body == null ? null : jsonEncode(body),
    );

    Map<String, dynamic> decodeToMap(dynamic decoded) {
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return {"data": decoded};
    }

    dynamic decoded;
    if (res.body.isNotEmpty) {
      try {
        decoded = jsonDecode(res.body);
      } catch (_) {
        decoded = {"message": res.body};
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded == null ? <String, dynamic>{} : decodeToMap(decoded);
    }

    // Try to extract a message from response
    final msg = (decoded is Map && decoded["message"] != null)
        ? decoded["message"].toString()
        : "Request failed (${res.statusCode})";

    throw Exception(msg);
  }
}
