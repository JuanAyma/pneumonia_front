import 'dart:io' as io;
import 'package:flutter/material.dart';

class XRayImage extends StatelessWidget {
  final String imagePath;
  final double height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const XRayImage({
    super.key,
    required this.imagePath,
    required this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // For contain mode, add a black background so letterbox areas look clean
    final image = _buildImage();
    final child = fit == BoxFit.contain
        ? Container(
            width: double.infinity,
            height: height,
            color: Colors.black,
            child: image,
          )
        : image;
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _buildImage() {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _loading(),
      );
    }
    if (imagePath.isNotEmpty) {
      return Image.file(
        io.File(imagePath),
        width: double.infinity,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        width: double.infinity,
        height: height,
        color: Colors.grey.withOpacity(0.08),
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
        ),
      );

  Widget _loading() => Container(
        width: double.infinity,
        height: height,
        color: Colors.grey.withOpacity(0.08),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
}
