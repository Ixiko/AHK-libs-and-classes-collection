; DBGp Client Functions - v0.2
; Authors: Lexikos, fincs

; Execute a DBGp command. If a continuation command is specified, omit or ignore args and response.
DBGp(session, command, args="", ByRef response="")
{
	if (r := DBGp_Send(session, command, args)) = 0
	{
		; The debugger responds to a continuation command when it next breaks execution, so return
		; immediately, and call the script's DBGp_OnBreak() callback when a response is received.
		if command in run,step_into,step_over,step_out
			r := DBGp_SetSessionAsync(session, true)
		; Other commands should complete quickly, so wait for and return a response.
		else
			r := DBGp_Receive(session, response)
	}
	return r
}

; Start listening for debugger connections. Must be called before any debugger may connect.
DBGp_StartListening(localAddress="127.0.0.1", localPort=9000)
{
	static AF_INET:=2 ; note: AF_INET is IPv4; AutoHotkey_L currently does not support IPv6.
		, SOCK_STREAM:=1, IPPROTO_TCP:=6, FD_ACCEPT:=8
	static wsaData
	if !VarSetCapacity(wsaData)
	{   ; Initialize Winsock to version 2.2.
		VarSetCapacity(wsaData,400)
		wsaError := DllCall("ws2_32\WSAStartup", "ushort", 0x202, "ptr", &wsaData)
		if wsaError
			return DBGp_WSAE(wsaError)
	}
	; Create socket to be used to listen for connections.
	s := DllCall("ws2_32\socket", "int", AF_INET, "int", SOCK_STREAM, "int", IPPROTO_TCP)
	if s = -1
		return DBGp_WSAE()
	; Bind to specific local interface, or any/all.
	VarSetCapacity(sockaddr_in, 16, 0)
	NumPut(AF_INET, sockaddr_in, 0, "ushort")
	NumPut(DllCall("ws2_32\htons", "ushort", localPort), sockaddr_in, 2, "ushort")
	NumPut(DllCall("ws2_32\inet_addr", "astr", localAddress), sockaddr_in, 4)
	if DllCall("ws2_32\bind", "uint", s, "ptr", &sockaddr_in, "int", 16) = 0 ; no error
		; Request window message-based notification of network events.
		&& DllCall("ws2_32\WSAAsyncSelect", "uint", s, "ptr", DBGp_hwnd(), "uint", 0x8000, "int", FD_ACCEPT) = 0 ; no error
		&& DllCall("ws2_32\listen", "uint", s, "int", 4) = 0 ; no error
			return s
	; An error occurred.
	DllCall("ws2_32\closesocket", "uint", s)
	return DBGp_WSAE()
}

; Set the function to be called when a debugger connection is accepted.
DBGp_OnBegin(function_name)
{
	global DBGp_OnBegin := function_name ; Subject to change.
}

; Set the function to be called when a response to a continuation command is received.
DBGp_OnBreak(function_name)
{
	global DBGp_OnBreak := function_name ; Subject to change.
}

; Set the function to be called when a stream packet is received.
DBGp_OnStream(function_name)
{
	global DBGp_OnStream := function_name ; Subject to change.
}

; Set the function to be called when a debugger connection is lost.
DBGp_OnEnd(function_name)
{
	global DBGp_OnEnd := function_name ; Subject to change.
}

; Stops listening for debugger connections. Does not disconnect debuggers, but prevents more debuggers from connecting.
DBGp_StopListening(socket)
{
	return DllCall("ws2_32\closesocket", "uint", socket) = -1 ? DBGp_WSAE() : 0
}

