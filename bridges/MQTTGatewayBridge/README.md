# MQTT Gateway Agent MCP Bridge

The MQTT Gateway Bridge acts as an MCP server bridge between MCP compatible AI assistants such as Gemini, Claude etc. 
and the MQTT Gateway A2A Agent. This allows AI assistants to directly interface to the MQTT ecosystem, exchanging text messages with
a large variety of devices, machines and platforms from high-end server deployments to highly constrained IoT devices.

The bridge is an extension of A2A MCP Bridge and so provides the same basic tool set as it does, allowing agent
registration and control. See the A2A project [README](https://github.com/shamblett/a2a/blob/main/README.md) for more details.

It also provides the following tools to allow interfacing to the A2A MQTT Gateway Agent :-

1. Connect to/Disconnect from an MQTT Broker
2. Subscribe to/unsubscribe from an MQTT topic
3. Publish messages to an MQTT topic
4. Get messages received on an MQTT topic
5. Query the status of the MQTT Gateway

Please see the A2A MQTT Gateway [sample](ttps://github.com/shamblett/a2a-dart-samples/tree/main/agents/MQTTGateway) 
for further details of the MQTT implementation and the agent command protocol.

The tools above accept the same parameters as those accepted by the MQTT Gateway Agent itself.

See the comment at the top of the containerfile for instructions on how to build and run the bridge as a podman container.