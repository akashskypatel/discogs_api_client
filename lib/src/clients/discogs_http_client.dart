//file path: lib/src/clients/discogs_http_client.dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A custom HTTP client for interacting with the Discogs API.
///
/// This client handles rate limiting, authentication, and request/response logging.
/// It extends [http.BaseClient] to provide additional functionality for Discogs API requests.
class DiscogsHttpClient extends http.BaseClient {
  final String _apiKey;
  final String _apiSecret;
  static final _logger = Logger('DiscogsApi.DiscogsHttpClient');
  final http.Client _httpClient;

  int _rateLimit = 60; // Default rate limit
  int _rateLimitUsed = 0;
  int _rateLimitRemaining = 60;
  DateTime _lastRequestTime = DateTime.now();
  bool _closed = false;

  bool get closed => _closed;
  String get apiKey => _apiKey;
  String get apiSecret => _apiSecret;

  /// Private constructor for creating an instance of [DiscogsHttpClient].
  ///
  /// - [apiKey]: The Discogs API key.
  /// - [apiSecret]: The Discogs API secret.
  static const Map<String, String> _defaultHeaders = {
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.18 Safari/537.36',
  };

  /// Factory constructor to create an instance of [DiscogsHttpClient] asynchronously.
  ///
  /// This method loads the API key and secret from the `.env` file.
  ///
  /// Returns a [Future<DiscogsHttpClient>].
  ///
  /// Throws an [Exception] if the API key or secret is not found in the `.env` file.
  DiscogsHttpClient._({required String apiKey, required String apiSecret})
    : _apiKey = apiKey,
      _apiSecret = apiSecret,
      _httpClient = http.Client();

  // Factory constructor to load credentials asynchronously
  static Future<DiscogsHttpClient> create() async {
    final credentials = await _getApiCredetials();
    return DiscogsHttpClient._(
      apiKey: credentials['api_key']!,
      apiSecret: credentials['api_secret']!,
    );
  }

  /// Loads the API key and secret from the `.env` file.
  ///
  /// Returns a [Map<String, String>] containing the API key and secret.
  ///
  /// Throws an [Exception] if the API key or secret is not found in the `.env` file.
  static Future<Map<String, String>> _getApiCredetials() async {
    try {
      await dotenv.load(fileName: '.env');
      final apiKey = dotenv.env['DISCOGS_API_KEY'];
      final apiSecret = dotenv.env['DISCOGS_API_SECRET'];

      // Validate that the values are not null
      if (apiKey == null || apiSecret == null) {
        throw Exception('API key or secret not found in .env file');
      }

      return {'api_key': apiKey, 'api_secret': apiSecret};
    } catch (e, stackTrace) {
      _logger.severe('getApiCredetials', e, stackTrace);
      throw Exception('API key or secret not found in .env file');
    }
  }

  /// Validates the HTTP response and throws an exception if the status code indicates an error.
  ///
  /// - [response]: The HTTP response to validate.
  /// - [statusCode]: The status code of the response.
  ///
  /// Throws an [Exception] if the status code is 4xx or 5xx.
  void _validateResponse(http.BaseResponse response, int statusCode) {
    if (_closed) return;

    if (statusCode >= 500) {
      throw Exception(response);
    }

    if (statusCode == 429) {
      throw Exception(response);
    }

    if (statusCode >= 400) {
      throw Exception(response);
    }
  }

  /// Checks and enforces the rate limit for API requests.
  ///
  /// If the rate limit is exceeded, this method waits until the rate limit resets.
  Future<void> _checkRateLimit() async {
    final now = DateTime.now();
    final difference = now.difference(_lastRequestTime);

    // Reset the counter if more than a minute has passed since the last request
    if (difference.inSeconds > 60) {
      _rateLimitRemaining = _rateLimit; // Reset remaining requests
      _lastRequestTime = now;
    }

    // If no requests are remaining, wait until the next window
    if (_rateLimitRemaining <= 0) {
      final waitTime = 60 - difference.inSeconds;
      if (waitTime > 0) {
        _logger.warning('Rate limit reached. Waiting for $waitTime seconds...');
        await Future.delayed(Duration(seconds: waitTime));
        _rateLimitRemaining = _rateLimit; // Reset remaining requests
        _lastRequestTime = DateTime.now();
      }
    }
  }

