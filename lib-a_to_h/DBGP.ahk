/* DBGp client functions - v1.1
 *  Enables scripts to debug other scripts via DBGp.
 *  Requires AutoHotkey v1.1.21+
 */

/*
Public functions:

DBGp_StartListening(localAddress="127.0.0.1", localPort=9000) returns socket
DBGp_OnBegin(func)          ; func(session, initPacket)
DBGp_OnBreak(func)          ; func(session, responsePacket)
DBGp_OnStream(func)         ; func(session, streamPacket)
DBGp_OnEnd(func)            ; func(session)
DBGp_StopListening(socket)

DBGp(session, command [, args, ByRef response])
DBGp_Send(session, command [, args, responseHandler])
DBGp_Receive(session, ByRef packet)

DBGp_Base64UTF8Decode(ByRef base64) returns decoded string
DBGp_Base64UTF8Encode(ByRef textdata) returns encoded string

DBGp_EncodeFileURI(filename) returns fileuri
DBGp_DecodeFileURI(fileuri) returns filename

DBGp_GetSessionSocket(session)  -> session.Socket
DBGp_GetSessionIDEKey(session)  -> session.IDEKey
DBGp_GetSessionCookie(session)  -> session.Cookie
DBGp_GetSessionThread(session)  -> session.Thread
DBGp_GetSessionFile(session)    -> session.File
*/

class DBGp_Session
{
;public:
    static __Call := Func("DBGp")
    Send     := Func("DBGp_Send")
    Receive  := Func("DBGp_Receive")
    Close    := Func("DBGp_CloseSession")
;internal:
    static OnBegin, OnBreak, OnStream, OnEnd
    static sockets := {}
    static callQueue := []
    responseQueue := []
    handlers := {}
    lastID := 0
    __New() {
        ObjSetCapacity(this, "buf", 4096)
        this.bufLen := 0
    }
    class WaitHandler {
        static Call := Func("_DBGp_WaitHandler_Call")
    }
    class QueueHandler {
        static Call := Func("_DBGp_QueueHandler_Call")
        static __New := Func("_DBGp_QueueHandler_New")
    }
}

; Start listening for debugger connections. Must be called before any debugger may connect.
DBGp_StartListening(localAddress="127.0.0.1", localPort=9000)
{
    static AF_INET:=2, SOCK_STREAM:=1, IPPROTO_TCP:=6
        , FD_ACCEPT:=8, FD_READ:=1, FD_CLOSE:=0x20
    static wsaData := ""
    if !VarSetCapacity(wsaData)
    {   ; Initialize Winsock to version 2.2.
        VarSetCapacity(wsaData, 402)
        wsaError := DllCall("ws2_32\WSAStartup", "ushort", 0x202, "ptr", &wsaData)
        if wsaError
            return DBGp_WSAE(wsaError)
    }
    ; Create socket to be used to listen for connections.
    s := DllCall("ws2_32\socket", "int", AF_INET, "int", SOCK_STREAM, "int", IPPROTO_TCP, "ptr")
    if s = -1
        return DBGp_WSAE()
    ; Bind to specific local interface, or any/all.
    VarSetCapacity(sockaddr_in, 16, 0)
    NumPut(AF_INET, sockaddr_in, 0, "ushort")
    NumPut(DllCall("ws2_32\htons", "ushort", localPort, "ushort"), sockaddr_in, 2, "ushort")
    NumPut(DllCall("ws2_32\inet_addr", "astr", localAddress), sockaddr_in, 4)
    if DllCall("ws2_32\bind", "ptr", s, "ptr", &sockaddr_in, "int", 16) = 0 ; no error
        ; Request window message-based notification of network events.
        && DllCall("ws2_32\WSAAsyncSelect", "ptr", s, "ptr", DBGp_hwnd(), "uint", 0x8000, "int", FD_ACCEPT|FD_READ|FD_CLOSE) = 0 ; no error
        && DllCall("ws2_32\listen", "ptr", s, "int", 4) = 0 ; no error
            return s
    ; An error occurred.
    DllCall("ws2_32\closesocket", "ptr", s)
    return DBGp_WSAE()
}

; Set the function to be called when a debugger connection is accepted.
DBGp_OnBegin(fn)
{
    ; Subject to change - do not use this property directly:
    DBGp_Session.OnBegin := fn ? new DBGp_Session.QueueHandler(fn) : ""
}

