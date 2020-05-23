/* SciTE Director for AHK v2

*/

class SciTEdirector {
	WM_COPYDATA := 0x4A
	IDM_TOOLS := 1100	;1100-1199 can be used for lua scripts (command.number)

	__New(exeSciTE) {
		DetectHiddenWindows "On"
		OnMessage(this.WM_COPYDATA, (param*)=>this.recvmsg(param*))
		Run(exeSciTE " -director.hwnd=" A_ScriptHwnd, , , scitePID) 
		;script starts SciTE as its director
		
		WinWait("ahk_pid " scitePID)
		this.PID := scitePID
		return this
	}

	recvmsg(hwndSender, recvdata, msg, hwnd){
		size := NumGet(recvdata, A_PtrSize, A_PtrSize < 8 ? "UInt" : "UInt64")
		pData := NumGet(recvdata, A_PtrSize*2, A_PtrSize < 8 ? "UInt" : "UInt64")
		data := StrGet(pData, size, "UTF-8")
		cmd := StrSplit(data, ":")
		print("RECV: " data)
		If InStr(data,"identity:")
			this.directorID := hwndSender
	}

	sendmsg(command, param:="") {
	;"\" needs to be replaced with "\\".  Avoid regex for speed
	; see SciTE.h for constants to use with menucommand
	; IDM_TOOLS (1100 to 1199) gives 100 lua scripts <- maybe not
		cmd := command ":" param
		;~ if command == "output"
			;~ print("SEND: " command ": (Some Text)")
		;~ else
			;~ print("SEND: " cmd)
		len := this.strPutVar(cmd, myvar, "UTF-8")
		VarSetCapacity(structData, 3*A_PtrSize, 0)		
		NumPut(len, structData, A_PtrSize, "UInt64")
		NumPut(&myvar, structData, A_PtrSize*2, "UInt64")
		SendMessage( this.WM_COPYDATA, , &structData, , "ahk_id " this.directorID)
	}
	
	strPutVar(string, ByRef var, encoding) {
		; Ensure capacity.
		VarSetCapacity( var, StrPut(string, encoding)
			; StrPut returns char count, but VarSetCapacity needs bytes.
			* ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
		; Copy or convert the string.
		return StrPut(string, &var, encoding)
	}
}