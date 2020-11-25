class tcp {

  __New()  {
    __nw_initWinsock()
    this.__protocolId := 6 ;IPPROTO_TCP
    this.__socketType := 1 ;SOCK_STREAM
    this.socket := -1
  }

  __Delete()  {
    this.disconnect()
  }

	connect(host, port) {

    if ((this.socket!=-1) || (!(next := __nw_getaddrinfo(host, port))))
      return 0

	while (next)    {

		sockaddrlen := NumGet(next+0, 16, "uint")
		sockaddr := NumGet(next+0, 16+(2*A_PtrSize), "ptr")

		if ((this.socket := DllCall("ws2_32\socket", "int", NumGet(next+0, 4, "int"), "int", this.__socketType, "int", this.__protocolId, "ptr"))!=-1)      {

			if ((r := DllCall("ws2_32\WSAConnect", "ptr", this.socket, "ptr", sockaddr, "uint", sockaddrlen, "ptr", 0, "ptr", 0, "ptr", 0, "ptr", 0, "int"))=0)
				return 1

			this.disconnect()
      }

      next := NumGet(next+0, 16+(3*A_PtrSize), "ptr")
    }

    this.lastError := DllCall("ws2_32\WSAGetLastError")

	return 0
	}

  bind(host, port) {
    if ((this.socket!=-1) || (!(next := __nw_getaddrinfo(host, port))))
      return 0
    while (next)
    {
      sockaddrlen := NumGet(next+0, 16, "uint")
      sockaddr := NumGet(next+0, 16+(2*A_PtrSize), "ptr")
      if ((this.socket := DllCall("ws2_32\socket", "int", NumGet(next+0, 4, "int"), "int", this.__socketType, "int", this.__protocolId, "ptr"))!=-1)
      {
        if (DllCall("ws2_32\bind", "ptr", this.socket, "ptr", sockaddr, "uint", sockaddrlen, "int")=0)
          return 1
        this.disconnect()
      }
      next := NumGet(next+0, 16+(3*A_PtrSize), "ptr")
    }
    this.lastError := DllCall("ws2_32\WSAGetLastError")
    return 0
  }

  listen(backlog=32) {
    return (DllCall("ws2_32\listen", "ptr", this.socket, "int", backlog)=0) ? 1 : 0
  }

  accept(host="", port=0) {

    if (this.socket=-1)    {

      this.bind(host, port)
      this.listen()

    }

    if ((s := DllCall("ws2_32\accept", "ptr", this.socket, "ptr", 0, "int", 0, "ptr"))!=-1)    {

        this.disconnect()
        this.socket := s

      return true
    }

  return false
 }

  onAccept(callback) {

    this.__onAccept := callback

  return __nw_eventProc("register", 8, this, 0)
  }

  disconnect() {
    DllCall("ws2_32\closesocket", "ptr", this.socket, "int")
    this.socket := -1 ;INVALID_SOCKET
    return 1
  }

  onDisconnect(callback) {
    this.__onDisconnect := callback
    return __nw_eventProc("register", 32, this, 0)
  }

  msgSize() {
    VarSetCapacity(argp, 4, 0)
    if (DllCall("ws2_32\ioctlsocket", "ptr", this.socket, "uint", 0x4004667F, "ptr", &argp)!=0)
      return 0
    return NumGet(argp, 0, "int")
  }

  sendBinary(addr, length) {
    if ((r := DllCall("ws2_32\send", "ptr", this.socket, "ptr", addr, "int", length, "int", 0, "int"))<=0)
      return 0
    return r
  }

  send(msg, encoding="UTF-8") {
    VarSetCapacity(buffer, length := (StrPut(msg, encoding)*(((encoding="utf-16")||(encoding="cp1200")) ? 2 : 1)))
    StrPut(msg, &buffer, encoding)
    return this.sendBinary(&buffer, length)
  }

  recvBinary(byref buffer, wait=1) {
    while ((wait) && ((length := this.msgSize())=0))
      sleep, 50
    if (length)
    {
      VarSetCapacity(buffer, length)
      if ((r := DllCall("ws2_32\recv", "ptr", this.socket, "ptr", &buffer, "int", length, "int", 0))<=0)
        return 0
      return r
    }
    return 0
  }

  recv(wait=1, encoding="UTF-8") {
    if (length := this.recvBinary(buffer, wait))
      return StrGet(&buffer, length, encoding)
    return
  }

  onRecv(callback) {
    this.__onRecv := callback
    return __nw_eventProc("register", 1, this, 0)
  }
}

class udp {

  __New()
  {
    __nw_initWinsock()
    this.__protocolId := 17 ;IPPROTO_UDP
    this.__socketType := 2 ;SOCK_DGRAM
    this.socket := -1
  }

  __Delete()
  {
    this.disconnect()
  }

  bind(host, port) {
    if ((this.socket!=-1) || (!(next := __nw_getaddrinfo(host, port))))
      return 0
    while (next)
    {
      sockaddrlen := NumGet(next+0, 16, "uint")
      sockaddr := NumGet(next+0, 16+(2*A_PtrSize), "ptr")
      if ((this.socket := DllCall("ws2_32\socket", "int", NumGet(next+0, 4, "int"), "int", this.__socketType, "int", this.__protocolId, "ptr"))!=-1)
      {
        if (DllCall("ws2_32\bind", "ptr", this.socket, "ptr", sockaddr, "uint", sockaddrlen, "int")=0)
          return 1
        this.disconnect()
      }
      next := NumGet(next+0, 16+(3*A_PtrSize), "ptr")
    }
    this.lastError := DllCall("ws2_32\WSAGetLastError")
    return 0
  }

