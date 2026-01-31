import '../entities/uploaded_image_entity.dart';
import '../repositories/media_repository.dart';

class ListImagesUsecase {
  final MediaRepository repo;
  ListImagesUsecase(this.repo);

  Future<List<UploadedImageEntity>> call() => repo.listImages();
}
