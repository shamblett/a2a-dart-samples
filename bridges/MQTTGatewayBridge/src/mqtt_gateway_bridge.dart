// ignore_for_file: prefer_single_quotes
/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 05/12/2025
* Copyright :  S.Hamblett
*/

import 'dart:convert';

import 'package:a2a/a2a.dart';
import 'package:a2a_mcp_bridge/a2a_mcp_bridge.dart';
import 'package:mcp_dart/mcp_dart.dart';

import 'gateway_command.dart';
import 'log.dart';

/// MQTT Bridge
///
class MqttGatewayBridge extends A2AMCPBridge {
  static const mqttGatewayAgentName = 'MQTT Gateway Agent';
  static const serverName = 'MQTT Gateway Bridge';
  static const serverVersion = '1.0.0';

  /// Fail for send message
  static const fail = '';

  // The A2A Client
  A2AClient? _client;

  MqttGatewayBridge({super.name, super.version}) : super() {
    // Initialise the MQTT gateway tools
    _initialiseTools();
  }

  // Status callback
  Future<CallToolResult> _statusCallback({
    Map<String, dynamic>? args,
    RequestHandlerExtra? extra,
  }) async {
    // No arguments, just build and send the command.
    final GWCommand command = {};
    command[GatewayCommand.command] = GatewayCommand.status;
    final gwCommand = json.encode(command);
    Log.info('Sending status command');
    final res = await _sendMessage(gwCommand);

    // Check the result
    if (res == fail) {
      Log.warn('Status command failed');
      return CallToolResult.fromContent(
        content: [TextContent(text: '_statusCallback - status command failed')],
        isError: true,
      );
    }

    final result = json.decode(res);
    final content = {
      "content": [
        {"type": "text", "text": json.encode(result)},
      ],
      "structuredContent": result,
    };
    return CallToolResult.fromJson(content);
  }

  // Connect callback
  Future<CallToolResult> _connectCallback({
    Map<String, dynamic>? args,
    RequestHandlerExtra? extra,
  }) async {
    if (args == null) {
      Log.warn('_connectCallback - args are null');
      return CallToolResult.fromContent(
        content: [TextContent(text: '_connectCallback - args are null')],
        isError: true,
      );
    }

    // Build and send the command.
    final GWCommand command = args;
    command[GatewayCommand.command] = GatewayCommand.connect;
    final gwCommand = json.encode(command);
    Log.info('Sending connect command');
    final res = await _sendMessage(gwCommand);

    // Check the result
    if (res == fail) {
      Log.warn('Connect command failed');
      return CallToolResult.fromContent(
        content: [
          TextContent(text: '_connectCallback - connect command failed'),
        ],
        isError: true,
      );
    }

    final result = json.decode(res);
    final content = {
      "content": [
        {"type": "text", "text": json.encode(result)},
      ],
      "structuredContent": result,
    };
    return CallToolResult.fromJson(content);
  }

  // Subscribe callback
  Future<CallToolResult> _subscribeCallback({
    Map<String, dynamic>? args,
    RequestHandlerExtra? extra,
  }) async {
    if (args == null) {
      Log.warn('_subscribeCallback - args are null');
      return CallToolResult.fromContent(
        content: [TextContent(text: '_subscribeCallback - args are null')],
        isError: true,
      );
    }

    // Build and send the command.
    final GWCommand command = args;
    command[GatewayCommand.command] = GatewayCommand.subscribe;
    final gwCommand = json.encode(command);
    Log.info('Sending a subscribe command');
    final res = await _sendMessage(gwCommand);

    // Check the result
    if (res == fail) {
      Log.warn('Subscribe command failed');
      return CallToolResult.fromContent(
        content: [
          TextContent(text: '_subscribeCallback - subscribe command failed'),
        ],
        isError: true,
      );
    }

    final result = json.decode(res);
    final content = {
      "content": [
        {"type": "text", "text": json.encode(result)},
      ],
      "structuredContent": result,
    };
    return CallToolResult.fromJson(content);
  }

