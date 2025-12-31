@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';

import 'package:a2a/a2a.dart';
import 'package:mcp_dart/mcp_dart.dart';

class AuthProvider implements OAuthClientProvider {
  /// Get current tokens if available
  @override
  Future<OAuthTokens?> tokens() async =>
      OAuthTokens(accessToken: '', refreshToken: '');

  /// Redirect to authorization endpoint
  @override
  Future<void> redirectToAuthorization() async {
    return;
  }
}

final implementation = Implementation(
  name: 'MQTT Gateway Bridge Manual Test',
  version: '1.0.0',
);
final options = ClientOptions();
final client = Client(implementation, options: options);

final serverUrl = Uri.parse('http://localhost:10005/mcp');
final serverOptions = StreamableHttpClientTransportOptions(
  authProvider: AuthProvider(),
);
final clientTransport = StreamableHttpClientTransport(
  serverUrl,
  opts: serverOptions,
);

const agentUrl = 'http://localhost:10004';
const brokerUrl = 'localhost';

Future<void> registerGateway(Client client) async {
  final paramsRegister = CallToolRequest(
    name: 'register_agent',
    arguments: {'url': agentUrl},
  );
  var result = await client.callTool(paramsRegister);
  expect(result.isError, isFalse);
  var content = result.structuredContent;
  expect(content!['agent_name'], 'MQTT Gateway Agent');
  expect(content['url'], agentUrl);
}

Future<void> main() async {
  // Start the client
  await client.connect(clientTransport);

  test('Server Version', () async {
    final serverVersion = client.getServerVersion();
    expect(serverVersion, isNotNull);
    expect(serverVersion?.name, 'MQTT Gateway Bridge');
    expect(serverVersion?.version, '1.0.0');
  });

  test('Status - not registered', () async {
    final params = CallToolRequest(name: 'status');
    final result = await client.callTool(params);
    expect(result.isError, isTrue);
    final content = result.content;
    expect(content.first.type, 'text');
    expect(
      (content.first as TextContent).text,
      '_statusCallback - status command failed',
    );
  });

  test('Status - valid', () async {
    await registerGateway(client);
    final paramsStatus = CallToolRequest(name: 'status');
    var result = await client.callTool(paramsStatus);
    expect(result.isError, isFalse);
    var content = result.structuredContent;
    expect(content, {'result': 'not_connected'});
  });
  test('Connect - no args', () async {
    final paramsStatus = CallToolRequest(name: 'connect');
    var result = await client.callTool(paramsStatus);
    expect(result.isError, isTrue);
    final content = result.content;
    expect(content.first.type, 'text');
    expect(
      (content.first as TextContent).text,
      '_connectCallback - args are null',
    );
  });
  test('Connect', () async {
    var paramsStatus = CallToolRequest(
      name: 'connect',
      arguments: {'broker_url': brokerUrl},
    );
    var result = await client.callTool(paramsStatus);
    expect(result.isError, isFalse);
    var content = result.structuredContent;
    expect(content, {'result': 'success'});
    paramsStatus = CallToolRequest(name: 'status');
    result = await client.callTool(paramsStatus);
    expect(result.isError, isFalse);
    content = result.structuredContent;
    expect(content, {'result': 'connected'});
  });
  test('Subscribe', () async {
    var paramsStatus = CallToolRequest(
      name: 'subscribe',
      arguments: {'topic': 'theTopic'},
    );
    var result = await client.callTool(paramsStatus);
    expect(result.isError, isFalse);
    var content = result.structuredContent;
    expect(content, {'result': 'success'});
  });
  test('Publish', () async {
    var paramsStatus = CallToolRequest(
      name: 'publish',
      arguments: {'topic': 'theTopic', 'payload': 'thePayload'},
    );
    var result = await client.callTool(paramsStatus);
    expect(result.isError, isFalse);
    var content = result.structuredContent;
    expect(content, {'result': 'success'});
  });
  test('Get Messages', () async {
    var paramsStatus = CallToolRequest(
      name: 'get_messages',
      arguments: {'topic': 'theTopic'},
    );
    var result = await client.callTool(paramsStatus);
    expect(result.isError, isFalse);
    var content = result.structuredContent;
    final tn = A2AUtilities.getCurrentTimestamp().split('.').first;
    expect(
      json.encode(content),
      '{"result":"success","messages":[{"payload":"thePayload","timestamp":"$tn"}]}',
    );
  });
  test('Unsubscribe', () async {
    var paramsStatus = CallToolRequest(
      name: 'unsubscribe',
      arguments: {'topic': 'theTopic'},
    );
    var result = await client.callTool(paramsStatus);
    expect(result.isError, isFalse);
    var content = result.structuredContent;
    expect(content, {'result': 'success'});
  });
  test('Disconnect', () async {
    var paramsStatus = CallToolRequest(name: 'disconnect');
    var result = await client.callTool(paramsStatus);
    expect(result.isError, isFalse);
    var content = result.structuredContent;
    expect(content, {'result': 'success'});
    paramsStatus = CallToolRequest(name: 'status');
    result = await client.callTool(paramsStatus);
    expect(result.isError, isFalse);
    content = result.structuredContent;
    expect(content, {'result': 'not_connected'});
  });
}
