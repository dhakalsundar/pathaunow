import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse("$baseUrl$path");
    final res = await _client.get(uri, headers: headers);

    dynamic decoded;
    if (res.body.isNotEmpty) {
      try {
        decoded = jsonDecode(res.body);
      } catch (_) {
        decoded = {"message": res.body};
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return {"data": decoded};
    }

    final msg = (decoded is Map && decoded["message"] != null)
        ? decoded["message"].toString()
        : "GET failed (${res.statusCode})";

    throw Exception(msg);
  }

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

    dynamic decoded;
    if (res.body.isNotEmpty) {
      try {
        decoded = jsonDecode(res.body);
      } catch (_) {
        decoded = {"message": res.body};
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return {"data": decoded};
    }

    final msg = (decoded is Map && decoded["message"] != null)
        ? decoded["message"].toString()
        : "POST failed (${res.statusCode})";

    throw Exception(msg);
  }

  Future<Map<String, dynamic>> multipartPost(
    String path, {
    required File file,
    String fileField = "image",
    Map<String, String>? headers,
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse("$baseUrl$path");
    final request = http.MultipartRequest("POST", uri);

    if (headers != null) request.headers.addAll(headers);
    if (fields != null) request.fields.addAll(fields);

    request.files.add(await http.MultipartFile.fromPath(fileField, file.path));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    dynamic decoded;
    if (res.body.isNotEmpty) {
      try {
        decoded = jsonDecode(res.body);
      } catch (_) {
        decoded = {"message": res.body};
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return {"data": decoded};
    }

    final msg = (decoded is Map && decoded["message"] != null)
        ? decoded["message"].toString()
        : "Upload failed (${res.statusCode})";

    throw Exception(msg);
  }

  void dispose() => _client.close();
}
