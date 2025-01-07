import 'dart:io';
import 'package:flutter/material.dart';

class ProductCardImage extends StatelessWidget {
  final String image;

  const ProductCardImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: image.isNotEmpty
          ? (image.startsWith('http')
              ? Image.network(
                  image,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                )
              : _loadImageFromFile(image))
          : const Icon(Icons.image, size: 140, color: Colors.grey),
    );
  }

  Widget _loadImageFromFile(String path) {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file,
          width: double.infinity, height: 220, fit: BoxFit.cover);
    } else {
      return const Icon(Icons.image, size: 140, color: Colors.grey);
    }
  }
}
