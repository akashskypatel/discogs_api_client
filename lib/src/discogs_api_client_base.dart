//file path: lib/src/discogs_api_client_base.dart
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

  /// Private constructor for creating an instance of [DiscogsApiClient].
  ///
  /// Use the [create] factory method to initialize the client.
  DiscogsApiClient._();

  /// Factory method to create and initialize an instance of [DiscogsApiClient].
  ///
  /// This method initializes the HTTP client and all sub-clients.
  ///
  /// Returns a [Future<DiscogsApiClient>] that resolves to an initialized client.
  static Future<DiscogsApiClient> create() async {
    final client = DiscogsApiClient._();
    await client._initialize();
    return client;
  }

  /// Initializes the HTTP client and all sub-clients.
  ///
  /// This method is called internally by the [create] factory method.
  Future<void> _initialize() async {
    _httpClient = await DiscogsHttpClient.create();
    artists = ArtistClient(_httpClient);
    labels = LabelClient(_httpClient);
    masters = MasterClient(_httpClient);
    releases = ReleaseClient(_httpClient);
    search = SearchClient(_httpClient);
  }

  /// Closes the underlying HTTP client and releases any resources.
  ///
  /// Call this method when the client is no longer needed to free up resources.
  void close() => _httpClient.close();
}
