import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../l10n/localization_helper.dart';
import '../models/blog.dart';
import '../providers/blogs_provider.dart';
import '../providers/language_provider.dart';
import '../enums/language_enum.dart';
import '../enums/story_type_enum.dart'; // Import StoryType
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
        title: Text(l10n.translate('Stories')),
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
                    const Icon(Icons.article_outlined,
                        size: 60, color: Colors.grey),
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
                // Pass blog.storyType to _buildBlogCard
                return _buildBlogCard(context, blog, language, blog.storyType,
                    () {
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
    StoryType storyType,
    VoidCallback onTap,
  ) {
    final title = language == Language.english ? blog.titleEn : blog.titleSr;
    final dateFormat = blog.createdAt != null
        ? '${blog.createdAt!.day}/${blog.createdAt!.month}/${blog.createdAt!.year}'
        : '';
    final badgeText = _getStoryTypeBadgeText(storyType, language);

    // Card dimensions - Made bigger
    double cardWidth =
        MediaQuery.of(context).size.width * 0.92; // Slightly wider
    double cardHeight = cardWidth * 0.75; // Taller cards
    double imageHeight =
        cardHeight * 0.65; // Image takes 65% of new card height

    // Base styling
    Color cardBackgroundColor = const Color(0xFF131313);
    Color titleColor = Colors.grey.shade200;
    Color dateColor = Colors.grey.shade500;
    Color badgeTextColor = Colors.black;
    Color badgeBackgroundColor = Colors.grey.shade400;
    Color buttonIconColor = Colors.grey.shade400;

    // Accent colors based on StoryType
    Color accentColor = Colors.grey.shade700;

    switch (storyType) {
      case StoryType.INTERVIEW:
        accentColor = Colors.purpleAccent.shade200;
        badgeBackgroundColor = Colors.purpleAccent.shade100.withOpacity(0.85);
        badgeTextColor = Colors.purple.shade900;
        break;
      case StoryType.TOUR_PROMOTION:
        accentColor = Colors.tealAccent.shade200;
        badgeBackgroundColor = Colors.tealAccent.shade100.withOpacity(0.85);
        badgeTextColor = Colors.teal.shade900;
        break;
      case StoryType.LANDMARK_SPOTLIGHT:
        accentColor = Colors.amber.shade400;
        badgeBackgroundColor = Colors.amber.shade200.withOpacity(0.85);
        badgeTextColor = Colors.orange.shade900;
        break;
      case StoryType.VENUE_SPOTLIGHT:
        accentColor = Colors.cyanAccent.shade200;
        badgeBackgroundColor = Colors.cyanAccent.shade100.withOpacity(0.85);
        badgeTextColor = Colors.cyan.shade900;
        break;
      case StoryType.GENERAL_STORY:
        // Uses default accent and badge colors
        badgeBackgroundColor = Colors.grey.shade700;
        badgeTextColor = Colors.white;
        break;
    }
    titleColor = accentColor; // Title uses the accent color for vibrancy
    buttonIconColor = accentColor;

    BoxDecoration cardDecoration = BoxDecoration(
      color: cardBackgroundColor,
      borderRadius:
          BorderRadius.circular(14), // Slightly more rounded for bigger card
      // No border, as requested
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.55), // Slightly stronger shadow
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.only(
          bottom: 24), // Increased margin for bigger cards
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (blog.imageUrl != null && blog.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                  child: Image.network(
                    blog.imageUrl!,
                    height: imageHeight,
                    width: cardWidth,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight,
                        width: cardWidth,
                        color: Colors.grey.shade900,
                        child: Icon(Icons.broken_image_outlined,
                            size: 40,
                            color: Colors
                                .grey.shade700), // Larger placeholder icon
                      );
                    },
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      14, 10, 14, 10), // Increased padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    // Larger title
                                    color: titleColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.1,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeText.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4), // Slightly larger badge padding
                              decoration: BoxDecoration(
                                color: badgeBackgroundColor,
                                borderRadius: BorderRadius.circular(
                                    5), // Slightly larger badge radius
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  color: badgeTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10, // Larger badge font
                                ),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            dateFormat,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: dateColor,
                                      fontSize: 11, // Larger date font
                                    ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onTap,
                              borderRadius: BorderRadius.circular(
                                  22), // Larger splash radius
                              splashColor: buttonIconColor.withOpacity(0.2),
                              highlightColor: buttonIconColor.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    6.0), // Larger padding for icon
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: buttonIconColor,
                                  size: 18, // Larger icon
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStoryTypeBadgeText(StoryType storyType, Language language) {
    switch (storyType) {
      case StoryType.INTERVIEW:
        return language == Language.english ? 'INTERVIEW' : 'INTERVJU';
      case StoryType.TOUR_PROMOTION:
        return language == Language.english ? 'TOUR' : 'TURA'; // Shortened
      case StoryType.LANDMARK_SPOTLIGHT:
        return language == Language.english
            ? 'LANDMARK'
            : 'OBJEKAT'; // Shortened
      case StoryType.VENUE_SPOTLIGHT:
        return language == Language.english ? 'VENUE' : 'LOKAL';
      case StoryType.GENERAL_STORY:
        return language == Language.english
            ? 'STORY'
            : 'PRIČA'; // General badge
    }
  }
}
