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
  ..name = 'LLM Comparison Agent'
  ..description =
      'An agent that sends a prompt to two LLM\'s, gemma3 and gemma3:270m models '
      'allowing the response from each model to be compared.'
  // Adjust the base URL and port as needed.
  ..url = 'http://localhost:41242/'
  ..agentProvider = (A2AAgentProvider()
    ..organization = 'Darticulate A2A Agents'
    ..url = 'https://example.com/a2a-agents')
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
  ..defaultOutputModes = ['text/plain']
  ..skills = ([
    A2AAgentSkill()
      ..id = 'llm_comparison'
      ..name = 'LLM Comparison'
      ..description = 'Compare the responses of two LLM\'s for the same prompt.'
      ..tags = ['LLM', 'gemma']
      ..examples = ['What is Paris famous for?']
      ..inputModes = ['text/plain']
      ..outputModes = ['text/plain'],
  ])
  ..supportsAuthenticatedExtendedCard = false;

///
/// Step 2 - Define the Agent Executor
///

// 1. Define your agent's logic as an  A2AAgentExecutor
class MovieAgent implements A2AAgentExecutor {
  /// Executor construction helper.
  /// Late is OK here, a task cannot be cancelled until it has been created,
  /// which is done in the execute method.
  late A2AExecutorConstructor ec;

  /// Ollama API key - adjust as you wish
  final ollamaApiKey = 'sk-cd76c5a922384cb780c5f935eedf3214';

  /// Model names - adjust as you wish
  final model1 = 'gemma:7b';

  /// Model provider id
  final providerId = 'ollama';

  @override
  Future<void> cancelTask(String taskId, A2AExecutionEventBus eventBus) async =>
      ec.cancelTask = taskId;
  // The execute loop is responsible for publishing the final state

  @override
  Future<void> execute(
    A2ARequestContext requestContext,
    A2AExecutionEventBus eventBus,
  ) async {
    /// Create the executor construction helper
    ec = A2AExecutorConstructor(requestContext, eventBus);

    /// Create the Ollama providers
    final model1Provider = await createProvider(
      providerId: providerId,
      apiKey: ollamaApiKey,
      model: model1,
    );

    // Check for request cancellation
    if (ec.isTaskCancelled) {
      print('${Colorize('Request cancelled for task: ${ec.taskId}').yellow()}');
      ec.publishCancelTaskUpdate();
      return;
    }

    // 4. Publish final status update

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
  const port = 41242;
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