; Receive an XML message packet.
DBGp_Receive(session, ByRef packet)
{
	static MSG_WAITALL:=8
	; Get socket.
	s := NumGet(session+0)
	; Each message begins with a numeric string representing the length of the remainder.
	VarSetCapacity(length,20) ; Should never be longer than this, but OK if it is.
	Loop
	{   ; Read one byte at a time until null-terminator is reached.
		if DllCall("ws2_32\recv", "uint", s, "char*", c, "int", 1, "int", 0) != 1
			return DBGp_WSAE()
		if c = 0
			break
		length .= Chr(c)
	}
	if length is not integer
		return DBGp_E("invalid message length received")
	
	; Allocate buffer space for the message plus null terminator.
	VarSetCapacity(packet, ++length)
	received := 0
	While (received < length)
	{   ; recv() returns when *some* data is available, so loop until *all* data is received.
		r := DllCall("ws2_32\recv", "uint", s, "ptr", &packet + received, "int", length - received, "int", 0)
		if r = -1
			return DBGp_WSAE()
		if r = 0
			return DBGp_E("connection closed before message complete")
		received += r
	}
	packet := StrGet(&packet, "UTF-8")

	if RegExMatch(packet, "<error\s+code=""\K.*?(?="")", dbgp_error_code)
		return DBGp_E(dbgp_error_code)
	return 0 ; Success.
}

; Send a command.
DBGp_Send(session, command, args="")
{
	; Format command line (insert -i transaction_id).
	NumPut(transaction_id:=NumGet(session+A_PtrSize)+1, session+A_PtrSize)
	packet = %command% -i %transaction_id%
	if args !=
		packet .= " " . args
	
	if A_IsUnicode
	{
		VarSetCapacity(packetdata, packet_len := StrPut(packet, "UTF-8"))
		StrPut(packet, packet_ptr := &packetdata, "UTF-8")
	}else
	{
		packet_len := StrLen(packet)+1
		packet_ptr := &packet
	}
	
	if DllCall("ws2_32\send", "uint", NumGet(session+0), "ptr", packet_ptr, "int", packet_len, "int", 0) = -1
		return DBGp_WSAE()
	return 0
}

; BASE64 FUNCTIONS

DBGp_Base64UTF8Decode(ByRef base64) {
    if base64=
        return
    cp := DBGp_StringToBinary(result, base64, 1)
    return StrGet(&result, cp, "utf-8")
}

DBGp_Base64UTF8Encode(ByRef textdata) {
    if textdata=
        return
    VarSetCapacity(rawdata, StrPut(textdata, "utf-8")), sz := StrPut(textdata, &rawdata, "utf-8") - 1
	return DBGp_BinaryToString(rawdata, sz, 0x40000001)
}

DBGp_Base64Decode(ByRef base64) {
    if base64=
        return
    cp := DBGp_StringToBinary(result, base64, 1)
    NumPut(0, result, cp, A_IsUnicode ? "ushort":"char")
    VarSetCapacity(result, -1)
    return result
}
DBGp_Base64Encode(ByRef textdata) {
    return textdata!="" ? DBGp_BinaryToString(textdata, StrLen(textdata), 0x40000001) : ""
}
;http://www.autohotkey.com/forum/viewtopic.php?p=238120#238120
DBGp_BinaryToString(ByRef bin, sz=0, fmt=12) {   ; return base64 or formatted-hex
   n := sz>0 ? sz : VarSetCapacity(bin)
   DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&bin, "uint",n, "uint",fmt, "ptr",0, "uint*",cp) ; get size
   VarSetCapacity(str, cp*(A_IsUnicode ? 2:1))
   DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&bin, "uint",n, "uint",fmt, "str",str, "uint*",cp)
   return str
}
DBGp_StringToBinary(ByRef bin, hex, fmt=12) {    ; return length, result in bin
   DllCall("Crypt32.dll\CryptStringToBinary", "ptr",&hex, "uint",StrLen(hex), "uint",fmt, "ptr",0, "uint*",cp, "ptr",0,"ptr",0) ; get size
   VarSetCapacity(bin, cp)
   DllCall("Crypt32.dll\CryptStringToBinary", "ptr",&hex, "uint",StrLen(hex), "uint",fmt, "ptr",&bin, "uint*",cp, "ptr",0,"ptr",0)
   return cp
}

