import 'dart:io';

abstract class ImageRepository {
  Future<List<String>> uploadImages(List<File> images);

  Future<void> deleteImages(List<String> imageUrls);
}
