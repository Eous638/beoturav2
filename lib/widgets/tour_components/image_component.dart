import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Component for displaying images with captions in the tour
class ImageComponent extends StatelessWidget {
  final String src;
  final String? caption;
  final bool fullWidth;
  final double? height;
  final BoxFit fit;
  final bool isNetworkImage;

  const ImageComponent({
    super.key,
    required this.src,
    this.caption,
    this.fullWidth = true,
    this.height,
    this.fit = BoxFit.cover,
    this.isNetworkImage = false, required String imageUrl, required TextStyle captionStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      margin: const EdgeInsets.symmetric(vertical: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Hero(
            tag: 'tour_image_$src',
            child: GestureDetector(
              onTap: () => _showFullScreenImage(context),
              child: _buildImage(),
            ),
          ),

          // Caption if provided
          if (caption != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.black.withOpacity(0.7),
              child: Text(
                caption!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final imageWidget = isNetworkImage
        ? CachedNetworkImage(
            imageUrl: src,
            fit: fit,
            height: height,
            width: fullWidth ? double.infinity : null,
            placeholder: (context, url) => Container(
              height: height ?? 200,
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: height ?? 200,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          )
        : Image.asset(
            src,
            fit: fit,
            height: height,
            width: fullWidth ? double.infinity : null,
            errorBuilder: (context, error, stackTrace) => Container(
              height: height ?? 200,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          );

    return imageWidget;
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Hero(
                tag: 'tour_image_$src',
                child: _buildImage(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
