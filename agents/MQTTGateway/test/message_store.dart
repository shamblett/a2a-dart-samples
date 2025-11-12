/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 11/11/2025
* Copyright :  S.Hamblett
*/

@TestOn('vm')
library;

import 'package:mqtt_client/mqtt_client.dart';
import 'package:test/test.dart';

import '../message.dart';
import '../message_store.dart';

void main() {
  group('Message', () {
    test('Construction', () {
      final message = Message(MqttPublishMessage());
      expect(message.timestamp.isNotEmpty, isTrue);
    });
  });
  group('Message Store', () {
    test('Construction', () {
      final store = MessageStore();
      expect(store.hasMessages('topic'), isFalse);
      expect(store.getMessage('topic'), isNull);
      expect(store.getMessages('topic'), []);
    });
    test('API - single message', () {
      final store = MessageStore();
      final message = Message(
        MqttPublishMessage()..withQos(MqttQos.exactlyOnce),
      );
      store.addMessage('topic1', message);
      expect(store.hasMessages('topic1'), isTrue);
      final storeMessage = store.getMessage('topic1');
      expect(store.hasMessages('topic1'), isFalse);
      expect(storeMessage, isNotNull);
      expect(storeMessage?.timestamp.isNotEmpty, isTrue);
      expect(storeMessage?.publishMessage.header?.qos, MqttQos.exactlyOnce);
      store.addMessage('topic1', message);
      expect(store.hasMessages('topic1'), isTrue);
      store.clearTopic('topic1');
      expect(store.hasMessages('topic1'), isFalse);
    });
    test('API - all messages', () {
      final store = MessageStore();
      final message1 = Message(
        MqttPublishMessage()..withQos(MqttQos.exactlyOnce),
      );
      final message2 = Message(
        MqttPublishMessage()..withQos(MqttQos.atLeastOnce),
      );
      final message3 = Message(
        MqttPublishMessage()..withQos(MqttQos.atMostOnce),
      );
      store.addMessage('topic1', message1);
      store.addMessage('topic1', message2);
      store.addMessage('topic1', message3);
      expect(store.hasMessages('topic1'), isTrue);
      final storeMessages = store.getMessages('topic1');
      expect(store.hasMessages('topic1'), isFalse);
      expect(storeMessages.isNotEmpty, isTrue);
      expect(storeMessages.length, 3);
      expect(storeMessages[0].timestamp.isNotEmpty, isTrue);
      expect(storeMessages[0].publishMessage.header?.qos, MqttQos.exactlyOnce);
      expect(storeMessages[1].timestamp.isNotEmpty, isTrue);
      expect(storeMessages[1].publishMessage.header?.qos, MqttQos.atLeastOnce);
      expect(storeMessages[2].timestamp.isNotEmpty, isTrue);
      expect(storeMessages[2].publishMessage.header?.qos, MqttQos.atMostOnce);
    });
  });
}
