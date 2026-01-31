import '../../domain/entities/uploaded_image_entity.dart';

class UploadedImageModel extends UploadedImageEntity {
  const UploadedImageModel({
    required super.id,
    required super.filename,
    required super.url,
    required super.createdAt,
  });

  factory UploadedImageModel.fromJson(Map<String, dynamic> json) {
    return UploadedImageModel(
      id: json['id'].toString(),
      filename: json['filename'].toString(),
      url: json['url'].toString(),
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }
}
