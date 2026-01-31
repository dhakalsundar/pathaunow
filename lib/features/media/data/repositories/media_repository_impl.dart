import 'dart:io';
import 'package:pathau_now/features/media/data/datasources/media_remote_datasource.dart';

import '../../domain/entities/uploaded_image_entity.dart';
import '../../domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDatasource remote;
  MediaRepositoryImpl({required this.remote});

  @override
  Future<UploadedImageEntity> uploadImage(File imageFile) {
    return remote.uploadImage(imageFile);
  }

  @override
  Future<List<UploadedImageEntity>> listImages() {
    return remote.listImages();
  }
}
