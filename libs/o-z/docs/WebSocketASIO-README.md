### 1. Introduce 

1. This project provides several functions for AutoHotKey to connect to server as websocket client.
2. `WebSocketAsio-[x86|x64].dll` should be only compatible with AutoHotKey __unicode__ installation. (Not tested with AutoHotKey ANSI version)
3. __Currently it doesn't support wss (websocket with SSL).__
    1. For ssl enabled AHK websocket client, please see https://github.com/G33kDude/WebSocket.ahk.
4. WebSocketAsio dll is based on boost beast library.
5. Static link with runtime library so it should support win7/win8/win10
6. Provide both x86 & x64 dll. See bin folder for pre-built binaries.
7. Check Samples folder for usage.

### 2. Motivation
I need websocket APIs to write a GUI AutoHotKey script for controlling and monitoring OBS application through websocket protocol. 
I find there is only 1 suitable websocket client library for AutoHotKey which supports non-ssl websocket (https://github.com/agrippa1994/WebSocket-API).
But it only supports ANSI 32bit AutoHotKey which can't call functions in bcrypt.dll. So I refer to websocket async client example of boost beast library to create this AHK module.
Another implementation (https://github.com/G33kDude/WebSocket.ahk) doesn't support non-ssl.

### 3. Backlog    
    1. [ ] Support wss (ssl websocket)
    2. [ ] Enhancement error handling
    
### 4. Known issue/Limitation
1. Windows only since AutoHotKey only supports windows
2. Sometimes you will get error "The I/O operation has been aborted because of either a thread exit or an application request" when calling websocketConnect again.
3. on_disconnected callback gets called only when user actively calls websocketDisconnect. It won't get called if unexpected error occurs such as server close the connection but on_fail callback can handle them.
    
### 5. API list
1. `int websocketRegisterOnConnectCb(callbackName)`
    * Desc: Register a function defined in user's AHK script to be called after connection is successfully established.
    * `@callbackName string`: user defined function without parameter in AHK script. e.g. `on_connect(){}`
    * `@return int`: 0 success, 1 failed 
2. `int websocketRegisterOnDataCb(callbackName)`
    * Desc: Register a function defined in user's AHK script to be called after data from server reaches client.
    * `@callbackName string`: user defined function with 2 parameters in AHK script. e.g. `on_data(data, len){}`
    * `@return int`: 0 success, 1 failed
3. `int websocketRegisterOnFailCb(callbackName)`
    * Desc: Register a function defined in user's AHK script to be called whenever websocket error occurs
    * `@callbackName string`: user defined function with 1 parameter in AHK script. e.g. `on_fail(from){}`
    * `@return int`: 0 success, 1 failed
4. `int websocketRegisterOnDisconnectCb(callbackName)`
    * Desc: Register a function defined in user's AHK script to be called after user actively calls `websocketDisconnect()` function
    * `@callbackName string`: user defined function without parameter in AHK script. e.g. `on_disconnected(){}`
    * `@return int`: 0 success, 1 failed
5. `int websocketEnableVerbose(nEnabled)`
    * Desc: Enable or disable verbose output from `WebsocketAsio-[x86|x64].dll` internally
    * `@nEnable int`: 0 disable, 1 enable 
    * `@return int`: 0 success, 1 failed 
6. `int websocketConnect(websocketUri)`
    * Desc: Connect to websocket server. on_connect callback gets called if the function is registered by calling `websocketRegisterOnConnectCb(callbackName)`
    * `@websocketUri string`: websocket uri. e.g. `ws://localhost:8199/ws`
    * `@return int`: 0 success, 1 failed 
7. `int websocketDisconnect()`
    * Desc: Close connection to websocket server. on_disconnected callback gets called if the function is registered by calling `websocketRegisterOnDisconnectCb(callbackName)`
    * `@return int`: 0 success, 1 failed 
8. `int websocketIsConnected()`
    * Desc: Get connection status
    * `@return int`: 0 closed, 1 connected 
9. `int websocketSendData(requestPayload)`
    * Desc: Send data to remote websocket server
    * `@requestPayload string`: request payload to send to the server
    * `@return int`: 0 success, 1 failed
    
### 6. Welcome any feedback or pull request of bug fix and feature enhancement
    1. Reach me via mail pdckxd@gmail.com