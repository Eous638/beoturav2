import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/blog.dart';
import '../graphql/blog_queries.dart';
import '../services/graphql_client.dart';

final blogsProvider = StateNotifierProvider<BlogsNotifier, AsyncValue<List<Blog>>>((ref) {
  return BlogsNotifier(ref);
});

final selectedBlogProvider = StateProvider<Blog?>((ref) => null);

// Provider for fetching a specific blog by ID
final blogDetailProvider = FutureProvider.family<Blog?, String>((ref, id) async {
  return ref.read(blogsProvider.notifier).fetchBlogDetails(id);
});

class BlogsNotifier extends StateNotifier<AsyncValue<List<Blog>>> {
  final Ref ref;

  BlogsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    try {
      state = const AsyncValue.loading();
      
      // Get the GraphQL client from the provider
      final client = ref.read(graphQLClientProvider);
      final graphQLService = GraphQLService(client);
      
      // Perform the query using the service
      final result = await graphQLService.performQuery(BlogQueries.getBlogs);
      
      if (result.hasException) {
        debugPrint('GraphQL errors: ${result.exception.toString()}');
        throw result.exception!;
      }

      // Check if blogs data exists in the response
      if (result.data == null || result.data!['blogs'] == null) {
        throw Exception('No blog data in response');
      }

      final blogsJson = result.data!['blogs'] as List;
      final blogs = blogsJson.map((blogJson) => Blog.fromJson(blogJson as Map<String, dynamic>)).toList();
      
      debugPrint('Successfully loaded ${blogs.length} blogs from server');
      state = AsyncValue.data(blogs);
    } catch (error, stackTrace) {
      debugPrint('Error fetching blogs: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Blog?> fetchBlogDetails(String id) async {
    try {
      // Get the GraphQL client from the provider
      final client = ref.read(graphQLClientProvider);
      final graphQLService = GraphQLService(client);
      
      // Perform the query using the service with variables
      final result = await graphQLService.performQuery(
        BlogQueries.getBlogDetails,
        variables: {'id': id},
      );
      
      if (result.hasException) {
        debugPrint('GraphQL errors: ${result.exception.toString()}');
        throw result.exception!;
      }

      if (result.data == null || result.data!['blog'] == null) {
        debugPrint('No blog found with ID: $id');
        return null;
      }
      
      return Blog.fromJson(result.data!['blog'] as Map<String, dynamic>);
    } catch (error) {
      debugPrint('Error fetching blog details: $error');
      rethrow;
    }
  }
}
