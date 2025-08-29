/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 29/08/2025
* Copyright :  S.Hamblett
*/

import 'dart:async';

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:dartantic_interface/dartantic_interface.dart';
import 'package:json_schema/json_schema.dart';

import 'config.dart';

// Json schemas
final mustBeStringSchema = {'type': 'string'};
final searchMoviesSchema = JsonSchema.create(mustBeStringSchema);
final searchPeopleSchema = JsonSchema.create(mustBeStringSchema);

// Tools
final searchMoviesOnCall = ((args) async => {});

final searchMovies = Tool(name: 'searchMovies', description: 'Search TMDB for movies by title',
inputSchema: searchMoviesSchema,onCall: searchMoviesOnCall);

final searchPeopleOnCall = ((args) async => {});

final searchPeople = Tool(name: 'searchPeople', description: 'Search TMDB for or people by name',
    inputSchema: searchPeopleSchema,onCall: searchPeopleOnCall);


// Provider
final geminiProvider = GoogleProvider(apiKey: googleApIKey);

final chatModel = geminiProvider.createChatModel(name: 'gemini-2.0-flash', tools: [searchMovies]);

