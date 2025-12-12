@TestOn('vm')
library;

import 'package:test/test.dart';

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
bool gatewayIsRegistered = false;

Future<void> registerGateway(Client client) async {
  if (!gatewayIsRegistered) {
    final paramsRegister = CallToolRequestParams(
      name: 'register_agent',
      arguments: {'url': agentUrl},
    );
    var result = await client.callTool(paramsRegister);
    expect(result.isError, isNull);
    var content = result.structuredContent;
    expect(content['agent_name'], 'MQTT Gateway Agent');
    expect(content['url'], agentUrl);
    gatewayIsRegistered = true;
  }
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
    final params = CallToolRequestParams(name: 'status');
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
    final paramsStatus = CallToolRequestParams(name: 'status');
    var result = await client.callTool(paramsStatus);
    expect(result.isError, isNull);
    var content = result.structuredContent;
    expect(content, {'result': 'not_connected'});
  });
  test('Connect - no args', () async {
    await registerGateway(client);
    final paramsStatus = CallToolRequestParams(name: 'connect');
    var result = await client.callTool(paramsStatus);
    expect(result.isError, isTrue);
    final content = result.content;
    expect(content.first.type, 'text');
    expect(
      (content.first as TextContent).text,
      '_connectCallback - args are null',
    );
  });
  test('Connect - basic', () async {
    await registerGateway(client);
    final paramsStatus = CallToolRequestParams(name: 'connect',
      arguments: {'broker_url': brokerUrl},);
    var result = await client.callTool(paramsStatus);
    expect(result.isError, isNull);
    var content = result.structuredContent;
    expect(content, {'result': 'success'});
  });
}
