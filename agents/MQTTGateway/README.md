# MQTT Gateway Agent

This sample agent acts as a gateway to the MQTT protocol.

It uses an MQTT client to perform basic MQTT message exchange and session management along with
status reporting.

Specifically the agent supports :-

- Connection/Disconnection to/from an MQTT broker.
- Subscription/Unsubscription to/from topics.
- Publishing and reception of MQTT messages
- Reporting of the status of the MQTT client.

This allows basic MQTT communication and control without over complicating the
gateway functionality. It is envisaged that a supporting MCP bridge will be
provided to allow AI tools such as Gemini to interface to MQTT devices.

The gateway supports a command driven interface in JSON format, commands being :-
- Connect with parameters of broker URL, client id, user id and password.
- Disconnect.
- Subscribe with parameters of topic and QoS level.
- Unsubscribe
- Publish message with parameters of topic, QoS and payload.
- Get all received messages for a specific topic.
- Report current MQTT client status, such as connected/disconnected.

An example of a command to connect the gateway to a broker is :-
```JSON
{"command" : "connect", "brokerURL" : "test.mosquitto.org", "clientId" : "ffderhhh"}
```
Each command will report success or failure back to the user.

A full description of each command and its parameters can be found in the 
COMMANDS.md document.