; Set the function to be called when a response to a continuation command is received.
DBGp_OnBreak(fn)
{
    ; Subject to change - do not use this property directly:
    DBGp_Session.OnBreak := fn ? new DBGp_Session.QueueHandler(fn) : ""
}

; Set the function to be called when a stream packet is received.
DBGp_OnStream(fn)
{
    ; Subject to change - do not use this property directly:
    DBGp_Session.OnStream := fn ? new DBGp_Session.QueueHandler(fn) : ""
}

; Set the function to be called when a debugger connection is lost.
DBGp_OnEnd(fn)
{
    ; Subject to change - do not use this property directly:
    DBGp_Session.OnEnd := fn ? new DBGp_Session.QueueHandler(fn) : ""
}

; Stops listening for debugger connections. Does not disconnect debuggers, but prevents more debuggers from connecting.
DBGp_StopListening(socket)
{
    return DllCall("ws2_32\closesocket", "ptr", socket) = -1 ? DBGp_WSAE() : 0
}

; Execute a DBGp command.
DBGp(session, command, args="", ByRef response="")
{
    response := ""
    
    handler := ""
    ; If OnBreak has been set and this is a continuation command,
    ; call OnBreak when the response is received instead of waiting.
    if InStr(" run step_into step_over step_out ", " " command " ")
        handler := DBGp_Session.OnBreak
    if wait := !handler
        handler := new DBGp_Session.WaitHandler
    
    if (r := _DBGp_SendEx(session, command, args, handler)) = 0
    {
        if wait
        {
            handler.cmd := command ;dbg
            ; Wait for and return a response.
            r := _DBGp_WaitHandler_Wait(handler, session, response)
        }
    }
    return r
}

; Send a command.
DBGp_Send(session, command, args="", responseHandler="")
{
    if responseHandler
        responseHandler := new DBGp_Session.QueueHandler(responseHandler)
    return _DBGp_SendEx(session, command, args, responseHandler)
}

_DBGp_SendEx(session, command, args, responseHandler)
{
    ; Format command line (insert -i transaction_id).
    transaction_id := ++session.lastID
    packet := command " -i " transaction_id
    if (args != "")
        packet .= " " args
    
    ; Convert to UTF-8 (regardless of ANSI vs Unicode).
    VarSetCapacity(packetData, packetLen := StrPut(packet, "UTF-8"))
    StrPut(packet, &packetData, "UTF-8")
    
    ; Set the handler first to avoid a possible race condition.
    if responseHandler
        session.handlers[transaction_id] := responseHandler
    
    if DllCall("ws2_32\send", "ptr", session.Socket, "ptr", &packetData, "int", packetLen, "int", 0) = -1
    {
        ; Remove the handler, since it is unlikely to be called. This
        ; may be unnecessary since it's likely the session is ending.
        if responseHandler
            session.handlers.Delete(transaction_id)
        return DBGp_WSAE()
    }
    return 0
}

; Retrieve the next <response/>.
DBGp_Receive(session, ByRef packet)
{
    return _DBGp_WaitHandler_Wait(session.responseQueue, session, packet)
}


; ## SESSION API ##

DBGp_GetSessionSocket(session)
{
    return session.Socket
}

DBGp_GetSessionIDEKey(session)
{
    return session.IDEKey
}

DBGp_GetSessionCookie(session)
{
    return session.Cookie
}

DBGp_GetSessionThread(session)
{
    return session.Thread
}

DBGp_GetSessionFile(session)
{
    return session.File
}

DBGp_CloseSession(session)
{
    return DllCall("ws2_32\closesocket", "ptr", session.Socket) = -1 ? DBGp_WSAE() : 0
}


; ## UTILITY FUNCTIONS ##

DBGp_Base64UTF8Decode(ByRef base64) {
    if (base64 = "")
        return
    cp := DBGp_StringToBinary(result, base64, 1)
    return StrGet(&result, cp, "utf-8")
}

DBGp_Base64UTF8Encode(ByRef textdata) {
    if (textdata = "")
        return
    VarSetCapacity(rawdata, StrPut(textdata, "utf-8")), sz := StrPut(textdata, &rawdata, "utf-8") - 1
    return DBGp_BinaryToString(rawdata, sz, 0x40000001)
}

