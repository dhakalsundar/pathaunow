import 'dart:io';
import '../entities/uploaded_image_entity.dart';
import '../repositories/media_repository.dart';

class UploadImageUsecase {
  final MediaRepository repo;
  UploadImageUsecase(this.repo);

  Future<UploadedImageEntity> call(File file) => repo.uploadImage(file);
}
