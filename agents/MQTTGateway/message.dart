/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'package:mqtt_client/mqtt_client.dart';

///
/// MQTT message
///
class Message {
  // Timestamp
  final String _timestamp;

  // Publish message
  final MqttPublishMessage _publishMessage;

  String get timestamp => _timestamp;

  MqttPublishMessage get publishMessage => _publishMessage;

  String get payload =>
      MqttPublishPayload.bytesToStringAsString(_publishMessage.payload.message);

  Message(this._timestamp, this._publishMessage);
}
