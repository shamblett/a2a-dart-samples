// ignore_for_file: avoid-passing-self-as-argument

/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'package:a2a/a2a.dart';

import 'command_processor.dart';
import 'log.dart';
import 'message_store.dart';
import 'middleware_logging.dart';
import 'mqtt_gateway_agent_card.dart';
import 'mqtt_manager.dart';

/// The MQTT Gateway A2A Sample
///
/// Status information is printed to the console, blue is for information,
/// yellow for an event that has occurred and red for failure. If you enable
/// server debug this output will be in green.

/// MQTTGatewayExecutor implements the agent's core logic.
class MqttGateway implements A2AAgentExecutor {
  /// Executor construction helper.
  /// Late is OK here, a task cannot be cancelled until it has been created,
  /// which is done in the execute method.
  late A2AExecutorConstructor ec;

  // MQTT client manager
  late MqttManager _mqttManager;

  // Message store
  final MessageStore _messageStore = MessageStore();

  late final CommandProcessor _commandProcessor;

  MqttGateway() {
    _mqttManager = MqttManager(_messageStore);
    _commandProcessor = CommandProcessor(_messageStore, _mqttManager);
  }

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
    Log.info(
      'Processing message ${ec.userMessage.messageId} '
      'for task ${ec.taskId} (context: ${ec.contextId})',
    );

    // 1. Publish initial Task event if it's a new task
    if (ec.existingTask == null) {
      ec.publishInitialTaskUpdate();
    }

    // 2. Publish "working" status update
    final textPart = ec.createTextPart('Processing your content, hang tight!');
    ec.publishWorkingTaskUpdate(part: [textPart]);

    // 3. Process the command
    String result = '';
    try {
      result = await _commandProcessor.executeCommand(
        (ec.userMessage.parts?.first as A2ATextPart).text,
      );
    } catch (e) {
      Log.warn('Error processing task: ${ec.taskId}, $e');
      final errorResponse = ec.createTextPart('Agent error: $e');
      final messageId = ec.v4Uuid;
      final message = ec.createMessage(messageId, parts: [errorResponse]);
      ec.publishFailedTaskUpdate(message: message);
    }

    // 4. Check for request cancellation
    if (ec.isTaskCancelled) {
      Log.warn('Request cancelled for task: ${ec.taskId}');
      ec.publishCancelTaskUpdate();
      return;
    }

    // 5. Complete the task
    final message = ec.createMessage(
      ec.v4Uuid,
      parts: [A2ATextPart()..text = result],
    );
    ec.publishFinalTaskUpdate(message: message);
    Log.info('Task ${ec.taskId} finished with state: completed');
  }
}

// Main server
void main() {
  /// Initialise the required server components for the express application
  final taskStore = A2AInMemoryTaskStore();
  final agentExecutor = MqttGateway();
  final eventBusManager = A2ADefaultExecutionEventBusManager();
  final requestHandler = A2ADefaultRequestHandler(
    MqttGatewayAgentCard.mqttGatewayCard,
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
    middlewares: [MiddlewareLogging.mwLogging],
  );

  // Start listening
  const port = 10004;
  expressApp.listen(port, () {
    Log.info(' Server using new framework started on http://localhost:$port');
    Log.info('Agent Card: http://localhost:$port}/.well-known/agent-card.json');
    Log.info('Press Ctrl+C to stop the server');
    print('');
  });
}
