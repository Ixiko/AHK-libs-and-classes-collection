﻿class Socket {
	static WM_SOCKET := 0x9987, MSG_PEEK := 2, FD_READ := 1, FD_ACCEPT := 8, FD_CLOSE := 32
	Bound := false, Blocking := true, BlockSleep := 50
	__New(Socket := -1, ProtocolId := 6, SocketType := 1) {
		static Init := 0
		if (!Init) {
			; DllCall("LoadLibrary", "Str", "ws2_32", "Ptr")
			WSAData := Buffer(394 + A_PtrSize)
			if (err := DllCall("ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSAData))
				throw Error("Error starting Winsock", , err)
			if (NumGet(WSAData, 2, "UShort") != 0x0202)
				throw Error("Winsock version 2.2 not available")
			Init := true
		}
		this.Ptr := Socket, this.ProtocolId := ProtocolId, this.SocketType := SocketType
	}

	__Delete() {
		if (this.Ptr != -1)
			this.Disconnect()
	}

	Connect(Address) {
		if (this.Ptr != -1)
			throw Error("Socket already connected")
		Next := pAddrInfo := this.GetAddrInfo(Address)
		while Next {
			ai_addrlen := NumGet(Next + 0, 16, "UPtr")
			ai_addr := NumGet(Next + 0, 16 + (2 * A_PtrSize), "Ptr")
			if ((this.Ptr := DllCall("ws2_32\socket", "Int", NumGet(Next + 0, 4, "Int")
				, "Int", this.SocketType, "Int", this.ProtocolId, "Ptr")) != -1) {
				if (DllCall("ws2_32\WSAConnect", "Ptr", this.Ptr, "Ptr", ai_addr
					, "UInt", ai_addrlen, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Int") = 0) {
					DllCall("ws2_32\FreeAddrInfoW", "Ptr", pAddrInfo)	; TODO: Error Handling
					return this.EventProcRegister(Socket.FD_READ | Socket.FD_CLOSE)
				}
				this.Disconnect()
			}
			Next := NumGet(Next + 0, 16 + (3 * A_PtrSize), "Ptr")
		}
		throw Error("Error connecting")
	}

	Bind(Address) {
		if (this.Ptr != -1)
			throw Error("Socket already connected")
		Next := pAddrInfo := this.GetAddrInfo(Address)
		while Next {
			ai_addrlen := NumGet(Next + 0, 16, "UPtr")
			ai_addr := NumGet(Next + 0, 16 + (2 * A_PtrSize), "Ptr")
			if ((this.Ptr := DllCall("ws2_32\socket", "Int", NumGet(Next + 0, 4, "Int")
				, "Int", this.SocketType, "Int", this.ProtocolId, "Ptr")) != -1) {
				if (DllCall("ws2_32\bind", "Ptr", this.Ptr, "Ptr", ai_addr
					, "UInt", ai_addrlen, "Int") == 0) {
					DllCall("ws2_32\FreeAddrInfoW", "Ptr", pAddrInfo)	; TODO: ERROR HANDLING
					return this.EventProcRegister(Socket.FD_READ | Socket.FD_ACCEPT | Socket.FD_CLOSE)
				}
				this.Disconnect()
			}
			Next := NumGet(Next + 0, 16 + (3 * A_PtrSize), "Ptr")
		}
		throw Error("Error binding")
	}

	Listen(backlog := 32) {
		return DllCall("ws2_32\listen", "Ptr", this.Ptr, "Int", backlog) == 0
	}

	Accept() {
		if ((s := DllCall("ws2_32\accept", "Ptr", this.Ptr, "Ptr", 0, "Ptr", 0, "Ptr")) == -1)
			throw Error("Error calling accept", , this.GetLastError())
		Sock := Socket(s, this.ProtocolId, this.SocketType)
		Sock.EventProcRegister(Socket.FD_READ | Socket.FD_CLOSE)
		return Sock
	}

	Disconnect() {
		; Return 0 if not connected
		if (this.Ptr == -1)
			return 0

		; Unregister the socket event handler and close the socket
		this.EventProcUnregister()
		if (DllCall("ws2_32\closesocket", "Ptr", this.Ptr, "Int") == -1)
			throw Error("Error closing socket", , this.GetLastError())
		this.Ptr := -1
		return 1
	}

	MsgSize() {
		static FIONREAD := 0x4004667F
		if (DllCall("ws2_32\ioctlsocket", "Ptr", this.Ptr, "UInt", FIONREAD, "UInt*", &argp := 0) == -1)
			throw Error("Error calling ioctlsocket", , this.GetLastError())
		return argp
	}

	Send(pBuffer, BufSize, Flags := 0) {
		if ((r := DllCall("ws2_32\send", "Ptr", this.Ptr, "Ptr", pBuffer, "Int", BufSize, "Int", Flags)) == -1)
			throw Error("Error calling send", , this.GetLastError())
		return r
	}

	SendText(Text, Flags := 0, Encoding := "UTF-8") {
		buf := Buffer(Length := StrPut(Text, Encoding) - ((Encoding = "UTF-16" || Encoding = "cp1200") ? 2 : 1))
		Length := StrPut(Text, buf, Encoding)
		return this.Send(buf, Length, Flags)
	}

	Recv(&Buf, BufSize := 0, Flags := 0, Timeout := 0) {
		t := 0
		while (!(Length := this.MsgSize()) && this.Blocking && (!Timeout || t < Timeout))
			Sleep(this.BlockSleep), t += this.BlockSleep
		if !Length
			return 0
		if !BufSize
			BufSize := Length
		else
			BufSize := Min(BufSize, Length)
		Buf := Buffer(BufSize)
		if ((r := DllCall("ws2_32\recv", "Ptr", this.Ptr, "Ptr", Buf, "Int", BufSize, "Int", Flags)) == -1)
			throw Error("Error calling recv", , this.GetLastError())
		return r
	}

	RecvText(BufSize := 0, Flags := 0, Encoding := "UTF-8") {
		if (Length := this.Recv(&Buf := 0, BufSize, flags))
			return StrGet(Buf, Length, Encoding)
		return ""
	}

	RecvLine(BufSize := 0, Flags := 0, Encoding := "UTF-8", KeepEnd := false) {
		while !(i := InStr(this.RecvText(BufSize, Flags | Socket.MSG_PEEK, Encoding), "`n")) {
			if (!this.Blocking)
				return ""
			Sleep(this.BlockSleep)
		}
		if KeepEnd
			return this.RecvText(i, Flags, Encoding)
		else
			return RTrim(this.RecvText(i, Flags, Encoding), "`r`n")
	}

	GetAddrInfo(Address) {
		Host := Address[1], Port := Address[2]
		Hints := Buffer(16 + (4 * A_PtrSize), 0)
		NumPut("Int", this.SocketType, "Int", this.ProtocolId, Hints, 8)
		if (err := DllCall("ws2_32\GetAddrInfoW", "Str", Host, "Str", Port, "Ptr", Hints, "Ptr*", &Result := 0))
			throw Error("Error calling GetAddrInfo", , err)
		return Result
	}

	OnMessage(wParam, lParam, Msg, hWnd) {
		if (Msg != Socket.WM_SOCKET || wParam != this.Ptr)
			return
		if (lParam & Socket.FD_READ)
			this.HasOwnProp('onRecv') ? this.onRecv() : 0
		else if (lParam & Socket.FD_ACCEPT)
			this.HasOwnProp('onAccept') ? this.onAccept() : 0
		else if (lParam & Socket.FD_CLOSE)
			this.EventProcUnregister(), this.HasOwnProp('OnDisconnect') ? this.OnDisconnect() : 0
	}

	EventProcRegister(lEvent) {
		this.AsyncSelect(lEvent)
		if !this.Bound {
			this.Bound := ObjBindMethod(this, "OnMessage")
			OnMessage(Socket.WM_SOCKET, this.Bound)
		}
	}

	EventProcUnregister() {
		this.AsyncSelect(0)
		if this.Bound {
			OnMessage(Socket.WM_SOCKET, this.Bound, 0)
			this.Bound := false
		}
	}

	AsyncSelect(lEvent) {
		if (DllCall("ws2_32\WSAAsyncSelect"
			, "Ptr", this.Ptr	; s
			, "Ptr", A_ScriptHwnd	; hWnd
			, "UInt", Socket.WM_SOCKET	; wMsg
			, "UInt", lEvent) == -1)	; lEvent
			throw Error("Error calling WSAAsyncSelect", , this.GetLastError())
	}

	GetLastError() {
		return DllCall("ws2_32\WSAGetLastError")
	}
}

class SocketUDP extends Socket {
	__New(socket := -1) {
		; ProtocolId := 17	; IPPROTO_UDP
		; SocketType := 2	; SOCK_DGRAM
		super.__New(socket, 17, 2)
	}

	SetBroadcast(Enable) {
		static SOL_SOCKET := 0xFFFF, SO_BROADCAST := 0x20
		if (DllCall("ws2_32\setsockopt"
			, "Ptr", this.Ptr	; SOCKET s
			, "Int", SOL_SOCKET	; int    level
			, "Int", SO_BROADCAST	; int    optname
			, "UInt*", &Enable := !!Enable	; *char  optval
			, "Int", 4) == -1)	; int    optlen
			throw Error("Error calling setsockopt", , this.GetLastError())
	}
}