; SESSION API

DBGp_GetSessionSocket(session)
{
	return NumGet(session+0)
}

DBGp_GetSessionIDEKey(session)
{
	if NumGet(session+2*A_PtrSize)
		return StrGet(NumGet(session+2*A_PtrSize))
}

DBGp_GetSessionCookie(session)
{
	if NumGet(session+3*A_PtrSize)
		return StrGet(NumGet(session+3*A_PtrSize))
}

DBGp_GetSessionThread(session)
{
	return NumGet(session+4*A_PtrSize)
}

DBGp_GetSessionFile(session)
{
	if NumGet(session+5*A_PtrSize)
		return StrGet(NumGet(session+5*A_PtrSize))
}

/* ; Internal structure, subject to change.
struct session {
	( 0) uint socket         ; Handle to connected socket.
	( 4) int transactions    ; Number of transactions (for calc of next transaction_id).
	( 8) str idekey          ; Value of DBGp_IDEKEY env var (from <init ide_key/>).
	(12) str cookie          ; Value of DBGp_COOKIE env var (from <init session/>).
	(16) int thread          ; Thread ID, returned in init packet.
	(20) str fileuri         ; File URI of main script file (from <init fileuri/>).
}
*/

; *** INTERNAL FUNCTIONS ***

; Internal: Window procedure for handling WSAAsyncSelect notifications.
DBGp_WindowMessageHandler(hwnd, uMsg, wParam, lParam)
{
	static FD_ACCEPT:=8, FD_READ:=1, FD_CLOSE:=0x20
	
	uMsg &= 0xFFFFFFFF
	
	if uMsg != 0x8000
		return DllCall("DefWindowProc", "ptr", hwnd, "uint", uMsg, "ptr", wParam, "ptr", lParam)
	
	event := lParam & 0xffff
	error := (lParam >> 16) & 0xffff
	
	if (error && event != FD_CLOSE)
	{   ; what to do?
		;ListVars
		;Pause
		return 0 ;, DBGp_WSAE(error)
	}
	
	if (event = FD_ACCEPT)
	{
		; Accept incoming connection.
		s := DllCall("ws2_32\accept", "uint", wParam, "uint", 0, "uint", 0)
		if s = -1
			return 0, DBGp_WSAE()
		
		; Create structure to store information about this debugging session.
		session := DllCall("GlobalAlloc", "uint", 0x40, "ptr", 6*A_PtrSize, "ptr")
		NumPut(s, session+0)
		
		; Disable message-based notification of network events and reset to blocking/synchronous mode.
		; We should expect asynchronous messages only after issuing a continuation command, up until
		; we receive its response. All other commands are implemented synchronously (i.e. send the
		; command, then wait for, receive and process its response - which should be immediate.)
		if DBGp_SetSessionAsync(session, false) != 0
		{   ; An error occurred. Call error function for debugging, but continue anyway.
			DBGp_WSAE()
		}
		
		DBGp_AddSession(session)
		
		; Receive init packet. Relies on nonblocking mode having been disabled.
		DBGp_Receive(session, init)
		
		; Parse init packet.
		RegExMatch(init, "(?<=\bide_key="").*?(?="")", idekey)
		RegExMatch(init, "(?<=\bsession="").*?(?="")", cookie)
		RegExMatch(init, "(?<=\bfileuri="").*?(?="")", fileuri)
		RegExMatch(init, "(?<=\bthread="").*?(?="")", thread)
		idekey := DBGp_DecodeXmlEntities(idekey)
		cookie := DBGp_DecodeXmlEntities(cookie)
		fileuri := DBGp_DecodeFileURI(fileuri)
		
		; Store information in session structure.
		NumPut(DBGp_StrDup(idekey),  session+2*A_PtrSize)
		NumPut(DBGp_StrDup(cookie),  session+3*A_PtrSize)
		NumPut(            thread ,  session+4*A_PtrSize)
		NumPut(DBGp_StrDup(fileuri), session+5*A_PtrSize)
		
		global DBGp_OnBegin
		%DBGp_OnBegin%(session, init) ; fincs-edit
	}
	else if (event = FD_READ) ; Receiving data.
	{
		if !(session := DBGp_FindSessionBySocket(wParam))
			return 0, DBGp_E("received FD_READ notification for non-session socket")
		
		; Disable non-blocking mode while receiving.
		if DBGp_SetSessionAsync(session, false) != 0
			DBGp_WSAE()
		
		; Receive a stream packet or (presumably) response to a continuation command.
		if DBGp_Receive(session, response) = 0
		{
			global DBGp_OnBreak, DBGp_OnStream
			if InStr(response, "<response")
				%DBGp_OnBreak%(session, response)
			else if InStr(response, "<stream") ; <stream type="stdout|stderr">...Base64 Data...</stream>
			{
				%DBGp_OnStream%(session, response)
				if DBGp_SetSessionAsync(session, true) != 0
					DBGp_WSAE()
			}else
				DBGp_E("unsupported packet: " RegExReplace(response,"s).*?<(?!\?)([^ >]+).*","$1"))
		}
		else
			DBGp_WSAE()
			
		; Async should be left disabled unless a stream packet was received (in which case we're still
		; waiting for a response from a continuation command) or another continuation command was
		; issued (in which case that command should have re-enabled async).
	}
	else if (event = FD_CLOSE) ; Connection closed.
	{
		global DBGp_OnEnd
		session := DBGp_FindSessionBySocket(wParam)
		%DBGp_OnEnd%(session)
		DllCall("ws2_32\closesocket", "uint", wParam)
		DBGp_RemoveSession(session)
		DllCall("GlobalFree", "ptr", NumGet(session+2*A_PtrSize))
		DllCall("GlobalFree", "ptr", NumGet(session+3*A_PtrSize))
		DllCall("GlobalFree", "ptr", NumGet(session+5*A_PtrSize))
		DllCall("GlobalFree", "ptr", session)
	}
	
	return 0
}

