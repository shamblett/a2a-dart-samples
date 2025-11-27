/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'log.dart';
import 'message.dart';
import 'message_store.dart';

///
/// MQTT client management.
///
class MqttManager {
  static const defaultClientId = 'A2AMQTTGatewayAgent';

  final MessageStore _messageStore;

  late MqttServerClient _client;

  String _brokerUrl = '';

  int _port = 0;

  String _clientId = '';

  bool _connected = false;

  bool get isConnected => _connected;

  /// Construction
  MqttManager(this._messageStore);

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
      Log.warn(' MqttManager already connected, disconnect the client first');
      return false;
    }
    _brokerUrl = brokerUrl;
    _port = port;
    _clientId = clientId;
    _client = MqttServerClient.withPort(_brokerUrl, _clientId, _port);

    // Connect the client
    Log.info(
      'MqttManager connecting to broker at [$_brokerUrl] on port $_port',
    );
    try {
      await _client.connect(userName, password);
    } catch (e) {
      // Any exception denotes failure
      Log.warn('MqttManager failed to connect, exception is $e');
      return false;
    }

    // Check connection status
    if (_client.connectionStatus!.state != MqttConnectionState.connected) {
      Log.warn(
        'MqttManager failed to connect, connection state is ${_client.connectionStatus!.state}',
      );
      return false;
    }

    // Connected
    Log.info('MqttManager connected to broker at [$_brokerUrl] on port $_port');
    _connected = true;
    _listenForMessages();
    return true;
  }

  /// Disconnect, can't fail, always returns true.
  bool disconnect() {
    if (!_connected) {
      Log.warn(
        'MqttManager already disconnected from broker at [$_brokerUrl] on port $_port',
      );
      return true;
    }
    _client.disconnect();
    Log.info(
      'MqttManager disconnected from broker at [$_brokerUrl] on port $_port',
    );
    _connected = false;
    return true;
  }

  /// Subscribe to a topic
  bool subscribe(String topic, [int qos = 0]) {
    if (!_connected) {
      Log.warn('MqttManager disconnected, cannot subscribe to topic [$topic]');
      return false;
    }
    final sub = _client.subscribe(topic, _getQos(qos));
    if (sub == null) {
      Log.warn('MqttManager failed to subscribe to topic [$topic]');
      return false;
    }
    Log.info(' MqttManager subscribed to topic [$topic]');
    return true;
  }

  /// Unsubscribe from a topic
  bool unsubscribe(String topic) {
    if (!_connected || topic.isEmpty) {
      Log.warn(
        'MqttManager disconnected, cannot unsubscribe from topic [$topic]',
      );
      return false;
    }
    _client.unsubscribe(topic);
    Log.info('MqttManager unsubscribed from topic [$topic]');
    return true;
  }

  /// Publish a message to a topic
  bool publish(String topic, String payload, [int qos = 0]) {
    if (!_connected) {
      Log.warn('MqttManager disconnected, cannot publish to topic $topic');
      return false;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    try {
      _client.publishMessage(topic, _getQos(qos), builder.payload!);
    } catch (e) {
      Log.warn('MqttManager failed to publish message to topic $topic');
      return false;
    }
    Log.info('MqttManager published message to topic $topic');
    return true;
  }

  // Get the MQTT QoS value
  MqttQos _getQos(int qos) {
    switch (qos) {
      case 0:
        return MqttQos.atLeastOnce;
      case 1:
        return MqttQos.atMostOnce;
      case 2:
        return MqttQos.exactlyOnce;
      default:
        return MqttQos.atLeastOnce;
    }
  }

  void _listenForMessages() {
    // We know we are connected at this point
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c!.first.payload as MqttPublishMessage;
      final message = Message(recMess);
      _messageStore.addMessage(c.first.topic, message);
    });
  }
}
