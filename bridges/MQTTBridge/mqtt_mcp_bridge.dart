/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 29/08/2025
* Copyright :  S.Hamblett
*/

import 'package:a2a/a2a.dart';
import 'package:colorize/colorize.dart';
import './mqtt_manager.dart';

/// MQTT Bridge
///
class MqttMcpBridge extends A2AMCPBridge {
  // MQTT manager
  final _mqttManager = MqttManager();

  MqttMcpBridge() : super() {
    // Remove the tools we don't need
    _mcpServer.
  }
}

// Main server
void main() async {
  // Create and start the bridge
  print('${Colorize('Creating the MQTT MCP Bridge').blue()}');
  MqttMcpBridge mqttMcpBridge = MqttMcpBridge();
  try {
    await mqttMcpBridge
        .startServer(); // Set your port if you do not want the default
  } catch (e) {
    print('${Colorize('MQTT MCP Bridge failed to start $e').red()}');
    return;
  }
}
