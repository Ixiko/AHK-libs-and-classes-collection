/*
Title: Socket Lib (Netzwerk) + HowTo
Author: Bentschi
Website: http://de.autohotkey.com/forum/viewtopic.php?p=62765#62765

WS_Startup(version=2.0) Started Winsock 2.0 oder höher
WS_Shutdown() Beendet Winsock
WS_Socket(protocol="TCP", ipversion="IPv4") Erstellt einen Socket (eine neue Verbindung)
WS_CloseSocket(byref socket) Beendet einen Socket
WS_GetSocketInfo(socket, byref af, byref maxsockaddr, byref minsockaddr, byref type, byref protocol) Ermittelt die informationen die automatisch bei Socket() gesetzt werden.
WS_Listen(socket, backlog=32) Erlaubt eine eingehende verbindung
WS_Bind(socket, ip, port) Bindet den Socket an eine Adresse oder einen Host
WS_Accept(socket, byref out_ip, byref out_port) Nimmt eine eingehende verbindung an.
WS_Connect(socket, ip, port) Verbindet zu einer Adresse
WS_RecvFrom(socket, byref out_ip, byref out_port, byref message, len=1024, flags=0) Wartet bis eine Nachricht eintrifft und ließt diese.
WS_Recv(socket, byref message, len=1024, flags=0) Wartet bis eine Nachricht eintrifft und ließt diese.
WS_RecvBinary(socket, byref pbuffer, len, flags=0) Wartet bis eine Nachricht eintrifft und ließt diese (binär).
WS_RecvFile(socket, file, flags=0) Speichert eine eingehende Nachricht in eine Datei.
WS_SendTo(socket, ip, port, message, len=0, flags=0) Sendet eine Nachricht.
WS_Send(socket, message, len=0, flags=0) Sendet eine Nachricht.
WS_SendBinary(socket, buffer, len=0, flags=0) Sendet eine Nachricht (Binär).
WS_SendFile(socket, file, flags=0) Sendet den Inhalt einer Datei.
WS_GetAddressFromString(hostname_or_ip) 05.12.2010 - Ersetzt durch WS_GetAddrInfo()
WS_GetAddrInfo(socket, hostname_or_ip, port, byref sockaddr, byref sockaddrlen) Konvertiert einen Hostnamen zu einer IP und gibt die struktur sockaddr zurück.
WS_EnableBroadcast(socket) Erlaubt Broadcast für UDP
WS_MessageSize(socket) Ermittelt die größe in bytes einer Nachricht am eingang.
WS_HandleEvents(socket, events="READ ACCEPT CONNECT CLOSE") Events die in Callbacks bearbeited werden sollen.
WS_Log(str, type=0) Schreibt den Log
WS_GetLog() Giebt den Log zurück und löscht den Buffer.
WS_GetConsoleInput() Erlaubt die Benutzereingabe, wenn die Konsole verwendet wird.


Callbacks:
============================
WS_OnRead(socket) Wird ausgeführt wenn WS_HandleEvents() mit "READ" aufgerufen wird und Daten zum lesen vorhanden sind
WS_OnAccept(socket) Wird ausgeführt wenn WS_HandleEvents() mit "ACCEPT" aufgerufen wird und eine eingehende Verbindung vorhanden ist.
WS_OnConnect(socket) Wird ausgeführt wenn WS_HandleEvents() mit "CONNECT" aufgerufen wird und der Socket bereits verbunden ist.
WS_OnClose(socket) Wird ausgeführt wenn WS_HandleEvents() mit "CLOSE" aufgerufen wird und die Verbindung unterbrochen wird.


Interne Funktionen:
============================
WS_Proc(wParam, lParam, msg, hwnd) Ist ein Callback, das die Informationen an WS_DefProc oder WS_On... weiterleitet.
WS_DefProc(socket, event) Ist ein Callback das die Standartaktion für WS_HandleEvents() ausführt


Globale Variablen:
============================
WS_NOLOG Schreibt keinen Log
WS_LOGTOCONSOLE Zeigt den Log in einer Konsole an.
WS_LASTRECVMESSAGE Enthält die zulezt gelesene Nachricht, wenn WS_OnRead() definiert wurde, aber nicht existiert oder 0 (false) zurückgiebt.
WS_LASTACCEPTEDSOCKET Enthält den Socket der letzten akzeptierten Verbindung, wenn WS_OnAccept() definiert wurde, aber nicht existiert oder 0 (false) zurückgiebt.
WS_LASTACCEPTEDIP Enthält die IP-Adresse der letzten akzeptierten Verbindung, wenn WS_OnAccept() definiert wurde, aber nicht existiert oder 0 (false) zurückgiebt.
WS_LASTACCEPTEDPORT Enthält den Port der letzten akzeptierten Verbindung, wenn WS_OnAccept() definiert wurde, aber nicht existiert oder 0 (false) zurückgiebt.
WS_LASTCONNECTEDSOCKET Enthält den Socket der neuesten Verbindung, wenn WS_OnConnect() definiert wurde, aber nicht existiert oder 0 (false) zurückgiebt.
WS_LASTCLOSEDSOCKET Enthält den zulezt geschlossenen Socket, wenn WS_OnClose() definiert wurde, aber nicht existiert oder 0 (false) zurückgiebt.


Hinweise:
============================
- Die in WS_HandleEvents() definierten Callbacks müssen nicht im script existieren.
In diesem Fall übernimmt WS_DefProc() eine Standardaktion.
WS_DefProc() wird ebenso aufgerufen, wenn eines der Callbacks 0 (false) zurückgiebt.

- Anstelle von den Parametern "ip" kann auch ein Hostname verwendet werden. (bsp: "www.someurl.com")
ACHTUNG: Der Hostname darf kein "http://", "ftp://" oder sonstige Protokollinformationen enthalten.
Andernfalls kann auch eine der folgenen IP-Addressen (für IPv4) verwendet werden:
"0.0.0.0" für INADDR_ANY bzw. ADDR_ANY
"127.0.0.1" für INADDR_LOOPBACK bzw. ADDR_LOOPBACK
"255.255.255.255" für INADDR_BROADCAST bzw. ADDR_BROADCAST
"255.255.255.255" für INADDR_NONE bzw. ADDR_NONE
*/

