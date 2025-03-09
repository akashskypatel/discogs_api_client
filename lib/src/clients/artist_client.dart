//file path: lib/src/clients/artist_client.dart
import 'dart:convert';

import 'package:discogs_api_client/src/clients/discogs_http_client.dart';

/// A client for interacting with the Discogs API's artist-related endpoints.
///
/// This class provides methods to fetch details about artists and their releases.
class ArtistClient {
  final DiscogsHttpClient _httpClient;
  final String _baseurl = 'api.discogs.com';

  /// Creates an instance of [ArtistClient].
  ///
  /// The [httpClient] is used to make HTTP requests to the Discogs API.
  ArtistClient(DiscogsHttpClient httpClient) : _httpClient = httpClient;

  /// Fetches details about a specific artist by their Discogs ID.
  ///
  /// - [id]: The Discogs ID of the artist.
  ///
  /// Returns a [Map<String, dynamic>] containing the artist's details.
  ///
  /// Throws an [Exception] if the request fails (e.g., due to network issues or an invalid artist ID).
  Future<Map<String, dynamic>> artists(int id) async {
    // Build the URI
    final uri = Uri.https(_baseurl, '/artists/$id');

    // Make the HTTP GET request
    final response = await _httpClient.get(uri);

    // Handle the response
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load search results: ${response.statusCode}');
    }
  }

  /// Fetches a list of releases associated with a specific artist.
  ///
  /// - [id]: The Discogs ID of the artist.
  /// - [sort]: (Optional) The field to sort the results by (`year`, `title`, `format`).
  /// - [sortOrder]: (Optional) The order of sorting (`asc` for ascending, `desc` for descending).
  /// - [perPage]: (Optional) The number of results per page (default is `500`).
  /// - [page]: (Optional) The page number to fetch (default is `1`).
  ///
  /// Returns a [Map<String, dynamic>] containing the artist's releases.
  ///
  /// Throws an [Exception] if the request fails (e.g., due to network issues or an invalid artist ID).
  Future<Map<String, dynamic>> artistReleases(
    int id, {
    String? sort,
    String? sortOrder,
    int? perPage = 500,
    int? page = 1,
  }) async {
    // Build query parameters
    final Map<String, String> queryParams = {
      'per_page': perPage.toString(),
      'page': page.toString(),
    };

    // Add optional parameters if they are provided
    if (sort != null) queryParams['sort'] = sort;
    if (sortOrder != null) queryParams['sort_order'] = sortOrder;

    // Build the URI
    final uri = Uri.https(_baseurl, '/artists/$id/releases', queryParams);

    // Make the HTTP GET request
    final response = await _httpClient.get(uri);

    // Handle the response
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load search results: ${response.statusCode}');
    }
  }
}
