# MQTT Gateway Protocol

The gateway protocol consists of JSON encoded strings requesting 
the gateway to execute a command. All requests contain a command identifier string 
followed by a list of mandatory and optional parameters for that command.

For each command a result identifier is returned which indicates the result of the command processing, either success or fail.
Optional parameters may also be returned in the event of a successful command, e.g. a list of messages for a topic.

Note that MQTT allows payload data to be binary data however the gateway expects payload data
to be in UTF8 string format. This caters for simple message passing and Base64 encoding.

The commands and parameters expected with the result returned are as follows :-

#### Connect

command    : "connect"

broker_url : "Broker URL string"   - Mandatory

port       : "Port string"         - Optional 

client_id  : "Client Id string"    - Optional

user_id    : "User Id string"      - Optional

password   : "User password string - Optional

Result returned "success" or "fail"

Example 
```JSON
{"command" : "connect", "broker_url" : "test.mosquitto.org", "client_id" : "12345"}
```
Returns 
```JSON
{"result" : "success"}
```

#### Disconnect

command    : "disconnect"

Example
```JSON
{"command" : "disconnect"}
```
Returns
```JSON
{"result" : "success"}
```
#### Subscribe

command    : "subscribe"

topic : "Topic string"   - Mandatory

Returns
```JSON
{"result" : "success"}
```