WS_HandleEvents(socket, events="READ ACCEPT CONNECT CLOSE"){
  static FD_READ := 1, FD_ACCEPT := 8, FD_CONNECT := 16, FD_CLOSE := 32
  static msg := 0xB93D
  Ptr := (A_PtrSize) ? "uptr" : "uint"
  fdevents := 0
  Loop, parse, events, % " "
  {
    if (A_LoopField="READ")
      fdevents |= FD_READ
    else if (A_LoopField="ACCEPT")
      fdevents |= FD_ACCEPT
    else if (A_LoopField="CONNECT")
      fdevents |= FD_CONNECT
    else if (A_LoopField="CLOSE")
      fdevents |= FD_CLOSE
  }

  WS_Log(A_ThisFunc "(" socket ")", 3)
  OnMessage(msg, "WS_Proc")
  Gui, 33: +LastFound
  if (DllCall("ws2_32\WSAAsyncSelect", Ptr, socket, Ptr, WinExist(), "uint", msg, "uint", fdevents)!=0)
  {
    WS_Log("[ERROR] Can't handle events", 1)
    return 0
  }
  return 1
}

WS_Proc(wParam, lParam, msg, hwnd){
  static FD_READ := 1, FD_ACCEPT := 8, FD_CONNECT := 16, FD_CLOSE := 32
  event := lParam & 0xFFFF
  error := lParam >> 16
  socket := wParam

  if (event=FD_READ)
  {
    Func := (IsFunc("WS_OnRead")) ? "WS_OnRead" : "WS_DefProc"
    if (IsFunc("WS_OnRead"))
      result := %Func%(socket)
    if ((result=0) || (!IsFunc("WS_OnRead")))
      WS_DefProc(socket, event)
  }
  else if (event=FD_ACCEPT)
  {
    Func := (IsFunc("WS_OnAccept")) ? "WS_OnAccept" : "WS_DefProc"
    if (IsFunc("WS_OnAccept"))
      result := %Func%(socket)
    if ((result=0) || (!IsFunc("WS_OnAccept")))
      WS_DefProc(socket, event)
  }
  else if (event=FD_CONNECT)
  {
    Func := (IsFunc("WS_OnConnect")) ? "WS_OnConnect" : "WS_DefProc"
    if (IsFunc("WS_OnConnect"))
      result := %Func%(socket)
    if ((result=0) || (!IsFunc("WS_OnConnect")))
      WS_DefProc(socket, event)
  }
  else if (event=FD_CLOSE)
  {
    Func := (IsFunc("WS_OnClose")) ? "WS_OnClose" : "WS_DefProc"
    if (IsFunc("WS_OnClose"))
      result := %Func%(socket)
    if ((result=0) || (!IsFunc("WS_OnClose")))
      WS_DefProc(socket, event)
  }
  return 1
}

WS_DefProc(socket, event){
  global WS_LASTRECVMESSAGE, WS_LASTACCEPTEDSOCKET, WS_LASTACCEPTEDIP, WS_LASTACCEPTEDPORT
  global WS_LASTCONNECTEDSOCKET, WS_LASTCLOSEDSOCKET

  static FD_READ := 1, FD_ACCEPT := 8, FD_CONNECT := 16, FD_CLOSE := 32

  if (event=FD_READ)
  {
    WS_Log("Handle READ for socket " socket, 5)
    size := WS_MessageSize(socket)
    if (size>0)
      WS_Recv(socket, WS_LASTRECVMESSAGE, size)
    return 1
  }
  else if (event=FD_ACCEPT)
  {
    WS_Log("Handle ACCEPT for socket " socket, 5)
    WS_LASTACCEPTEDSOCKET := WS_Accept(socket, WS_LASTACCEPTEDIP, WS_LASTACCEPTEDPORT)
    return 1
  }
  else if (event=FD_CONNECT)
  {
    WS_Log("Handle CONNECT for socket " socket, 5)
    WS_LASTCONNECTEDSOCKET := socket
    return 1
  }
  else if (event=FD_CLOSE)
  {
    WS_Log("Handle CLOSE for socket " socket, 5)
    WS_LASTCLOSEDSOCKET := socket
    WS_CloseSocket(socket)
    return 1
  }
  return 1
}

