/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'package:a2a/a2a.dart';
import 'package:colorize/colorize.dart';

import 'mqtt_manager.dart';
import 'message_store.dart';

/// The MQTT Gateway A2A Sample
///
/// Status information is printed to the console, blue is for information,
/// yellow for an event that has occurred and red for failure. If you enable
/// server debug this output will be in green.

// Agent Card
final mqttGatewayCard = A2AAgentCard()
  ..name = 'MQTT Gateway Agent'
  ..description = 'An agent that allows communication with MQTT devices.'
  ..url = 'http://localhost:10004/'
  ..agentProvider = (A2AAgentProvider()
    ..organization = 'A2A Dart Samples'
    ..url = 'https://github.com/shamblett/a2a-dart-samples')
  ..version = '1.0.0'
  ..capabilities = (A2AAgentCapabilities()
    ..streaming =
        true // Supports streaming
    ..pushNotifications =
        false //  Assuming not implemented for this agent yet
    ..stateTransitionHistory = false)
  ..securitySchemes =
      null // Or define actual security schemes if any
  ..security = null
  ..defaultInputModes = ['text/plain']
  ..defaultOutputModes = ['text/plain']
  ..skills = ([
    A2AAgentSkill()
      ..id = 'mqttgateway'
      ..name = 'MQTT Gateway'
      ..description = 'Allows communication with MQTT devices.'
      ..tags = ['mqtt', 'gateway']
      ..examples = [
        '{"command" : "connect", "brokerURL : "test.mosquitto.org"}',
        '{"command" : "subscribe", "topic" : "theTopic", "qos" : "1"}',
      ]
      ..inputModes = ['text/plain']
      ..outputModes = ['text/plain'],
  ])
  ..supportsAuthenticatedExtendedCard = false;

/// MQTTGatewayExecutor implements the agent's core logic.
class MqttGateway implements A2AAgentExecutor {
  /// Executor construction helper.
  /// Late is OK here, a task cannot be cancelled until it has been created,
  /// which is done in the execute method.
  late A2AExecutorConstructor ec;

  // MQTT client manager
  final MqttManager _mqttManager;

  // Message store
  final MessageStore _messageStore;

  MqttGateway() : _mqttManager = MqttManager(), _messageStore = MessageStore();

  @override
  Future<void> cancelTask(String taskId, A2AExecutionEventBus eventBus) async =>
      ec.cancelTask = taskId;

  @override
  Future<void> execute(
    A2ARequestContext requestContext,
    A2AExecutionEventBus eventBus,
  ) async {
    /// Create the executor construction helper
    ec = A2AExecutorConstructor(requestContext, eventBus);

    print(
      '${Colorize('[MQTTGateway] Processing message ${ec.userMessage.messageId} '
      'for task ${ec.taskId} (context: ${ec.contextId})').blue()}',
    );

    // 1. Publish initial Task event if it's a new task
    if (ec.existingTask == null) {
      ec.publishInitialTaskUpdate();
    }

    // 2. Publish "working" status update
    final textPart = ec.createTextPart('Processing your content, hang tight!');
    ec.publishWorkingTaskUpdate(part: [textPart]);

    // 3. Process the command
    try {} catch (e) {
      print(
        '${Colorize('[MQTTGatewayExecutor] Error processing task: ${ec.taskId}, $e').yellow()}',
      );

      final errorResponse = ec.createTextPart('Agent error: $e');
      final message = ec.createMessage(ec.v4Uuid, parts: [errorResponse]);
      ec.publishFailedTaskUpdate(message: message);
    }
  }
}

final mwLogging = ((Request req, Response res, NextFunction next) {
  print(
    '${Colorize('📝 Request: ${req.method} ${req.uri} from ${req.hostname}').blue()}',
  );
  next();
});

// Main server
void main() {
  /// Initialise the required server components for the express application
  final taskStore = A2AInMemoryTaskStore();
  final agentExecutor = MqttGateway();
  final eventBusManager = A2ADefaultExecutionEventBusManager();
  final requestHandler = A2ADefaultRequestHandler(
    mqttGatewayCard,
    taskStore,
    agentExecutor,
    eventBusManager,
    null,
  );
  final transportHandler = A2AJsonRpcTransportHandler(requestHandler);

  /// Initialise the Darto application with the middleware logger.
  /// You can add as many middleware functions as you wish, each
  /// chained to the next.
  final appBuilder = A2AExpressApp(requestHandler, transportHandler);
  final expressApp = appBuilder.setupRoutes(
    Darto(),
    '',
    middlewares: [mwLogging],
  );

  // Turn on debug if needed
  // A2AServerDebug.on();

  // Start listening
  const port = 10004;
  expressApp.listen(port, () {
    print(
      '${Colorize('[MQTTGateway] Server using new framework started on http://localhost:$port').blue()}',
    );
    print(
      '${Colorize('[MQTTGateway] Agent Card: http://localhost:$port}/.well-known/agent-card.json').blue()}',
    );
    print(
      '${Colorize('[MQTTGateway] Press Ctrl+C to stop the server').blue()}',
    );
    print('');
  });
}