; Internal: Add new session to list.
DBGp_AddSession(session)
{
	global DBGp_Sessions .= session "`n"
}

; Internal: Remove disconnecting session from list.
DBGp_RemoveSession(session)
{
	global DBGp_Sessions := RegExReplace(DBGp_Sessions, "(?<![^\n])\Q" session "\E\n")
}

; Internal: Find session structure given its socket handle.
DBGp_FindSessionBySocket(socket)
{
	global DBGp_Sessions
	StringTrimRight, session_list, DBGp_Sessions, 1
	Loop, Parse, session_list, `n
		if NumGet(A_LoopField+0) = socket
			return A_LoopField
}

; Internal: Enable or disable nonblocking/asynchronous mode and window message-based notification of network events.
DBGp_SetSessionAsync(session, async)
{
	static FD_READ:=1, FD_CLOSE:=0x20, FIONBIO:=0x8004667E
	s := NumGet(session+0) ; Get socket.
	if async
	{
		; Request window message-based notification for network events. Automatically sets socket so nonblocking mode.
		if DllCall("ws2_32\WSAAsyncSelect", "uint", s, "ptr", DBGp_hwnd(), "uint", 0x8000, "int", FD_READ|FD_CLOSE) = -1
			return DBGp_WSAE()
	}
	else
	{
		; Clear the event record and disable window message-based notification of network events.
		if DllCall("ws2_32\WSAAsyncSelect", "uint", s, "ptr", DBGp_hwnd(), "uint", 0, "int", 0) = -1
			return DBGp_WSAE()
		; Disable nonblocking mode.
		if DllCall("ws2_32\ioctlsocket", "uint", s, "int", FIONBIO, "uint*", 0) = -1
			return DBGp_WSAE()
	}
	return 0
}

; Convert file path to URI
; Rewritten by fincs to support Unicode paths
DBGp_EncodeFileURI(s)
{
	Loop, %s%, 0
		s := A_LoopFileLongPath
	StringReplace, s, s, \, /, All
	StringReplace, s, s, `%, `%25, All
	VarSetCapacity(h, 4)
	f := A_FormatInteger
	SetFormat, IntegerFast, Hex
	while RegExMatch(s, "[^\w\-.!~*'()/%]", c)
	{
		StrPut(c, &h, "UTF-8")
		r =
		while n := NumGet(h, A_Index-1, "UChar")
			r .= "%" DBGp_StrUpper(SubStr("0" SubStr(n, 3), -1))
		StringReplace, s, s, % c, % r, All
	}
	SetFormat, IntegerFast, %f%
	return s
}

DBGp_StrUpper(q)
{
	StringUpper, q, q
	return q
}

; Convert URI to file path
; Rewritten by fincs to support Unicode paths
DBGp_DecodeFileURI(s)
{
	if SubStr(s, 1, 8) = "file:///"
		s := SubStr(s, 9)
	StringReplace, s, s, /, \, All
	
	VarSetCapacity(buf, StrLen(s)+1)
	i := 0, o := 0
	while i <= StrLen(s)
	{
		c := NumGet(s, i * (A_IsUnicode ? 2 : 1), A_IsUnicode ? "UShort" : "UChar")
		if(c = Asc("%"))
			c := "0x" SubStr(s, i+2, 2), i += 2
		NumPut(c, buf, o, "UChar")
		i ++, o ++
	}
	return StrGet(&buf, "UTF-8")
}

; Replace XML entities with the appropriate characters.
DBGp_DecodeXmlEntities(s)
{
	; Replace XML entities which may be returned by AutoHotkey_L (e.g. in ide_key attribute of init packet if DBGp_IDEKEY env var contains one of "&'<>).
	StringReplace, s, s, &quot;, ", All
	StringReplace, s, s, &amp;, &, All
	StringReplace, s, s, &apos;, ', All
	StringReplace, s, s, &lt;, <, All
	StringReplace, s, s, &gt;, >, All
	return s
}

; Duplicates a string, for use with structures (NumPut).
DBGp_StrDup(str)
{
	p := DllCall("GlobalAlloc", "uint", 0x40, "ptr", (A_IsUnicode ? 2:1) * (StrLen(str) + 1), "ptr")
	if p
		StrPut(str, p)
	return p
}

; Internal: Creates or returns a handle to a window which can be used for window message-based notifications.
DBGp_hwnd()
{
	static hwnd
	if !hwnd
	{
		hwnd := DllCall("CreateWindowEx", "uint", 0, "str", "Static", "str", "ahkDbgpMsgWin", "uint", 0, "int", 0, "int", 0, "int", 0, "int", 0, "ptr", 0, "ptr", 0, "ptr", 0, "ptr", 0, "ptr")
		DllCall((A_PtrSize=4)?"SetWindowLong":"SetWindowLongPtr", "ptr", hwnd, "int", -4, "ptr", RegisterCallback("DBGp_WindowMessageHandler"))
	}
	return hwnd
}

; Internal: Sets ErrorLevel to WSAE:<Winsock error code> then returns an empty string.
DBGp_WSAE(n="")
{
	if n=
		n:=DllCall("ws2_32\WSAGetLastError")
	if n
		ErrorLevel=WSAE:%n%
	else
		ErrorLevel=0
	;ListLines
	;Pause
	;return ""
}

; Internal: Sets ErrorLevel then returns an empty string or DBGp error code.
DBGp_E(n)
{
	ErrorLevel := n
	if ErrorLevel is integer
		return ErrorLevel ; Return DBGp error code.
	;ListLines
	;Pause
	;return "" ; Empty/no return value indicates a client-internal error.
}


DBGp_CloseSession(session)
{
	return DllCall("ws2_32\closesocket", "uint", NumGet(session+0)) = -1 ? DBGp_WSAE() : 0
}