WS_MessageSize(socket){
  static FIONREAD := 0x4004667F
  Ptr := (A_PtrSize) ? "uptr" : "uint"

  VarSetCapacity(argp, 4, 0)
  if (DllCall("ws2_32\ioctlsocket", Ptr, socket, "uint", FIONREAD, Ptr, &argp)!=0)
    return 0
  return NumGet(argp, 0, "int")
}

WS_EnableBroadcast(socket)  { ;(UDP only!)
  static SOL_SOCKET := 0xFFFF
  static SO_BROADCAST := 0x0020
  static IPPROTO_UDP := 17

  Ptr := (A_PtrSize) ? "uptr" : "uint"

  WS_Log(A_ThisFunc "(" socket ")", 3)

  if (WS_GetSocketInfo(socket, af, maxsockaddr, minsockaddr, type, protocol)!=0)
  {
    WS_Log("[ERROR] Can't retreview information of this socket!", 1)
    return 0
  }
  if (protocol!=IPPROTO_UDP)
  {
    WS_Log("[ERROR] Can't set the broadcast-state for non UDP-sockets!", 1)
    return 0
  }
  VarSetCapacity(optval, 4, 0)
  NumPut(1, optval, 0, "uint")
  if (DllCall("ws2_32\setsockopt", Ptr, socket, "int", SOL_SOCKET, "int", SO_BROADCAST, Ptr, &optval, "int", 4)!=0)
  {
    WS_Log("[ERROR] Can't set the broadcast-state!", 1)
    return 0
  }
  WS_Log("Broadcast-state enabled!")
  return 1
}

WS_GetAddrInfo(socket, hostname_or_ip, port, byref sockaddr, byref sockaddrlen){
  static AF_INET := 2, AF_INET6 := 23
  static ADDR_ANY := 0xFFFFFFFF, ADDR_NONE := 0
  static addr

  sPtr := (A_PtrSize) ? A_PtrSize : 4
  Ptr := (A_PtrSize) ? "uptr" : "uint"
  AStr := (A_IsUnicode) ? "astr" : "str"

  if (WS_GetSocketInfo(socket, af, maxsockaddr, minsockaddr, type, protocol)!=0)
  {
    WS_Log("[ERROR] Can't retreview information of this socket!", 1)
    return 0
  }
  VarSetCapacity(hints, 20+(3*sPtr), 0)
  NumPut(af, hints, 4, "int")
  NumPut(type, hints, 8, "int")
  NumPut(protocol, hints, 12, "int")
  if (DllCall("ws2_32\getaddrinfo", AStr, hostname_or_ip, AStr, port, Ptr, &hints, Ptr "*", result)!=0)
  {
    WS_Log("[ERROR] Can't retreview information of this address!", 1)
    return 0
  }
  sockaddrlen := NumGet(result+0, 16, "int")
  sockaddr := NumGet(result+0, 16+(2*sPtr), Ptr)
  if (af=AF_INET)
  {
    ip := NumGet(sockaddr+0, 4, "uchar") "." NumGet(sockaddr+0, 5, "uchar") "." NumGet(sockaddr+0, 6, "uchar") "." NumGet(sockaddr+0, 7, "uchar")
    if (ip!=hostname_or_ip)
      WS_Log("IP converted from " hostname_or_ip " to " ip ":" DllCall("ws2_32\ntohs", "ushort", NumGet(sockaddr+0, 2, "ushort"), "ushort"))
  }
  return 1
}

WS_Send(socket, message, len=0, flags=0){
  static MSG_DONTROUTE := 4, MSG_OOB := 1

  Ptr := (A_PtrSize) ? "uptr" : "uint"
  AStr := (A_IsUnicode) ? "astr" : "str"

  if (len<=0)
    len := strlen(message)
  fl := 0
  Loop, parse, flags, % " "
  {
    if (A_LoopField="MSG_DONTROUTE")
      fl |= MSG_DONTROUTE
    else if (A_LoopField="MSG_OOB")
      fl |= MSG_OOB
  }

  WS_Log(A_ThisFunc "(" socket ", message, " len ", " flags ")", 3)
  result := DllCall("ws2_32\send", Ptr, socket, AStr, message, "int", len, "int", fl, "int")
  if (result=-1)
  {
    WS_Log("[ERROR] Sending failed!", 1)
    return 0
  }
  WS_Log(result " of " len " bytes sent.`n----`nSending Message:`n----`n" Substr(message, 1, len) "`n----", 4)
  return result
}

