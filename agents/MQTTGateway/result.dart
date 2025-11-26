/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'command.dart';
import 'message.dart';

///
/// Result of a command
///
class Result {
  static const fail = 'fail';
  static const success = 'success';

  /// Original command
  String command = '';

  /// Success or fail
  String result = fail;

  /// Message list for get messages command.
  List<Message> messages = [];

  String toJson() {
    final sb = StringBuffer();
    sb.write('{ "result" : "$result"');
    if (command == Command.getMessages && messages.isNotEmpty) {
      sb.write(', "messages" : [ ');
      for (final message in messages) {
        sb.write(
          '{ "payload" : "${message.payload}", "timestamp" : "${message.timestamp}" }, ',
        );
      }
      sb.write(']');
    }
    sb.write(' }');
    return sb.toString();
  }
}