  connect(host, port) {
    if ((this.socket!=-1) || (!(next := __nw_getaddrinfo(host, port))))
      return 0
    while (next)
    {
      sockaddrlen := NumGet(next+0, 16, "uint")
      sockaddr := NumGet(next+0, 16+(2*A_PtrSize), "ptr")
      if ((this.socket := DllCall("ws2_32\socket", "int", NumGet(next+0, 4, "int"), "int", this.__socketType, "int", this.__protocolId, "ptr"))!=-1)
      {
        if ((r := DllCall("ws2_32\WSAConnect", "ptr", this.socket, "ptr", sockaddr, "uint", sockaddrlen, "ptr", 0, "ptr", 0, "ptr", 0, "ptr", 0, "int"))=0)
          return 1
        this.disconnect()
      }
      next := NumGet(next+0, 16+(3*A_PtrSize), "ptr")
    }
    this.lastError := DllCall("ws2_32\WSAGetLastError")
    return 0
  }

  disconnect() {
    DllCall("ws2_32\closesocket", "ptr", this.socket, "int")
    this.socket := -1 ;INVALID_SOCKET
    return 1
  }

  enableBroadcast() {
    VarSetCapacity(optval, 4, 0)
    NumPut(1, optval, 0, "uint")
    if (DllCall("ws2_32\setsockopt", "ptr", this.socket, "int", 0xFFFF, "int", 0x0020, Ptr, &optval, "int", 4)=0)
      return 1
    return 0
  }

  disableBroadcast() {
    VarSetCapacity(optval, 4, 0)
    if (DllCall("ws2_32\setsockopt", "ptr", this.socket, "int", 0xFFFF, "int", 0x0020, Ptr, &optval, "int", 4)=0)
      return 1
    return 0
  }

  msgSize() {
    VarSetCapacity(argp, 4, 0)
    if (DllCall("ws2_32\ioctlsocket", "ptr", this.socket, "uint", 0x4004667F, "ptr", &argp)!=0)
      return 0
    return NumGet(argp, 0, "int")
  }

  sendBinary(addr, length) {
    if ((r := DllCall("ws2_32\send", "ptr", this.socket, "ptr", addr, "int", length, "int", 0, "int"))<=0)
      return 0
    return r
  }

  send(msg, encoding="UTF-8") {
    VarSetCapacity(buffer, length := (StrPut(msg, encoding)*(((encoding="utf-16")||(encoding="cp1200")) ? 2 : 1)))
    StrPut(msg, &buffer, encoding)
    return this.sendBinary(&buffer, length)
  }

  recvBinary(byref buffer, wait=1) {
    while ((wait) && ((length := this.msgSize())=0))
      sleep, 50
    if (length)
    {
      VarSetCapacity(buffer, length)
      if ((r := DllCall("ws2_32\recv", "ptr", this.socket, "ptr", &buffer, "int", length, "int", 0))<=0)
        return 0
      return r
    }
    return 0
  }

  recv(wait=1, encoding="UTF-8") {
    if (length := this.recvBinary(buffer, wait))
      return StrGet(&buffer, length, encoding)
    return
  }

  onRecv(callback) {
    this.__onRecv := callback
    return __nw_eventProc("register", 1, this, 0)
  }
}

__nw_initWinsock() {
  static init
  if (!init)
  {
    DllCall("LoadLibrary", "str", "ws2_32", "ptr")
    VarSetCapacity(wsadata, 394+A_PtrSize)
    DllCall("ws2_32\WSAStartup", "ushort", 0x0000, "ptr", &wsadata)
    DllCall("ws2_32\WSAStartup", "ushort", NumGet(wsadata, 2, "ushort"), "ptr", &wsadata)
    init := 1
  }
}

__nw_getAddrInfo(host, port) {
  if host in localhost,addr_loopback,inaddr_loopback
    host := "127.0.0.1"
  else if host in addr_any,inaddr_any
    host := "0.0.0.0"
  else if host in addr_broadcast,inaddr_broadcast,addr_none,inaddr_none
    host := "255.255.255.255"
  else if host in localhost6,addr_loopback6,inaddr_loopback6
    host := "::1"
  else if host in addr_any6,inaddr_any6
    host := "::"
  else if host in addr_broadcast6,inaddr_broadcast6,addr_none6,inaddr_none6
    host := "FF00::"

  VarSetCapacity(hints, 16+(4*A_PtrSize), 0)
  NumPut(this.__inetType, hints, 4, "int")
  NumPut(this.__socketType, hints, 8, "int")
  NumPut(this.__protocolId, hints, 12, "int")
  if ((r := DllCall("ws2_32\getaddrinfo", "astr", host, "astr", port, "ptr", &hints, "ptr*", next))!=0)
  {
    this.lastError := DllCall("ws2_32\WSAGetLastError")
    return 0
  }
  return next
}

__nw_eventProc(wParam, lParam, msg, hwnd) {

  static
  if (wParam="register") {

    if (!init) {

      OnMessage(0x9987, A_ThisFunc)
      Gui, +LastFound
      hMsgWnd := WinExist()
      array := Object()
      init := 1
    }

    array.Insert(msg)
    return (DllCall("ws2_32\WSAAsyncSelect", "ptr", msg.socket, "ptr", hMsgWnd, "uint", 0x9987, "uint", lParam)=0) ? 1 : 0
  }

  found := 0
  for i,element in array
  {
    if (element.socket = wParam)
    {
      this := element
      found := 1
      break
    }
  }
  if (!found)
    return 0
  func := ""
  if ((lParam & 0xFFFF) = 1)
    func := this.__OnRecv
  else if ((lParam & 0xFFFF) = 8)
    func := this.__OnAccept
  else if ((lParam & 0xFFFF) = 32)
    func := this.__OnDisconnect
  if (IsFunc(func))
    return %func%(this)
  return 0
}

