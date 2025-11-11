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
  });
}
