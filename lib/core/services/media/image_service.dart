import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ImageUploadResponse {
  final bool success;
  final String? id;
  final String? filename;
  final String? url;
  final DateTime? createdAt;
  final String? message;

  ImageUploadResponse({
    required this.success,
    this.id,
    this.filename,
    this.url,
    this.createdAt,
    this.message,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageUploadResponse(
      success: json['success'] ?? false,
      id: json['data']?['id'],
      filename: json['data']?['filename'],
      url: json['data']?['url'],
      createdAt: json['data']?['createdAt'] != null
          ? DateTime.parse(json['data']['createdAt'])
          : null,
      message: json['message'],
    );
  }
}

class ImageModel {
  final String id;
  final String filename;
  final String url;
  final DateTime createdAt;

  ImageModel({
    required this.id,
    required this.filename,
    required this.url,
    required this.createdAt,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] ?? '',
      filename: json['filename'] ?? '',
      url: json['url'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }
}

class ImageService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/media';
    }

    if (Platform.isAndroid || Platform.isIOS) {
      return 'http://localhost:3000/api';
    }

    return 'http://localhost:3000/api';
  }

  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static Map<String, String> _getHeaders() {
    final headers = <String, String>{};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<ImageUploadResponse> uploadImage(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      final uri = Uri.parse('$baseUrl/upload');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(_getHeaders())
        ..files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        return ImageUploadResponse.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        throw Exception(jsonResponse['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      return ImageUploadResponse(
        success: false,
        message: 'Error uploading image: $e',
      );
    }
  }

  static Future<ImageUploadResponse> uploadImageFromPicker() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return ImageUploadResponse(
          success: false,
          message: 'No image selected',
        );
      }

      return uploadImage(File(pickedFile.path));
    } catch (e) {
      return ImageUploadResponse(
        success: false,
        message: 'Error picking image: $e',
      );
    }
  }

  static Future<ImageUploadResponse> uploadImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return ImageUploadResponse(
          success: false,
          message: 'No image captured',
        );
      }

      return uploadImage(File(pickedFile.path));
    } catch (e) {
      return ImageUploadResponse(
        success: false,
        message: 'Error capturing image: $e',
      );
    }
  }

  static Future<List<ImageModel>> getImages() async {
    try {
      final uri = Uri.parse('$baseUrl/');
      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'] as List<dynamic>;
        return data
            .map((item) => ImageModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch images');
      }
    } catch (e) {
      throw Exception('Error fetching images: $e');
    }
  }

  static Future<File> downloadImage(String imageUrl, String fileName) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final directory = Directory.systemTemp;
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Failed to download image');
      }
    } catch (e) {
      throw Exception('Error downloading image: $e');
    }
  }

  static Future<void> deleteLocalImage(File imageFile) async {
    try {
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      throw Exception('Error deleting image: $e');
    }
  }
}
