/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 29/08/2025
* Copyright :  S.Hamblett
*/

import 'dart:io';

import 'package:a2a/a2a.dart';
import 'package:colorize/colorize.dart';
import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:dartantic_interface/dartantic_interface.dart';

import 'config.dart';
import 'content_editor_prompt.dart';

/// The Content Editor A2A Sample
///
/// Status information is printed to the console, blue is for information,
/// yellow for an event that has occurred and red for failure. If you enable
/// server debug this output will be in green.

// Agent Card
final movieAgentCard = A2AAgentCard()
  ..name = 'Content Editor Agent'
  ..description = 'An agent that can proof-read and polish content.'
  ..url = 'http://localhost:10003/'
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
      ..id = 'editor'
      ..name = 'Edits content'
      ..description = 'Edits content by proof-reading and polishing'
      ..tags = ['writer']
      ..examples = [
        'Edit the following article, make sure it has a professional tone',
      ]
      ..inputModes = ['text/plain']
      ..outputModes = ['text/plain'],
  ])
  ..supportsAuthenticatedExtendedCard = false;

/// MovieAgentExecutor implements the agent's core logic.
class ContentEditor implements A2AAgentExecutor {
  /// Executor construction helper.
  /// Late is OK here, a task cannot be cancelled until it has been created,
  /// which is done in the execute method.
  late A2AExecutorConstructor ec;

  ContentEditor() {
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
      '${Colorize('[ContentEditor] Processing message ${ec.userMessage.messageId} '
      'for task ${ec.taskId} (context: ${ec.contextId})').blue()}',
    );

    // 1. Publish initial Task event if it's a new task
    if (ec.existingTask == null) {
      ec.publishInitialTaskUpdate();
    }

    // 2. Publish "working" status update
    final textPart = ec.createTextPart('Processing your content, hang tight!');
    ec.publishWorkingTaskUpdate(part: [textPart]);

    // 3. Run the prompt and the query
    try {
      final agent = Agent('google:gemini-2.0-flash');

      String responseText = '';
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
      final responseLines = <String>[];
      await for (final chunk in stream) {
        print(
          '${Colorize('[ContentEditor] Chunk output ${chunk.output}').blue()}',
        );
        responseLines.add(chunk.output);
      }

      // Assemble the response chunks into a text output
      for (final line in responseLines) {
        if (line.isEmpty) {
          continue;
        }
        responseText += line;
      }

      // Final task response
      final modelResponse = ec.createTextPart(responseText);
      final message = ec.createMessage(ec.v4Uuid, parts: [modelResponse]);
      ec.publishFinalTaskUpdate(message: message);
      print(
        '${Colorize('[ContentEditorExecutor] Task ${ec.taskId} finished with state: completed').blue()}',
      );
    } catch (e) {
      print(
        '${Colorize('[ContentEditorExecutor] Error processing task: ${ec.taskId}, $e').yellow()}',
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
  final agentExecutor = ContentEditor();
  final eventBusManager = A2ADefaultExecutionEventBusManager();
  final requestHandler = A2ADefaultRequestHandler(
    movieAgentCard,
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
  const port = 10003;
  expressApp.listen(port, () {
    print(
      '${Colorize('[ContentEditor] Server using new framework started on http://localhost:$port').blue()}',
    );
    print(
      '${Colorize('[ContentEditor] Agent Card: http://localhost:$port}/.well-known/agent-card.json').blue()}',
    );
    print(
      '${Colorize('[ContentEditor] Press Ctrl+C to stop the server').blue()}',
    );
    print('');
  });
}
