//file path: test/unit/search_client_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:discogs_api_client/discogs_api_client.dart';

void main() {
  late final DiscogsApiClient client;

  setUpAll(() {
    client = DiscogsApiClient();
  });

  tearDownAll(() {
    client.close();
  });

  group('SearchClient', () {
    test('Search for artists', () async {
      final response = await client.search.search(
        query: 'Radiohead',
        type: 'artist',
      );
      expect(response, isA<Map<String, dynamic>>());
      expect(response['results'], isA<List>());
      print('Search for artists id: ${response['results'][0]['id']}');
    });

    test('Search for releases', () async {
      final response = await client.search.search(
        query: 'OK Computer',
        type: 'release',
      );
      expect(response, isA<Map<String, dynamic>>());
      expect(response['results'], isA<List>());
      print('Search for releases id: ${response['results'][0]['id']}');
    });

    test('Search for labels', () async {
      final response = await client.search.search(
        query: 'Warp Records',
        type: 'label',
      );
      expect(response, isA<Map<String, dynamic>>());
      expect(response['results'], isA<List>());
      print('Search for labels id: ${response['results'][0]['id']}');
    });

    test('Search for specific artist', () async {
      final response = await client.search.searchArtist('Radiohead');
      expect(response, isA<Map<String, dynamic>>());
      expect(response['results'], isA<List>());
      print('Search for specific artist id: ${response['results'][0]['id']}');
    });
  });
}
