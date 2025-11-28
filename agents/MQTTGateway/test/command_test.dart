/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 11/11/2025
* Copyright :  S.Hamblett
*/

@TestOn('vm')
library;

import 'package:test/test.dart';

import '../src/command.dart';
import '../src/mqtt_manager.dart';

void main() {
  test('Empty command', () async {
    final cmd = Command.fromJson('');
    expect(cmd, isNull);
  });
  test('Invalid JSON', () async {
    final cmd = Command.fromJson('jr///ooo');
    expect(cmd, isNull);
  });
  test('No Command Key', () async {
    final cmd = Command.fromJson('{ "billy" : "fred" }');
    expect(cmd, isNull);
  });
  test('Connect - No Broker URL', () async {
    final cmd = Command.fromJson(
      '{ "command" : "connect", "client_id" : "www" }',
    );
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isFalse);
  });
  test('Connect - Defaults', () async {
    final cmd = Command.fromJson(
      '{ "command" : "connect", "broker_url" : "localhost"}',
    );
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isTrue);
    expect(cmd is Connect, isTrue);
    final connect = cmd as Connect;
    expect(connect.brokerUrl, 'localhost');
    expect(connect.port, 1883);
    expect(connect.clientId, MqttManager.defaultClientId);
    expect(connect.username, isNull);
    expect(connect.password, isNull);
  });
  test('Connect - All parameters', () async {
    final cmd = Command.fromJson(
      '{ "command" : "connect", "broker_url" : "localhost", "port" : 2000, "client_id" : "www", "user_name" : "billy", "password" : "dd"}',
    );
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isTrue);
    expect(cmd is Connect, isTrue);
    final connect = cmd as Connect;
    expect(connect.brokerUrl, 'localhost');
    expect(connect.port, 2000);
    expect(connect.clientId, 'www');
    expect(connect.username, 'billy');
    expect(connect.password, 'dd');
  });
}
