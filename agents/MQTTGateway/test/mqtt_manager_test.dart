/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 11/11/2025
* Copyright :  S.Hamblett
*/

@TestOn('vm')
library;

import 'package:test/test.dart';

import '../mqtt_manager.dart';
import '../message_store.dart';

void main() {
  const broker = 'localhost'; // Start a local MQTT broker
  const clientId = 'SJH-A2AClientId';
  const topic1 = 'SJH-A2ATopic1';
  const topic2 = 'SJH-A2ATopic2';
  const t1Payload = 't1Payload';
  const t2Payload = 't2Payload';

  test('Construction', () {
    final ms = MessageStore();
    final mm = MqttManager(ms);
    expect(mm.isConnected, isFalse);
  });
  test('Connect - exception', () async {
    final ms = MessageStore();
    final mm = MqttManager(ms);
    final res = await mm.connect('');
    expect(res, isFalse);
  });
  test('Connect/Disconnect', () async {
    final ms = MessageStore();
    final mm = MqttManager(ms);
    bool res = await mm.connect(broker, 1883, clientId);
    expect(res, isTrue);
    expect(mm.isConnected, isTrue);
    res = await mm.connect(broker, 1883, clientId);
    expect(res, isFalse);
    res = mm.disconnect();
    expect(res, isTrue);
    expect(mm.isConnected, isFalse);
    res = mm.disconnect();
    expect(res, isTrue);
  });
  test('Subscribe/Unsubscribe', () async {
    final ms = MessageStore();
    final mm = MqttManager(ms);
    bool res = mm.subscribe(topic1);
    expect(res, isFalse);
    res = mm.unsubscribe(topic1);
    expect(res, isFalse);
    res = await mm.connect(broker, 1883, clientId);
    expect(res, isTrue);
    expect(mm.isConnected, isTrue);
    res = mm.subscribe('');
    expect(res, isFalse);
    res = mm.subscribe(topic1);
    expect(res, isTrue);
    res = mm.unsubscribe('');
    expect(res, isFalse);
    res = mm.unsubscribe(topic1);
    expect(res, isTrue);
    res = mm.disconnect();
    expect(res, isTrue);
  });

  test('Publish/Receive', () async {
    final ms = MessageStore();
    final mm = MqttManager(ms);
    bool res = mm.publish(topic1, t1Payload);
    expect(res, isFalse);
    res = await mm.connect(broker, 1883, clientId);
    expect(res, isTrue);
    expect(mm.isConnected, isTrue);
    res = mm.subscribe(topic1);
    expect(res, isTrue);
    res = mm.subscribe(topic2);
    expect(res, isTrue);
    res = mm.publish(topic1, t1Payload);
    expect(res, isTrue);
    res = mm.publish(topic2, t2Payload);
    expect(res, isTrue);
    expect(ms.hasMessages(topic1), isTrue);
    expect(ms.hasMessages(topic2), isTrue);
    final mess1 = ms.getMessages(topic1);
    final mess2 = ms.getMessages(topic2);
    expect(mess1.first.payload, t1Payload);
    expect(mess2.first.payload, t2Payload);
    res = mm.unsubscribe(topic1);
    expect(res, isTrue);
    res = mm.disconnect();
    expect(res, isTrue);
  });
}
