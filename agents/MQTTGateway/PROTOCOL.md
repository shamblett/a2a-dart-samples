# MQTT Gateway Protocol

The gateway protocol consists of JSON encoded strings requesting 
the gateway to execute a command. All requests contain a command identifier string 
followed by a list of mandatory and optional parameters for that command.

For each command a result is returned which indicates the result of the command processing, usually either success or fail.
Optional parameters may also be returned in the event of a successful command, e.g. a list of messages for a topic.

Standard MQTT QoS values of 0, 1 and 2 are supported with 0 being at most once, 1 being at least once and 2
being exactly once.

Note that MQTT allows payload data to be binary data however the gateway expects payload data
to be in UTF8 string format. This caters for simple message passing and Base64 encoding.

The commands and parameters expected with the result returned are as follows :-

#### Connect to a broker

command    : "connect"

broker_url : "Broker URL string"   - Mandatory

port       : "Port string"         - Optional 

client_id  : "Client Id string"    - Optional

user_name   : "User name string"    - Optional

password   : "User password string - Optional

Result returns "success" or "fail"

Example 
```JSON
{"command" : "connect", "broker_url" : "test.mosquitto.org", "client_id" : "12345"}
```
Returns 
```JSON
{"result" : "success"}
```

#### Disconnect from a broker

command    : "disconnect"

Result returns "success" only

Example
```JSON
{"command" : "disconnect"}
```
Returns
```JSON
{"result" : "success"}
```
#### Subscribe to a topic

command    : "subscribe"

topic : "Topic string"   - Mandatory

qos    : 0, 1 or 2 - Optional, if not supplied 0 is used.

Result returns "success" or "fail"

Example
```JSON
{"command" : "subscribe", "topic" :  "theTopic", "qos" :  1}
```
Returns
```JSON
{"result" : "success"}
```

#### Unsubscribe from a topic

command    : "unsubscribe"

topic : "Topic string"   - Mandatory

Result returns "success" or "fail"

Example
```JSON
{"command" : "unsubscribe", "topic" :  "theTopic"}
```
Returns
```JSON
{"result" : "success"}
```

#### Publish a message to a topic

command    : "publish"

topic : "Topic string"   - Mandatory

payload: "The Payload"  - Mandatory

qos    : 0, 1 or 2 - Optional, if not supplied 0 is used.

Result returns "success" or "fail"

Example
```JSON
{"command" : "publish", "topic" :  "theTopic", "payload" :  "thePayload", "qos" :  1}
```
Returns
```JSON
{"result" : "success"}
```

#### Get Messages received for a topic

command    : "get_messages"

topic : "Topic string"   - Mandatory

Result always returns "success" and a list(may be empty) of received messages 

Example
```JSON
{"command" : "get_messages", "topic" :  "theTopic"}
```
Returns
```JSON
{"result" : "success", "messages" :  ["message1", "message2"]}
```

#### Get the status of the connection

command    : "status"

Result returns "connected" or "not_connected"

Example
```JSON
{"command" : "status"}
```
Returns
```JSON
{"result" : "connected"}
```