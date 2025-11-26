/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

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

  Command();
}

class Connect extends Command {
  String command = Command.connect;

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
}
