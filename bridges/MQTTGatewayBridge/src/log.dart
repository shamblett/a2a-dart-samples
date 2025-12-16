/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'package:colorize/colorize.dart';

///
/// Simple logging.
///
class Log {
  static const logName = '[MQTTGatewayBridge]';

  static void info(String text) =>
      print('${Colorize('$logName $text').blue()}');

  static void warn(String text) =>
      print('${Colorize('$logName $text').yellow()}');

  static void fatal(String text) =>
      print('${Colorize('$logName $text').red()}');
}
