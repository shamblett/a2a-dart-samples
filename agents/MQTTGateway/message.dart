/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'package:a2a/a2a.dart';
import 'package:mqtt_client/mqtt_client.dart';

///
/// MQTT message wrapper.
///
class Message {
  // Timestamp
  String _timestamp = '';

  // Publish message
  final MqttPublishMessage _publishMessage;

  String get timestamp => _timestamp;

  MqttPublishMessage get publishMessage => _publishMessage;

  String get payload =>
      MqttPublishPayload.bytesToStringAsString(_publishMessage.payload.message);

  Message(this._publishMessage) {
    _timestamp = A2AUtilities.getCurrentTimestamp();
  }
}
