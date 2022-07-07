; Socket class
;   Big thanks to GeekDude for remaking this.
;       Original script by GeekDude: https://github.com/G33kDude/Socket.ahk/blob/master/Socket.ahk
;        AHK Forum Post by GeekDude: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=35120
;
;   And thanks to Bentschi's work which GeekDude expanded on.
;       https://autohotkey.com/board/topic/94376-socket-class-%C3%BCberarbeitet/
;
;   Helpful info:
;       Event Objects vs ComplitionIO ports
;       https://stackoverflow.com/questions/44664511/windows-event-based-overlapped-io-vs-io-completion-ports-real-world-performanc
;
;   Thanks to winsockdotnetworkprogramming.com
;       https://www.winsocketdotnetworkprogramming.com/winsock2programming/winsock2advancediomethod5g.html
;       - this gave a workaround for using overlapped I/O
;
;   MS Help Docs:
;       
; =====================================================================================================
; 
;

class winsock {
    Static __New() { ; init WS2 lib on script start
        this.hModule := DllCall("LoadLibrary", "Str", "Ws2_32", "UPtr")
        this.WSAData := Buffer(394+A_PtrSize)
        if (Err := DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "UPtr", this.WSAData.ptr))
            throw Error("Error starting Winsock",, Err)
        if (NumGet(this.WSAData, 2, "UShort") != 0x0202)
            throw Error("Winsock version 2.2 not available")
        
