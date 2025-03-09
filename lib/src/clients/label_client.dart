//file path: lib/src/clients/label_client.dart
import 'dart:convert';

import 'package:discogs_api_client/src/clients/discogs_http_client.dart';

/// A client for interacting with the Discogs API's label-related endpoints.
///
/// This class provides methods to fetch details about labels and their releases.
class LabelClient {
  final DiscogsHttpClient _httpClient;
  final String _baseurl = 'api.discogs.com';

  /// Creates an instance of [LabelClient].
  ///
  /// The [httpClient] is used to make HTTP requests to the Discogs API.
  LabelClient(DiscogsHttpClient httpClient) : _httpClient = httpClient;

  /// Fetches details about a specific label by its Discogs ID.
  ///
  /// - [id]: The Discogs ID of the label.
  ///
  /// Returns a [Map<String, dynamic>] containing the label's details.
  ///
  /// Throws an [Exception] if the request fails (e.g., due to network issues or an invalid label ID).
  Future<Map<String, dynamic>> labels(int id) async {
    // Build query parameters
    final Map<String, String> queryParams = {
      'key': _httpClient.apiKey,
      'secret': _httpClient.apiSecret,
    };

    // Build the URI
    final uri = Uri.https(_baseurl, '/labels/$id', queryParams);

    // Make the HTTP GET request
    final response = await _httpClient.get(uri);

    // Handle the response
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load search results: ${response.statusCode}');
    }
  }

  /// Fetches a list of releases associated with a specific label.
  ///
  /// - [id]: The Discogs ID of the label.
  /// - [perPage]: (Optional) The number of results per page (default is `500`).
  /// - [page]: (Optional) The page number to fetch (default is `1`).
  ///
  /// Returns a [Map<String, dynamic>] containing the label's releases.
  ///
  /// Throws an [Exception] if the request fails (e.g., due to network issues or an invalid label ID).
  Future<Map<String, dynamic>> labelReleases(int id, {int? perPage = 500, int? page = 1}) async {
    // Build query parameters
    final Map<String, String> queryParams = {
      'per_page': perPage.toString(),
      'page': page.toString(),
    };

    // Build the URI
    final uri = Uri.https(_baseurl, '/labels/$id/releases', queryParams);

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
