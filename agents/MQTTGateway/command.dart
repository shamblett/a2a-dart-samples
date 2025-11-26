/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'dart:convert';

///
/// Gateway commands.
///
sealed class Command {
  static const connect = 'connect';
  static const disconnect = 'disconnect';
  static const subscribe = 'subscribe';
  static const unsubscribe = 'unsubscribe';
  static const publish = 'publish';
  static const getMessages = 'get_messages';
  static const status = 'status';

  String command = '';

  bool isValid = false;

  Command();

  static Command? fromJson(String jsonString) {
    final jsonMap = json.decode(jsonString);
    if (!jsonMap.contains('command')) {
      return null;
    }
    switch (jsonMap['command']) {
      case Command.connect:
        {
          return Connect.fromJson(jsonString);
        }
    }
    return null;
  }
}

class Connect extends Command {
  /// Mandatory
  String brokerUrl = '';

  /// Optional
  int port = 1883;

  /// Optional
  String clientId = '';

  /// Optional
  String username = '';

  /// Optional
  String password = '';

  Connect();

  Connect.fromJson(String jsonString) {
    final jsonMap = json.decode(jsonString);
    if (jsonMap.contains('broker_url')) {
      brokerUrl = jsonMap['broker_url'];
      isValid = true;
    }
    if (jsonMap.contains('port')) {
      port = jsonMap['port'];
    }
    if (jsonMap.contains('client_id')) {
      clientId = jsonMap['client_id'];
    }
    if (jsonMap.contains('user_name')) {
      username = jsonMap['user_name'];
    }
    if (jsonMap.contains('password')) {
      password = jsonMap['password'];
    }
    command = Command.connect;
  }
}
