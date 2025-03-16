import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for GraphQL client
final graphQLClientProvider = Provider<GraphQLClient>((ref) {
  final HttpLink httpLink = HttpLink(
    'http://88.99.137.223:3000/api/graphql/', // Replace with your GraphQL endpoint
  );

  return GraphQLClient(
    cache: GraphQLCache(),
    link: httpLink,
  );
});

// Helper class to execute GraphQL operations
class GraphQLService {
  final GraphQLClient client;

  GraphQLService(this.client);

  // Execute a query
  Future<QueryResult> performQuery(String query,
      {Map<String, dynamic>? variables}) async {
    final options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
    );

    return await client.query(options);
  }

  // Execute a mutation
  Future<QueryResult> performMutation(String mutation,
      {Map<String, dynamic>? variables}) async {
    final options = MutationOptions(
      document: gql(mutation),
      variables: variables ?? {},
    );

    return await client.mutate(options);
  }
}
