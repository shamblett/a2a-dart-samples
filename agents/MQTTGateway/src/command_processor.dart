/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'command.dart';
import 'log.dart';
import 'message_store.dart';
import 'mqtt_manager.dart';
import 'result.dart';

///
/// Gateway command processor.
///
class CommandProcessor {
  final MqttManager _mqttManager;

  final MessageStore _messageStore;

  CommandProcessor(this._messageStore, this._mqttManager);

  /// Execute a command and return the JSON string result.
  /// Returns a fail result if a command is found to be invalid.
  Future<String> executeCommand(String input) async {
    final command = Command.fromJson(input);
    if (command == null) {
      Log.warn('Command Processor input is invalid JSON');
      return Result().toJson();
    }
    if (!command.isValid) {
      Log.warn('Command Processor input is not a valid command');
      return Result().toJson();
    }

    // Valid command
    final result = switch (command) {
      Connect() => await _doConnect(command),
    };

    return result.toJson();
  }

  // Connect
  Future<Result> _doConnect(Connect command) async {
    final res = await _mqttManager.connect(
      command.brokerUrl,
      command.port,
      command.clientId,
      command.username,
      command.password,
    );
    if (res) {
      return Result()..result = Result.success;
    }

    return Result();
  }
}
