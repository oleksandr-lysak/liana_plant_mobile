import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoGridPage extends StatefulWidget {
  const PhotoGridPage({Key? key}) : super(key: key);

  @override
  State<PhotoGridPage> createState() => _PhotoGridPageState();
}

class _PhotoGridPageState extends State<PhotoGridPage> {
  final ImagePicker _picker = ImagePicker();
  List<AssetEntity> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  Future<void> _loadGalleryImages() async {
    final PermissionState permitted =
        await PhotoManager.requestPermissionExtend();
    if (permitted.hasAccess) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );
      final List<AssetEntity> photos = await albums.first.getAssetListPaged(
        page: 0,
        size: 50, // Кількість фото, яку хочеш завантажити
      );
      setState(() {
        _photos = photos;
      });
    } else {
      // Обробка випадку, коли немає дозволу на доступ до галереї
    }
  }

  Future<void> _pickCameraImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        // Тут потрібно створити AssetEntity з нового фото і додати його до списку.
        // Однак, створення AssetEntity з нового фото не є простим завданням
        // в рамках бібліотеки photo_manager. Можливо, доведеться зберігати файл на диск
        // і потім сканувати його.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Grid')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemCount: _photos.length + 1, // +1 для іконки камери
          itemBuilder: (context, index) {
            if (index == 0) {
              return GestureDetector(
                onTap: _pickCameraImage,
                child: Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.camera_alt, size: 50),
                ),
              );
            } else {
              return FutureBuilder<File?>(
                future: _photos[index - 1].file,
                builder: (context, snapshot) {
                  final file = snapshot.data;
                  if (file == null) return const SizedBox();
                  return Image.file(
                    file,
                    fit: BoxFit.cover,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
