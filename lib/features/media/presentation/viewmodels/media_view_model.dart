import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/uploaded_image_entity.dart';
import '../../domain/usecases/list_images_usecase.dart';
import '../../domain/usecases/upload_image_usecase.dart';

class MediaViewModel extends ChangeNotifier {
  final UploadImageUsecase uploadUsecase;
  final ListImagesUsecase listUsecase;

  MediaViewModel({required this.uploadUsecase, required this.listUsecase});

  bool _loading = false;
  String? _error;
  List<UploadedImageEntity> _images = [];

  bool get loading => _loading;
  String? get error => _error;
  List<UploadedImageEntity> get images => _images;

  Future<void> loadImages() async {
    _setLoading(true);
    _error = null;
    try {
      _images = await listUsecase();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> upload(File file) async {
    _setLoading(true);
    _error = null;
    try {
      final uploaded = await uploadUsecase(file);
      _images = [uploaded, ..._images];
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
