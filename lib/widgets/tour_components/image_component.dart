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
    this.isNetworkImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: fullWidth ? double.infinity : null,
      margin: const EdgeInsets.symmetric(vertical: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2), // Use theme shadow color
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
              child: _buildImage(context), // Pass context
            ),
          ),

          // Caption if provided
          if (caption != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: theme.colorScheme.surface
                  .withOpacity(0.7), // Gunmetal with opacity
              child: Text(
                caption!,
                style: theme.textTheme.bodySmall?.copyWith(
                  // Use theme text style
                  color: theme.colorScheme.onSurface, // White text
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    // Add context parameter
    final theme = Theme.of(context); // Now context is available
    final placeholderColor =
        theme.colorScheme.surface.withOpacity(0.5); // Gunmetal tint
    final errorIconColor =
        theme.colorScheme.onSurface.withOpacity(0.7); // White tint

    final imageWidget = isNetworkImage
        ? CachedNetworkImage(
            imageUrl: src.isNotEmpty
                ? src
                : 'https://source.unsplash.com/random/800x600?city,historic', // Use Unsplash for empty src
            fit: fit,
            height: height,
            width: fullWidth ? double.infinity : null,
            placeholder: (context, url) => Container(
              height: height ?? 200,
              color: placeholderColor,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: height ?? 200,
              color: placeholderColor,
              child: Icon(Icons.broken_image, color: errorIconColor, size: 40),
            ),
          )
        : Image.asset(
            src.isNotEmpty
                ? src
                : 'images/beotura_logo.png', // Fallback to a local asset if src is empty for asset images
            fit: fit,
            height: height,
            width: fullWidth ? double.infinity : null,
            errorBuilder: (context, error, stackTrace) => Container(
              height: height ?? 200,
              color: placeholderColor,
              child: Icon(Icons.broken_image, color: errorIconColor, size: 40),
            ),
          );

    return imageWidget;
  }

  void _showFullScreenImage(BuildContext context) {
    // This context is from the onTap callback
    final theme = Theme.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: theme
              .scaffoldBackgroundColor, // Smoky black for fullscreen background
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme:
                IconThemeData(color: theme.colorScheme.onSurface), // White icon
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Hero(
                tag: 'tour_image_$src',
                child: _buildImage(context), // Pass context
              ),
            ),
          ),
        ),
      ),
    );
  }
}