;http://www.autohotkey.com/forum/viewtopic.php?p=238120#238120
DBGp_BinaryToString(ByRef bin, sz=0, fmt=12) {   ; return base64 or formatted-hex
   n := sz>0 ? sz : VarSetCapacity(bin)
   DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&bin, "uint",n, "uint",fmt, "ptr",0, "uint*",cp:=0) ; get size
   VarSetCapacity(str, cp*(A_IsUnicode ? 2:1))
   DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&bin, "uint",n, "uint",fmt, "str",str, "uint*",cp)
   return str
}
DBGp_StringToBinary(ByRef bin, hex, fmt=12) {    ; return length, result in bin
   DllCall("Crypt32.dll\CryptStringToBinary", "ptr",&hex, "uint",StrLen(hex), "uint",fmt, "ptr",0, "uint*",cp:=0, "ptr",0,"ptr",0) ; get size
   VarSetCapacity(bin, cp)
   DllCall("Crypt32.dll\CryptStringToBinary", "ptr",&hex, "uint",StrLen(hex), "uint",fmt, "ptr",&bin, "uint*",cp, "ptr",0,"ptr",0)
   return cp
}

; Convert file path to URI
; Rewritten by fincs to support Unicode paths
DBGp_EncodeFileURI(s)
{
    len := DllCall("GetFullPathName", "str", s, "uint", 0, "ptr", 0, "ptr", 0)
    VarSetCapacity(buf, len*2)
    DllCall("GetFullPathName", "str", s, "uint", len, "str", buf, "ptr", 0)
    s := StrReplace(StrReplace(s, "\", "/"), "%", "%25")
    VarSetCapacity(h, 4)
    regex := (A_AhkVersion >= "2." ? "" : "O)") "[^\w\-.!~*'()/%]"
    while RegExMatch(s, regex, c)
    {
        StrPut(c[0], &h, "UTF-8")
        r := ""
        while n := NumGet(h, A_Index-1, "UChar")
            r .= Format("%{:02X}", n)
        s := StrReplace(s, c[0], r)
    }
    return s
}

; Convert URI to file path
; Rewritten by fincs to support Unicode paths
DBGp_DecodeFileURI(s)
{
    if SubStr(s, 1, 8) = "file:///"
        s := SubStr(s, 9)
    s := StrReplace(s, "/", "\")
    
    VarSetCapacity(buf, StrLen(s)+1)
    i := 0, o := 0
    while i <= StrLen(s)
    {
        c := NumGet(s, i * (A_IsUnicode ? 2 : 1), A_IsUnicode ? "UShort" : "UChar")
        if (c = Ord("%"))
            c := "0x" SubStr(s, i+2, 2), i += 2
        NumPut(c, buf, o, "UChar")
        i++, o++
    }
    return StrGet(&buf, "UTF-8")
}

; Replace XML entities with the appropriate characters.
DBGp_DecodeXmlEntities(s)
{
    ; Replace XML entities which may be returned by AutoHotkey_L (e.g. in ide_key attribute of init packet if DBGp_IDEKEY env var contains one of "&'<>).
    s := StrReplace(s, "&quot;", Chr(34))
    s := StrReplace(s, "&amp;", "&")
    s := StrReplace(s, "&apos;", "'")
    s := StrReplace(s, "&lt;", "<")
    s := StrReplace(s, "&gt;", ">")
    return s
}


; ## INTERNAL FUNCTIONS ##

; Internal: Window procedure for handling WSAAsyncSelect notifications.
DBGp_HandleWindowMessage(hwnd, uMsg, wParam, lParam)
{
    static FD_ACCEPT:=8, FD_READ:=1, FD_CLOSE:=0x20
    
    ; Must not be interrupted by FD_READ while processing FD_ACCEPT
    ; (e.g. setting up the session which FD_READ may be received for)
    ; or FD_READ (still processing previous data).
    Critical 10000

    uMsg &= 0xFFFFFFFF
    
    if uMsg != 0x8000
        return DllCall("DefWindowProc", "ptr", hwnd, "uint", uMsg, "ptr", wParam, "ptr", lParam)
    
    event := lParam & 0xffff
    ; error := (lParam >> 16) & 0xffff
    
    if (event = FD_ACCEPT)
    {
        ; Accept incoming connection.
        s := DllCall("ws2_32\accept", "ptr", wParam, "uint", 0, "uint", 0, "ptr")
        if s = -1
        {
            DBGp_WSAE()
            return 0
        }
        
        ; Create object to store information about this debugging session.
        session := new DBGp_Session
        session.Socket := s
        
        DBGp_AddSession(session)
    }
    else if (event = FD_READ) ; Receiving data.
    {
        if !(session := DBGp_FindSessionBySocket(wParam))
            return 0
        
        DBGp_HandleIncomingData(session)
    }
    else if (event = FD_CLOSE) ; Connection closed.
    {
        if !(session := DBGp_FindSessionBySocket(wParam))
            return 0
        
        DBGp_CallHandler(DBGp_Session.OnEnd, session)
        
        DBGp_RemoveSession(session), session.Socket := -1
        DllCall("ws2_32\closesocket", "ptr", wParam)
    }
    
    return 0
}

DBGp_HandleIncomingData(session)
{
    cap := ObjGetCapacity(session, "buf")
    ptr := ObjGetAddress(session, "buf")
    len := session.bufLen
    
    ; Copy available data into the buffer.
    r := DllCall("ws2_32\recv", "ptr", session.Socket
                , "ptr", ptr + len, "int", cap - len, "int", 0)
    ; Be tolerant of errors because WSAEWOULDBLOCK is expected in some
    ; cases, and even if some other error occurs, there may be data in
    ; our buffer that we can try to process.
    if (r != -1)
        session.bufLen := (len += r)
    
    if (packetLen := session.packetLen) = ""
    {
        ; Each message begins with the length of the message body
        ; encoded as a null-terminated numeric string.
        
        ; Ensure the data is null-terminated.
        NumPut(0, ptr+0, len, "char")
        
        headerLen := DllCall("lstrlenA", "ptr", ptr)
        
        ; If we've received the complete string, len must include the 
        ; null-terminator.  Otherwise, the data is invalid/incomplete.
        ; This case should be very rare:
        if (headerLen = len)
        {
            ; Haven't seen the null-terminator yet.
            if (len < 20)
                return
            ; This section can only execute if we've received >= 20
            ; bytes and still don't have a null-terminated string.
            ; No valid message length would be >= 20 characters.
            packetLen := "invalid"
        }
        else
        {
            ; The most common case: we've received the complete header.
            packetLen := StrGet(ptr, headerLen, "utf-8")
        }
        
        if packetLen is not integer
        {
            ; Recovering from invalid data doesn't seem very useful in
            ; this context, so just shutdown and wait for the other end
            ; to close the connection.
            DllCall("ws2_32\shutdown", "ptr", session.Socket, "int", 2)
            return DBGp_E("invalid message header")
        }
        
        ; Let packetLen include the null-terminator.
        packetLen += 1
        
        ; Discard the null-terminated header.
        headerLen += 1
        len -= headerLen
        DllCall("RtlMoveMemory", "ptr", ptr, "ptr", ptr + headerLen, "ptr", len)
        
        ; Ensure the buffer is large enough for the complete packet.
        if (cap < packetLen)
        {
            ; Grow exponentially to avoid incrementally reallocating.
            while (cap < packetLen)
                cap *= 2
            if !(cap := ObjSetCapacity(session, "buf", cap))
                throw Exception("Insufficient memory")
            ptr := ObjGetAddress(session, "buf")
        }
        
        ; Update session object.
        session.bufLen := len
        session.packetLen := packetLen
    }
    
    if (len >= packetLen)  ; We have a complete packet.
    {
        ; Retrieve and decode the packet.
        packet := StrGet(ptr, packetLen, "utf-8")
        
        ; Remove it from the buffer.
        session.bufLen := (len -= packetLen)
        DllCall("RtlMoveMemory", "ptr", ptr, "ptr", ptr + packetLen, "ptr", len)
        session.packetLen := ""
        
        if len
        {
            ; Post a message so this function will be called again to
            ; process the rest of the data.  Unlike loop/goto, this
            ; method allows data to be received and processed while one
            ; of the handlers called below is still running.
            DllCall("PostMessage", "ptr", DBGp_hwnd(), "uint", 0x8000
                    , "ptr", session.Socket, "ptr", 1)
        }
        
        ; Call the appropriate handler.
        if !RegExMatch(packet, "<\K\w+", packetType)
            DBGp_E("invalid packet")
        else if (packetType = "response")
            DBGp_HandleResponsePacket(session, packet)
        else if (packetType = "stream")
            DBGp_HandleStreamPacket(session, packet)
        else if (packetType = "init")
            DBGp_HandleInitPacket(session, packet)
        else
            DBGp_E("unknown packet type: " packetType)
    }
}

DBGp_CallHandler(handler, session="", ByRef packet="")
{
    handler.Call(session, packet)
}

_DBGp_QueueHandler_Call(handler, session, ByRef packet)
{
    DBGp_Session.callQueue.Push([handler.fn, session, packet])
    ; Using a single timer ensures that each handler finishes before
    ; the next is called, and that each runs in its own thread.
    SetTimer _DBGp_DispatchTimer, -1
}

_DBGp_DispatchTimer()
{
    ; Call exactly one handler per new thread.
    if next := DBGp_Session.callQueue.RemoveAt(1)
        fn := next[1], %fn%(next[2], next[3])
    ; If the queue is not empty, reset the timer.
    if DBGp_Session.callQueue.Length()
        SetTimer _DBGp_DispatchTimer, -1
}

_DBGp_QueueHandler_New(handler, fn)
{
    handler.fn := IsObject(fn) ? fn : Func(fn)
}

_DBGp_WaitHandler_Call(handler, session, ByRef response)
{
    ObjPush(handler, response)
}

_DBGp_WaitHandler_Wait(handler, session, ByRef response)
{
    WasCritical := A_IsCritical
    Critical Off ; Must be Off to allow data to be received.
    while !ObjLength(handler)
    {
        if session.Socket = -1
            return DBGp_E("Disconnected")
        Sleep 10
    }
    Critical % WasCritical
    response := ObjRemoveAt(handler, 1)
    if RegExMatch(response, "<error\s+code=""\K.*?(?="")", DBGp_error_code)
        return DBGp_E(DBGp_error_code)
    return 0 ; Success.
}

DBGp_HandleResponsePacket(session, ByRef packet)
{
    if RegExMatch(packet, "(?<=\btransaction_id="").*?(?="")", transaction_id)
        && (handler := session.handlers.Delete(transaction_id))
    {
        ; Call the callback previously set for this transaction.
        DBGp_CallHandler(handler, session, packet)
    }
    else
    {
        ; Append the packet to the queue, for DBGp_Receive().
        session.responseQueue.Push(packet)
    }
}

DBGp_HandleStreamPacket(session, ByRef packet)
{
    DBGp_CallHandler(DBGp_Session.OnStream, session, packet)
}

DBGp_HandleInitPacket(session, ByRef packet)
{
    ; Parse init packet.
    RegExMatch(packet, "(?<=\bide_key="").*?(?="")", idekey)
    RegExMatch(packet, "(?<=\bsession="").*?(?="")", cookie)
    RegExMatch(packet, "(?<=\bfileuri="").*?(?="")", fileuri)
    RegExMatch(packet, "(?<=\bthread="").*?(?="")", thread)
    
    ; Store information in session object.
    session.IDEKey := DBGp_DecodeXmlEntities(idekey)
    session.Cookie := DBGp_DecodeXmlEntities(cookie)
    session.Thread := thread
    session.File   := DBGp_DecodeFileURI(fileuri)
    
    DBGp_CallHandler(DBGp_Session.OnBegin, session, packet)
}

; Internal: Add new session to list.
DBGp_AddSession(session)
{
    DBGp_Session.sockets[session.Socket] := session
}

; Internal: Remove disconnecting session from list.
DBGp_RemoveSession(session)
{
    DBGp_Session.sockets.Delete(session.Socket)
}

; Internal: Find session structure given its socket handle.
DBGp_FindSessionBySocket(socket)
{
    return DBGp_Session.sockets[socket]
}

; Internal: Creates or returns a handle to a window which can be used for window message-based notifications.
DBGp_hwnd()
{
    static hwnd := 0
    if !hwnd
    {
        hwnd := DllCall("CreateWindowEx", "uint", 0, "str", "Static", "str", "ahkDBGpMsgWin", "uint", 0, "int", 0, "int", 0, "int", 0, "int", 0, "ptr", 0, "ptr", 0, "ptr", 0, "ptr", 0, "ptr")
        DllCall((A_PtrSize=4)?"SetWindowLong":"SetWindowLongPtr", "ptr", hwnd, "int", -4, "ptr", RegisterCallback("DBGp_HandleWindowMessage"))
    }
    return hwnd
}

; Internal: Sets ErrorLevel to WSAE:<Winsock error code> then returns an empty string.
DBGp_WSAE(n="")
{
    if (n = "")
        n := DllCall("ws2_32\WSAGetLastError")
    if n
        ErrorLevel := "WSAE:" n
    else
        ErrorLevel := 0
}

; Internal: Sets ErrorLevel then returns an empty string or DBGp error code.
DBGp_E(n)
{
    ErrorLevel := n
    if ErrorLevel is integer
        return ErrorLevel ; Return DBGp error code.
    ; Empty/no return value indicates an internal/protocol error.
}
