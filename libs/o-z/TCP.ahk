; --------------------------------------------------------------------------------------------------------------------------------
TCP_Startup(OnExit = True, OnMessage = "") {
   ; Returns True upon success, False upon failure
   ; The WSAStartup function initiates use of the Winsock DLL by a process.
    Static WSADataSize := 394 + A_PtrSize
    HDLL := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ws2_32.dll", "UPtr")
    If !(HDLL) {
      MsgBox, % "WS2_32.dll could not be loaded!"
      Return False
   }
   TCP_Handle(HDLL)
   VarSetCapacity(WSAData, WSADataSize, 0)
   ; Request Winsock 2.0 (0x0002)
   Result := DllCall("Ws2_32.dll\WSAStartup", "UShort", 0x0002, "Ptr", &WSAData, "Int")
   ; Since WSAStartup() must be the first Winsock function called by this 
   ; script, check ErrorLevel to see if the OS has Winsock 2.0 available
   If (ErrorLevel) {
      MsgBox, % "WSAStartup() could not be called due to error " . ErrorLevel 
              . "`nWinsock 2.0 or higher is required."
      Return False
   }
   ; Non-zero, which means it failed (most Winsock functions Return 0 upon success).
   If (Result) { 
      MsgBox % "WSAStartup() indicated Winsock error " . DllCall("Ws2_32.dll\WSAGetLastError", "Int")
      Return False
   }
   If (OnExit)
      OnExit, TCP_OnExit ; For connection cleanup purposes.
   If (OnMessage)
      OnMessage(TCP_Message(), OnMessage) ; Register messagehandler for TCP event notifications.
   Return True
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_Shutdown() {
   ; MSDN: "Any sockets open when WSACleanup is called are reset and automatically
   ; deallocated as if closesocket was called."
   ; A script must call one TCP_Shutdown() call for every successful TCP_Startup() call.
   DllCall("Ws2_32.dll\WSACleanup")
   If TCP_Handle()
      DllCall("Kernel32.dll\FreeLibrary", "Ptr", TCP_Handle())
   Return True
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_Listen(IPAddress, Port) {
   ; Create a listener socket for incoming connections
   ; This can connect to most types of TCP servers, not just Network.
   ; Returns -1 (INVALID_SOCKET) upon failure or the socket ID upon success.
   Static INVALID_SOCKET = -1
   Static SOMAXCONN = 0x7FFFFFFF
   Static AF_INET = 2
   Static SOCK_STREAM = 1
   Static IPPROTO_TCP = 6
   Static SOCKADDRSize = 16
   Socket := DllCall("Ws2_32.dll\socket", "Int", AF_INET, "Int", SOCK_STREAM, "Int", IPPROTO_TCP, "Ptr")
   If (Socket = INVALID_SOCKET) {
      MsgBox % "socket() indicated Winsock error " . DllCall("Ws2_32.dll\WSAGetLastError", "Int")
      Return Socket
   }
   ; Prepare for connection:
   VarSetCapacity(SOCKADDR, SOCKADDRSize, 0)
   NumPut(AF_INET, SOCKADDR, 0, "Short") ; sin_family
   NumPut(DllCall("Ws2_32.dll\htons", "UShort", Port), SOCKADDR, 2, "UShort") ; sin_port
   NumPut(DllCall("Ws2_32.dll\inet_addr", "AStr", IPAddress, "UInt"), SOCKADDR, 4, "UInt") ; sin_addr.s_addr
   ; Bind to socket:
   If DllCall("Ws2_32.dll\bind", "Ptr", Socket, "Ptr", &SOCKADDR, "Int", SOCKADDRSize, "Int") {
      MsgBox % "bind() indicated Winsock error " . DllCall("Ws2_32.dll\WSAGetLastError", "Int")
      Return INVALID_SOCKET
   }
   If DllCall("Ws2_32.dll\listen", "Ptr", Socket, "UInt", SOMAXCONN, "Int") {
      MsgBox % "listen() indicated Winsock error " . DllCall("Ws2_32.dll\WSAGetLastError", "Int")
      Return INVALID_SOCKET
   }
   ; Request Windows message-based notification of incoming connections.
   TCP_AsyncSelect(Socket, TCP_Hwnd(), TCP_Message(), "FD_ACCEPT")
   Return Socket  ; Indicate success by returning a valid socket ID rather than -1. 
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_Accept(Listener, hWnd) {
   Static INVALID_SOCKET = -1
   Socket := DllCall("Ws2_32.dll\accept", "Ptr", Listener, "UInt", 0, "Int", 0, "UPtr")
   If (Socket = INVALID_SOCKET) {
      MsgBox % "socket() indicated Winsock error " . DllCall("Ws2_32.dll\WSAGetLastError", "Int")
      Return Socket
   }
   TCP_AsyncSelect(Socket, hWnd, TCP_Message(), "FD_CLOSE|FD_READ|FD_CONNECT")
   Return Socket
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_Socket() {
   ; Returns -1 (INVALID_SOCKET) upon failure or the socket ID upon success.
   Static INVALID_SOCKET := -1
   Static AF_INET := 2     ; address family
   Static SOCK_STREAM := 1 ; socket type
   Static IPPROTO_TCP := 6 ; protocol
   Socket := DllCall("Ws2_32.dll\socket", "Int", AF_INET, "Int", SOCK_STREAM, "Int", IPPROTO_TCP, "UPtr")
   If (Socket = INVALID_SOCKET)
      MsgBox % "socket() indicated Winsock error " . DllCall("Ws2_32.dll\WSAGetLastError", "Int")
   Return Socket
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_Connect(Socket, IPAddress, Port) {
   ; Returns True upon success or False upon failure. 
   ; Prepare for connection
   Static INVALID_SOCKET := -1
   Static AF_INET := 2 ; address family
   Static SOCKADDRSize := 16
   If (Socket = INVALID_SOCKET) {
      Socket := TCP_Socket()
      If (Socket = INVALID_SOCKET)
         Return INVALID_SOCKET
   }
   VarSetCapacity(SOCKADDR, SOCKADDRSize, 0)
   NumPut(AF_INET, SOCKADDR, 0, "Short") ; sin_family
   NumPut(DllCall("Ws2_32.dll\htons", "UShort", Port, "UShort"), SOCKADDR, 2, "UShort") ; sin_port
   Numput(DllCall("Ws2_32.dll\inet_addr", "AStr", IPAddress, "UInt"), SOCKADDR, 4, "UInt") ; sin_addr.s_addr
   ; Attempt connection
   If DllCall("Ws2_32.dll\connect", "Ptr", Socket, "Ptr", &SOCKADDR, "Int", SOCKADDRSize, "Int") {
      MsgBox % "connect() indicated Winsock error " . DllCall("Ws2_32.dll\WSAGetLastError", "Int")
      Return INVALID_SOCKET
   }
   TCP_AsyncSelect(Socket, TCP_Hwnd(), TCP_Message(), "FD_READ|FD_CLOSE|FD_CONNECT")
   Return Socket 
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_Disconnect(Socket) {
   If DllCall("Ws2_32.dll\closesocket", "Ptr", Socket, "Int") {
      MsgBox % "closesocket() indicated Winsock error " . DllCall("Ws2_32.dll\WSAGetLastError", "Int")
      Return False
   }
   Return True
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_AsyncSelect(Socket, hWnd, Msg, Events) {
   ; Request Windows message-based notification of network events for a socket.
   ; This avoids the need to poll the connection and thus cuts down on resource usage.
   Static FD_READ = 1     ; Receive notification when data is available to be read.
   Static FD_ACCEPT = 8   ; Receive notification of incoming connections.
   Static FD_CONNECT = 16 ; Recieve notification when connection has been made.
   Static FD_CLOSE = 32   ; Receive notification when connection has been closed.
   ThisEvents := 0
   Loop, Parse, Events, |
      If %A_LoopField%
         ThisEvents |= %A_LoopField%
   If DllCall("Ws2_32.dll\WSAAsyncSelect", "Ptr", Socket, "Ptr", hWnd, "UInt", Msg, "Int", ThisEvents, "Int") {
      MsgBox % "WSAAsyncSelect() indicated Winsock error " . DllCall("Ws2_32.dll\WSAGetLastError", "Int")
      ExitApp
   }
   Return True
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_Event(Socket, lParam, Msg, hWnd) {
   Static FD_READ = 1     ; Notification when data is available to be read.
   Static FD_ACCEPT = 8   ; Notification of incoming connections.
   Static FD_CONNECT = 16 ; Notification when connection has been made.
   Static FD_CLOSE = 32   ; Notification when connection has been closed.
   Static ReceivedDataSize := 4096  ; Large in case a lot of data gets buffered due to delay in processing previous data.
   ThisEvent := TCP_LoWord(lParam)
   ThisError := TCP_HiWord(lParam)
   If (ThisEvent = FD_ACCEPT) {
      NewSocket := TCP_Accept(Socket, hWnd)
      If (NewSocket = -1) {
         TCP_Send(NewSocket, "Connection rejected!")
         Return NewSocket . " >>> Connection rejected!"
      } Else {
         TCP_Send(NewSocket, "Connection accepted!")
         Return NewSocket . " >>> Connection accepted!"
      }
   }
   If (ThisEvent = FD_CLOSE) {
      TCP_Disconnect(Socket)
      Return Socket . " >>> Connection closed!"
   }
   If (ThisEvent = FD_CONNECT) {
      Return Socket . " >>> Connection accepted!"
   }
   If (ThisEvent = FD_READ) {
   ; The loop solves the issue of the notification message being discarded due to thread-already-running.
      Data := ""
      Loop { 
         VarSetCapacity(ReceivedData, ReceivedDataSize, 0)  ; 0 for last param terminates string for use with recv().
         ReceivedDataLength := DllCall("Ws2_32.dll\recv", "Ptr", Socket, "Ptr", &ReceivedData, "Int", ReceivedDataSize, "Int", 0, "Int")
         If ReceivedDataLength = 0  ; The connection was gracefully closed,
            ExitApp ; The OnExit routine will call WSACleanup() for us.
         If (ReceivedDataLength = -1) {
            WinsockError := DllCall("Ws2_32.dll\WSAGetLastError", "Int")
            If (WinsockError = 10035) { ; WSAEWOULDBLOCK, which means "no more data to be read".
               Return Socket . " <<< " . Data
            }
            If (WinsockError <> 10054) { ; WSAECONNRESET, which happens when Network closes via system shutdown/logoff.
               ; Since it's an unexpected error, report it.  Also exit to avoid infinite loop.
               MsgBox % "recv() indicated Winsock error " . WinsockError
            }
            ExitApp ; The OnExit routine will call WSACleanup() for us.
         }
         ; Otherwise, process the data received.
         Data .= StrGet(&ReceivedData, "UTF-8")
      }
   }
   Return False ; Tell the program that no further processing of this message is needed.
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_Send(Socket, Data) {
   SOCKET_ERROR = -1
   VarSetCapacity(SendData, SendDataLength := StrPut(Data, "UTF-8"), 0)
   StrPut(Data, &SendData, "UTF-8")
   RetVal := DllCall("Ws2_32.dll\send", "Ptr", Socket, "Ptr", &SendData, "Int", SendDataLength, "Int", 0, "Int")
   If (RetVal = SOCKET_ERROR) {
      MsgBox % "send() indicated Winsock error " . DllCall("Ws2_32.dll\WSAGetLastError", "Int")
      Return False
   }
   Return RetVal
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_Hwnd() {
   Return A_ScriptHwnd
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_Handle(Handle = "") {
   Static TPCHandle := 0
   If (Handle)
      TPCHandle := Handle
   Return TPCHandle
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_Message(Msg = "") {
   ; An arbitrary message number, but should be greater than 0x1000.
   Static TCPMsg := 0x5555
   If (Msg)
      TCPMsg := Msg
   Return TCPMsg
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_LoWord(DWORD) {
   Return (DWORD & 0xFFFF)
}
; --------------------------------------------------------------------------------------------------------------------------------
TCP_HiWord(DWORD) {
   Return ((DWORD >> 16) & 0xFFFF)
}
; --------------------------------------------------------------------------------------------------------------------------------
; This subroutine is called automatically when the script exits for any reason.
TCP_OnExit:
   TCP_Shutdown()
ExitApp