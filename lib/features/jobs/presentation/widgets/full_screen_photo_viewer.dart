import 'dart:io';

import 'package:flutter/material.dart';

class FullScreenPhotoViewer extends StatelessWidget {
  const FullScreenPhotoViewer({required this.imageSource, super.key});

  final String imageSource;

  bool get _isNetwork =>
      imageSource.startsWith('http://') || imageSource.startsWith('https://');

  static Future<void> show(BuildContext context, String imageSource) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => FullScreenPhotoViewer(imageSource: imageSource),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: _isNetwork
              ? Image.network(imageSource, fit: BoxFit.contain)
              : Image.file(File(imageSource), fit: BoxFit.contain),
        ),
      ),
    );
  }
}
