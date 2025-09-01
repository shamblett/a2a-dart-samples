/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 29/08/2025
* Copyright :  S.Hamblett
*/

import 'dart:async';
import 'dart:isolate';

import 'package:colorize/colorize.dart';
import 'package:oxy/oxy.dart';

import 'config.dart';

/// Utility function to call the TMDB API
/// @param endpoint The TMDB API endpoint (e.g., 'movie', 'person')
/// @param query The search query
/// @returns [Future] that resolves to the API response data
Future<dynamic> callTmdbApi(String endpoint, String query) async {
  final apiKey = tmdbApiKey;
  if (apiKey.isEmpty) {
    throw ArgumentError('callTmdbApi:: the TMDB API key is not set');
  }

  try {
    final url = Uri(
      scheme: 'https',
      host: 'api.themoviedb.org',
      path: '3/search/$endpoint',
      queryParameters: {
        'api_key': apiKey,
        'query': query,
        'include_adult': 'false',
        'language': 'en-GB',
        'page': '1',
      },
    );
    final response = await fetch(url.toString());

    if (!response.ok) {
      throw RemoteError(
        'callTmdbApi:: TMDB API error: ${response.status} ${response.statusText}',
        '',
      );
    }

    return await response.json();
  } catch (e) {
    print(
      '${Colorize('callTmdbApi:: Error calling TMDB API ($endpoint):').red()}, $e',
    );
    rethrow;
  }
}