  // Unsubscribe callback
  Future<CallToolResult> _unsubscribeCallback({
    Map<String, dynamic>? args,
    RequestHandlerExtra? extra,
  }) async {
    if (args == null) {
      Log.warn('_unsubscribeCallback - args are null');
      return CallToolResult.fromContent(
        content: [TextContent(text: '_unsubscribeCallback - args are null')],
        isError: true,
      );
    }

    // Build and send the command.
    final GWCommand command = args;
    command[GatewayCommand.command] = GatewayCommand.unsubscribe;
    final gwCommand = json.encode(command);
    Log.info('Sending an unsubscribe command');
    final res = await _sendMessage(gwCommand);

    // Check the result
    if (res == fail) {
      Log.warn('Unsubscribe command failed');
      return CallToolResult.fromContent(
        content: [
          TextContent(
            text: '_unsubscribeCallback - unsubscribe command failed',
          ),
        ],
        isError: true,
      );
    }

    final result = json.decode(res);
    final content = {
      "content": [
        {"type": "text", "text": json.encode(result)},
      ],
      "structuredContent": result,
    };
    return CallToolResult.fromJson(content);
  }

  // Publish callback
  Future<CallToolResult> _publishCallback({
    Map<String, dynamic>? args,
    RequestHandlerExtra? extra,
  }) async {
    if (args == null) {
      Log.warn('_publishCallback - args are null');
      return CallToolResult.fromContent(
        content: [TextContent(text: '_publishCallback - args are null')],
        isError: true,
      );
    }

    // Build and send the command.
    final GWCommand command = args;
    command[GatewayCommand.command] = GatewayCommand.publish;
    final gwCommand = json.encode(command);
    Log.info('Sending a publish command');
    final res = await _sendMessage(gwCommand);

    // Check the result
    if (res == fail) {
      Log.warn('Publish command failed');
      return CallToolResult.fromContent(
        content: [
          TextContent(text: '_publishCallback - publish command failed'),
        ],
        isError: true,
      );
    }

    final result = json.decode(res);
    final content = {
      "content": [
        {"type": "text", "text": json.encode(result)},
      ],
      "structuredContent": result,
    };
    return CallToolResult.fromJson(content);
  }

  // Get messages callback
  Future<CallToolResult> _getMessagesCallback({
    Map<String, dynamic>? args,
    RequestHandlerExtra? extra,
  }) async {
    if (args == null) {
      Log.warn('_getMessagesCallback - args are null');
      return CallToolResult.fromContent(
        content: [TextContent(text: '_getMessagesCallback - args are null')],
        isError: true,
      );
    }

    // Build and send the command.
    final GWCommand command = args;
    command[GatewayCommand.command] = GatewayCommand.messages;
    final gwCommand = json.encode(command);
    Log.info('Sending a get messages command');
    final res = await _sendMessage(gwCommand);

    // Check the result
    if (res == fail) {
      Log.warn('get messages command failed');
      return CallToolResult.fromContent(
        content: [
          TextContent(
            text: '_getMessagesCallback - get messages command failed',
          ),
        ],
        isError: true,
      );
    }

    final result = json.decode(res);
    final content = {
      "content": [
        {"type": "text", "text": json.encode(result)},
      ],
      "structuredContent": result,
    };
    return CallToolResult.fromJson(content);
  }

  // Disconnect callback
  Future<CallToolResult> _disconnectCallback({
    Map<String, dynamic>? args,
    RequestHandlerExtra? extra,
  }) async {
    // No arguments, just build and send the command.
    final GWCommand command = {};
    command[GatewayCommand.command] = GatewayCommand.disconnect;
    final gwCommand = json.encode(command);
    Log.info('Sending disconnect command');
    final res = await _sendMessage(gwCommand);

    // Check the result
    if (res == fail) {
      Log.warn('Disconnect command failed');
      return CallToolResult.fromContent(
        content: [
          TextContent(text: '_disconnectCallback - disconnect command failed'),
        ],
        isError: true,
      );
    }

    final result = json.decode(res);
    final content = {
      "content": [
        {"type": "text", "text": json.encode(result)},
      ],
      "structuredContent": result,
    };
    return CallToolResult.fromJson(content);
  }

