import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/blog.dart';
import '../providers/language_provider.dart';
import '../providers/blogs_provider.dart';
import '../enums/language_enum.dart';
import '../widgets/document_renderer.dart'; // Import the document renderer

class BlogDetailScreen extends HookConsumerWidget {
  final Blog blog;

  const BlogDetailScreen({
    super.key,
    required this.blog,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final title = language == Language.english ? blog.titleEn : blog.titleSr;
    final content = language == Language.english ? blog.contentEn : blog.contentSr;
    final dateFormat = blog.createdAt != null 
        ? '${blog.createdAt!.day}/${blog.createdAt!.month}/${blog.createdAt!.year}' 
        : '';

    // We can use the blogDetailProvider to get complete blog details if needed
    // This could be triggered for example if content fields are empty
    if ((content['document'] as List?)?.isEmpty ?? true) {
      // Use the blogDetailProvider to fetch full blog details
      final detailResult = ref.watch(blogDetailProvider(blog.id));
      
      return detailResult.when(
        data: (detailedBlog) {
          if (detailedBlog != null) {
            // Use the detailed blog data
            final detailedContent = language == Language.english 
                ? detailedBlog.contentEn 
                : detailedBlog.contentSr;
            
            return _buildDetailScreen(context, title, detailedBlog, detailedContent, dateFormat);
          } else {
            // If detailed blog is null, use the original blog data
            return _buildDetailScreen(context, title, blog, content, dateFormat);
          }
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: Text(title), centerTitle: true),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 40, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading blog details', style: Theme.of(context).textTheme.titleMedium),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // If content is available, just show the detail screen
    return _buildDetailScreen(context, title, blog, content, dateFormat);
  }
  
  // Extracted the detail screen UI to a separate method for reuse
  Widget _buildDetailScreen(
    BuildContext context, 
    String title, 
    Blog blog, 
    Map<String, dynamic> content,
    String dateFormat,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Only show image if imageUrl is not null and not empty
              if (blog.imageUrl != null && blog.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    blog.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading detail image: $error');
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                
              const SizedBox(height: 16),
              
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              
              if (blog.createdAt != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    dateFormat,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                
              const SizedBox(height: 16),
              
              // Use the ConsumerWidget-based DocumentRenderer
              DocumentRenderer(content: content),
            ],
          ),
        ),
      ),
    );
  }
}
