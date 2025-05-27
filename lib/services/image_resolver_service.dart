import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/graphql_client.dart';
import '../utils/url_utils.dart'; // Import the utility function

// Provider for the image resolver service
final imageResolverProvider = Provider((ref) {
  final graphQLClient = ref.read(graphQLClientProvider);
  return ImageResolverService(graphQLClient);
});

// A provider that caches image URLs by their ID
final imageUrlCacheProvider = StateProvider<Map<String, String>>((ref) => {});

class ImageResolverService {
  final GraphQLClient _client;

  ImageResolverService(this._client);

  // Query to get image URL by ID
  static const String _getImageByIdQuery = '''
    query GetImageById(\$id: ID!) {
      image(where: {id: \$id}) {
        image {
          url
        }
      }
    }
  ''';

  /// Resolves an image ID to its URL
  Future<String?> resolveImageUrl(String imageId) async {
    try {
      // Fetch image URL from server
      final result = await _client.query(
        QueryOptions(
          document: gql(_getImageByIdQuery),
          variables: {'id': imageId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        debugPrint('GraphQL error fetching image: ${result.exception}');
        return null;
      }

      if (result.data == null || 
          result.data!['image'] == null || 
          result.data!['image']['image'] == null ||
          result.data!['image']['image']['url'] == null) {
        return null;
      }

      // Extract the URL and replace localhost if necessary
      final rawUrl = result.data!['image']['image']['url'] as String;
      final updatedUrl = replaceLocalhost(rawUrl);
      return updatedUrl;
    } catch (e) {
      debugPrint('Error resolving image URL: $e');
      return null;
    }
  }
}