  // Initialise the MQTT Gateway tools
  void _initialiseTools() {
    // Status
    var inputSchema = ToolInputSchema(properties: {});
    var outputSchema = ToolOutputSchema(
      properties: {
        "result": {
          "type": "string",
          "description": "The status of the MQTT Gateway",
        },
      },
      required: ["result"],
    );
    var registerAgent = Tool(
      name: 'status',
      description: 'MQTTGateway status',
      inputSchema: inputSchema,
      outputSchema: outputSchema,
    );
    registerTool(registerAgent, _statusCallback);

    // Connect
    inputSchema = ToolInputSchema(
      properties: {
        "broker_url": {
          "type": "string",
          "description": "URL of the MQTT broker",
        },
        "port": {
          "type": "integer",
          "description": "The MQTT Broker port if not 1883",
        },
        "client_id": {
          "type": "String",
          "description": "The MQTT client id to use",
        },
        "user_name": {
          "type": "String",
          "description": "The MQTT Broker user name",
        },
        "password": {
          "type": "String",
          "description": "The MQTT Broker password",
        },
      },
      required: ["broker_url"],
    );
    outputSchema = ToolOutputSchema(
      properties: {
        "result": {
          "type": "string",
          "description": "The connect command success/fail indicator",
        },
      },
      required: ["result"],
    );
    registerAgent = Tool(
      name: 'connect',
      description: 'Connect the MQTT Gateway to an MQTT Broker',
      inputSchema: inputSchema,
      outputSchema: outputSchema,
    );
    registerTool(registerAgent, _connectCallback);

    // Subscribe
    inputSchema = ToolInputSchema(
      properties: {
        "topic": {"type": "string", "description": "The subscription topic"},
        "qos": {
          "type": "integer",
          "description": "The QoS for the subscription",
        },
      },
      required: ["topic"],
    );
    outputSchema = ToolOutputSchema(
      properties: {
        "result": {
          "type": "string",
          "description": "The subscribe command success/fail indicator",
        },
      },
      required: ["result"],
    );
    registerAgent = Tool(
      name: 'subscribe',
      description: 'Subscribe to an MQTT topic',
      inputSchema: inputSchema,
      outputSchema: outputSchema,
    );
    registerTool(registerAgent, _subscribeCallback);

    // Unsubscribe
    inputSchema = ToolInputSchema(
      properties: {
        "topic": {"type": "string", "description": "The unsubscription topic"},
      },
      required: ["topic"],
    );
    outputSchema = ToolOutputSchema(
      properties: {
        "result": {
          "type": "string",
          "description": "The unsubscribe command success/fail indicator",
        },
      },
      required: ["result"],
    );
    registerAgent = Tool(
      name: 'unsubscribe',
      description: 'Unsubscribe from an MQTT topic',
      inputSchema: inputSchema,
      outputSchema: outputSchema,
    );
    registerTool(registerAgent, _unsubscribeCallback);

    // Publish
    inputSchema = ToolInputSchema(
      properties: {
        "topic": {
          "type": "string",
          "description": "The MQTT topic to publish to",
        },
        "qos": {
          "type": "integer",
          "description": "The QoS for the published message",
        },
        "payload": {
          "type": "String",
          "description": "The payload of the published message",
        },
      },
      required: ["topic", "payload"],
    );
    outputSchema = ToolOutputSchema(
      properties: {
        "result": {
          "type": "string",
          "description": "The publish command success/fail indicator",
        },
      },
      required: ["result"],
    );
    registerAgent = Tool(
      name: 'publish',
      description: 'Publish an MQTT message',
      inputSchema: inputSchema,
      outputSchema: outputSchema,
    );
    registerTool(registerAgent, _publishCallback);

    // Get Messages
    inputSchema = ToolInputSchema(
      properties: {
        "topic": {"type": "string", "description": "The message topic"},
      },
      required: ["topic"],
    );
    outputSchema = ToolOutputSchema(
      properties: {
        "result": {
          "type": "string",
          "description": "The get messages command success/fail indicator",
        },
      },
      required: ["result"],
    );
    registerAgent = Tool(
      name: 'get_messages',
      description: 'Get received messages from an MQTT topic',
      inputSchema: inputSchema,
      outputSchema: outputSchema,
    );
    registerTool(registerAgent, _getMessagesCallback);

    // Disconnect
    inputSchema = ToolInputSchema(properties: {});
    outputSchema = ToolOutputSchema(
      properties: {
        "result": {
          "type": "string",
          "description": "The disconnect command success indicator",
        },
      },
      required: ["result"],
    );
    registerAgent = Tool(
      name: 'disconnect',
      description: 'MQTTGateway disconnect command',
      inputSchema: inputSchema,
      outputSchema: outputSchema,
    );
    registerTool(registerAgent, _disconnectCallback);
  }

