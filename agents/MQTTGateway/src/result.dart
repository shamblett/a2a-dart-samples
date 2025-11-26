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
      int messCount = 0;
      for (final message in messages) {
        messCount++;
        sb.write(
          '{ "payload" : "${message.payload}", "timestamp" : "${message.timestamp}"',
        );
        if (messCount == messages.length) {
          // Last message
          sb.write(' } ');
        } else {
          sb.write(' }, ');
        }
      }
      sb.write(']');
    }
    sb.write(' }');
    return sb.toString();
  }
}
