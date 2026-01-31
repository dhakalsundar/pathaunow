import 'dart:io';
import 'package:pathau_now/core/api/api_client.dart';
import 'package:pathau_now/core/api/api_endpoints.dart';
import 'package:pathau_now/features/media/data/models/uploaded_image_model.dart';

class MediaRemoteDatasource {
  final ApiClient api;
  MediaRemoteDatasource({required this.api});

  Future<UploadedImageModel> uploadImage(File file) async {
    final res = await api.multipartPost(ApiEndpoints.uploadImage, file: file);
    final data = Map<String, dynamic>.from(res['data'] as Map);
    return UploadedImageModel.fromJson(data);
  }

  Future<List<UploadedImageModel>> listImages() async {
    final res = await api.get(ApiEndpoints.listImages);
    final list = (res['data'] as List).cast<dynamic>();

    return list
        .map(
          (e) =>
              UploadedImageModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }
}
