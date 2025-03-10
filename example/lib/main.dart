import 'package:discogs_api_client/discogs_api_client.dart';
import 'dart:io';

void main() async {
  // Create and initialize the Discogs API client
  final DiscogsApiClient client = await DiscogsApiClient.create();

  // Use the client to interact with the Discogs API
  final artist = await client.artists.artists(108713); // Example artist ID
  print(artist);

  final searchResults = await client.search.search(
    query: 'bad bunny',
    type: 'artist',
  );
  print(searchResults);

  // Close the client when done
  client.close();
  exit(0);
}