  /// Parses the rate limit headers from the HTTP response.
  ///
  /// Updates the rate limit, used requests, and remaining requests based on the headers.
  void _parseRateLimitHeaders(http.Response response) {
    final rateLimit = response.headers['X-Discogs-Ratelimit'];
    final rateLimitUsed = response.headers['X-Discogs-Ratelimit-Used'];
    final rateLimitRemaining =
        response.headers['X-Discogs-Ratelimit-Remaining'];

    if (rateLimit != null) _rateLimit = int.parse(rateLimit);
    if (rateLimitUsed != null) _rateLimitUsed = int.parse(rateLimitUsed);
    if (rateLimitRemaining != null) {
      _rateLimitRemaining = int.parse(rateLimitRemaining);
    }

    _logger.warning(
      'Rate Limit: $_rateLimit, Used: $_rateLimitUsed, Remaining: $_rateLimitRemaining',
    );
  }

  @override
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers = const {},
    bool validate = false,
  }) async {
    await _checkRateLimit(); // Enforce rate limiting
    // Create a new map of query parameters
    final Map<String, String> updatedQueryParams = Map.from(url.queryParameters)
      ..addAll({'key': apiKey, 'secret': apiSecret});

    // Create a new Uri with the updated query parameters
    final updatedUri = url.replace(queryParameters: updatedQueryParams);

    final response = await super.get(updatedUri, headers: headers);

    if (_closed) throw Exception(response);

    _parseRateLimitHeaders(response); // Parse rate limit headers

    if (validate) {
      _validateResponse(response, response.statusCode);
    }

    final now = DateTime.now();
    _logger.warning(
      response.body,
      '${now.minute}.${now.second}.${now.millisecond}-${url.pathSegments.last}-GET',
    );

    return response;
  }

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool validate = false,
  }) async {
    await _checkRateLimit(); // Enforce rate limiting
    // Create a new map of query parameters
    final Map<String, String> updatedQueryParams = Map.from(url.queryParameters)
      ..addAll({'key': apiKey, 'secret': apiSecret});

    // Create a new Uri with the updated query parameters
    final updatedUri = url.replace(queryParameters: updatedQueryParams);

    final response = await super.post(
      updatedUri,
      headers: headers,
      body: body,
      encoding: encoding,
    );

    if (_closed) throw Exception(response);

    _parseRateLimitHeaders(response); // Parse rate limit headers

    if (validate) {
      _validateResponse(response, response.statusCode);
    }
    return response;
  }

  @override
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool validate = false,
  }) async {
    await _checkRateLimit(); // Enforce rate limiting
    // Create a new map of query parameters
    final Map<String, String> updatedQueryParams = Map.from(url.queryParameters)
      ..addAll({'key': apiKey, 'secret': apiSecret});

    // Create a new Uri with the updated query parameters
    final updatedUri = url.replace(queryParameters: updatedQueryParams);

    final response = await super.post(
      updatedUri,
      headers: headers,
      body: body,
      encoding: encoding,
    );

    if (_closed) throw Exception(response);

    _parseRateLimitHeaders(response); // Parse rate limit headers

    if (validate) {
      _validateResponse(response, response.statusCode);
    }
    return response;
  }

  @override
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool validate = false,
  }) async {
    await _checkRateLimit(); // Enforce rate limiting
    // Create a new map of query parameters
    final Map<String, String> updatedQueryParams = Map.from(url.queryParameters)
      ..addAll({'key': apiKey, 'secret': apiSecret});

    // Create a new Uri with the updated query parameters
    final updatedUri = url.replace(queryParameters: updatedQueryParams);

    final response = await super.post(
      updatedUri,
      headers: headers,
      body: body,
      encoding: encoding,
    );

    if (_closed) throw Exception(response);

    _parseRateLimitHeaders(response); // Parse rate limit headers

    if (validate) {
      _validateResponse(response, response.statusCode);
    }
    return response;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (_closed) throw Exception();

    // Apply default headers if they are not already present
    _defaultHeaders.forEach((key, value) {
      if (request.headers[key] == null) {
        request.headers[key] = _defaultHeaders[key]!;
      }
    });

    _logger.fine('Sending request: $request', null, StackTrace.current);
    _logger.finer('Request headers: ${request.headers}');
    if (request is http.Request) {
      _logger.finer('Request body: ${request.body}');
    }
    return _httpClient.send(request);
  }

  @override
  void close() {
    _closed = true;
    _httpClient.close();
  }
}
