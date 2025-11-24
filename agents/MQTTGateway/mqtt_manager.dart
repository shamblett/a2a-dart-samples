/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'package:colorize/colorize.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

///
/// MQTT client management.
///
class MqttManager {
  static const defaultClientId = 'A2AMQTTGatewayAgent';

  late MqttServerClient _client;

  String _brokerUrl = '';

  int _port = 0;

  String _clientId = '';

  bool _connected = false;

  bool get isConnected => _connected;

  /// Construction
  MqttManager();

  /// Create the MQTT Server client and connect to the specified broker with the supplied
  /// parameters. Returns true on success.
  Future<bool> connect(
    String brokerUrl, [
    int port = 1883,
    String clientId = defaultClientId,
    String? userName,
    String? password,
  ]) async {
    // Check if already connected
    if (_connected) {
      print(
        '${Colorize('[MQTTGateway] MqttManager already connected, disconnect first').yellow()}',
      );
      return false;
    }
    _brokerUrl = brokerUrl;
    _port = port;
    _clientId = clientId;
    _client = MqttServerClient.withPort(_brokerUrl, _clientId, _port);

    // Connect the client
    print(
      '${Colorize('[MQTTGateway] MqttManager connecting to broker at $_brokerUrl on port $_port').blue()}',
    );
    try {
      await _client.connect(userName, password);
    } catch (e) {
      // Any exception denotes failure
      print(
        '${Colorize('[MQTTGateway] MqttManager failed to connect, exception is $e').yellow()}',
      );
      return false;
    }

    // Check connection status
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      print(
        '${Colorize('[MQTTGateway] MqttManager failed to connect, connection state is ${_client.connectionStatus!.state}').yellow()}',
      );
      return false;
    }

    // Connected
    _connected = true;
    return true;
  }
}
