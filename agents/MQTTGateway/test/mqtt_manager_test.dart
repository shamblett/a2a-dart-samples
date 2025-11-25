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
  const topic1 = 'AJH-A2ATopic1';
  const topic2 = 'AJH-A2ATopic2';

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
}
