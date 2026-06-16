import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickService {
  ImagePickService._();

  static final ImagePicker _imagePicker = ImagePicker();

  static Future<String?> pickCameraImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (image == null) {
        return null;
      }
      return image.path;
    } on PlatformException {
      return null;
    }
  }

  static Future<String?> pickGalleryImage() async {
    final images = await pickGalleryImages(maxCount: 1);
    if (images.isEmpty) {
      return null;
    }
    return images.first;
  }

  static Future<List<String>> pickGalleryImages({required int maxCount}) async {
    if (maxCount <= 0) {
      return const [];
    }

    if (Platform.isAndroid) {
      return _pickMultipleWithFilePicker(maxCount);
    }

    return _pickMultipleWithImagePicker(maxCount);
  }

  static Future<void> recoverLostData({
    required void Function(String path) onRecovered,
  }) async {
    try {
      final response = await _imagePicker.retrieveLostData();
      if (response.isEmpty) {
        return;
      }

      final file = response.file;
      if (file != null && file.path.isNotEmpty) {
        onRecovered(file.path);
      }
    } on PlatformException {
      // No lost picker session to recover.
    }
  }

  static Future<List<String>> _pickMultipleWithFilePicker(int maxCount) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: maxCount > 1,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return const [];
    }

    final paths = <String>[];
    for (final picked in result.files.take(maxCount)) {
      final path = await _resolvePickedFilePath(picked);
      if (path != null) {
        paths.add(path);
      }
    }

    return paths;
  }

  static Future<List<String>> _pickMultipleWithImagePicker(int maxCount) async {
    if (maxCount == 1) {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (image == null) {
        return const [];
      }
      return [image.path];
    }

    final images = await _imagePicker.pickMultiImage(
      limit: maxCount,
      imageQuality: 85,
    );

    return images.map((image) => image.path).toList();
  }

  static Future<String?> _resolvePickedFilePath(PlatformFile picked) async {
    final path = picked.path;
    if (path != null && path.isNotEmpty) {
      return path;
    }

    final bytes = picked.bytes;
    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    final tempDir = Directory.systemTemp;
    final extension = picked.extension?.isNotEmpty == true
        ? picked.extension!
        : 'jpg';
    final tempFile = File(
      '${tempDir.path}/picked_${DateTime.now().millisecondsSinceEpoch}.$extension',
    );
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile.path;
  }
}
