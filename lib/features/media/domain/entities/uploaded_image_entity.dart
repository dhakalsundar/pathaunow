class UploadedImageEntity {
  final String id;
  final String filename;
  final String url;
  final DateTime createdAt;

  const UploadedImageEntity({
    required this.id,
    required this.filename,
    required this.url,
    required this.createdAt,
  });
}
