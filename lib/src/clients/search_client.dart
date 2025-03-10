//file path: lib/src/clients/search_client.dart
import 'dart:convert';

import 'package:discogs_api_client/src/clients/discogs_http_client.dart';

/// A client for interacting with the Discogs API's search-related endpoints.
///
/// This class provides methods to search for artists, releases, labels, and other entities in the Discogs database.
class SearchClient {
  final DiscogsHttpClient _httpClient;
  final String _baseurl = 'api.discogs.com';

  /// Creates an instance of [SearchClient].
  ///
  /// The [httpClient] is used to make HTTP requests to the Discogs API.
  SearchClient(DiscogsHttpClient httpClient) : _httpClient = httpClient;

  /// Performs a search query on the Discogs database.
  ///
  /// - [query]: (Optional) The search query string.
  /// - [type]: (Optional) The type of entity to search for (`release`, `master`, `artist`, `label`).
  /// - [title]: (Optional) Filter results by title.
  /// - [releaseTitle]: (Optional) Filter results by release title.
  /// - [credit]: (Optional) Filter results by credit.
  /// - [artist]: (Optional) Filter results by artist name.
  /// - [anv]: (Optional) Filter results by artist name variation.
  /// - [label]: (Optional) Filter results by label name.
  /// - [genre]: (Optional) Filter results by genre.
  /// - [style]: (Optional) Filter results by style.
  /// - [country]: (Optional) Filter results by country.
  /// - [year]: (Optional) Filter results by year.
  /// - [format]: (Optional) Filter results by format (e.g., `Vinyl`, `CD`).
  /// - [catno]: (Optional) Filter results by catalog number.
  /// - [barcode]: (Optional) Filter results by barcode.
  /// - [track]: (Optional) Filter results by track title.
  /// - [submitter]: (Optional) Filter results by submitter.
  /// - [contributor]: (Optional) Filter results by contributor.
  /// - [perPage]: (Optional) The number of results per page (default is `500`).
  /// - [page]: (Optional) The page number to fetch (default is `1`).
  ///
  /// Returns a [Map<String, dynamic>] containing the search results.
  ///
  /// Throws an [Exception] if the request fails (e.g., due to network issues or invalid parameters).
  Future<Map<String, dynamic>> search({
    String? query,
    String? type,
    String? title,
    String? releaseTitle,
    String? credit,
    String? artist,
    String? anv,
    String? label,
    String? genre,
    String? style,
    String? country,
    String? year,
    String? format,
    String? catno,
    String? barcode,
    String? track,
    String? submitter,
    String? contributor,
    int? perPage = 500,
    int? page = 1,
  }) async {
    // Build query parameters
    final Map<String, String> queryParams = {
      'per_page': perPage.toString(),
      'page': page.toString(),
    };

    // Add optional parameters if they are provided
    if (query != null) queryParams['q'] = query;
    if (type != null) queryParams['type'] = type;
    if (title != null) queryParams['title'] = title;
    if (releaseTitle != null) queryParams['release_title'] = releaseTitle;
    if (credit != null) queryParams['credit'] = credit;
    if (artist != null) queryParams['artist'] = artist;
    if (anv != null) queryParams['anv'] = anv;
    if (label != null) queryParams['label'] = label;
    if (genre != null) queryParams['genre'] = genre;
    if (style != null) queryParams['style'] = style;
    if (country != null) queryParams['country'] = country;
    if (year != null) queryParams['year'] = year;
    if (format != null) queryParams['format'] = format;
    if (catno != null) queryParams['catno'] = catno;
    if (barcode != null) queryParams['barcode'] = barcode;
    if (track != null) queryParams['track'] = track;
    if (submitter != null) queryParams['submitter'] = submitter;
    if (contributor != null) queryParams['contributor'] = contributor;

    // Build the URI
    final uri = Uri.https(_baseurl, '/database/search', queryParams);

    // Make the HTTP GET request
    final response = await _httpClient.get(uri);

    // Handle the response
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load search results: ${response.statusCode}');
    }
  }

  /// Searches for artists by name.
  ///
  /// - [name]: The name of the artist to search for.
  ///
  /// Returns a [Map<String, dynamic>] containing the search results for artists.
  ///
  /// Throws an [Exception] if the request fails (e.g., due to network issues or invalid parameters).
  Future<Map<String, dynamic>> searchArtist(String name) async {
    return search(query: name, type: 'artist');
  }
}
