/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 29/08/2025
* Copyright :  S.Hamblett
*/

import 'package:colorize/colorize.dart';
import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:dartantic_interface/dartantic_interface.dart';
import 'package:json_schema/json_schema.dart';

import 'config.dart';
import 'tmdb.dart';

// Json schemas
final jsonSchema = {
  'type': 'object',
  'properties': {
    'query': {'type': 'string'},
  },
};
final searchMoviesSchema = JsonSchema.create(jsonSchema);
final searchPeopleSchema = JsonSchema.create(jsonSchema);

// Tools
final searchMoviesOnCall = ((query) async {
  print('${Colorize('TMDB:searchMovies $query').blue()}');

  try {
    final data = await callTmdbApi('movie', query) as Map<String, dynamic>;
    final results = data['results'];

    // Only modify image paths to be full URLs
    if (results.containsKey('poster_path')) {
      results['poster_path'] =
          'https://image.tmdb.org/t/p/w500${results['poster_path']}';
    }
    if (results.containsKey('backdrop_path')) {
      data['backdrop_path'] =
          'https://image.tmdb.org/t/p/w500${results['backdrop_path']}';
    }
    return results;
  } catch (e) {
    print('${Colorize('TMDB:searchMovies error searching movies').yellow()}');
    rethrow;
  }
});

final searchMovies = Tool(
  name: 'searchMovies',
  description: 'Search TMDB for movies by title',
  inputSchema: searchMoviesSchema,
  onCall: searchMoviesOnCall
);

final searchPeopleOnCall = ((query) async {
  print('${Colorize('TMDB:searchPeople $query').blue()}');

  try {
    final data = await callTmdbApi('person', query) as Map<String, dynamic>;
    final results = data['results'];

    // Only modify image paths to be full URLs
    if (results.containsKey('profile_path')) {
      results['profile_path'] =
          'https://image.tmdb.org/t/p/w500${results['profile_path']}';
    }

    // Also modify poster paths in known_for works
    if (results.containsKey('known_for')) {
      for (final known in results['known_for']) {
        if (known.containsKey('poster_path')) {
          known['profile_path'] =
              'https://image.tmdb.org/t/p/w500${known['poster_path']}';
        }
        if (known.containsKey('backdrop_path')) {
          known['backdrop_path'] =
              'https://image.tmdb.org/t/p/w500${known['backdrop_path']}';
        }
      }
    }
    return results;
  } catch (e) {
    print('${Colorize('TMDB:searchPeople error searching people').yellow()}');
    rethrow;
  }
});

final searchPeople = Tool(
  name: 'searchPeople',
  description: 'Search TMDB for or people by name',
  inputSchema: searchPeopleSchema,
  onCall: searchPeopleOnCall
);

// Provider
final geminiProvider = GoogleProvider(apiKey: googleApIKey);

final chatModel = geminiProvider.createChatModel(
  name: 'gemini-2.0-flash',
  tools: [searchMovies, searchPeople],
);
