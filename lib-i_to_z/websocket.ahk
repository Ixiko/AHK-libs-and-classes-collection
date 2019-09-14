#NoEnv

PATH_WEBSOCKET := RelToAbs(A_ScriptDir, "..\..\dll\websocket.dll")

if (FileExist(PATH_WEBSOCKET))
{
	SplitPath, PATH_WEBSOCKET, dll_FullFileName, dll_Dir,, dll_FileName
	DllCall("AddDllDirectory", "Str", dll_Dir)
    if !(hModule := DllCall("LoadLibrary", "Str", dll_FullFileName, "UPtr"))
    {
        MsgBox % "Can't load`n" dll_FullFileName "`n`nfrom directory`n" dll_dir "`n`nwith LoadLibrary ( A_LastError= " A_LastError " )"    ; <== stops here with 193 (script is compiled)
        ExitApp
    }
}
else
{
    MsgBox % PATH_WEBSOCKET "`nFile NOT Found"
    ExitApp
}


/* hModule := DllCall("LoadLibrary", "Str", PATH_WEBSOCKET)
if(hModule == -1 || hModule == 0)
{
	MsgBox, 48, Error, The dll-file couldn't be found!
	ExitApp
}
 */
websocket_connect_func 	    		:= DllCall("GetProcAddress", "UInt", hModule, "Str", "websocket_connect")
websocket_disconnect_func 	    	:= DllCall("GetProcAddress", "UInt", hModule, "Str", "websocket_disconnect")
websocket_send_func 		            	:= DllCall("GetProcAddress", "UInt", hModule, "Str", "websocket_send")
websocket_isconnected_func 	    	:= DllCall("GetProcAddress", "UInt", hModule, "Str", "websocket_isconnected")
websocket_registerCallback_func	:= DllCall("GetProcAddress", "UInt", hModule, "Str", "websocket_registerCallback")


websocket_connect(hostStr) {
	global websocket_connect_func
	return DllCall(websocket_connect_func, "Str", hostStr, "UChar")
}

websocket_disconnect() {
	global websocket_disconnect_func
	return DllCall(websocket_disconnect_func, "UChar")
}

websocket_send(data, len, is_binary) {
	global websocket_send_func
	return DllCall(websocket_send_func, "Str", data, "UInt", len, "UChar", is_binary, "UChar")
}

websocket_isconnected() {
	global websocket_isconnected_func
	return DllCall(websocket_isconnected_func, "UChar")
}

websocket_registerCallback(id, func) {
	global websocket_registerCallback_func
	return DllCall(websocket_registerCallback_func, "UInt", id, "UInt", RegisterCallback(func,"F", (id == 3) ? 2 : 0), "UChar")
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