WS_SendBinary(socket, pbuffer, len, flags=0){
  static MSG_DONTROUTE := 4, MSG_OOB := 1

  Ptr := (A_PtrSize) ? "uptr" : "uint"
  AStr := (A_IsUnicode) ? "astr" : "str"

  fl := 0
  Loop, parse, flags, % " "
  {
    if (A_LoopField="MSG_DONTROUTE")
      fl |= MSG_DONTROUTE
    else if (A_LoopField="MSG_OOB")
      fl |= MSG_OOB
  }

  WS_Log(A_ThisFunc "(" socket ", message, " len ", " flags ")", 3)
  result := DllCall("ws2_32\send", Ptr, socket, Ptr, pbuffer, "int", len, "int", fl, "int")
  if (result=-1)
  {
    WS_Log("[ERROR] Sending failed!", 1)
    return 0
  }
  WS_Log(result " of " len " bytes sent (binary)", 4)
  return result
}

WS_SendFile(socket, file, flags=0){
  static MSG_DONTROUTE := 4, MSG_OOB := 1
  static GENERIC_READ := 0x80000000, OPEN_EXISTING := 3

  Ptr := (A_PtrSize) ? "uptr" : "uint"
  AStr := (A_IsUnicode) ? "astr" : "str"

  fl := 0
  Loop, parse, flags, % " "
  {
    if (A_LoopField="MSG_DONTROUTE")
      fl |= MSG_DONTROUTE
    else if (A_LoopField="MSG_OOB")
      fl |= MSG_OOB
  }

  if ((hFile := DllCall("CreateFile", Ptr, &file, "uint", GENERIC_READ, "uint", 0, Ptr, 0, "uint", OPEN_EXISTING, "uint", 0, Ptr, 0, Ptr))=0)
  {
    WS_Log("[ERROR] Can't open the file!", 1)
    return 0
  }
  if ((len := DllCall("GetFileSize", Ptr, hFile, Ptr, 0, "uint"))=0xFFFFFFFF)
  {
    WS_Log("[ERROR] Can't get the filesize!", 1)
    return 0
  }
  VarSetCapacity(buffer, len)
  if (DllCall("ReadFile", Ptr, hFile, Ptr, &buffer, "uint", len, Ptr, 0, Ptr, 0)=0)
  {
    WS_Log("[ERROR] Can't read from the file!", 1)
    return 0
  }
  if (DllCall("CloseHandle", Ptr, hFile)=0)
  {
    WS_Log("[ERROR] Can't close the file!", 1)
    return 0
  }
  WS_Log(A_ThisFunc "(" socket ", " file ", " flags ")", 3)
  result := DllCall("ws2_32\send", Ptr, socket, Ptr, &buffer, "int", len, "int", fl, "int")
  if (result=-1)
  {
    WS_Log("[ERROR] Sending failed!", 1)
    return 0
  }
  WS_Log(result " of " len " bytes sent from " file, 4)
  return result
}

WS_SendTo(socket, ip, port, message, len=0, flags=0){
  static MSG_DONTROUTE := 4, MSG_OOB := 1

  Ptr := (A_PtrSize) ? "uptr" : "uint"
  AStr := (A_IsUnicode) ? "astr" : "str"

  if (len<=0)
    len := strlen(message)
  fl := 0
  Loop, parse, flags, % " "
  {
    if (A_LoopField="MSG_DONTROUTE")
      fl |= MSG_DONTROUTE
    else if (A_LoopField="MSG_OOB")
      fl |= MSG_OOB
  }

  WS_Log(A_ThisFunc "(" socket ", " ip ", " port ", message, " len ", " flags ")", 3)

  if (!WS_GetAddrInfo(socket, ip, port, sockaddr, sockaddrlen))
  {
    WS_Log("Can't get an addressinfo!", 1)
    return 0
  }
  result := DllCall("ws2_32\sendto", Ptr, socket, AStr, message, "int", len, "int", fl, Ptr, sockaddr, "int", sockaddrlen, "int")
  if (result=-1)
  {
    WS_Log("[ERROR] Sending failed!", 1)
    return 0
  }
  WS_Log(result " of " len " bytes sent.`n----`nSending Message:`n----`n" Substr(message, 1, len) "`n----", 4)
  return result
}