        this.socketMonitor := ObjBindMethod(this,"WM_SOCKET")
        OnMessage(0x9987,this.socketMonitor)
    }
    
    ; Static event := DllCall("Ws2_32\WSACreateEvent")
    ; Static WM_SOCKET := 0x9987, MSG_PEEK := 2

    ; Static FD_READ := 1, FD_ACCEPT := 8, FD_CLOSE := 32
    
    Static sockets := Map()
    Static flags := {Passive:0x1         , NonAuthoritative:0x4000 ; ai_flags
                   , CanonName:0x2       , Secure:0x8000
                   , NumericHost:0x4     , ReturnPreferredNames:0x10000
                   , All:0x100           , FQDN:0x20000
                   , AddrConfig:0x400    , FileServer:0x40000
                   , V4Mapped:0x800}
    
         , family   := {Unspec:0, IPV4:2, NetBIOS:17, IPV6:23, IRDA:26, BTH:32}
         , socktype := {Stream:1, DGram:2, RAW:3, RDM:4, SeqPacket:5}
         , protocol := {TCP:6, UDP:17, RM:113}
         
         , events := {1:"Read"
                     ,2:"Write"
                     ,4:"OOB"
                     ,8:"Accept"
                     ,16:"Connect"
                     ,32:"Close"
                     ,64:"QOS"
                     ,128:"GroupQOS"
                     ,256:"RoutingInterfaceChange"
                     ,512:"AddressListChange"}
         
         , errors := {6:"WSA_INVALID_HANDLE"
                    , 8:"WSA_NOT_ENOUGH_MEMORY"
                    , 87:"WSA_INVALID_PARAMETER"
                    , 995:"WSA_OPERATION_ABORTED"
                    , 996:"WSA_IO_INCOMPLETE"
                    , 997:"WSA_IO_PENDING"
                    , 10004:"WSAEINTR"
                    , 10009:"WSAEBADF"
                    , 10013:"WSAEACCES"
                    , 10014:"WSAEFAULT"
                    , 10022:"WSAEINVAL"
                    , 10024:"WSAEMFILE"
                    , 10035:"WSAEWOULDBLOCK"
                    , 10036:"WSAEINPROGRESS"
                    , 10037:"WSAEALREADY"
                    , 10038:"WSAENOTSOCK"
                    , 10039:"WSAEDESTADDRREQ"
                    , 10040:"WSAEMSGSIZE"
                    , 10041:"WSAEPROTOTYPE"
                    , 10042:"WSAENOPROTOOPT"
                    , 10043:"WSAEPROTONOSUPPORT"
                    , 10044:"WSAESOCKTNOSUPPORT"
                    , 10045:"WSAEOPNOTSUPP"
                    , 10046:"WSAEPFNOSUPPORT"
                    , 10047:"WSAEAFNOSUPPORT"
                    , 10048:"WSAEADDRINUSE"
                    , 10049:"WSAEADDRNOTAVAIL"
                    , 10050:"WSAENETDOWN"
                    , 10051:"WSAENETUNREACH"
                    , 10052:"WSAENETRESET"
                    , 10053:"WSAECONNABORTED"
                    , 10054:"WSAECONNRESET"
                    , 10055:"WSAENOBUFS"
                    , 10056:"WSAEISCONN"
                    , 10057:"WSAENOTCONN"
                    , 10058:"WSAESHUTDOWN"
                    , 10059:"WSAETOOMANYREFS"
                    , 10060:"WSAETIMEDOUT"
                    , 10061:"WSAECONNREFUSED"
                    , 10062:"WSAELOOP"
                    , 10063:"WSAENAMETOOLONG"
                    , 10064:"WSAEHOSTDOWN"
                    , 10065:"WSAEHOSTUNREACH"
                    , 10066:"WSAENOTEMPTY"
                    , 10067:"WSAEPROCLIM"
                    , 10068:"WSAEUSERS"
                    , 10069:"WSAEDQUOT"
                    , 10070:"WSAESTALE"
                    , 10071:"WSAEREMOTE"
                    , 10091:"WSASYSNOTREADY"
                    , 10092:"WSAVERNOTSUPPORTED"
                    , 10093:"WSANOTINITIALISED"
                    , 10101:"WSAEDISCON"
                    , 10102:"WSAENOMORE"
                    , 10103:"WSAECANCELLED"
                    , 10104:"WSAEINVALIDPROCTABLE"
                    , 10105:"WSAEINVALIDPROVIDER"
                    , 10106:"WSAEPROVIDERFAILEDINIT"
                    , 10107:"WSASYSCALLFAILURE"
                    , 10108:"WSASERVICE_NOT_FOUND"
                    , 10109:"WSATYPE_NOT_FOUND"
                    , 10110:"WSA_E_NO_MORE"
                    , 10111:"WSA_E_CANCELLED"
                    , 10112:"WSAEREFUSED"
                    , 11001:"WSAHOST_NOT_FOUND"
                    , 11002:"WSATRY_AGAIN"
                    , 11003:"WSANO_RECOVERY"
                    , 11004:"WSANO_DATA"
                    , 11005:"WSA_QOS_RECEIVERS"
                    , 11006:"WSA_QOS_SENDERS"
                    , 11007:"WSA_QOS_NO_SENDERS"
                    , 11008:"WSA_QOS_NO_RECEIVERS"
                    , 11009:"WSA_QOS_REQUEST_CONFIRMED"
                    , 11010:"WSA_QOS_ADMISSION_FAILURE"
                    , 11011:"WSA_QOS_POLICY_FAILURE"
                    , 11012:"WSA_QOS_BAD_STYLE"
                    , 11013:"WSA_QOS_BAD_OBJECT"
                    , 11014:"WSA_QOS_TRAFFIC_CTRL_ERROR"
                    , 11015:"WSA_QOS_GENERIC_ERROR"
                    , 11016:"WSA_QOS_ESERVICETYPE"
                    , 11017:"WSA_QOS_EFLOWSPEC"
                    , 11018:"WSA_QOS_EPROVSPECBUF"
                    , 11019:"WSA_QOS_EFILTERSTYLE"
                    , 11020:"WSA_QOS_EFILTERTYPE"
                    , 11021:"WSA_QOS_EFILTERCOUNT"
                    , 11022:"WSA_QOS_EOBJLENGTH"
                    , 11023:"WSA_QOS_EFLOWCOUNT"
                    , 11024:"WSA_QOS_EUNKOWNPSOBJ"
                    , 11025:"WSA_QOS_EPOLICYOBJ"
                    , 11026:"WSA_QOS_EFLOWDESC"
                    , 11027:"WSA_QOS_EPSFLOWSPEC"
                    , 11028:"WSA_QOS_EPSFILTERSPEC"
                    , 11029:"WSA_QOS_ESDMODEOBJ"
                    , 11030:"WSA_QOS_ESHAPERATEOBJ"
                    , 11031:"WSA_QOS_RESERVED_PETYPE"}
    
    Static WM_SOCKET(sockDesc, lParam, msg, hwnd) { ; socket monitor
        event_cd := lParam & 0xFFFF
        errCode  := (lParam >> 16) & 0xFFFF
        event    := (winsock.events.HasProp(event_cd) ? winsock.events.%event_cd% : event_cd)
        socket   := winsock.sockets[String(sockDesc)]
        cb := socket.cb
        if (cb)
            cb(socket,event,errCode)
    }
    
    family := 0, protocol := 0, socktype := 0, sockaddr_size := 0
    callback := 0
    desc := -1
    name := ""
    err := "", errnum := 0, LastOp := ""
    
    __New(name, callback:=0, family:="Unspec", protocol:="TCP", socktype:="Stream", desc:=-1) {
        this.name := name
        this.desc := desc
        this.cb := callback
        If !winsock.family.HasProp(family) ; IPV4:2, NetBIOS:17, IPV6:23, IRDA:26, BTH:32
            throw Error("Invalid socket family specified.",,"Valid values are:`n`nIPV4,IPV6,NetBIOS,IRDA,BTH")
        this.family := winsock.family.%family%
        this.familyName := family
        this.socktype := winsock.socktype.%socktype%
        this.socktypeName := socktype
        this.protocol := winsock.protocol.%protocol%
        this.protocolName := protocol
        
        switch (this.familyName) {
            case "IPV4": this.sockaddr_size := 16
            case "IPV6": this.sockaddr_size := 28
                default: this.sockaddr_size := -1 ; force an error to improve for other families
        }
        
        this.CreateSocket(this.desc)
        if (this.errnum)
            throw Error("Error creating socket.",,"Error Code: " this.errnum " / " this.err "`nLast Op: " this.LastOp)
        else
            winsock.sockets[String(this.desc)] := this
    }
    
    Bind(host:=0,port:=0) {
        Static AI_PASSIVE:=0x1
        
        result := this.GetAddrInfo(host,port,AI_PASSIVE) ; addrinfo struct
        retCode := 1
        If (DllCall("Ws2_32\bind", "UInt", this.desc
                                 , "UPtr", result.addr
                                 , "UInt", result.addrlen) = -1) {
            this.WsaLastErr("bind"), retCode := 0, this.Close() ; close socket
        }
        DllCall("Ws2_32\FreeAddrInfo", "UPtr", result.ptr) ; free memory of addrinfo chain
        return retCode
    }
    
    Listen(backlog:=5) { ; SOMAXCONN = 5
        retCode := 1
        If (DllCall("Ws2_32\listen","UInt",this.desc,"Int",backlog) = -1)
            this.WsaLastErr("bind"), retCode := 0, this.Close() ; close socket
        return retCode
    }
    
    Accept(&addr:=0,&newsock:=0) { ; optional VarRef to capture the sockaddr struct of new connection
        retCode := 1
        buf := buffer(16,0)
        NumPut("UInt",16,sz := buffer(4,0))
        If ((newdesc := DllCall("Ws2_32\accept","UInt",this.desc,"UPtr",buf.ptr,"UPtr",sz.ptr)) = -1) {
            this.WsaLastErr("accept"), retCode := 0, this.Close()
            return 0
        }
        
        addr := winsock.sockaddr(buf)
        
        newsock := winsock("serving-" newdesc, this.cb, this.familyName, this.protocolName, this.socktypeName, newdesc)
        winsock.sockets[String(newsock.desc)] := newsock ; catalog new socket
        
        return retcode
    }
    
    CreateSocket(desc:=-1) { ; make new socket, or take given socket, then call WSAAsyncSelect
        If ((desc = -1)
          && (this.desc := DllCall("Ws2_32\socket","Int",this.family ; try to open the socket
                                                  ,"Int",this.socktype
                                                  ,"Int",this.protocol)) = -1) {
            this.WsaLastErr("socket")
        }
        
        If (DllCall("Ws2_32\WSAAsyncSelect","UInt",this.desc
                                           ,"UPtr",A_ScriptHwnd
                                           ,"UInt",0x9987 ; WM_ msg to use for callback
                                           ,"UInt",FD_ALL_EVENTS:=0x3FF) = -1) {
            this.WsaLastErr("WSAAsyncSelect")
        }
    }
    
    WsaLastErr(LastOp:="") {
        result := DllCall("Ws2_32\WSAGetLastError")
        If (result) {
            this.err := winsock.errors.%result%
            this.errnum := result
            this.LastOp := LastOp
        } Else {
            this.err := ""
            this.errnum := 0
            this.LastOp := ""
        }
        return result
    }
    
    Connect(host:=0,port:=0) {
        result := this.GetAddrInfo(host,port) ; addrinfo struct
        next := result.ptr
        retCode := 1
        while next {
            If (DllCall("Ws2_32\connect","UInt",this.desc ; connect to host
                                        ,"UPtr",result.addr
                                        ,"UInt",result.addrlen) = -1) {
                this.WsaLastErr("connect") ; check fail code
                If (this.err = "WSAEWOULDBLOCK") {
                    retCode := 1
                    Break ; break on sucess
                } Else
                    retCode := 0
            } Else {
                retCode := 1
                Break ; break on success
            }
            
            If (result.next) ; access next address if unable to connect
                next := (result := winsock.addrinfo(result.next)).ptr
        }
        
        DllCall("Ws2_32\FreeAddrInfo", "UPtr", result.ptr) ; free memory of addrinfo chain
        
        return retCode
    }
    
    Send(buf,flags:=0) {
        If (DllCall("Ws2_32\send","UInt",this.desc
                                 ,"UPtr",buf.ptr  ; get first packet
                                 ,"UInt",buf.size
                                 ,"UInt",flags) = -1) {
            this.WsaLastErr("send")
            return 0
        }
        return 1
    }
    
    Recv(flags:=0) {
        Static FIONREAD:=0x4004667F
        If (DllCall("Ws2_32\ioctlsocket", "UInt", this.desc
                                        , "UInt", FIONREAD
                                        , "UInt*", &bytes:=0) == -1) {
            this.WsaLastErr("ioctlsocket")
            If (this.err != "WSAEWOULDBLOCK")
                return Buffer(0)
        }
        
        buf := Buffer(bytes,0)
        If (DllCall("Ws2_32\recv","UInt",this.desc
                                 ,"UPtr",buf.ptr
                                 ,"Int",buf.size
                                 ,"Int",flags) = -1) {
            this.WsaLastErr("recv")
            if (this.err != "WSAEWOULDBLOCK")
                return Buffer(0)
        }
        
        return buf
    }
    
    QueueData(buf) {
        this.OutQueue.Push(buf)
    }
    
    Close() {
        if (DllCall("Ws2_32\closesocket","Int",this.desc) = -1) {
            this.WsaLastErr("closesocket")
            return 0
        }
        winsock.sockets.Delete(String(this.desc))
        return 1
    }
    
    GetAddrInfo(host,port,flags:=0) {
        hints := winsock.addrinfo()
        hints.family   := this.family
        hints.socktype := this.socktype
        hints.protocol := this.protocol
        hints.flags    := flags
        
        if (err := DllCall("Ws2_32\GetAddrInfo",(host?"Str":"UPtr"),host
                                               ,(port?"Str":"UPtr"),(port?String(port):0)
                                               ,"UPtr",hints.ptr
                                               ,"UPtr*",&result:=0)) {
            this.WsaLastErr("GetAddrInfo")
            return winsock.addrinfo(0) ; return NULL ptr
        }
        
        return winsock.addrinfo(result)
    }
    
    __Delete() {
        this.Close() ; close socket if open
    }
    
    AddrToStr(sock_addr, protocol_info:=0) {
        DllCall("Ws2_32\WSAAddressToString","UPtr",sock_addr.ptr
                                           ,"UInt",sock_addr.address.size
                                           ,"UPtr",protocol_info
                                           ,"UPtr",0 ; LPWSTR
                                           ,"UInt*",&strSize:=0)
        
        strbuf := Buffer(strSize * (StrLen(0xFFFF)?2:1),0)
        NumPut("UInt",strSize,(sz := Buffer(4,0)))
        If (DllCall("Ws2_32\WSAAddressToString","UPtr",sock_addr.ptr
                                           ,"UInt",sock_addr.address.size
                                           ,"UPtr",protocol_info
                                           ,"UPtr",strbuf.ptr
                                           ,"UPtr",sz.ptr) = -1) {
            this.WsaLastErr()
            return ""
        }
        return StrGet(strbuf)
    }
    
    class addrinfo {
        ptr := 0
        cn_off := 16+A_PtrSize
        addr_off := 16 + (A_PtrSize*2)
        next_off := 16 + (A_PtrSize*3)
        __New(ptr := 0) {
            if (!ptr) {
                this._struct := Buffer(16 + (A_PtrSize*4),0)
                this.ptr := this._struct.ptr
            } else this.ptr := ptr
        }
        flags {
            get => NumGet(this.ptr,0,"Int")
            set => NumPut("Int",Value,this.ptr)
        }
        family {
            get => NumGet(this.ptr,4,"Int")
            set => NumPut("Int",Value,this.ptr,4)
        }
        socktype {
            get => NumGet(this.ptr,8,"Int")
            set => NumPut("Int",Value,this.ptr,8)
        }
        protocol {
            get => NumGet(this.ptr,12,"Int")
            set => NumPut("Int",Value,this.ptr,12)
        }
        addrlen {
            get => NumGet(this.ptr,16,"UPtr")
            set => NumPut("UPtr",Value,this.ptr,16)
        }
        canonname {
            get => NumGet(this.ptr,this.cn_off,"UPtr")
            set => NumPut("UPtr",Value,this.ptr,this.cn_off)
        }
        addr {
            get => NumGet(this.ptr,this.addr_off,"UPtr")
        }
        next {
            get => NumGet(this.ptr,this.next_off,"UPtr")
        }
    }
    
    class sockaddr {
        ptr := 0, size := -1
        addroffset := -1
        __New(buf := 0, size := -1) {
            if (Type(buf) != "Integer") {
                this._struct := buf
                this.ptr := buf.ptr
                this.size := buf.size
            } else {
                this.ptr := buf
                this.size := size
            }
            
            if (this.family = 2)        ; ipv4
                this.addroffset := 4
            else if (this.family = 23)  ; ipv6
                this.addroffset := 8
        }
        family {
            get => NumGet(this.ptr,"UShort")
            set => NumPut("UShort",Value,this.ptr)
        }
        port {
            get => NumGet(this.ptr,2,"UShort")
            set => NumPut("UShort",Value,this.ptr,2)
        }
        address {
            get {
                if (this.addroffset != -1 && this.size != -1) { ; check for unknown struct size
                    buf := Buffer(this.size,0)
                    DllCall("RtlCopyMemory","UPtr",buf.ptr,"UPtr",this.ptr+this.addroffset,"UPtr",this.size)
                    return buf
                } else
                    return Buffer(0) ; unknown struct and size
            }
        }
        flowinfo {
            get {
                if (this.size = 28)
                    return NumGet(this.ptr,4,"UInt")
                else return -1
            }
        }
        scopeid {
            get {
                if (this.size = 28)
                    return NumGet(this.ptr,24,"UInt")
                else return -1
            }
        }
    }
    

    
    ; MsgSize() {
        ; static FIONREAD := 0x4004667F
        ; if (DllCall("Ws2_32\ioctlsocket", "UInt", this.Socket, "UInt", FIONREAD, "UInt*", &argp:=0) == -1)
            ; throw Error("Error calling ioctlsocket",, this.GetLastError())
        ; return argp
    ; }
    

    
    ; MsgMonitor(wParam, lParam, Msg, hWnd) {
        ; dbg("msg: " Format("0x{:X}",msg) " / hwnd: " hWnd " / wParam: " wParam " / lParam: " lParam)
        
        ; if (Msg != Socket.WM_SOCKET || wParam != this.Socket)
            ; return
        
        ; dbg("it worked? / " Type(this.recvCB) " / ID: " this.SockID)
        
        ; If (RecvCB := this.recvCB) { ; data, date, EventType, socket
            ; if (lParam & Socket.FD_READ) {
                ; dbg("reading... / ID: " this.SockID)
                
                
                ; RecvCB("", "read", this) ; this.Recv()
            ; } else if (lParam & Socket.FD_ACCEPT) {
                ; dbg("accepting... / ID: " this.SockID)
                ; RecvCB("", "accept", this) ; this.Accept()
                
            ; } else if (lParam & Socket.FD_CLOSE) {
                ; dbg("closing... / ID: " this.SockID)
                ; this.EventProcUnregister(), this.Disconnect(), RecvCB("", "close", this)
            ; }
        ; }
    ; }
    
    ; EventProcRegister(lEvent) {
        ; this.AsyncSelect(lEvent)
        ; if !this.Bound {
            ; this.Bound := ObjBindMethod(this,"MsgMonitor")
            ; OnMessage Socket.WM_SOCKET, this.Bound ; register event function
        ; }
    ; }
    
    ; EventProcUnregister() {
        ; this.AsyncSelect(0)
        ; if this.Bound {
            ; OnMessage Socket.WM_SOCKET, this.Bound, 0 ; unregister event function
            ; this.Bound := False
        ; }
    ; }
    
    ; AsyncSelect(lEvent) {
        ; if (r := DllCall("Ws2_32\WSAAsyncSelect"
            ; , "UInt", this.Socket    ; s
            ; , "Ptr", A_ScriptHwnd    ; hWnd
            ; , "UInt", Socket.WM_SOCKET ; wMsg
            ; , "UInt", lEvent) == -1) ; lEvent
            ; throw Error("Error calling WSAAsyncSelect ---> SockID: " this.SockID " / " this.Socket,, this.GetLastError())
    ; }
    
    ; GetLastError() {
        ; return DllCall("Ws2_32\WSAGetLastError")
    ; }
    
    ; SetBroadcast(Enable) { ; for UDP sockets only -- don't know what this does yet
        ; static SOL_SOCKET := 0xFFFF, SO_BROADCAST := 0x20
        ; if (DllCall("Ws2_32\setsockopt"
            ; , "UInt", this.Socket ; SOCKET s
            ; , "Int", SOL_SOCKET   ; int    level
            ; , "Int", SO_BROADCAST ; int    optname
            ; , "UInt", !!Enable   ; *char  optval
            ; , "Int", 4) == -1)    ; int    optlen
            ; throw Error("Error calling setsockopt",, this.GetLastError())
    ; }
}
