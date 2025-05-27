import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../l10n/localization_helper.dart';
import '../models/blog.dart';
import '../providers/blogs_provider.dart';
import '../providers/language_provider.dart';
import '../enums/language_enum.dart';
import 'blog_detail_screen.dart';

class BlogScreen extends HookConsumerWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = LocalizationHelper(ref);
    final blogsState = ref.watch(blogsProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('blog')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(blogsProvider.notifier).fetchBlogs();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: blogsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  l10n.translate('error_loading_blogs'),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Error: ${error.toString()}',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(blogsProvider.notifier).fetchBlogs();
                  },
                  child: Text(l10n.translate('try_again')),
                ),
              ],
            ),
          ),
          data: (blogs) {
            if (blogs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.article_outlined, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      l10n.translate('no_blogs_available'),
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                final blog = blogs[index];
                return _buildBlogCard(context, blog, language, () {
                  // Navigate to blog detail screen, passing the blog ID to the detailed provider if needed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlogDetailScreen(blog: blog),
                    ),
                  );
                  
                  // Prefetch the detailed blog content if needed
                  ref.read(blogDetailProvider(blog.id));
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlogCard(
    BuildContext context, 
    Blog blog, 
    Language language,
    VoidCallback onTap,
  ) {
    final title = language == Language.english ? blog.titleEn : blog.titleSr;
    final dateFormat = blog.createdAt != null 
        ? '${blog.createdAt!.day}/${blog.createdAt!.month}/${blog.createdAt!.year}' 
        : '';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Only show image container if imageUrl is not null
            if (blog.imageUrl != null && blog.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  blog.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading image: $error');
                    return Container(
                      height: 120, // Smaller height for error state
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_not_supported, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            language == Language.english ? 'Image not available' : 'Slika nije dostupna',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (blog.createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        dateFormat,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: onTap,
                        child: Row(
                          children: [
                            Text(language == Language.english ? 'Read more' : 'Pročitaj više'),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
