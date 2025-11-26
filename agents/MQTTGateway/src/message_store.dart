/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'dart:collection';

import 'message.dart';

///
/// Message storage and retrieval
///
class MessageStore {
  // Message queue indexed by topic
  final Map<String, Queue<Message>> _messages = {};
  MessageStore();

  /// Does a topic have messages
  bool hasMessages(String topic) =>
      _messages[topic] != null ? _messages[topic]!.isNotEmpty : false;

  /// Get the next message for a topic.
  Message? getMessage(String topic) =>
      hasMessages(topic) ? _messages[topic]?.removeFirst() : null;

  /// Get all messages for a topic
  List<Message> getMessages(String topic) {
    List<Message> ret = [];
    if (hasMessages(topic)) {
      ret = _messages[topic]!.toList();
      _messages[topic]!.clear();
    }
    return ret;
  }

  /// Clear all messages from a topic
  void clearTopic(String topic) {
    if (hasMessages(topic)) {
      _messages[topic]?.clear();
    }
  }

  /// Add a message
  void addMessage(String topic, Message message) {
    if (_messages[topic] == null) {
      _messages[topic] = Queue<Message>();
    }
    _messages[topic]?.add(message);
  }
}
