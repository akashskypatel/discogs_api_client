import 'package:discogs_api_client/discogs_api_client.dart';
import 'dart:io';

void main() async {
  final client = DiscogsApiClient();
  var response = await client.artists.artists(194);
  print(response);
  response = await client.artists.artistReleases(3840);
  print(response);
  response = await client.labels.labels(1);
  print(response);
  response = await client.labels.labelReleases(1);
  print(response);
  response = await client.masters.masters(21481);
  print(response);
  response = await client.masters.masterReleaseVersions(21481);
  print(response);
  response = await client.releases.releases(249504);
  print(response);
  response = await client.releases.releasesRatingByUser(
    249504,
    username: 'bartman',
  );
  print(response);
  response = await client.releases.releasesRating(249504);
  print(response);
  response = await client.releases.releasesStats(249504);
  print(response);
  response = await client.search.search(query: 'Radiohead', type: 'artist');
  print(response);
  response = await client.search.search(query: 'OK Computer', type: 'release');
  print(response);
  response = await client.search.search(query: 'Warp Records', type: 'label');
  print(response);
  response = await client.search.searchArtist('Radiohead');
  print(response);
  exit(0);
}
