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

void main() {
  test('Empty command', () async {
    final cmd = Command.fromJson('');
    expect(cmd, isNull);
  });
  test('Invalid JSON', () async {
    final cmd = Command.fromJson('jr///ooo');
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
    final cmd = Command.fromJson('{ "billy" : "fred" }');
    expect(cmd, isNull);
  });
}
