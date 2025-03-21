//file path: lib/src/discogs_api_client_base.dart
import 'dart:async';

import 'package:discogs_api_client/src/clients/artist_client.dart';
import 'package:discogs_api_client/src/clients/discogs_http_client.dart';
import 'package:discogs_api_client/src/clients/label_client.dart';
import 'package:discogs_api_client/src/clients/master_client.dart';
import 'package:discogs_api_client/src/clients/release_client.dart';
import 'package:discogs_api_client/src/clients/search_client.dart';

/// The main client for interacting with the Discogs API.
///
/// This class provides access to various sub-clients for interacting with different parts of the Discogs API,
/// such as artists, labels, masters, releases, and search functionality.
class DiscogsApiClient {
  late final DiscogsHttpClient _httpClient;
  late final ArtistClient artists;
  late final LabelClient labels;
  late final MasterClient masters;
  late final ReleaseClient releases;
  late final SearchClient search;
  late StreamSubscription<bool?> _httpClientClosedSubscription;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Factory method to create and initialize an instance of [DiscogsApiClient].
  ///
  /// This method initializes the HTTP client and all sub-clients.
  ///
  /// Returns a [Future<DiscogsApiClient>] that resolves to an initialized client.
  DiscogsApiClient({bool isSilent = true}) {
    _initialize(isSilent: true);
    _httpClientClosedSubscription = _httpClient.closedController.stream.listen(
      (closed) => _isInitialized = !closed,
    );
  }

  /// Initializes the HTTP client and all sub-clients.
  ///
  /// This method is called internally by the [create] factory method.
  void _initialize({bool isSilent = true}) {
    _httpClient = DiscogsHttpClient(isSilent: isSilent);
    artists = ArtistClient(_httpClient);
    labels = LabelClient(_httpClient);
    masters = MasterClient(_httpClient);
    releases = ReleaseClient(_httpClient);
    search = SearchClient(_httpClient);
  }

  /// Closes the underlying HTTP client and releases any resources.
  ///
  /// Call this method when the client is no longer needed to free up resources.
  void close() {
    _httpClientClosedSubscription.cancel();
    _httpClient.close();
  }
}
