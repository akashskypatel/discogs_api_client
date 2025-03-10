# Discogs API Client

A Dart/Flutter client for interacting with the [Discogs API](https://www.discogs.com/developers/). This package provides a simple and easy-to-use interface for accessing Discogs' music database, including artists, labels, masters, releases, and search functionality that do not require user level authentication. This package does not provide any methods that requires user level authentication.

## Features

- **Artist Information**: Fetch details about artists and their releases.
- **Label Information**: Retrieve details about labels and their releases.
- **Master Releases**: Access master release information and versions.
- **Release Details**: Get detailed information about specific releases, including ratings and statistics.
- **Search**: Search for artists, releases, labels, and more.

## Installation

1. Download repository
2. Run the following command in project directory

```bash
flutter pub get
```

## Setup

### 1. Obtain Discogs API Credentials

To use the Discogs API, you need to obtain an API key and secret from [Discogs Developer Portal](https://www.discogs.com/settings/developers).

### 2. Add Credentials to `.env` File

1. Sign up for a Discogs account
2. Create an application under `Settings`>`Developers`
3. Create a `.env` file in the root of your project and add your Discogs API credentials:

```plaintext
DISCOGS_API_KEY=<Your_Consumer_Key>
DISCOGS_API_SECRET=<Your_Consumer_Secret>
```
4. Initialize dotenv with the `.env` file in your app before initializing DiscogsApiClient

## Usage

### Initialize the Client

```dart
import 'package:discogs_api_client/discogs_api_client.dart';

void main() async {
  final client = await DiscogsApiClient.create();

  // Use the client to interact with the Discogs API
  final artist = await client.artists.artists(108713); // Example artist ID
  print(artist);

  // Close the client when done
  client.close();
}
```

### Fetch Artist Details

```dart
final artist = await client.artists.artists(108713); // Example artist ID
print(artist);
```

### Fetch Artist Releases

```dart
final releases = await client.artists.artistReleases(108713); // Example artist ID
print(releases);
```

### Search for Artists

```dart
final searchResults = await client.search.search(query: 'Radiohead', type: 'artist');
print(searchResults);
```

### Fetch Release Details

```dart
final release = await client.releases.releases(249504); // Example release ID
print(release);
```

### Fetch Label Details

```dart
final label = await client.labels.labels(1); // Example label ID
print(label);
```

### Fetch Master Release Details

```dart
final master = await client.masters.masters(1000); // Example master ID
print(master);
```

## Running Tests

This project includes unit tests for all clients. To run the tests, use the following command:

```bash
flutter test
```

### Running Specific Tests

- **Run all tests**:
  ```bash
  flutter test
  ```

- **Run a specific test file**:
  ```bash
  flutter test test/artist_client_test.dart
  ```

## Contributing

Contributions are welcome! If you find a bug or want to add a feature, please open an issue or submit a pull request.

1. Fork the repository.
2. Create a new branch in your own fork (`git checkout -b feature/YourFeatureName`).
3. Make sure you create test cases for your changes and test thoroughly. Include tests in your commit.
4. Commit your changes to the new branch (`git commit -m 'Add some feature'`).
5. Push to the branch (`git push origin feature/YourFeatureName`).
6. Open a pull request in this repo.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- [Discogs API](https://www.discogs.com/developers/) for providing the music database.
- [Flutter](https://flutter.dev/) for the awesome framework.