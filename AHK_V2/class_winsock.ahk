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
    Static sockets := Map(), wm_msg := 0x9987
    
    Static __New() { ; init WS2 lib on script start
        invert("family","family_2") ; for looking up family name by number
        
        this.hModule := DllCall("LoadLibrary", "Str", "Ws2_32", "UPtr")
        this.WSAData := Buffer(394+A_PtrSize)
        if (Err := DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "UPtr", this.WSAData.ptr))
            throw Error("Error starting Winsock",, Err)
        if (NumGet(this.WSAData, 2, "UShort") != 0x0202)
            throw Error("Winsock version 2.2 not available")
        
        this.socketMonitor := ObjBindMethod(this,"WM_SOCKET")
        OnMessage(this.wm_msg,this.socketMonitor) ; 0x9987
        
        this.sockaddr.Prototype.DefineProp("insert" ,{Call:(o,buf,dest)=>insert(buf,dest)})
        this.sockaddr.Prototype.DefineProp("extract",{Call:(o,src,len)=>extract(src,len)})
        
        insert(buf,dest) => DllCall("RtlCopyMemory","UPtr",dest,"UPtr",buf.ptr,"UPtr",buf.size)
        extract(src,len) {
            buf := Buffer(len,0)
            DllCall("RtlCopyMemory","UPtr",buf.ptr,"UPtr",src,"UPtr",len)
            return buf
        }
        invert(name,name_2) {
            this.%name_2% := {} 
            For name, value in this.%name%.OwnProps()
                this.%name_2%.%value% := name
        }
    }
    
     
    Static flags := {  Passive:0x1  , NumericHost:0x4    , Secure:0x8000 ,     NonAuthoritative:0x4000
                   , CanonName:0x2  ,  AddrConfig:0x400  ,   FQDN:0x20000, ReturnPreferredNames:0x10000
                   ,  V4Mapped:0x800,  FileServer:0x40000,    All:0x100}
    
         , family   := {Unspec:0, IPV4:2, NetBIOS:17, IPv6:23, IRDA:26, BTH:32}
         , fam_size := {Unspec:-1, IPv4:16,NetBIOS:-1, IPv6:28,IRDA:-1, BTH:-1}
         , fam_len  := {Unspec:-1, IPv4:4, NetBIOS:-1, IPv6:8, IRDA:-1, BTH:-1}
     , fam_addr_off := {Unspec:-1, IPv4:4, NetBIOS:-1, IPv6:8, IRDA:-1, BTH:-1}
         , socktype := {Stream:1, DGram:2, RAW:3, RDM:4, SeqPacket:5}
         , protocol := {TCP:6, UDP:17, RM:113}
         
         , events := {1:"Read",2:"Write",4:"OOB",8:"Accept",16:"Connect",32:"Close",64:"QOS"
                     ,128:"GroupQOS",256:"RoutingInterfaceChange",512:"AddressListChange"}
         
         , errors := {6:"WSA_INVALID_HANDLE", 8:"WSA_NOT_ENOUGH_MEMORY", 87:"WSA_INVALID_PARAMETER", 995:"WSA_OPERATION_ABORTED"
                    , 996:"WSA_IO_INCOMPLETE", 997:"WSA_IO_PENDING", 10004:"WSAEINTR", 10009:"WSAEBADF", 10013:"WSAEACCES"
                    , 10014:"WSAEFAULT", 10022:"WSAEINVAL", 10024:"WSAEMFILE", 10035:"WSAEWOULDBLOCK", 10036:"WSAEINPROGRESS"
                    , 10037:"WSAEALREADY", 10038:"WSAENOTSOCK", 10039:"WSAEDESTADDRREQ", 10040:"WSAEMSGSIZE", 10041:"WSAEPROTOTYPE"
                    , 10042:"WSAENOPROTOOPT", 10043:"WSAEPROTONOSUPPORT", 10044:"WSAESOCKTNOSUPPORT", 10045:"WSAEOPNOTSUPP"
                    , 10046:"WSAEPFNOSUPPORT", 10047:"WSAEAFNOSUPPORT", 10048:"WSAEADDRINUSE", 10049:"WSAEADDRNOTAVAIL", 10050:"WSAENETDOWN"
                    , 10051:"WSAENETUNREACH", 10052:"WSAENETRESET", 10053:"WSAECONNABORTED", 10054:"WSAECONNRESET", 10055:"WSAENOBUFS"
                    , 10056:"WSAEISCONN", 10057:"WSAENOTCONN", 10058:"WSAESHUTDOWN", 10059:"WSAETOOMANYREFS", 10060:"WSAETIMEDOUT"
                    , 10061:"WSAECONNREFUSED", 10062:"WSAELOOP", 10063:"WSAENAMETOOLONG", 10064:"WSAEHOSTDOWN", 10065:"WSAEHOSTUNREACH"
                    , 10066:"WSAENOTEMPTY", 10067:"WSAEPROCLIM", 10068:"WSAEUSERS", 10069:"WSAEDQUOT", 10070:"WSAESTALE", 10071:"WSAEREMOTE"
                    , 10091:"WSASYSNOTREADY", 10092:"WSAVERNOTSUPPORTED", 10093:"WSANOTINITIALISED", 10101:"WSAEDISCON", 10102:"WSAENOMORE"
                    , 10103:"WSAECANCELLED", 10104:"WSAEINVALIDPROCTABLE", 10105:"WSAEINVALIDPROVIDER", 10106:"WSAEPROVIDERFAILEDINIT"
                    , 10107:"WSASYSCALLFAILURE", 10108:"WSASERVICE_NOT_FOUND", 10109:"WSATYPE_NOT_FOUND", 10110:"WSA_E_NO_MORE"
                    , 10111:"WSA_E_CANCELLED", 10112:"WSAEREFUSED", 11001:"WSAHOST_NOT_FOUND", 11002:"WSATRY_AGAIN", 11003:"WSANO_RECOVERY"
                    , 11004:"WSANO_DATA", 11005:"WSA_QOS_RECEIVERS", 11006:"WSA_QOS_SENDERS", 11007:"WSA_QOS_NO_SENDERS", 11008:"WSA_QOS_NO_RECEIVERS"
                    , 11009:"WSA_QOS_REQUEST_CONFIRMED", 11010:"WSA_QOS_ADMISSION_FAILURE", 11011:"WSA_QOS_POLICY_FAILURE", 11012:"WSA_QOS_BAD_STYLE"
                    , 11013:"WSA_QOS_BAD_OBJECT", 11014:"WSA_QOS_TRAFFIC_CTRL_ERROR", 11015:"WSA_QOS_GENERIC_ERROR", 11016:"WSA_QOS_ESERVICETYPE"
                    , 11017:"WSA_QOS_EFLOWSPEC", 11018:"WSA_QOS_EPROVSPECBUF", 11019:"WSA_QOS_EFILTERSTYLE", 11020:"WSA_QOS_EFILTERTYPE"
                    , 11021:"WSA_QOS_EFILTERCOUNT", 11022:"WSA_QOS_EOBJLENGTH", 11023:"WSA_QOS_EFLOWCOUNT", 11024:"WSA_QOS_EUNKOWNPSOBJ"
                    , 11025:"WSA_QOS_EPOLICYOBJ", 11026:"WSA_QOS_EFLOWDESC", 11027:"WSA_QOS_EPSFLOWSPEC", 11028:"WSA_QOS_EPSFILTERSPEC"
                    , 11029:"WSA_QOS_ESDMODEOBJ", 11030:"WSA_QOS_ESHAPERATEOBJ", 11031:"WSA_QOS_RESERVED_PETYPE"}
    
    Static WM_SOCKET(sockDesc, lParam, msg, hwnd) { ; socket monitor
        event_cd := lParam & 0xFFFF
         errCode := (lParam >> 16) & 0xFFFF
           event := (winsock.events.HasProp(event_cd) ? winsock.events.%event_cd% : event_cd)
          socket := winsock.sockets[String(sockDesc)]
              cb := socket.cb
        
        If (event="Connect") {
            socket.statusCode := errCode
            If !(errCode)
                socket.ConnectFinish(), socket.status := "Connected"
            Else If socket.ConAddrStruct.next
                socket.ConnectNext() ; try next addr from GetAddrInfo
            Else If !socket.ConAddrStruct.next {
                socket.status := "Failed", socket.ConnectFinish() ; all addresses tried, and failed
                socket.addr := 0, socket.port := 0, socket.ConAddrIndex := 0
            }
        }
        
        if (cb)
            cb(socket,event,errCode)
    }
    
    family := 0, protocol := 0, socktype := 0
    callback := 0, desc := -1, name := ""
    err := "", errnum := 0, LastOp := ""
    
    host := "", port := 0, addr := "", status := "", statusCode := 0
    ConAddrStruct := 0, ConAddrIndex := 0, ConAddrRoot := 0
    
    block := false ; internal, don't use directly, use this.blocking
    
    ; sock := {name:"client", family:"Unspec", protocol:"TCP", type:"Stream", block:false, callback:fnc} ; init obj??
    
    __New(name, callback:=0, family:="Unspec", protocol:="TCP", socktype:="Stream", desc:=-1) {
        
        this.name := name, this.desc := desc, this.cb := callback
        
        If !winsock.family.HasProp(family) ; IPV4:2, NetBIOS:17, IPV6:23, IRDA:26, BTH:32
            throw Error("Invalid socket family specified.",-1,"Valid values are:`n`nIPV4,IPV6,NetBIOS,IRDA,BTH")
        
        this.family   := winsock.family.%family%    , this.familyName   := family
        this.socktype := winsock.socktype.%socktype%, this.socktypeName := socktype
        this.protocol := winsock.protocol.%protocol%, this.protocolName := protocol
        
        if !this.CreateSocket(this.desc)
            throw Error("Error creating socket.",-1,"Error Code: " this.errnum " / " this.err "`nLast Op: " this.LastOp)
        else
            winsock.sockets[String(this.desc)] := this
    }
    
    Accept(&addr:=0,&newsock:=0,block:=false) { ; optional VarRef to capture the sockaddr struct of new connection
        retCode := 1
        sockaddr := winsock.sockaddr(,this.familyName) ; new approach ...
        
        If ((newdesc := DllCall("Ws2_32\accept","UInt",this.desc,"UPtr",sockaddr.ptr,"Int*",sockaddr.size)) = -1) {
            this.WsaLastErr("accept"), retCode := 0, this.Close()
            return 0
        }
        
        newsock := winsock("serving-" newdesc, this.cb, this.familyName, this.protocolName, this.socktypeName, newdesc)
        (!block) ? newsock.RegisterEvents() : "" ; enable non-blocking mode (default)
        
        strAddr := newsock.AddrToStr(sockaddr), cSep := InStr(strAddr,":",,,-1)
        newsock.addr := RegExReplace(SubStr(strAddr,1,cSep-1),"[\[\]]","") ; record connecting address
        newsock.port := SubStr(strAddr,cSep+1) ; record connecting port
        winsock.sockets[String(newsock.desc)] := newsock ; catalog new socket
        
        return retcode
    }
    
    AddrToStr(sock_addr, protocol_info:=0) {
        DllCall("Ws2_32\WSAAddressToString","UPtr",sock_addr.ptr ,"UInt",sock_addr.size
                                           ,"UPtr",protocol_info ,"UPtr",0 ,"UInt*",&strSize:=0)
        
        strbuf := Buffer(strSize * (StrLen(0xFFFF)?2:1),0)
        If (DllCall("Ws2_32\WSAAddressToString","UPtr",sock_addr.ptr ,"UInt",sock_addr.size
                                               ,"UPtr",protocol_info ,"UPtr",strbuf.ptr ,"Int*",strSize) = -1) {
            this.WsaLastErr()
            return ""
        }
        return StrGet(strbuf)
    }
    
    RegisterEvents(lEvent:=0x3FF) { ; FD_ALL_EVENTS = 0x3FF
        this.block := !lEvent ? false : true
        
        If (result:=this._WSAAsyncSelect(this.desc, A_ScriptHwnd, winsock.wm_msg, lEvent) = -1)
            throw Error("WSAASyncSelect failed.", -1)
        
        ; If !lEvent
            ; result := this._ioctlsocket(this.desc, 0x8004667E, &r:=0) ; FIONBIO := 0x8004667E (non-blocking mode)
            
        return !result
    }
    
    _WSAAsyncSelect(sock_desc, hwnd, msg, lEvent) =>
        DllCall("Ws2_32\WSAAsyncSelect", "UInt", sock_desc, "UPtr", hwnd, "UInt", msg, "UInt", lEvent)
    
    Bind(host:=0,port:=0) {
        Static AI_PASSIVE:=0x1 ; required flag for calling Bind()
        
        result := this.GetAddrInfo(host,port,AI_PASSIVE) ; addrinfo struct
        retCode := 1
        If (DllCall("Ws2_32\bind", "UInt", this.desc, "UPtr", result.addr, "UInt", result.addrlen) = -1)
            this.WsaLastErr("bind"), retCode := 0, this.Close() ; close socket
        DllCall("Ws2_32\FreeAddrInfo", "UPtr", result.ptr) ; free memory of addrinfo chain
        return retCode
    }
    
    Close() {
        result := 1
        if (DllCall("Ws2_32\closesocket","Int",this.desc) = -1)
            this.WsaLastErr("closesocket"), result := 0
        Else
            winsock.sockets.Delete(String(this.desc)), this.status := "Closed"
        return result
    }
    
    Connect(host:=0,port:=0,block:=false) { ; init connect process
        (!block) ? (this.RegisterEvents()) : ""
        
        If (this.ConAddrStruct := this.GetAddrInfo(this.host:=host,port)) {
            this.ConAddrRoot := this.ConAddrStruct.ptr
            
            ; dbg("root: " this.ConAddrRoot " / next: " this.ConAddrStruct.next)
            
            If !block {
                result := this.ConnectNext()
            } Else {
                While (result := this.ConnectNext()) { ; initiate connect process
                    ; dbg("still looping?")
                    Sleep(10)
                }
                this.ConnectFinish() ; cleanup
            }
        }
        
        If (result=-1) && this.WsaLastErr("connect") && (this.err = "WSAEWOULDBLOCK")
            result := !result
        
        return !result
    }
    
    ConnectFinish() { ; free memory of addrinfo chain
        DllCall("Ws2_32\FreeAddrInfo", "UPtr", this.ConAddrRoot)
        this.ConAddrRoot := 0, this.ConAddrStruct := ""
    }
    
    ConnectNext() { ; ConAddrIndex is initiated at 0.  The first call of ConnectNext() sets ConAddrIndex to 1.
        this.status := "Connecting"
        
        this.ConAddrIndex++ ; When ConAddrIndex is > 1, the next line prepares the next address to try, if any.
        (this.ConAddrIndex>1) ? (this.ConAddrStruct := winsock.addrinfo(this.ConAddrStruct.next)) : "" ; this.ConAddrStruct.next checked in WM_SOCKET
        
        ; dbg("ConAddrIndex: " this.ConAddrIndex)
        
        sockaddr := winsock.sockaddr(this.ConAddrStruct.addr,this.ConAddrStruct.addrlen) ; get sockaddr struct
        strAddr := this.AddrToStr(sockaddr), cSep := InStr(strAddr,":",,,-1)
        this.addr := RegExReplace(SubStr(strAddr,1,cSep-1), "[\[\]]", "") ; record connecting address
        this.port := SubStr(strAddr,cSep+1) ; record connecting port
        
        If (r := DllCall("Ws2_32\connect","UInt",this.desc,"UPtr",this.ConAddrStruct.addr,"UInt",this.ConAddrStruct.addrlen) = -1)
            this.WsaLastErr("connect")
        
        ; dbg("connect result: " r " / err: " this.err)
        
        return r
    }
    
    CreateSocket(desc:=-1) { ; make new socket, or take given socket, then call WSAAsyncSelect
        result := 1
        If ((desc = -1) ; try to open the socket
          && (this.desc := DllCall("Ws2_32\socket","Int",this.family,"Int",this.socktype,"Int",this.protocol)) = -1)
            this.WsaLastErr("socket"), result := 0
        return result
    }
    
    GetAddrInfo(host,port:=0,flags:=0) {
        hints := winsock.addrinfo()
        hints.family   := this.family  , hints.protocol := this.protocol
        hints.socktype := this.socktype, hints.flags    := flags
        
        if (err := DllCall("Ws2_32\GetAddrInfo",(host?"Str":"UPtr"),host
                                               ,(port?"Str":"UPtr"),(port?String(port):0)
                                               ,"UPtr",hints.ptr
                                               ,"UPtr*",&result:=0)) {
            this.WsaLastErr("GetAddrInfo")
            return winsock.addrinfo(0) ; return NULL ptr
        }
        
        return winsock.addrinfo(result)
    }
    
    Listen(backlog:=5,block:=false) { ; SOMAXCONN = 5
        (!block) ? this.RegisterEvents() : "" ; enable non-blocking mode (default)
        retCode := 1
        If (DllCall("Ws2_32\listen","UInt",this.desc,"Int",backlog) = -1)
            this.WsaLastErr("bind"), retCode := 0, this.Close() ; close socket
        return retCode
    }
    
    ; QueueData(buf) => this.OutQueue.Push(buf) ; ???
    
    Recv(flags:=0) {
        If (this._ioctlsocket(this.desc, 0x4004667F, &bytes) = -1) { ; FIONREAD := 0x4004667F
            this.WsaLastErr("ioctlsocket")
            If (this.err != "WSAEWOULDBLOCK")
                return Buffer(0)
        }
        
        buf := Buffer(bytes,0)
        If (DllCall("Ws2_32\recv","UInt",this.desc,"UPtr",buf.ptr,"Int",buf.size,"Int",flags) = -1) {
            this.WsaLastErr("recv")
            if (this.err != "WSAEWOULDBLOCK")
                return Buffer(0)
        }
        
        return buf
    }
    
    _ioctlsocket(socket, cmd, &agrp:=0) => DllCall("Ws2_32\ioctlsocket", "UInt", socket, "UInt", cmd, "UInt*", &agrp:=0)
    
    Send(buf,flags:=0) {
        If (DllCall("Ws2_32\send","UInt",this.desc,"UPtr",buf.ptr,"UInt",buf.size,"UInt",flags) = -1) {
            this.WsaLastErr("send")
            return 0
        } Else return 1
    }
    
    WsaLastErr(LastOp:="") {
        If (result := DllCall("Ws2_32\WSAGetLastError"))
            this.errnum := result, this.LastOp := LastOp, this.err := winsock.errors.%result%
        Else
            this.errnum := 0     , this.LastOp := ""    , this.err := ""
        return result
    }
    
    __Delete() => this.Close() ; close socket if open
    
    class addrinfo {
        Static __New() {
            off := {flags:     {off:0,   type:"Int"} ,addrlen:   {off:16,  type:"UPtr"}
                   ,family:    {off:4,   type:"Int"} ,cannonname:{off:16+(p:=A_PtrSize),type:"UPtr"}
                   ,socktype:  {off:8,   type:"Int"} ,addr:      {off:16+(p*2),type:"UPtr"}
                   ,protocol:  {off:12,  type:"Int"} ,next:      {off:16+(p*3),type:"UPtr"}}
            this.Prototype.DefineProp("s",{Value:off})
        }
        
        __New(buf := 0) {
            this.DefineProp("_struct",{Value:(!buf) ? Buffer(16 + (A_PtrSize*4),0) : {ptr:buf}})
            this.DefineProp("Ptr",{Get:(o)=>this._struct.ptr})
        }
        
        __Get(name,p) => NumGet(this.ptr, this.s.%name%.off, this.s.%name%.type)
        __Set(name,p,value) => NumPut(this.s.%name%.type, value, this.ptr, this.s.%name%.off)
    }
    
    class sockaddr { ; family := {Unspec:0, IPV4:2, NetBIOS:17, IPV6:23, IRDA:26, BTH:32}
        __New(buf := 0, fam := "IPv4") { ; buf=0 && fam=family_text   OR   buf=ptr && fam=size
            Static _fs := winsock.fam_size, _fo := winsock.fam_addr_off, _fL := winsock.fam_len
                 , _f := winsock.family, _f2 := winsock.family_2
            
            If !buf && !winsock.family.HasOwnProp(fam)
                throw Error("Invalid family for sockaddr creation: " fam, -1)
            
            this.DefineProp("size",{Value:size := (Type(fam)="String")?(_fs.%fam%):fam})
            this.DefineProp("_struct",{Value:(!buf) ? Buffer(size,0) : {ptr:buf}})
            this.DefineProp("Ptr",{Get:(o)=>this._struct.ptr})
            
            (buf) ? (fam := _f2.%NumGet(buf,0,"UShort")%) : NumPut("UShort",_f.%fam%,this.Ptr) ; init family, or get fam name
            
            off := {family: {off:0,type:"UShort"},flowinfo:{off:4 ,type:"UInt"}, address:{off:_fo.%fam% , len:_fL.%fam%}
                   ,  port: {off:2,type:"UShort"}, scopeid:{off:24,type:"UInt"}}
            
            this.DefineProp("s",{Value:off})
        }
        
        __Get(name,p) => (this.s.%name%.HasOwnProp("len")) ? this.extract(this.ptr + this.s.%name%.off,this.s.%name%.len)
                                                           : NumGet(this.ptr,this.s.%name%.off,this.s.%name%.type)
        
        __Set(name,p,value) => (this.s.%name%.HasOwnProp("len")) ? this.insert(value,this.ptr + this.s.%name%.off)
                                                                 : NumPut(this.s.%name%.type,value,this.ptr,this.s.%name%.off)
    }
    
    ; class ProtoInfo {
        ; Static __New() {
            ; off := 
        ; }
        
        ; __New(buf:=0) {
            ; Static u := StrLen(Chr(0xFFFF))
            ; this._struct := (!buf) ? Buffer(u?:,0) : {ptr:buf}
            
            ; this.DefineProp("Ptr",{Get:(o)=>this._struct.ptr})
        ; }
    ; }
    
}


; typedef struct _WSAPROTOCOL_INFOA {
  ; DWORD            dwServiceFlags1;
  ; DWORD            dwServiceFlags2;
  ; DWORD            dwServiceFlags3;
  ; DWORD            dwServiceFlags4;
  ; DWORD            dwProviderFlags;
  ; GUID             ProviderId;
  ; DWORD            dwCatalogEntryId;
  ; WSAPROTOCOLCHAIN ProtocolChain;
  ; int              iVersion;
  ; int              iAddressFamily;
  ; int              iMaxSockAddr;
  ; int              iMinSockAddr;
  ; int              iSocketType;
  ; int              iProtocol;
  ; int              iProtocolMaxOffset;
  ; int              iNetworkByteOrder;
  ; int              iSecurityScheme;
  ; DWORD            dwMessageSize;
  ; DWORD            dwProviderReserved;
  ; CHAR             szProtocol[WSAPROTOCOL_LEN + 1];
; } WSAPROTOCOL_INFOA, *LPWSAPROTOCOL_INFOA;


; ========================================================================
; Old methods
; ========================================================================

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