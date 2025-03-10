//file path: test/unit/artist_client_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:discogs_api_client/discogs_api_client.dart';
import 'package:fuzzy/fuzzy.dart';

void main() {
  late final DiscogsApiClient client;

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

    test('Fetch specific artist details', () async {
      final name = 'bad bunny';
      final res = await client.search.search(query: name, type: 'artist');
      if (res['results'].length > 0) {
        final names =
            res['results']
                .where((e) => e['type'] == 'artist')
                .map((e) => {'id': e['id'], 'title': e['title']})
                .toList();
        final WeightedKey keys = WeightedKey(
          name: 'title',
          getter: (e) => e['title'],
          weight: 1,
        );
        final fuzzy = Fuzzy(
          names,
          options: FuzzyOptions(threshold: 1, keys: [keys]),
        );
        final result = fuzzy.search(name);
        //result.forEach((e) => print(e.score == 0.0));
        if (result.where((e) => e.score == 0.0).isNotEmpty) {
          print(result.firstWhere((e) => e.score == 0.0).item['id']);
          expect(result.firstWhere((e) => e.score == 0.0).score, equals(0.0));
        }
      }
    });
  });
}
