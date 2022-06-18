; ******************************************************************************************************************************
; *************** Author: Alex <pdckxd@gmail.com>
; *************** Add path which WebSocketAsio.dll resides in. Please modify 'AllPath' based on your requirement
; ******************************************************************************************************************************
#SingleInstance force
EnvGet, SysPath, PATH
;~ Important!!!! Please set correctly dll folder according to your environment
AllPath = %A_ScriptDir%\..\bin\;%SysPath%
EnvSet PATH, %AllPath%
;~ EnvGet, SysPath, PATH
;~ FileAppend, %AllPath% `n,*
;~ ExitApp

;~ #include JSON.ahk
#include ..\AutoHotKeySrc\WebSocketAsio.ahk

; Set 1 to enable verbose output from WebSocketAsio.dll. Default is 0
websocketEnableVerbose(1)

; Registering callback functions which WebSocketAsio.dll can call when specific events occur
websocketRegisterOnConnectCb("on_connect")
websocketRegisterOnDataCb("on_data")
websocketRegisterOnFailCb("on_fail")
websocketRegisterOnDisconnectCb("on_disconnect")

wsUri := "ws://localhost:8199/ws"
; Connect websocket server
websocketConnect(wsUri)

; Sleep 30 seconds to receive message which server actively sends out per 5 seconds 
Sleep, 30000
; Close connection
websocketDisconnect()
Sleep, 1000
; Check connection status
res := websocketIsConnected()
log_debug("Is connected? " . (res == 1? "yes":"no") )

; Then you can reconnect the server
;~ websocketConnect(wsUri)
;~ Sleep, 30000
; Actually exit this script
ExitApp

; Callback function when connection is successfully established 
on_connect()
{
	Critical
	log_debug("The connection has been established!")
		
	requestPayload = {"message-id": "1", "content":"Hello Websocket Go Server!!!"}
	; Send json string to server
	websocketSendData(requestPayload)
}

; Callback function when connection has problem. In general user is responsible for closing connection
on_fail(from)
{
	Critical
	
	log_error("Error occur. From: " . StrGet(from))
	websocketDisconnect()
}

; Callback function when user calls websocketDisconnect() and connection is successfully closed
on_disconnect()
{
	Critical
	
	log_debug("The connection has been closed!")
}

; Callback function when client get data from server
on_data(data, len)
{
	Critical
	
	log_debug("len: " . len)
	resp := StrGet(data, len)
	log_debug("data: " . resp)	
	
	parsed := JSON.Load(resp)
	log_debug(parsed.go_server_time)
}