WS_Recv(socket, byref message, len=0, flags=0){
  static MSG_PEEK := 2, MSG_OOB := 1, MSG_WAITALL := 8

  Ptr := (A_PtrSize) ? "uptr" : "uint"
  fl := 0
  Loop, parse, flags, % " "
  {
    if (A_LoopField="MSG_PEEK")
      fl |= MSG_PEEK
    else if (A_LoopField="MSG_OOB")
      fl |= MSG_OOB
    else if (A_LoopField="MSG_WAITALL")
      fl |= MSG_WAITALL
  }
  WS_Log(A_ThisFunc "(" socket ", message, " len ", " flags ")", 3)
  while ((size := WS_MessageSize(socket))=0)
    sleep, 20
  if (len=0)
    len := size
  VarSetCapacity(buffer, len)
  result := DllCall("ws2_32\recv", Ptr, socket, Ptr, &buffer, "int", len, "int", fl)
  if (result=-1)
  {
    WS_Log("[ERROR] Receiving failed!", 1)
    return 0
  }
  message := ""
  Loop, % result
    message .= Chr(NumGet(buffer, A_Index-1, "uchar"))
  message .= Chr(0)
  WS_Log(result " bytes received.`n----`nReceived Message:`n----`n" message "`n----", 4)
  return result
}

WS_RecvBinary(socket, byref pbuffer, len, flags=0){
  static MSG_PEEK := 2, MSG_OOB := 1, MSG_WAITALL := 8

  Ptr := (A_PtrSize) ? "uptr" : "uint"
  fl := 0
  Loop, parse, flags, % " "
  {
    if (A_LoopField="MSG_PEEK")
      fl |= MSG_PEEK
    else if (A_LoopField="MSG_OOB")
      fl |= MSG_OOB
    else if (A_LoopField="MSG_WAITALL")
      fl |= MSG_WAITALL
  }
  WS_Log(A_ThisFunc "(" socket ", message, " len ", " flags ")", 3)
  result := DllCall("ws2_32\recv", Ptr, socket, Ptr, pbuffer, "int", len, "int", fl)
  if (result=-1)
  {
    WS_Log("[ERROR] Receiving failed!", 1)
    return 0
  }
  message := ""
  Loop, % result
    message .= Chr(NumGet(buffer, A_Index-1, "uchar"))
  message .= Chr(0)
  WS_Log(result " bytes received (binary)", 4)
  return result
}

WS_RecvFile(socket, file, flags=0){
  static MSG_PEEK := 2, MSG_OOB := 1, MSG_WAITALL := 8
  static GENERIC_WRITE := 0x40000000, CREATE_ALWAYS := 2

  Ptr := (A_PtrSize) ? "uptr" : "uint"
  fl := 0
  Loop, parse, flags, % " "
  {
    if (A_LoopField="MSG_PEEK")
      fl |= MSG_PEEK
    else if (A_LoopField="MSG_OOB")
      fl |= MSG_OOB
    else if (A_LoopField="MSG_WAITALL")
      fl |= MSG_WAITALL
  }
  while ((len := WS_MessageSize(socket))=0)
    sleep, 20
  VarSetCapacity(buffer, len)

  WS_Log(A_ThisFunc "(" socket ", " file ", " flags ")", 3)
  result := DllCall("ws2_32\recv", Ptr, socket, Ptr, &buffer, "int", len, "int", fl)
  if (result=-1)
  {
    WS_Log("[ERROR] Receiving failed!", 1)
    return 0
  }
  if ((hFile := DllCall("CreateFile", Ptr, &file, "uint", GENERIC_WRITE, "uint", 0, Ptr, 0, "uint", CREATE_ALWAYS, "uint", 0, Ptr, 0, Ptr))=0)
  {
    WS_Log("[ERROR] Can't create the file!", 1)
    return 0
  }
  if (DllCall("WriteFile", Ptr, hFile, Ptr, &buffer, "uint", len, Ptr, 0, Ptr, 0)=0)
  {
    WS_Log("[ERROR] Can't write into the file!", 1)
    return 0
  }
  if (DllCall("CloseHandle", Ptr, hFile)=0)
  {
    WS_Log("[ERROR] Can't close the file!", 1)
    return 0
  }
  WS_Log(result " bytes received and saved in " file, 4)
  return result
}

