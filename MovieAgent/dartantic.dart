/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 29/08/2025
* Copyright :  S.Hamblett
*/

import 'package:dartantic_ai/dartantic_ai.dart';

import 'config.dart';

final geminiProvider = GoogleProvider(apiKey: googleApIKey);

final chatModel = geminiProvider.createChatModel(name: 'gemini-2.0-flash', tools: []);

