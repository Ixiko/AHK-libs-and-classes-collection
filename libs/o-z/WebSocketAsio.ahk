;~ #NoEnv

#include class_bcrypt.ahk

ARCH_LABEL := "x86"
INT_TYPE := "Int"
if(A_PtrSize == 8) {
	ARCH_LABEL := "x64"
	INT_TYPE := "Int64"
}

log_debug(string, prefix="[DEBUG]") {
	string .= "`n"
    FileAppend %prefix% %string%,* ;* goes to stdout
}

log_error(string, prefix="[ERROR]") {
	string .= "`n"
    FileAppend %prefix% %string%,** ;* goes to stdout
}

;~ dllPath := "WebSocketAsio-" . ARCH_LABEL . ".dll"
dllPath := "WebSocketAsio-" . ARCH_LABEL . ".dll"
;~ log_debug(A_LineFile)
log_debug("Loading dll file: " . dllPath)
hModule := DllCall("LoadLibrary", "Str", dllPath, "Ptr")
if(A_LastError != 0) {
	log_debug("LoadLibrary Error: " . A_LastError)
	log_debug("hModule: " . hModule)
}

;~ Example
;~ websocketEnableVerbose(1)

;~ websocketConnect("ws://localhost:8199/ws")

;~ Sleep, 30000
;~ ExitApp

websocketRegisterOnConnectCb(callbackName) {
	global INT_TYPE
	global ARCH_LABEL	
	res := DllCall("WebSocketAsio-" . ARCH_LABEL . "\websocket_register_on_connect_cb", INT_TYPE, RegisterCallback("on_connect", "F", 0), "UChar")
	if(A_LastError != 0) {
		log_error("Register on connect callback Error: " . A_LastError)
		log_debug("res: " . res)
		MsgBox, Failed to register websocket callback for on connect event
		return 0
	}
	return 1
}

websocketRegisterOnDataCb(callbackName) {
	global INT_TYPE
	global ARCH_LABEL	
	res := DllCall("WebSocketAsio-" . ARCH_LABEL . "\websocket_register_on_data_cb", INT_TYPE, RegisterCallback("on_data", "F", 2), "UChar")
	if(A_LastError != 0) {
		log_error("Register on data callback Error: " . A_LastError)
		log_debug("res: " . res)
		MsgBox, Failed to register websocket callback for on data event
		return 0
	}
	return 1
}

websocketRegisterOnFailCb(callbackName) {
	global INT_TYPE
	global ARCH_LABEL	
	res := DllCall("WebSocketAsio-" . ARCH_LABEL . "\websocket_register_on_fail_cb", INT_TYPE, RegisterCallback("on_fail", "F", 1), "UChar")
	if(A_LastError != 0) {
		log_error("Register on fail callback Error: " . A_LastError)
		log_debug("res: " . res)
		MsgBox, Failed to register websocket callback for on fail event
		return 0
	}
	return 1
}

websocketRegisterOnDisconnectCb(callbackName) {
	global INT_TYPE
	global ARCH_LABEL	
	res := DllCall("WebSocketAsio-" . ARCH_LABEL . "\websocket_register_on_disconnect_cb", INT_TYPE, RegisterCallback("on_disconnect", "F", 0), "UChar")
	if(A_LastError != 0) {
		log_error("Register on disconnect callback Error: " . A_LastError)
		log_debug("res: " . res)
		MsgBox, Failed to register websocket callback for on disconnect event
		return 0
	}
	return 1
}

websocketEnableVerbose(nEnabled) {
	global INT_TYPE
	global ARCH_LABEL
	res := DllCall("WebSocketAsio-" . ARCH_LABEL . "\enable_verbose", INT_TYPE, nEnabled)
	if(A_LastError != 0) {
		log_error("Call dll function enable_verbose Error: " . A_LastError)
		log_debug("res: " . res)
		return 0
	}
	return 1
}

websocketConnect(websocketUri) {
	global INT_TYPE
	global ARCH_LABEL	
	res := DllCall("WebSocketAsio-" . ARCH_LABEL . "\websocket_connect", "Str", websocketUri)
	if(A_LastError != 0) {
		log_error("Call dll function websocket_connect Error: " . A_LastError)
		log_debug("res: " . res)
		return 0
	}
	return 1
}

websocketDisconnect() {
	global INT_TYPE
	global ARCH_LABEL	
	res := DllCall("WebSocketAsio-" . ARCH_LABEL . "\websocket_disconnect")
	if(A_LastError != 0) {
		log_error("Call dll function websocket_disconnect Error: " . A_LastError)
		log_debug("res: " . res)
		return 0
	}
	return 1
}

websocketIsConnected() {
	global INT_TYPE
	global ARCH_LABEL	
	res := DllCall("WebSocketAsio-" . ARCH_LABEL . "\websocket_isconnected")
	if(A_LastError != 0) {
		log_error("Call dll function websocket_isconnected Error: " . A_LastError)
		log_debug("res: " . res)
		return 0
	}
	return res
}

websocketSendData(requestPayload) {
	global INT_TYPE
	global ARCH_LABEL	
	res := DllCall("WebSocketAsio-" . ARCH_LABEL . "\websocket_send", "Str", requestPayload)
	if(A_LastError != 0) {
		log_error("Call dll function websocket_send Error: " . A_LastError)
		log_debug("res: " . res)
		return 0
	}

	return 1
}

b64Encode(string)
{
    VarSetCapacity(bin, StrPut(string, "UTF-8")) && len := StrPut(string, &bin, "UTF-8") - 1
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", 0, "uint*", size))
        throw Exception("CryptBinaryToString failed", -1)
    VarSetCapacity(buf, size << 1, 0)
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", &buf, "uint*", size))
        throw Exception("CryptBinaryToString failed", -1)
    return StrGet(&buf)
}

b64EncodeBin(ByRef bytes, len)
{
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bytes, "uint", len, "uint", 0x1, "ptr", 0, "uint*", size))
        throw Exception("CryptBinaryToString failed", -1)
    VarSetCapacity(buf, size << 1, 0)
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bytes, "uint", len, "uint", 0x1, "ptr", &buf, "uint*", size))
        throw Exception("CryptBinaryToString failed", -1)
    return StrGet(&buf)
}

b64Decode(string)
{
    if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", 0, "uint*", size, "ptr", 0, "ptr", 0))
        throw Exception("CryptStringToBinary failed", -1)
    VarSetCapacity(buf, size, 0)
    if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", &buf, "uint*", size, "ptr", 0, "ptr", 0))
        throw Exception("CryptStringToBinary failed", -1)
    return StrGet(&buf, size, "UTF-8")
}

RelToAbs(root, dir, s = "\") {
	pr := SubStr(root, 1, len := InStr(root, s, "", InStr(root, s . s) + 2) - 1)
		, root := SubStr(root, len + 1), sk := 0
	If InStr(root, s, "", 0) = StrLen(root)
		StringTrimRight, root, root, 1
	If InStr(dir, s, "", 0) = StrLen(dir)
		StringTrimRight, dir, dir, 1
	Loop, Parse, dir, %s%
	{
		If A_LoopField = ..
			StringLeft, root, root, InStr(root, s, "", 0) - 1
		Else If A_LoopField =
			root =
		Else If A_LoopField != .
			Continue
		StringReplace, dir, dir, %A_LoopField%%s%
	}
	Return, pr . root . s . dir
}