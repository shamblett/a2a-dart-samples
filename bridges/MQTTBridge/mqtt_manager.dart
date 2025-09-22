/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 29/08/2025
* Copyright :  S.Hamblett
*/

import 'package:colorize/colorize.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

///
/// Manages the MQTT client
///
class MqttManager {
  // Broker URL
  String _serverUrl = '';

  // Client Identifier
  String _clientIdentifier = '';

  late final MqttServerClient _client;

  // Subscribed topics
  List<String> _subscribedTopics = [];

  // Received messages
  List<MqttPublishMessage> _receivedMessages = [];

  MqttManager();
}
