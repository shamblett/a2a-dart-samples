/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 05/12/2025
* Copyright :  S.Hamblett
*/

typedef GWCommand = Map<String,dynamic>;

///
/// MQTT Gateway command support.
///
class GatewayCommand {
  /// Commands
  static const status = 'status';
  static const connect = 'connect';
  static const disconnect = 'disconnect';
  static const subscribe = 'subscribe';
  static const unsubscribe = 'unsubscribe';
  static const publish = 'publish';
  static const messages = 'get_messages';

  /// Command parameters
  static const command = 'command';

  /// Connect
  static const brokerUrl = 'broker_url';
  static const port = 'port';
  static const clientId = 'client_id';
  static const userName = 'username';
  static const password = 'password';

  /// General
  static const topic = 'topic';
  static const payload = 'payload';

  /// Result
  static const result = 'result';
}
