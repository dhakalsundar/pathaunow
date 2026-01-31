import 'package:flutter/material.dart';
import '../../domain/entities/uploaded_image_entity.dart';

class ImageGrid extends StatelessWidget {
  final List<UploadedImageEntity> images;
  const ImageGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      // Show a sample image from Picsum so UI isn't empty and user can see output
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://picsum.photos/600',
                width: 240,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No images yet — use the + button to upload a sample image',
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: images.length,
      itemBuilder: (_, i) {
        final img = images[i];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            img.url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Center(child: Icon(Icons.broken_image)),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    );
  }
}
