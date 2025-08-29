/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 29/08/2025
* Copyright :  S.Hamblett
*/

import 'package:a2a/a2a.dart';
import 'package:colorize/colorize.dart';

/// The Movie Agent A2A Sample
///
/// Status information is printed to the console, blue is for information,
/// yellow for an event that has occurred and red for failure. If you enable
/// server debug this output will be in green.

// Agent Card
final movieAgentCard = A2AAgentCard()
  ..name = 'Movie Agent'
  ..description =
      'An agent that can answer questions about movies and actors using TMDB.'
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
      ..id = 'general_movie_chat'
      ..name = 'General Movie Chat'
      ..description =
          'Answer general questions or chat about movies, actors, directors.'
      ..tags = ['movies', 'actors', 'directors']
      ..examples = [
        'Tell me about the plot of Inception.',
        'Recommend a good sci-fi movie.',
        'Who directed The Matrix?',
        'What other movies has Scarlett Johansson been in?',
        'Find action movies starring Keanu Reeves',
        'Which came out first, Jurassic Park or Terminator 2?',
      ]
      ..inputModes = ['text/plain']
      ..outputModes = ['text/plain', 'task-status'],
  ])
  ..supportsAuthenticatedExtendedCard = false;

/// MovieAgentExecutor implements the agent's core logic.
class MovieAgent implements A2AAgentExecutor {
  /// Executor construction helper.
  /// Late is OK here, a task cannot be cancelled until it has been created,
  /// which is done in the execute method.
  late A2AExecutorConstructor ec;

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
      '${Colorize('[MovieAgent] Processing message ${ec.userMessage.messageId} '
          'for task ${ec.taskId} (context: ${ec.contextId})').blue()}',
    );

    // 1. Publish initial Task event if it's a new task
    if (ec.existingTask == null) {
      ec.publishInitialTaskUpdate();
    }

    final textPart = ec.createTextPart('Processing your question, hang tight!');
    ec.publishWorkingTaskUpdate(part: [textPart]);


    // Check for request cancellation
    if (ec.isTaskCancelled) {
      print('${Colorize('Request cancelled for task: ${ec.taskId}').yellow()}');
      ec.publishCancelTaskUpdate();
      return;
    }

    final finalMessageText = ec.createTextPart(
      'Final update from the LLM comparator agent',
    );
    final finalMessage = ec.createMessage(
      'llm-comparison-agent',
      parts: [finalMessageText],
    );
    ec.publishFinalTaskUpdate(message: finalMessage);
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
  final agentExecutor = MovieAgent();
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
  const port = 41241;
  expressApp.listen(port, () {
    print(
      '${Colorize('[MovieAgent] Server using new framework started on http://localhost:$port').blue()}',
    );
    print(
      '${Colorize('[MovieAgent] Agent Card: http://localhost:$port}/.well-known/agent-card.json').blue()}',
    );
    print('${Colorize('[MovieAgent] Press Ctrl+C to stop the server').blue()}');
    print('');
  });
}
