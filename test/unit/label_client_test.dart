//file path: test/unit/label_client_test.dart

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

  group('LabelClient', () {
    test('Fetch label details', () async {
      final response = await client.labels.labels(1); // Example label ID
      expect(response, isA<Map<String, dynamic>>());
      expect(response['id'], equals(1));
      print('Fetch label details: ${response['id']}');
    });

    test('Fetch label releases', () async {
      final response = await client.labels.labelReleases(1); // Example label ID
      expect(response, isA<Map<String, dynamic>>());
      expect(response['releases'], isA<List>());
      print('Fetch label releases: ${response['releases'][0]['id']}');
    });
  });
}
