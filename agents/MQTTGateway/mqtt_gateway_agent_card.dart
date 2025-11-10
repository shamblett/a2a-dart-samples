/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

import 'package:a2a/a2a.dart';

/// Agent card
class MqttGatewayAgentCard {
  static final mqttGatewayCard = A2AAgentCard()
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
}
