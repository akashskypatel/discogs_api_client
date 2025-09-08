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
  static String _apiKey = '';
  static String _apiSecret = '';
  static final _logger = Logger('DiscogsApi.DiscogsHttpClient');
  static http.Client _httpClient = http.Client();

  static int _rateLimit = 60; // Default rate limit
  static int _rateLimitUsed = 0;
  static int _rateLimitRemaining = 60;
  static DateTime _lastRequestTime = DateTime.now();
  static bool _closed = true;
  static bool _isSilent = true;
  static final _closedController = StreamController<bool>.broadcast();

  bool get isSilent => _isSilent;
  bool get closed => _closed;
  String get apiKey => _apiKey;
  String get apiSecret => _apiSecret;
  StreamController<bool> get closedController => _closedController;

  static const Map<String, String> _defaultHeaders = {
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.18 Safari/537.36',
  };

  /// Private constructor for creating an instance of [DiscogsHttpClient].
  DiscogsHttpClient([http.Client? httpClient, bool isSilent = true]) {
    _httpClient = httpClient ?? http.Client();
    _isSilent = isSilent;
    _create();
  }

  /// Factory constructor to create an instance of [DiscogsHttpClient] asynchronously.
  ///
  /// This method loads the API key and secret from the `.env` file.
  ///
  /// Returns a [Future<DiscogsHttpClient>].
  ///
  /// Throws an [Exception] if the API key or secret is not found in the `.env` file.
  static void _create() async {
    if (_closed) {
      final credentials = await _getApiCredetials();
      if (_apiKey == '') _apiKey = credentials['api_key'] ?? '';
      if (_apiSecret == '') _apiSecret = credentials['api_secret'] ?? '';
    }
    if (_apiKey == '' || _apiSecret == '') {
      if (!_isSilent) {
        throw Exception('API Key or Secret not found in .env file.');
      }
      _logger.severe('API Key or Secret not found in .env file.');
    }
    _closed = false;
    _closedController.add(_closed);
  }

  /// Loads the API key and secret from the `.env` file.
  ///
  /// Returns a [Map<String, String>] containing the API key and secret.
  ///
  /// Throws an [Exception] if the API key or secret is not found in the `.env` file.
  static Future<Map<String, String>> _getApiCredetials() async {
    try {
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: '.env');
      }

      final apiKey = dotenv.env['DISCOGS_API_KEY'];
      final apiSecret = dotenv.env['DISCOGS_API_SECRET'];

      // Validate that the values are not null
      if (apiKey == null || apiSecret == null) {
        throw Exception('API key or secret not found in .env file');
      }

      return {'api_key': apiKey, 'api_secret': apiSecret};
    } catch (e, stackTrace) {
      _logger.severe(
        'getApiCredetials:${dotenv.isInitialized ? dotenv.env : ''}',
        e,
        stackTrace,
      );
      if (!_isSilent) {
        throw Exception('API key or secret not found in .env file');
      }
      return {};
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
      if (!_isSilent) {
        throw Exception(response);
      }
    }

    if (statusCode == 429) {
      if (!_isSilent) {
        throw Exception(response);
      }
    }

    if (statusCode >= 400) {
      if (!_isSilent) {
        throw Exception(response);
      }
    }
  }

  /// Checks and enforces the rate limit for API requests.
  ///
  /// If the rate limit is exceeded, this method waits until the rate limit resets.
  Future<void> _checkRateLimit() async {
    try {
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
          _logger.warning(
            'Rate limit reached. Waiting for $waitTime seconds...',
          );
          await Future.delayed(Duration(seconds: waitTime));
          _rateLimitRemaining = _rateLimit; // Reset remaining requests
          _lastRequestTime = DateTime.now();
        }
      }
    } catch (e) {
      _logger.warning('Error checking rate limit.');
    }
  }

  /// Checks the credentials by waiting for the `_closedController` stream to emit `false`.
  Future<bool> _checkCredentials() async {
    try {
      // Wait for the stream to emit `false` or timeout after 5 seconds
      if (!_closed) return true;
      await _closedController.stream
          .firstWhere((value) => value == false)
          .timeout(Duration(seconds: 5));
      return true; // Stream emitted `false` within the timeout
    } on TimeoutException {
      // Timeout occurred
      return false;
    } catch (e) {
      // Handle other errors (e.g., stream error)
      _logger.severe(
        'Timed out because credentials could not be loaded from .env: $e',
      );
      return false;
    }
  }

  /// Parses the rate limit headers from the HTTP response.
  ///
  /// Updates the rate limit, used requests, and remaining requests based on the headers.
  void _parseRateLimitHeaders(http.Response response) {
    try {
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
    } catch (e) {
      _logger.severe('Error in _parseRateLimitHeaders');
    }
  }

  @override
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers = const {},
    bool validate = false,
  }) async {
    try {
      await _checkRateLimit(); // Enforce rate limiting
      final creds = _closed ? await _checkCredentials() : true;
      if (creds) {
        // Create a new map of query parameters
        final Map<String, String> updatedQueryParams = Map.from(
          url.queryParameters,
        )..addAll({'key': apiKey, 'secret': apiSecret});

        // Create a new Uri with the updated query parameters
        final updatedUri = url.replace(queryParameters: updatedQueryParams);

        final response = await super.get(updatedUri, headers: headers);

        if (_closed) {
          if (!_isSilent) {
            throw Exception('Client is closed.');
          }
          return http.Response('{"error": "Client is closed."}', 400);
        }

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
      return http.Response('{"error": "Unauthorized"}', 401);
    } catch (e, stackTrace) {
      if (!_isSilent) {
        throw Exception('Credentials could not be retreived');
      }
      _logger.severe('Error in get request:', e, stackTrace);
      return http.Response('{}', 400);
    }
  }

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool validate = false,
  }) async {
    try {
      await _checkRateLimit(); // Enforce rate limiting
      final creds = _closed ? await _checkCredentials() : true;
      if (creds) {
        // Create a new map of query parameters
        final Map<String, String> updatedQueryParams = Map.from(
          url.queryParameters,
        )..addAll({'key': apiKey, 'secret': apiSecret});

        // Create a new Uri with the updated query parameters
        final updatedUri = url.replace(queryParameters: updatedQueryParams);

        final response = await super.post(
          updatedUri,
          headers: headers,
          body: body,
          encoding: encoding,
        );

        if (_closed) {
          if (!_isSilent) {
            throw Exception('Client is closed.');
          }
          return http.Response('{"error": "Client is closed."}', 400);
        }

        _parseRateLimitHeaders(response); // Parse rate limit headers

        if (validate) {
          _validateResponse(response, response.statusCode);
        }
        return response;
      }
      return http.Response('{"error": "Unauthorized"}', 401);
    } catch (e, stackTrace) {
      if (!_isSilent) {
        throw Exception('Credentials could not be retreived');
      }
      _logger.severe('Error in get request:', e, stackTrace);
      return http.Response('{}', 400);
    }
  }

  @override
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool validate = false,
  }) async {
    try {
      await _checkRateLimit(); // Enforce rate limiting
      final creds = _closed ? await _checkCredentials() : true;
      if (creds) {
        // Create a new map of query parameters
        final Map<String, String> updatedQueryParams = Map.from(
          url.queryParameters,
        )..addAll({'key': apiKey, 'secret': apiSecret});

        // Create a new Uri with the updated query parameters
        final updatedUri = url.replace(queryParameters: updatedQueryParams);

        final response = await super.post(
          updatedUri,
          headers: headers,
          body: body,
          encoding: encoding,
        );

        if (_closed) {
          if (!_isSilent) {
            throw Exception('Client is closed.');
          }
          return http.Response('{"error": "Client is closed."}', 400);
        }

        _parseRateLimitHeaders(response); // Parse rate limit headers

        if (validate) {
          _validateResponse(response, response.statusCode);
        }
        return response;
      }
      return http.Response('{"error": "Unauthorized"}', 401);
    } catch (e, stackTrace) {
      if (!_isSilent) {
        throw Exception('Credentials could not be retreived');
      }
      _logger.severe('Error in get request:', e, stackTrace);
      return http.Response('{}', 400);
    }
  }

  @override
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool validate = false,
  }) async {
    try {
      await _checkRateLimit(); // Enforce rate limiting
      final creds = _closed ? await _checkCredentials() : true;
      if (creds) {
        // Create a new map of query parameters
        final Map<String, String> updatedQueryParams = Map.from(
          url.queryParameters,
        )..addAll({'key': apiKey, 'secret': apiSecret});

        // Create a new Uri with the updated query parameters
        final updatedUri = url.replace(queryParameters: updatedQueryParams);

        final response = await super.post(
          updatedUri,
          headers: headers,
          body: body,
          encoding: encoding,
        );

        if (_closed) {
          if (!_isSilent) {
            throw Exception('Client is closed.');
          }
          return http.Response('{"error": "Client is closed."}', 400);
        }

        _parseRateLimitHeaders(response); // Parse rate limit headers

        if (validate) {
          _validateResponse(response, response.statusCode);
        }
        return response;
      }
      return http.Response('{"error": "Unauthorized"}', 401);
    } catch (e, stackTrace) {
      if (!_isSilent) {
        throw Exception('Credentials could not be retreived');
      }
      _logger.severe('Error in get request:', e, stackTrace);
      return http.Response('{}', 400);
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_closed) {
      if (!isSilent) {
        throw Exception();
      }
      final emptyStream = Stream<List<int>>.empty();
      final response = http.StreamedResponse(
        emptyStream, // Empty stream for the body
        204, // HTTP status code: 204 No Content
        request: request, // Pass the original request
        headers: {'Content-Length': '0'}, // Optional headers
      );

      return response;
    }

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
