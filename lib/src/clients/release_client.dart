//file path: lib/src/clients/release_client.dart
import 'dart:convert';

import 'package:discogs_api_client/src/clients/discogs_http_client.dart';

/// A client for interacting with the Discogs API's release-related endpoints.
///
/// This class provides methods to fetch details about releases, ratings, and statistics.
class ReleaseClient {
  final DiscogsHttpClient _httpClient;
  final String _baseurl = 'api.discogs.com';

  /// Creates an instance of [ReleaseClient].
  ///
  /// The [httpClient] is used to make HTTP requests to the Discogs API.
  ReleaseClient(DiscogsHttpClient httpClient) : _httpClient = httpClient;

  /// Fetches details about a specific release by its Discogs ID.
  ///
  /// - [id]: The Discogs ID of the release.
  /// - [currAbbr]: (Optional) The currency abbreviation for pricing information (e.g., `USD`, `EUR`).
  ///
  /// Returns a [Map<String, dynamic>] containing the release's details.
  ///
  /// Throws an [Exception] if the request fails (e.g., due to network issues or an invalid release ID).
  Future<Map<String, dynamic>> releases(int id, {String? currAbbr}) async {
    // Build query parameters
    final Map<String, String> queryParams = {};
    if (currAbbr != null) queryParams['curr_abbr'] = currAbbr;

    // Build the URI
    final uri = Uri.https(_baseurl, '/releases/$id', queryParams);

    // Make the HTTP GET request
    final response = await _httpClient.get(uri);

    // Handle the response
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load search results: ${response.statusCode}');
    }
  }

  /// Fetches the rating given to a specific release by a specific user.
  ///
  /// - [id]: The Discogs ID of the release.
  /// - [username]: The username of the user whose rating is being fetched.
  ///
  /// Returns a [Map<String, dynamic>] containing the user's rating for the release.
  ///
  /// Throws an [Exception] if the request fails (e.g., due to network issues or an invalid release ID or username).
  Future<Map<String, dynamic>> releasesRatingByUser(
    int id, {
    String? username,
  }) async {
    // Build the URI
    final uri = Uri.https(_baseurl, '/releases/$id/rating/$username');

    // Make the HTTP GET request
    final response = await _httpClient.get(uri);

    // Handle the response
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load search results: ${response.statusCode}');
    }
  }

  /// Fetches the community rating for a specific release.
  ///
  /// - [id]: The Discogs ID of the release.
  ///
  /// Returns a [Map<String, dynamic>] containing the community rating for the release.
  ///
  /// Throws an [Exception] if the request fails (e.g., due to network issues or an invalid release ID).
  Future<Map<String, dynamic>> releasesRating(int id) async {
    // Build the URI
    final uri = Uri.https(_baseurl, '/releases/$id/rating');

    // Make the HTTP GET request
    final response = await _httpClient.get(uri);

    // Handle the response
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load search results: ${response.statusCode}');
    }
  }

  /// Fetches statistics for a specific release.
  ///
  /// - [id]: The Discogs ID of the release.
  ///
  /// Returns a [Map<String, dynamic>] containing the release's statistics.
  ///
  /// Throws an [Exception] if the request fails (e.g., due to network issues or an invalid release ID).
  Future<Map<String, dynamic>> releasesStats(int id) async {
    // Build the URI
    final uri = Uri.https(_baseurl, '/releases/$id/stats');

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
