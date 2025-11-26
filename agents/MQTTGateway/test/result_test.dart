/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 11/11/2025
* Copyright :  S.Hamblett
*/

@TestOn('vm')
library;

import 'dart:convert';

import 'package:a2a/a2a.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:test/test.dart';

import '../command.dart';
import '../message.dart';
import '../result.dart';

void main() {
  test('toJson', () {
    final pl1 = MqttClientPayloadBuilder()..addString('payload1');
    final pl2 = MqttClientPayloadBuilder()..addString('payload2');
    final pm1 = MqttPublishMessage().toTopic('t1').publishData(pl1.payload!);
    final pm2 = MqttPublishMessage().toTopic('t2').publishData(pl2.payload!);
    final m1 = Message(pm1);
    final m2 = Message(pm2);
    final r1 = Result();
    expect(r1.toJson(), '{ "result" : "fail" }');
    r1.command = Command.getMessages;
    r1.result = Result.success;
    expect(r1.toJson(), '{ "result" : "success" }');
    final r1Map = json.decode(r1.toJson());
    expect(r1Map.length, 1);
    expect(r1Map['result'], Result.success);
    final r2 = Result();
    r2.command = Command.getMessages;
    r2.result = Result.success;
    r2.messages = [m1, m2];
    final tn = A2AUtilities.getCurrentTimestamp().split('.').first;
    expect(
      r2.toJson(),
      '{ "result" : "success", "messages" : [ { "payload" : "payload1", "timestamp" : "$tn" }, { "payload" : "payload2", "timestamp" : "$tn" } ] }',
    );
    final r2Map = json.decode(r2.toJson());
    expect(r2Map.length, 2);
    expect(r2Map['result'], Result.success);
    expect(r2Map['messages'].length, 2);
    expect(r2Map['messages'].first['payload'], 'payload1');
    expect(r2Map['messages'][1]['payload'], 'payload2');
    expect(r2Map['messages'].first['timestamp'], tn);
    expect(r2Map['messages'][1]['timestamp'], tn);
  });
}
