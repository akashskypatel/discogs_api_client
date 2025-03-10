//file path: test/unit/artist_client_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:discogs_api_client/discogs_api_client.dart';

void main() {
  late final DiscogsApiClient client;

  setUpAll(() async {
    client = await DiscogsApiClient.create();
  });

  tearDownAll(() {
    client.close();
  });

  group('MasterClient', () {
    test('Fetch master details', () async {
      final response = await client.masters.masters(21481); // Example master ID
      expect(response, isA<Map<String, dynamic>>());
      expect(response['id'], equals(21481));
      print('Fetch master details: ${response['id']}');
    });

    test('Fetch master release versions', () async {
      final response = await client.masters.masterReleaseVersions(
        21481,
      ); // Example master ID
      expect(response, isA<Map<String, dynamic>>());
      expect(response['versions'], isA<List>());
      print('Fetch master release versions: ${response['versions'][0]['id']}');
    });
  });
}
