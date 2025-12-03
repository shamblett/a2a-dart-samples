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
  test('Connect - All Parameters', () async {
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
  test('Disconnect', () async {
    final cmd = Command.fromJson('{ "command" : "disconnect" }');
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isTrue);
    expect(cmd is Disconnect, isTrue);
  });
  test('Subscribe - No topic', () async {
    final cmd = Command.fromJson('{ "command" : "subscribe" }');
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isFalse);
    expect(cmd is Subscribe, isTrue);
  });
  test('Subscribe - Default QoS', () async {
    final cmd = Command.fromJson(
      '{ "command" : "subscribe", "topic" : "theTopic" }',
    );
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isTrue);
    expect(cmd is Subscribe, isTrue);
    final subscribe = cmd as Subscribe;
    expect(subscribe.topic, 'theTopic');
    expect(subscribe.qos, 0);
  });
  test('Subscribe - All Parameters', () async {
    final cmd = Command.fromJson(
      '{ "command" : "subscribe", "topic" : "theTopic", "qos" : 2 }',
    );
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isTrue);
    expect(cmd is Subscribe, isTrue);
    final subscribe = cmd as Subscribe;
    expect(subscribe.topic, 'theTopic');
    expect(subscribe.qos, 2);
  });

  test('Unsubscribe - No topic', () async {
    final cmd = Command.fromJson('{ "command" : "unsubscribe" }');
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isFalse);
    expect(cmd is Unsubscribe, isTrue);
  });
  test('Publish - No topic', () async {
    final cmd = Command.fromJson('{ "command" : "publish" }');
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isFalse);
    expect(cmd is Publish, isTrue);
  });
  test('Publish - No payload', () async {
    final cmd = Command.fromJson(
      '{ "command" : "publish", "topic" : "theTopic" }',
    );
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isFalse);
    expect(cmd is Publish, isTrue);
  });

  test('Publish - Defaults', () async {
    final cmd = Command.fromJson(
      '{ "command" : "publish", "topic" : "theTopic", "payload" : "thePayload" }',
    );
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isTrue);
    expect(cmd is Publish, isTrue);
    final publish = cmd as Publish;
    expect(publish.topic, 'theTopic');
    expect(publish.payload, 'thePayload');
    expect(publish.qos, 0);
  });
  test('Publish - All Parameters', () async {
    final cmd = Command.fromJson(
      '{ "command" : "publish", "topic" : "theTopic", "payload" : "thePayload", "qos" : 2 }',
    );
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isTrue);
    expect(cmd is Publish, isTrue);
    final publish = cmd as Publish;
    expect(publish.topic, 'theTopic');
    expect(publish.payload, 'thePayload');
    expect(publish.qos, 2);
  });
  test('Get Messages - No topic', () async {
    final cmd = Command.fromJson('{ "command" : "get_messages" }');
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isFalse);
    expect(cmd is GetMessages, isTrue);
  });
  test('Get Messages - All parameters', () async {
    final cmd = Command.fromJson(
      '{ "command" : "get_messages", "topic" : "theTopic" }',
    );
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isTrue);
    expect(cmd is GetMessages, isTrue);
    final getMessages = cmd as GetMessages;
    expect(getMessages.topic, 'theTopic');
  });
  test('Status', () async {
    final cmd = Command.fromJson('{ "command" : "status" }');
    expect(cmd, isNotNull);
    expect(cmd!.isValid, isTrue);
    expect(cmd is Status, isTrue);
  });
}
