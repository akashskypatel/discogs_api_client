## 0.1.6

### Changes
- Improved failing conditions.
- Added silent failing.

## 0.1.5

### Changes
- Streamlined client construction. It is no longer asynchronous. Internal methods will wait for credentials to be loaded from `.env` file but the client will be constructed immediately.
- Other optimizations
- Updated tests
- Updated Readme

## 0.1.4

### Changes
- Updated example
- Updated tests
- Remove `.env` asset from package pubspec so `.env` loads correctly from parent package

## 0.1.3

### Changes
- Updated example

## 0.1.2

### Changes
- Updated formatting.

## 0.1.1

### Changes
- Updated to meet publishing requirements.

## 0.1.0

### Added
- Initial project setup with basic structure.
- Added `ArtistClient` to fetch artist details and releases.
- Added `LabelClient` to fetch label details and releases.
- Added `MasterClient` to fetch master release details and versions.
- Added `ReleaseClient` to fetch release details, ratings, and statistics.
- Added `SearchClient` to search for artists, releases, labels, and more.
- Added unit tests for all clients.



