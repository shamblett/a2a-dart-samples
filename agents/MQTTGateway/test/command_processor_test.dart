/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 11/11/2025
* Copyright :  S.Hamblett
*/

@TestOn('vm')
library;

import 'package:test/test.dart';

import '../src/command_processor.dart';
import '../src/mqtt_manager.dart';
import '../src/message_store.dart';
import '../src/result.dart';

void main() {
  group('Validity', () {
    test('Empty command', () async {
      final ms = MessageStore();
      final mm = MqttManager(ms);
      final cp = CommandProcessor(ms, mm);
      String command = '';
      expect(await cp.executeCommand(command), Result().toJson());
    });
    test('Invalid JSON', () async {
      final ms = MessageStore();
      final mm = MqttManager(ms);
      final cp = CommandProcessor(ms, mm);
      String command = 'jr///ooo';
      expect(await cp.executeCommand(command), Result().toJson());
    });
    test('Invalid command', () async {
      final ms = MessageStore();
      final mm = MqttManager(ms);
      final cp = CommandProcessor(ms, mm);
      String command = '{ "command" : "billy" }';
      expect(await cp.executeCommand(command), Result().toJson());
    });
  });
  group('Connect', () {
    test('No broker Url', () async {
      final ms = MessageStore();
      final mm = MqttManager(ms);
      final cp = CommandProcessor(ms, mm);
      String command = '{ "command" : "connect", "password" : "www" }';
      expect(await cp.executeCommand(command), Result().toJson());
    });
  });
}
