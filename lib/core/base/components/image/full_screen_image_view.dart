import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullScreenImageView extends StatelessWidget {
  final String imagePath;
  final String? label;

  const FullScreenImageView({super.key, required this.imagePath, this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 6.0,
              child: _buildImage(context),
            ),
          ),

          // Close button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Get.back(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.close, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Optional label at top center
          if (label != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    label!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: size.width,
        height: size.height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: 80,
        ),
      );
    }
    if (imagePath.isNotEmpty) {
      return Image.file(
        io.File(imagePath),
        width: size.width,
        height: size.height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: 80,
        ),
      );
    }
    return const Icon(Icons.image_not_supported, color: Colors.grey, size: 80);
  }
}
