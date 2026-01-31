import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pathau_now/core/api/api_client.dart';
import 'package:pathau_now/core/api/api_endpoints.dart';
import 'package:pathau_now/features/media/data/datasources/media_remote_datasource.dart';
import '../../data/repositories/media_repository_impl.dart';
import '../../domain/usecases/list_images_usecase.dart';
import '../../domain/usecases/upload_image_usecase.dart';
import '../viewmodels/media_view_model.dart';
import '../widgets/image_grid.dart';

class MediaPage extends StatefulWidget {
  static const routeName = "/media";
  final MediaViewModel? injectedVm; // for widget tests

  const MediaPage({super.key, this.injectedVm});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  late final MediaViewModel vm;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    vm =
        widget.injectedVm ??
        MediaViewModel(
          uploadUsecase: UploadImageUsecase(
            MediaRepositoryImpl(
              remote: MediaRemoteDatasource(
                api: ApiClient(baseUrl: ApiEndpoints.baseUrl),
              ),
            ),
          ),
          listUsecase: ListImagesUsecase(
            MediaRepositoryImpl(
              remote: MediaRemoteDatasource(
                api: ApiClient(baseUrl: ApiEndpoints.baseUrl),
              ),
            ),
          ),
        );

    vm.loadImages();
  }

  Future<void> _pickAndUpload() async {
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    await vm.upload(File(picked.path));

    if (!mounted) return;
    if (vm.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.error!)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully")),
      );
    }
  }

  Future<void> _uploadSampleImage() async {
    // Download a sample image from Picsum and upload it
    const sampleUrl = 'https://picsum.photos/800';

    try {
      final client = http.Client();
      final response = await client.get(Uri.parse(sampleUrl));
      client.close();
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch sample image');
      }

      final bytes = response.bodyBytes;
      final tempDir = Directory.systemTemp;
      final file = File(
        '${tempDir.path}/sample_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(bytes);

      await vm.upload(file);

      if (!mounted) return;
      if (vm.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(vm.error!)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample image uploaded successfully')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Upload & View Images"),
            actions: [
              IconButton(
                key: const Key("refresh_btn"),
                icon: const Icon(Icons.refresh),
                onPressed: vm.loading ? null : vm.loadImages,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            key: const Key("upload_fab"),
            onPressed: vm.loading
                ? null
                : () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Pick from gallery'),
                                onTap: () {
                                  Navigator.of(ctx).pop();
                                  _pickAndUpload();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.image_search),
                                title: const Text('Upload sample image (web)'),
                                onTap: () {
                                  Navigator.of(ctx).pop();
                                  _uploadSampleImage();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.cancel),
                                title: const Text('Cancel'),
                                onTap: () => Navigator.of(ctx).pop(),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
            child: const Icon(Icons.upload),
          ),
          body: Column(
            children: [
              if (vm.loading) const LinearProgressIndicator(),
              if (vm.error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    vm.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(child: ImageGrid(images: vm.images)),
            ],
          ),
        );
      },
    );
  }
}
