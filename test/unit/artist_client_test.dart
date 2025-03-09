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

  group('ArtistClient', () {
    test('Fetch artist details', () async {
      final response = await client.artists.artists(3840); // Example artist ID
      expect(response, isA<Map<String, dynamic>>());
      expect(response['id'], equals(3840));
      print('Fetch artist details: ${response['id']}');
    });

    test('Fetch artist releases', () async {
      final response = await client.artists.artistReleases(
        3840,
      ); // Example artist ID
      //print(response);
      expect(response, isA<Map<String, dynamic>>());
      expect(response['releases'], isA<List>());
      print('Fetch artist releases: ${response['releases'][0]['id']}');
    });
  });
}
