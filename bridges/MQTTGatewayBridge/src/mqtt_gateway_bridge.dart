/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 05/12/2025
* Copyright :  S.Hamblett
*/

import 'package:a2a/a2a.dart';
import 'package:mcp_dart/mcp_dart.dart';

import 'log.dart';

/// MQTT Bridge
///
class MqttGatewayBridge extends A2AMCPBridge {
  MqttGatewayBridge() : super() {
    // Initialise the MQTT gateway tools
    _initialiseTools();
  }

  // Status callback
  Future<CallToolResult> _statusCallback({
    Map<String, dynamic>? args,
    RequestHandlerExtra? extra,
  }) async {
    if (args == null) {
      Log.warn('_registerAgentCallback - args are null');
      return CallToolResult.fromContent(
        content: [TextContent(text: '_registerAgentCallback - args are null')],
        isError: true,
      );
    }
  }

  // Initialise the MQTT Gateway tools
  void _initialiseTools() {
    // Status
    // Get the status of the MQTT Gateway
    var inputSchema = ToolInputSchema(
      properties: {
        "url": {"type": "string", "description": "The agent URL"},
      },
      required: ["url"],
    );
    var outputSchema = ToolOutputSchema(
      properties: {
        "agent_name": {"type": "string", "description": "Name of the agent"},
        "url": {"type": "string", "description": "Url of the agent"},
      },
      required: ["agent_name", "url"],
    );
    final registerAgent = Tool(
      name: 'register_agent',
      description: 'A2A Bridge Register Agent',
      inputSchema: inputSchema,
      outputSchema: outputSchema,
    );
    registerTool(registerAgent, _statusCallback);
  }
}

// Main server
void main() async {
  // Create and start the bridge
  Log.info('Creating the MQTT Gateway Bridge');
  MqttGatewayBridge mqttMcpBridge = MqttGatewayBridge();
  try {
    await mqttMcpBridge.startServer(
      port: 10005,
    ); // Set your port if you do not want the default
  } catch (e) {
    Log.fatal('MQTT Gateway Bridge failed to start $e');
    return;
  }
}
