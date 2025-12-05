/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 05/12/2025
* Copyright :  S.Hamblett
*/

import 'package:a2a/a2a.dart';

import 'log.dart';

/// MQTT Bridge
///
class MqttGatewayBridge extends A2AMCPBridge {
  MqttGatewayBridge() : super();
}

// Main server
void main() async {
  // Create and start the bridge
  Log.info('Creating the MQTT Gateway Bridge');
  MqttGatewayBridge mqttMcpBridge = MqttGatewayBridge();
  try {
    await mqttMcpBridge
        .startServer(); // Set your port if you do not want the default
  } catch (e) {
    Log.fatal('MQTT Gateway Bridge failed to start $e');
    return;
  }
}
