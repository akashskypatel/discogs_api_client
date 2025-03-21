//file path: lib/src/clients/master_client.dart
import 'dart:convert';

import 'package:discogs_api_client/src/clients/discogs_http_client.dart';

/// A client for interacting with the Discogs API's master release-related endpoints.
///
/// This class provides methods to fetch details about master releases and their versions.
class MasterClient {
  final DiscogsHttpClient _httpClient;
  final String _baseurl = 'api.discogs.com';

  /// Creates an instance of [MasterClient].
  ///
  /// The [httpClient] is used to make HTTP requests to the Discogs API.
  MasterClient(DiscogsHttpClient httpClient) : _httpClient = httpClient;

  /// Fetches details about a specific master release by its Discogs ID.
  ///
  /// - [id]: The Discogs ID of the master release.
  ///
  /// Returns a [Map<String, dynamic>] containing the master release's details.
  ///
  /// Throws an [Exception] if the request fails (e.g., due to network issues or an invalid master release ID).
  Future<Map<String, dynamic>> masters(int id) async {
    try {
      // Build the URI
      final uri = Uri.https(_baseurl, '/masters/$id');

      // Make the HTTP GET request
      final response = await _httpClient.get(uri);

      // Handle the response
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (!_httpClient.isSilent) {
          throw Exception(
            'Failed to load masters results: ${response.statusCode}',
          );
        }
        return jsonDecode(response.body);
      }
    } catch (e, stackTrace) {
      if (!_httpClient.isSilent) {
        throw Exception('Failed to load masters results: $e \n $stackTrace');
      }
      return {'error': '$e \n $stackTrace'};
    }
  }

  /// Fetches a list of versions associated with a specific master release.
  ///
  /// - [id]: The Discogs ID of the master release.
  /// - [format]: (Optional) Filter results by format (e.g., `Vinyl`, `CD`).
  /// - [label]: (Optional) Filter results by label name.
  /// - [release]: (Optional) Filter results by release title.
  /// - [country]: (Optional) Filter results by country.
  /// - [sort]: (Optional) The field to sort the results by (`released`, `title`, `format`, `label`, `catno`, `country`).
  /// - [sortOrder]: (Optional) The order of sorting (`asc` for ascending, `desc` for descending).
  /// - [perPage]: (Optional) The number of results per page (default is `500`).
  /// - [page]: (Optional) The page number to fetch (default is `1`).
  ///
  /// Returns a [Map<String, dynamic>] containing the master release's versions.
  ///
  /// Throws an [Exception] if the request fails (e.g., due to network issues or an invalid master release ID).
  Future<Map<String, dynamic>> masterReleaseVersions(
    int id, {
    String? format,
    String? label,
    String? release,
    String? country,
    String? sort,
    String? sortOrder,
    int? perPage = 500,
    int? page = 1,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'per_page': perPage.toString(),
        'page': page.toString(),
      };

      // Add optional parameters if they are provided
      if (sort != null) queryParams['sort'] = sort;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;
      if (format != null) queryParams['format'] = format;
      if (label != null) queryParams['label'] = label;
      if (release != null) queryParams['release'] = release;
      if (country != null) queryParams['country'] = country;

      // Build the URI
      final uri = Uri.https(_baseurl, '/masters/$id/versions', queryParams);

      // Make the HTTP GET request
      final response = await _httpClient.get(uri);

      // Handle the response
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (!_httpClient.isSilent) {
          throw Exception(
            'Failed to load masterReleaseVersions results: ${response.statusCode}',
          );
        }
        return jsonDecode(response.body);
      }
    } catch (e, stackTrace) {
      if (!_httpClient.isSilent) {
        throw Exception(
          'Failed to load masterReleaseVersions results: $e \n $stackTrace',
        );
      }
      return {'error': '$e \n $stackTrace'};
    }
  }
}
