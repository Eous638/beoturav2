import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/image_resolver_service.dart';

/// A widget that renders rich content from a document structure
/// similar to the one used in KeystoneJS/GraphCMS content.
class DocumentRenderer extends ConsumerWidget {
  final Map<String, dynamic> content;
  final TextStyle? defaultTextStyle;

  const DocumentRenderer({
    super.key,
    required this.content,
    this.defaultTextStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if document exists in the content
    final document = content['document'] as List?;
    if (document == null || document.isEmpty) {
      return const Center(
        child: Text('No content available.'),
      );
    }
    
    // Generate widgets based on document structure
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: document.map((block) {
        return _renderBlock(context, ref, block);
      }).toList(),
    );
  }

  Widget _renderBlock(BuildContext context, WidgetRef ref, dynamic block) {
    final type = block['type'] as String?;
    final children = block['children'] as List?;
    
    if (type == null) {
      return const SizedBox.shrink();
    }
    
    // Handle different block types
    switch (type) {
      case 'heading':
        return _renderHeading(context, block, children ?? []);
      case 'paragraph':
        return _renderParagraph(context, children ?? []);
      case 'unordered-list':
        return _renderUnorderedList(context, children ?? []);
      case 'ordered-list':
        return _renderOrderedList(context, children ?? []);
      case 'divider':
        return _renderDivider(context);
      case 'blockquote':
        return _renderBlockquote(context, children ?? []);
      case 'code':
        return _renderCodeBlock(context, children ?? []);
      case 'layout':
        return _renderLayout(context, ref, block);
      case 'component-block':
        return _renderComponentBlock(context, ref, block);
      default:
        // For unsupported block types, show the text content
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            _getTextFromChildren(children ?? []),
            style: defaultTextStyle ?? Theme.of(context).textTheme.bodyMedium,
          ),
        );
    }
  }

  Widget _renderHeading(BuildContext context, dynamic block, List children) {
    final level = block['level'] as int? ?? 1;
    final text = _getTextFromChildren(children);
    
    // Select text style based on heading level
    TextStyle? style;
    switch (level) {
      case 1:
        style = Theme.of(context).textTheme.headlineLarge;
        break;
      case 2:
        style = Theme.of(context).textTheme.headlineMedium;
        break;
      case 3:
        style = Theme.of(context).textTheme.headlineSmall;
        break;
      case 4:
      case 5:
      case 6:
        style = Theme.of(context).textTheme.titleLarge;
        break;
      default:
        style = Theme.of(context).textTheme.titleMedium;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(text, style: style),
    );
  }

  Widget _renderParagraph(BuildContext context, List children) {
    final spans = _buildTextSpans(context, children);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          style: defaultTextStyle ?? Theme.of(context).textTheme.bodyLarge,
          children: spans,
        ),
      ),
    );
  }

  Widget _renderUnorderedList(BuildContext context, List children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((item) {
          final itemChildren = item['children'] as List?;
          if (itemChildren == null || itemChildren.isEmpty) {
            return const SizedBox.shrink();
          }
          
          // Get content from list item
          final content = itemChildren.firstWhere(
            (child) => child['type'] == 'list-item-content',
            orElse: () => {'children': []}
          );
          
          final contentChildren = content['children'] as List?;
          if (contentChildren == null || contentChildren.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: defaultTextStyle ?? Theme.of(context).textTheme.bodyLarge,
                      children: _buildTextSpans(context, contentChildren),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _renderOrderedList(BuildContext context, List children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          final itemChildren = item['children'] as List?;
          if (itemChildren == null || itemChildren.isEmpty) {
            return const SizedBox.shrink();
          }
          
          // Get content from list item
          final content = itemChildren.firstWhere(
            (child) => child['type'] == 'list-item-content',
            orElse: () => {'children': []}
          );
          
          final contentChildren = content['children'] as List?;
          if (contentChildren == null || contentChildren.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}. ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: defaultTextStyle ?? Theme.of(context).textTheme.bodyLarge,
                      children: _buildTextSpans(context, contentChildren),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _renderDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(color: Colors.grey[400]),
    );
  }

  Widget _renderBlockquote(BuildContext context, List children) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            width: 4.0,
          ),
        ),
        color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((child) {
          if (child['type'] == 'paragraph') {
            return _renderParagraph(context, child['children'] as List);
          }
          return const SizedBox.shrink();
        }).toList(),
      ),
    );
  }

  Widget _renderCodeBlock(BuildContext context, List children) {
    final text = _getTextFromChildren(children);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14.0,
        ),
      ),
    );
  }

  Widget _renderLayout(BuildContext context, WidgetRef ref, dynamic block) {
    final layout = block['layout'] as List?;
    final layoutChildren = block['children'] as List?;
    
    if (layout == null || layoutChildren == null || layoutChildren.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Create a row with flexible widgets based on the layout proportions
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: layoutChildren.asMap().entries.map((entry) {
          final index = entry.key;
          final layoutArea = entry.value;
          final proportion = layout.length > index ? layout[index] as int : 1;
          
          return Flexible(
            flex: proportion,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (layoutArea['children'] as List? ?? []).map((child) {
                  return _renderBlock(context, ref, child);
                }).toList(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _renderComponentBlock(BuildContext context, WidgetRef ref, dynamic block) {
    final component = block['component'] as String?;
    
    if (component == null) {
      return const SizedBox.shrink();
    }
    
    // Handle specific component types
    switch (component) {
      case 'embedImage':
        return _renderEmbeddedImage(context, ref, block);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _renderEmbeddedImage(BuildContext context, WidgetRef ref, dynamic block) {
    final props = block['props'] as Map<String, dynamic>?;
    
    if (props == null || props['image'] == null) {
      return const SizedBox.shrink();
    }
    
    // Extract image ID from props
    final imageId = props['image']['id'] as String?;
    final altText = props['altText'] as String? ?? '';
    final caption = props['caption'] as String? ?? '';
    
    if (imageId == null) {
      return const SizedBox.shrink();
    }
    
    // Check if the image URL is already in the cache
    final cachedUrls = ref.watch(imageUrlCacheProvider);
    final cachedUrl = cachedUrls[imageId];
    
    if (cachedUrl != null) {
      // If we already have the URL, render the image directly
      return _buildImageWidget(context, cachedUrl, altText, caption);
    }
    
    // Let's fix the type error by not passing the ref parameter:
    // Instead, let's use the resolveImageUrl without the ref parameter
    // and handle caching separately
    return FutureBuilder<String?>(
      future: () async {
        final imageResolver = ref.read(imageResolverProvider);
        final url = await imageResolver.resolveImageUrl(imageId);
        
        // If we get a URL, cache it manually
        if (url != null) {
          ref.read(imageUrlCacheProvider.notifier).update((state) {
            final newState = Map<String, String>.from(state);
            newState[imageId] = url;
            return newState;
          });
        }
        
        return url;
      }(),
      builder: (context, snapshot) {
        // Rest of the method remains the same
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while fetching the image URL
          return Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // If we got a URL, render the image
          return _buildImageWidget(context, snapshot.data!, altText, caption);
        } else {
          // If we failed to get a URL, show a placeholder
          return Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                if (altText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      altText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          );
        }
      },
    );
  }
  
  Widget _buildImageWidget(BuildContext context, String imageUrl, String altText, String caption) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image: $error');
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                      if (altText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            altText,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                caption,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  String _getTextFromChildren(List children) {
    if (children.isEmpty) return '';
    
    return children.map((child) => child['text'] ?? '').join(' ');
  }

  List<TextSpan> _buildTextSpans(BuildContext context, List children) {
    return children.map((child) {
      final text = child['text'] as String? ?? '';
      final isBold = child['bold'] as bool? ?? false;
      final isItalic = child['italic'] as bool? ?? false;
      final hasUnderline = child['underline'] as bool? ?? false;
      final isStrikethrough = child['strikethrough'] as bool? ?? false;
      final isCode = child['code'] as bool? ?? false;
      final isKeyboard = child['keyboard'] as bool? ?? false;
      final isSubscript = child['subscript'] as bool? ?? false;
      final isSuperscript = child['superscript'] as bool? ?? false;
      
      return TextSpan(
        text: text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : null,
          fontStyle: isItalic ? FontStyle.italic : null,
          decoration: hasUnderline 
              ? TextDecoration.underline 
              : isStrikethrough 
                  ? TextDecoration.lineThrough 
                  : null,
          fontFamily: isCode || isKeyboard ? 'monospace' : null,
          backgroundColor: isKeyboard ? Colors.grey[200] : null,
          fontSize: isSubscript || isSuperscript 
              ? (defaultTextStyle?.fontSize ?? Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * 0.75
              : null,
          height: isSubscript ? 2.5 : (isSuperscript ? 0.75 : null),
        ),
      );
    }).toList();
  }
}