  // Create the A2A client
  Future<void> _createA2AClient(String url) async {
    _client = A2AClient(url);
    await Future.delayed(Duration(seconds: 2));
    Log.info('A2A client created for URL [$url]');
  }

  // Send a message to the MQTT Gateway
  // Creates the A2A client if one is not yet created
  // Returns the response, if empty a failure has occurred
  Future<String> _sendMessage(String message) async {
    // Check if the A2A client has been created, if not create one
    String url = '';
    if (_client == null) {
      if (isAgentRegistered(mqttGatewayAgentName)) {
        final agentCard = registeredAgent(mqttGatewayAgentName);
        if (agentCard == null) {
          Log.fatal('MQTT Gateway agent is registered but has no agent card');
          return fail;
        }
        url = agentCard.url;
        await _createA2AClient(url);
      } else {
        Log.warn(
          'MQTT Gateway agent is not yet registered, please register it',
        );
        return fail;
      }
    }

    // Send the message
    String responseText = fail;
    try {
      final taskId = uuid.v4();
      addTaskToAgent(taskId, url);
      final clientMessage = A2AMessage()
        ..contextId = uuid.v4()
        ..messageId = uuid.v4()
        ..parts = [A2ATextPart()..text = message]
        ..role = 'user';
      final params = A2AMessageSendParams()
        ..message = clientMessage
        ..metadata = {"task_id": taskId};
      // Process the response, only assemble text responses for now.
      final response = await _client!.sendMessage(params);
      if (response.isError) {
        final errorResponse = response as A2AJSONRPCErrorResponseS;
        Log.warn(
          '_sendMessageCallback - error response ${errorResponse.error?.rpcErrorCode} from agent',
        );
        return fail;
      } else {
        final successResponse = response as A2ASendMessageSuccessResponse;
        // Check for a message or task
        if (successResponse.result is A2AMessage) {
          final success = successResponse.result as A2AMessage;
          final decodesParts = A2AUtilities.decodeParts(success.parts);
          responseText += decodesParts.allText;
        } else {
          // Task, assume the task has completed Ok.
          final success = successResponse.result as A2ATask;
          if (success.status?.message != null) {
            final decodesParts = A2AUtilities.decodeParts(
              success.status?.message?.parts,
            );
            responseText += decodesParts.allText;
          }
          if (success.artifacts != null) {
            for (final artifact in success.artifacts!) {
              final decodesParts = A2AUtilities.decodeParts(artifact.parts);
              responseText += decodesParts.allText;
            }
          }
        }
      }
    } catch (e) {
      Log.warn('Exception raised in send Message, exception is $e');
      return fail;
    }
    // Return the response
    return responseText;
  }
}

// Main server
void main() async {
  // Create and start the bridge
  Log.info('Creating the MQTT Gateway Bridge');
  MqttGatewayBridge mqttMcpBridge = MqttGatewayBridge(
    name: MqttGatewayBridge.serverName,
    version: MqttGatewayBridge.serverVersion,
  );
  try {
    await mqttMcpBridge.startServer(
      port: 10005,
    ); // Set your port if you do not want the default
  } catch (e) {
    Log.fatal('MQTT Gateway Bridge failed to start $e');
    return;
  }
}
