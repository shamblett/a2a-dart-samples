/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 29/08/2025
* Copyright :  S.Hamblett
*/

import 'dart:io';
import 'dart:convert';

import 'package:a2a/a2a.dart';
import 'package:colorize/colorize.dart';
import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:dartantic_interface/dartantic_interface.dart';

import 'config.dart';
import 'coder_agent_prompt.dart';

/// The Coder A2A Sample
///
/// Status information is printed to the console, blue is for information,
/// yellow for an event that has occurred and red for failure. If you enable
/// server debug this output will be in green.

// Agent Card
final coderAgentCard = A2AAgentCard()
  ..name = 'Coder Agent'
  ..description = 'A simple code writing assistant agent for the Dart language.'
  ..url = 'http://localhost:41241/'
  ..agentProvider = (A2AAgentProvider()
    ..organization = 'A2A Dart Samples'
    ..url = 'https://github.com/shamblett/a2a-dart-samples')
  ..version = '1.0.0'
  ..capabilities =
      (A2AAgentCapabilities()
        ..streaming =
            true // Supports streaming
        ..pushNotifications =
            false //  Assuming not implemented for this agent yet
        ..stateTransitionHistory = true) // Agent uses history
  ..securitySchemes =
      null // Or define actual security schemes if any
  ..security = null
  ..defaultInputModes = ['text/plain']
  ..defaultOutputModes = ['text/plain', 'task-status']
  ..skills = ([
    A2AAgentSkill()
      ..id = 'code_writing'
      ..name = 'Code generation'
      ..description = 'Acts as a simple Dart code writing assistant'
      ..tags = ['code', 'assistant']
      ..examples = [
        'Generate code to calculate the first 6 terms in the Fibonacci sequence',
      ]
      ..inputModes = ['text/plain']
      ..outputModes = ['text/plain', 'task-status'],
  ])
  ..supportsAuthenticatedExtendedCard = false;

/// CoderExecutor implements the agent's core logic.
class CoderAgent implements A2AAgentExecutor {
  /// Executor construction helper.
  /// Late is OK here, a task cannot be cancelled until it has been created,
  /// which is done in the execute method.
  late A2AExecutorConstructor ec;

  CoderAgent() {
    // Set the API keys from their environment variables
    googleApIKey = Platform.environment['GEMINI_API_KEY']!;
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

    print(
      '${Colorize('[CoderAgent] Processing message ${ec.userMessage.messageId} '
      'for task ${ec.taskId} (context: ${ec.contextId})').blue()}',
    );

    // 1. Publish initial Task event if it's a new task
    if (ec.existingTask == null) {
      ec.publishInitialTaskUpdate();
    }

    // 2. Publish "working" status update
    final textPart = ec.createTextPart('Processing your question, hang tight!');
    ec.publishWorkingTaskUpdate(part: [textPart]);

    // 3. Run the prompt and the query
    try {
      final agent = Agent('google:gemini-2.0-flash');

      final question = (ec.userMessage.parts?.first as A2ATextPart).text;
      final stream = agent.sendStream(
        question,
        history: [ChatMessage.system(prompt)],
      );

      // Check for request cancellation
      if (ec.isTaskCancelled) {
        print(
          '${Colorize('Request cancelled for task: ${ec.taskId}').yellow()}',
        );
        ec.publishCancelTaskUpdate();
        return;
      }

      // Get the response
      final a2aParts = <A2APart>[];
      await for (final chunk in stream) {
        print(
          '${Colorize('[CoderAgent] Chunk output ${chunk.output}').blue()}',
        );

        // Process the response, extract the text and files into A2A parts
        await for (final chunk in stream) {
          print(
            '${Colorize('[CoderAgent] Chunk output ${chunk.output}').blue()}',
          );
          for (final message in chunk.messages) {
            if (message.text.isNotEmpty) {
              a2aParts.add(A2ATextPart()..text = message.text);
            }
            for (final part in message.parts) {
              if (part is TextPart) {
                a2aParts.add(A2ATextPart()..text = part.text);
              }
              if (part is DataPart) {
                a2aParts.add(
                  (A2AFilePart()
                    ..file = (A2AFileWithBytes()
                      ..name = part.name ?? 'noname'
                      ..bytes = utf8.decode(part.bytes))),
                );
              }
            }
          }
        }
      }

      // Send the response back to the client as a series of artifacts
      int artifactCount = 1;
      for (final part in a2aParts) {}
    } catch (e) {
      print(
        '${Colorize('[CoderAgentExecutor] Error processing task: ${ec.taskId}, $e').yellow()}',
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
  final agentExecutor = CoderAgent();
  final eventBusManager = A2ADefaultExecutionEventBusManager();
  final requestHandler = A2ADefaultRequestHandler(
    coderAgentCard,
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
  const port = 41241;
  expressApp.listen(port, () {
    print(
      '${Colorize('[CoderAgent] Server using new framework started on http://localhost:$port').blue()}',
    );
    print(
      '${Colorize('[CoderAgent] Agent Card: http://localhost:$port}/.well-known/agent-card.json').blue()}',
    );
    print('${Colorize('[CoderAgent] Press Ctrl+C to stop the server').blue()}');
    print('');
  });
}