WS_RecvFrom(socket, byref out_ip, byref out_port, byref message, len=0, flags=0){
  static MSG_PEEK := 2, MSG_OOB := 1, MSG_WAITALL := 8

  Ptr := (A_PtrSize) ? "uptr" : "uint"
  fl := 0
  Loop, parse, flags, % " "
  {
    if (A_LoopField="MSG_PEEK")
      fl |= MSG_PEEK
    else if (A_LoopField="MSG_OOB")
      fl |= MSG_OOB
    else if (A_LoopField="MSG_WAITALL")
      fl |= MSG_WAITALL
  }
  WS_Log(A_ThisFunc "(" socket ", message, " len ", " flags ")", 3)

  while ((size := WS_MessageSize(socket))=0)
    sleep, 20
  if (len=0)
    len := size
  VarSetCapacity(buffer, len)

  if (WS_GetSocketInfo(socket, af, maxsockaddr, minsockaddr, type, protocol)!=0)
  {
    WS_Log("[ERROR] Can't retreview information of this socket!", 1)
    return 0
  }
  VarSetCapacity(sockaddr, maxsockaddr, 0)
  result := DllCall("ws2_32\recv", Ptr, socket, Ptr, &buffer, "int", len, "int", fl, Ptr, &sockaddr, "int", maxsockaddr)
  if (result=-1)
  {
    WS_Log("[ERROR] Receiving failed!", 1)
    return 0
  }
  message := ""
  Loop, % result
    message .= Chr(NumGet(buffer, A_Index-1, "uchar"))
  message .= Chr(0)

  out_port := DllCall("ws2_32\htons", "ushort", NumGet(sockaddr, 2, "ushort"))
  out_ip := ""
  if (NumGet(sockaddr, 0, "short")=AF_INET)
  {
    pout_ip := DllCall("ws2_32\inet_ntoa", "uint", NumGet(sockaddr, 4, "uint"))
    loop, 32
    {
      if (NumGet(pout_ip+0, A_Index-1, "uchar")=0)
        break
      out_ip .= Chr(NumGet(pout_ip+0, A_Index-1, "uchar"))
    }
  }
  else if (NumGet(sockaddr, 0, "short")=AF_INET6)
  {
    VarSetCapacity(out_ip, 64)
    DllCall("ws2_32\InetNtop", "int", AF_INET6, Ptr, &sockaddr+12, Ptr, &out_ip, int, 64)
  }
  WS_Log(result " bytes received.`n----`nReceived Message:`n----`n" message "`n----", 4)
  return result
}

WS_Connect(socket, ip, port){
  static AF_INET := 2, AF_INET6 := 23

  WS_Log(A_ThisFunc "(" socket ", " ip ", " port ")", 3)
  sPtr := (A_PtrSize) ? A_PtrSize : 4
  Ptr := (A_PtrSize) ? "uptr" : "uint"
  AStr := (A_IsUnicode) ? "astr" : "str"

  if (!WS_GetAddrInfo(socket, ip, port, sockaddr, sockaddrlen))
  {
    WS_Log("Can't get an addressinfo!", 1)
    return 0
  }
  if (DllCall("ws2_32\WSAConnect", Ptr, socket, Ptr, sockaddr, int, sockaddrlen, Ptr, 0, Ptr, 0, Ptr, 0, Ptr, 0, "int")!=0)
  {
    WS_Log("[ERROR] Can't connect to this address!", 1)
    return 0
  }
  WS_Log("Connected to " ip " on Port " port ".")
  return 1
}

WS_Accept(socket, byref out_ip, byref out_port){
  static AF_INET := 2, AF_INET6 := 23

  WS_Log(A_ThisFunc "(" socket ")", 3)
  sPtr := (A_PtrSize) ? A_PtrSize : 4
  Ptr := (A_PtrSize) ? "uptr" : "uint"
  AStr := (A_IsUnicode) ? "astr" : "str"

  if (WS_GetSocketInfo(socket, af, maxsockaddr, minsockaddr, type, protocol)!=0)
  {
    WS_Log("[ERROR] Can't retreview information of this socket!", 1)
    return 0
  }
  VarSetCapacity(sockaddr, maxsockaddr, 0)
  WS_Log("Waiting for connection to accept.")
  VarSetCapacity(pmaxsockaddr, 4, 0)
  NumPut(maxsockaddr, pmaxsockaddr)
  newsocket := DllCall("ws2_32\accept", Ptr, socket, Ptr, &sockaddr, Ptr, &pmaxsockaddr)
  if (newsocket=-1)
  {
    WS_Log("[ERROR] Can't accept connections!", 1)
    return 0
  }
  out_port := DllCall("ws2_32\htons", "ushort", NumGet(sockaddr, 2, "ushort"))
  out_ip := ""
  if (NumGet(sockaddr, 0, "short")=AF_INET)
  {
    pout_ip := DllCall("ws2_32\inet_ntoa", "uint", NumGet(sockaddr, 4, "uint"))
    loop, 32
    {
      if (NumGet(pout_ip+0, A_Index-1, "uchar")=0)
        break
      out_ip .= Chr(NumGet(pout_ip+0, A_Index-1, "uchar"))
    }
  }
  else if (NumGet(sockaddr, 0, "short")=AF_INET6)
  {
    VarSetCapacity(out_ip, 64)
    DllCall("ws2_32\InetNtop", "int", AF_INET6, Ptr, &sockaddr+12, Ptr, &out_ip, int, 64)
  }
  WS_Log("Connection from " out_ip " accepted on Port " out_port ".")
  return newsocket
}

WS_Bind(socket, ip, port){
  static AF_INET := 2, AF_INET6 := 23

  WS_Log(A_ThisFunc "(" socket ", " ip ", " port ")", 3)
  sPtr := (A_PtrSize) ? A_PtrSize : 4
  Ptr := (A_PtrSize) ? "uptr" : "uint"
  AStr := (A_IsUnicode) ? "astr" : "str"


  if (!WS_GetAddrInfo(socket, ip, port, sockaddr, sockaddrlen))
  {
    WS_Log("Can't get an addressinfo!", 1)
    return 0
  }
  if (DllCall("ws2_32\bind", Ptr, socket, Ptr, sockaddr, "int", sockaddrlen)!=0)
  {
    WS_Log("[ERROR] Can't bind to this address!", 1)
    return 0
  }
  WS_Log("Socket bound to " ip " on Port " port ".")
  return 1
}

