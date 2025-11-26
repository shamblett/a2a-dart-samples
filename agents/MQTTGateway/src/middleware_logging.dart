/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'package:a2a/a2a.dart';
import 'package:colorize/colorize.dart';

/// Middleware logging class
class MiddlewareLogging {
  static final mwLogging = ((Request req, Response res, NextFunction next) {
    print(
      '${Colorize('📝 Request: ${req.method} ${req.uri} from ${req.hostname}').blue()}',
    );
    next();
  });
}
