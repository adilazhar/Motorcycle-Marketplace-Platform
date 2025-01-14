import 'dart:io';
import 'package:bike_listing/src/fetures/listing/data/image_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorageImageRepository implements ImageRepository {
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  FirebaseStorageImageRepository(this._storage);

  @override
  Future<List<String>> uploadImages(List<File> images) async {
    if (images.isEmpty) return [];

    final List<String> uploadedUrls = [];

    try {
      for (final imageFile in images) {
        final compressedFile = await _compressImage(imageFile);
        if (compressedFile == null) continue;

        final String fileName = '${_uuid.v4()}.jpg';
        final Reference ref = _storage.ref().child('listings/$fileName');

        final UploadTask uploadTask = ref.putFile(
          compressedFile,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'compressed': 'true'},
          ),
        );

        final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        uploadedUrls.add(downloadUrl);

        await compressedFile.delete();
      }

      return uploadedUrls;
    } catch (e) {
      if (uploadedUrls.isNotEmpty) {
        await deleteImages(uploadedUrls);
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteImages(List<String> imageUrls) async {
    if (imageUrls.isEmpty) return;

    final List<Future<void>> deletionTasks = [];

    for (final url in imageUrls) {
      try {
        final ref = _storage.refFromURL(url);
        deletionTasks.add(ref.delete());
      } catch (e) {
        debugPrint('Error deleting image: $url - ${e.toString()}');
      }
    }

    await Future.wait(deletionTasks);
  }

  Future<File?> _compressImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      img.Image compressedImage = image;
      if (image.width > 1920 || image.height > 1920) {
        compressedImage = img.copyResize(
          image,
          width: image.width > image.height ? 1920 : null,
          height: image.height >= image.width ? 1920 : null,
        );
      }

      final compressedBytes = img.encodeJpg(compressedImage, quality: 70);

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${_uuid.v4()}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      return tempFile;
    } catch (e) {
      debugPrint('Error compressing image: ${e.toString()}');
      return null;
    }
  }
}
