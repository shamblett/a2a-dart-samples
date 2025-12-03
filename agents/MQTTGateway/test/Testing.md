# Test Procedure

The easiest way to test the gateway is using the A2A CLI client or similar utility.

Start an MQTT broker on localhost using the standard(1883) MQTT port.

Start the gateway agent.

Start the A2A CLI client with the URL of the agent :-
```
a2a_cli_client http://localhost:10004
```
Check the gateway agent card is displayed correctly.
```
✓ Agent Card Found
  Agent Name : MQTT Gateway Agent
  Description : An agent that allows communication with MQTT devices.
  Version : 1.0.0
  Streaming supported
```

Perform the following test steps :-

1. Check the gateway is not connected
```
{ "command" : "status" }

Returns 

{ "result: : "not_connected" }
```

2. Connect the gateway to the MQTT broker
```
{ "command" : "connect", "broker_url" : "localhost" }

Returns 

{ "result" : "success" }
```

3. Subscribe to the test topic
```
{ "command" : "subscribe", "topic" : "theTopic" }

Returns

{ "result" : "success" }
```

4. Publish two messages to the test topic
```
{ "command" : "publish", "topic" : "theTopic", "payload" : "Hello from A2A 1" }

Returns

{ "result" : "success" }

{ "command" : "publish", "topic" : "theTopic", "payload" : "Hello from A2A 2" }

Returns

{ "result" : "success" }
```

5. Get the messages just published
```
{ "command" : "get_messages", "topic" : "theTopic" }

Returns

{ "result" : "success", "messages" : [ { "payload" : "Hello from A2A 1", "timestamp" : "<Timestamp>" }, { "payload" : "Hello from A2A 2", "timestamp" : "<Timestamp>" } ] },

where <Timestamp> is a string in the form '2025-12-02T15:57:47'
```

6. Get the same messages again
```
{ "command" : "get_messages", "topic" : "theTopic" }

Returns

{ "result" : "success" }

i.e. no messages are now returned
```

7. Unsubscribe from the test topic
```
{ "command" : "unsubscribe", "topic" : "theTopic" }

Returns 

{ "result" : "success" }
```

8. Disconnect the broker
```
{ "command" : "disconnect" }

Returns 

{ "result" : "success" }
```

9. Check the status
```
{ "command" : "status" }

Returns

{ "result: : "not_connected" }
```

Check the gateway agent log output, only info(blue) messages should be present, there should be no warning(yellow)
or fatal(red) messages.