WS_Listen(socket, backlog=32){
  WS_Log(A_ThisFunc "(" socket ", " backlog ")", 3)
  Ptr := (A_PtrSize) ? "uptr" : "uint"
  if (DllCall("ws2_32\listen", Ptr, socket, "int", backlog)!=0)
  {
    WS_Log("[ERROR] Can't listen on this socket!", 1)
    return 0
  }
  WS_Log("The socket is listening.")
  return 1
}

WS_GetSocketInfo(socket, byref af, byref maxsockaddr, byref minsockaddr, byref type, byref protocol){
  static SOL_SOCKET := 0xFFFF
  static SO_PROTOCOL_INFOA := 0x2004

  sPtr := (A_PtrSize) ? A_PtrSize : 4
  Ptr := (A_PtrSize) ? "uptr" : "uint"

  size := 1024
  VarSetCapacity(protocol_info, size, 0)
  VarSetCapacity(psize, 4, 0)
  NumPut(size, psize)

  result := DllCall("ws2_32\getsockopt", Ptr, socket, "int", SOL_SOCKET, "int", SO_PROTOCOL_INFOA, Ptr, &protocol_info, Ptr, &psize)
  offset := 76
  af := NumGet(protocol_info, offset, "int")
  maxsockaddr := NumGet(protocol_info, offset+4, "int")
  minsockaddr := NumGet(protocol_info, offset+8, "int")
  type := NumGet(protocol_info, offset+12, "int")
  protocol := NumGet(protocol_info, offset+16, "int")
  return result
}

WS_Socket(protocol="TCP", ipversion="IPv4"){
  static AF_INET := 2, AF_INET6 := 23
  static SOCK_STREAM := 1, SOCK_DGRAM := 2
  static IPPROTO_TCP := 6, IPPROTO_UDP := 17

  WS_Log(A_ThisFunc "(" protocol ", " ipversion ")", 3)
  sPtr := (A_PtrSize) ? A_PtrSize : 4
  Ptr := (A_PtrSize) ? "uptr" : "uint"

  af := (Instr(ipversion, "6")) ? AF_INET6 : AF_INET
  type := (Instr(protocol, "UDP")) ? SOCK_DGRAM : SOCK_STREAM
  protocol := (Instr(protocol, "udp")) ? IPPROTO_UDP : IPPROTO_TCP
  socket := DllCall("ws2_32\socket", "int", af, "int", type, "int", protocol, Ptr)
  if (socket=0)
  {
    WS_Log("[ERROR] Can't create this Socket!", 1)
    return 0
  }
  log := (protocol=IPPROTO_TCP) ? "TCP" : "UDP"
  log .= " socket created, for use with "
  log .= (af=AF_INET) ? "IPv4" : "IPv6"
  log .= " (Handle: " socket ")"
  WS_Log(log)
  return socket
}

WS_CloseSocket(byref socket){
  WS_Log(A_ThisFunc "(" socket ")", 3)
  sPtr := (A_PtrSize) ? A_PtrSize : 4
  Ptr := (A_PtrSize) ? "uptr" : "uint"

  if (DllCall("ws2_32\closesocket", Ptr, socket, "int")!=0)
  {
    WS_Log("[ERROR] Can't close this Socket!", 1)
    return 0
  }
  WS_Log("Socket (" socket ") closed.")
  socket := 0
  return 1
}

WS_Startup(version = "2.0"){
  WS_Log(A_ThisFunc "(" version ")", 3)
  sPtr := (A_PtrSize) ? A_PtrSize : 4
  Ptr := (A_PtrSize) ? "uptr" : "uint"

  hWS := DllCall("LoadLibrary", "str", "ws2_32", Ptr)
  if (hWS=0)
  {
    WS_Log("[ERROR] Winsock Library can't be loaded!", 2)
    return 0
  }
  WS_Log("Winsock Library loaded. (Handle: " hWS ")")

  VarSetCapacity(WSAData, 394+sPtr, 0)
  if (instr(version, "."))
  {
    wVersionRequested := (Substr(version, 1, Instr(version, ".")-1) & 0xFF)
    wVersionRequested |= (Substr(version, Instr(version, ".")+1) & 0xFF) << 8
  }
  else
    wVersionRequested := version & 0xFF
  result := DllCall("ws2_32\WSAStartup", "ushort", wVersionRequested, Ptr, &WSAData, "int")
  if (result!=0)
  {
    WS_Log("[ERROR] Can't start up the Winsock Library! (errorcode: " result ")", 2)
    return 0
  }
  WS_Log("Winsock started.")
  WS_Log("Startup-Info, Winsock version: " NumGet(WSAData, 0, "uchar") "." NumGet(WSAData, 1, "uchar"))
  WS_Log("Startup-Info, Highest allowed Winsock version: " NumGet(WSAData, 2, "uchar") "." NumGet(WSAData, 3, "uchar"))
  Loop, 256
    szDescription .= Chr(NumGet(WSAData, A_Index+3, "uchar"))
  WS_Log("Startup-Info, Description: " szDescription)
  Loop, 128
    szSystemStatus .= Chr(NumGet(WSAData, A_Index+259, "uchar"))
  WS_Log("Startup-Info, System status: " szSystemStatus)
  return 1
}

