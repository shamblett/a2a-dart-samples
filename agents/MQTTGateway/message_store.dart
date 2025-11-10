/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'dart:collection';

import 'package:mqtt_client/mqtt_client.dart';

///
/// MQTT message storage and retrieval
///
class MessageStore {
  // Message queue indexed by topic
  final Map<String, Queue<MqttPublishMessage>> _messages = {};
  MessageStore();

  /// Get the next message for a topic.
  MqttPublishMessage? getMessage(String topic) =>
      _messages[topic]?.removeFirst();

  /// Get all messages for a topic
  List<MqttPublishMessage>? getMessages(String topic) =>
      _messages[topic]?.toList();

  /// Does a topic have messages
  bool hasMessages(String topic) => _messages[topic] != null;

  /// Clear all messages from a topic
  void clearTopic(String topic) {
    if (hasMessages(topic)) {
      _messages[topic]?.clear();
    }
  }
}
