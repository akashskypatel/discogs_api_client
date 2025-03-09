//file path: test/unit/artist_client_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:discogs_api_client/discogs_api_client.dart';

void main() {
  late DiscogsApiClient client;

  setUpAll(() async {
    client = await DiscogsApiClient.create();
  });

  tearDownAll(() {
    client.close();
  });

  group('ReleaseClient', () {
    test('Fetch release details', () async {
      final response = await client.releases.releases(249504); // Example release ID
      expect(response, isA<Map<String, dynamic>>());
      expect(response['id'], equals(249504));
      print('Fetch release details: ${response['id']}');
    });

    test('Fetch release rating by user', () async {
      final response = await client.releases.releasesRatingByUser(249504, username: 'bartman'); // Example release ID and username
      expect(response, isA<Map<String, dynamic>>());
      expect(response['rating'], isA<num>());
      print('Fetch release rating by user: $response');
    });

    test('Fetch release rating', () async {
      final response = await client.releases.releasesRating(249504); // Example release ID
      expect(response, isA<Map<String, dynamic>>());
      expect(response['rating']['average'], isA<num>());
      print('Fetch release rating: ${response['rating']['average']}');
    });

    test('Fetch release stats', () async {
      final response = await client.releases.releasesStats(249504); // Example release ID
      expect(response, isA<Map>());
      print('Fetch release stats: $response');
    });
  });
}
