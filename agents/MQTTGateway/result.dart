/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'message.dart';

///
/// Result of a command
///
class Result {
  /// Original command
  String command = '';

  /// Success or fail
  String result = 'fail';

  /// Message list for get messages command.
  List<Message> messages = [];

  String toJson() {}
}
