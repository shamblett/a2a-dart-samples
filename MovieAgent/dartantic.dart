/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 29/08/2025
* Copyright :  S.Hamblett
*/

import 'package:colorize/colorize.dart';
import 'package:dartantic_interface/dartantic_interface.dart';
import 'package:json_schema/json_schema.dart';

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
  final queryString = query['query'];
  try {
    final data = await callTmdbApi('movie', queryString);
    final results = data['results'];

    // Only modify image paths to be full URLs
    if (results.first.containsKey('poster_path')) {
      results['poster_path'] =
          'https://image.tmdb.org/t/p/w500${results.first['poster_path']}';
    }
    if (results.first.containsKey('backdrop_path')) {
      data['backdrop_path'] =
          'https://image.tmdb.org/t/p/w500${results.first['backdrop_path']}';
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
  final queryString = query['query'];
  try {
    final data = await callTmdbApi('person', queryString);
    final results = data['results'];

    // Only modify image paths to be full URLs
    if (results.first.containsKey('profile_path')) {
      results.first['profile_path'] =
          'https://image.tmdb.org/t/p/w500${results.first['profile_path']}';
    }

    // Also modify poster paths in known_for works
    if (results.first.containsKey('known_for')) {
      for (final known in results.first['known_for']) {
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
    return results.first;
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

