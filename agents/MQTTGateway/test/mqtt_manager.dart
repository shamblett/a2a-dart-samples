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
  test('Construction', () {
    final ms = MessageStore();
    final mm = MqttManager(ms);
    expect(mm.isConnected, isFalse);
  });
}
