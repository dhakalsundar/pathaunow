import 'dart:io';
import '../entities/uploaded_image_entity.dart';

abstract class MediaRepository {
  Future<UploadedImageEntity> uploadImage(File imageFile);
  Future<List<UploadedImageEntity>> listImages();
}
