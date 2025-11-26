/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'command.dart';
import 'message_store.dart';
import 'mqtt_manager.dart';
import 'result.dart';

///
/// Gateway command processor.
///
class CommandProcessor {
  final _mqttManager;

  final _messageStore;

  CommandProcessor(this._messageStore, this._mqttManager);

  /// Execute a command and return the JSON string result.
  /// Returns a fail result if a command is found to be invalid.
  String executeCommand(String input) {
    final command = Command.fromJson(input);
    if (command == null) {
      return Result().toJson();
    }
    if (!command.isValid) {
      return Result().toJson();
    }

    // Valid command
    Result result;
    switch (command.command) {
      case Command.connect:
        {
          result = _doConnect(command);
        }
      default:
        result = Result();
    }

    return result.toJson();
  }

  // Connect
  Result _doConnect(Command command) {
    return Result();
  }
}