WS_Shutdown(){
  WS_Log(A_ThisFunc "()", 3)
  Ptr := (A_PtrSize) ? "uptr" : "uint"

  result := DllCall("ws2_32\WSACleanup", "int")
  if (result!=0)
    WS_Log("[ERROR] Can't shut down the Winsock Library! (errorcode: " result ")", 2)
  else
    WS_Log("Winsock cleaned up.")
  hWS := DllCall("GetModuleHandle", "str", "ws2_32", Ptr)
  if (hWS=0)
  {
    WS_Log("[ERROR] Can't request the Module Handle for the Winsock Library!", 2)
    WS_Log("[ERROR] Maybe the Winsock Library is not loaded!", 2)
  }
  else
  {
    if (DllCall("FreeLibrary", Ptr, hWS)=0)
      WS_Log("[ERROR] The Winsock Library can't be unloaded!", 2)
    else
      WS_Log("Winsock Library unloaded. (Handle: " hWS ")")
  }
  return 1
}

WS_Log(str, type=0){
  global WS_NOLOG, WS_LOGTOCONSOLE
  static log, cmd, stdout
  Ptr := (A_PtrSize) ? "uptr" : "uint"

  if (WS_NOLOG=1)
    return 0

  if (type=1)
    str .= " (errorcode: " DllCall("ws2_32\WSAGetLastError", "int") ")"
  if (WS_LOGTOCONSOLE)
  {
    if ((!cmd) || (!stdout))
    {
      cmd := DllCall("AllocConsole", "uint")
      stdout := DllCall("GetStdHandle", "uint", -11, Ptr)
      if ((!cmd) || (!stdout))
        WS_LOGTOCMD=0
    }
    if (stdout)
    {
      str .= "`n"
      time := A_Hour ":" A_Min ":" A_Sec " - "
      DllCall("WriteConsole", Ptr, stdout, Ptr, &time, "uint", strlen(time), Ptr "*", numwritten, Ptr, 0, "uint")
      if (type=1 || type=2)
        DllCall("SetConsoleTextAttribute", Ptr, stdout, "ushort", 0x0C)
      else if (type=3)
        DllCall("SetConsoleTextAttribute", Ptr, stdout, "ushort", 0x01)
      else if (type=4)
        DllCall("SetConsoleTextAttribute", Ptr, stdout, "ushort", 0x0A)
      else if (type=5)
        DllCall("SetConsoleTextAttribute", Ptr, stdout, "ushort", 0x0E)
      else
        DllCall("SetConsoleTextAttribute", Ptr, stdout, "ushort", 0x0F)
      DllCall("WriteConsole", Ptr, stdout, Ptr, &str, "uint", strlen(str), Ptr "*", numwritten, Ptr, 0, "uint")
      DllCall("SetConsoleTextAttribute", Ptr, stdout, "ushort", 0x0F)
    }
  }
  else
  {
    if (str!="")
    {
      log .= (log!="") ? "`n" : ""
      log .= A_DD "." A_MM "." A_YYYY " " A_Hour ":" A_Min ":" A_Sec
      log .= " - " str
      return 1
    }
    else
    {
      l := log
      log := ""
      return l
    }
  }
  return 1
}

WS_GetConsoleInput(){
  global WS_LOGTOCONSOLE
  if (!WS_LOGTOCONSOLE)
    return 0
  Ptr := (A_PtrSize) ? "uptr" : "uint"
  stdout := DllCall("GetStdHandle", "uint", -11, Ptr)
  stdin := DllCall("GetStdHandle", "uint", -10, Ptr)
  if ((stdin=0) || (stdout=0))
    return
  cmdlog := A_Hour ":" A_Min ":" A_Sec " - User Input: "
  DllCall("WriteConsole", Ptr, stdout, Ptr, &cmdlog, "uint", strlen(cmdlog), Ptr "*", numwritten, Ptr, 0, "uint")

  VarSetCapacity(buffer, 1024)
  if ((!DllCall("ReadConsole", Ptr, stdin, Ptr, &buffer, "uint", 1024, Ptr "*", numreaded, Ptr, 0, "uint")) || (numreaded=0))
    return
  Loop, % numreaded
    msg .= Chr(NumGet(buffer, (A_Index-1) * ((A_IsUnicode) ? 2 : 1), (A_IsUnicode) ? "ushort" : "uchar"))
  return msg
}

WS_GetLog(){
  return WS_Log("")
}