;http://www.autohotkey.com/forum/topic35575.html

/*
WS2.ahk / StdLib WinSock IPv4 Library for AHK
written and published by derRaphael

Based on WinSock2.ahk // a rewrite by derRaphael (w) Sep, 9 2008

Following people also helped in evolving this library

based on the WinLIRC Script from Chris
    http://www.autohotkey.com/docs/scripts/WinLIRC.htm
and on the WinLIRC Rewrite by ZedGecko
    http://www.autohotkey.com/forum/viewtopic.php?t=13829

__WSA_GetHostByName - Parts based upon scripts from DarviK
and Tasman. Not much left of the origin source, but it was
their achievement by doing the neccessary research.

WS2_SendData, __WSA_GetLastError, __WSA_recv, __WSA_send
   incorporate changes as suggested and
WS2_SendDataEx, WS2_SendNumber
   are submissions added to this Lib by Lexikos
   http://www.autohotkey.com/forum/viewtopic.php?p=285164#285164
*/

; WS2 Connect - This establishes a connection to a named resource
; The parameter is to be passed in an URI:Port manner.
; Returns the socket upon successfull connection, otherwise it
; returns -1. In the latter case more Information is in the global
; variable __WSA_ErrMsg
;
; Usage-Example:
;    Pop3_Socket := WS2_Connect("mail.isp.com:110")
; See the Doc for more Information.
WS2_Connect(lpszUrl) {

    Global

    ; split our targetURI
    __WinINet_InternetCrackURL("info://" lpszUrl,"__WSA")

    ; name our port
    WS2_Port := __WSA_nPort

    ; Init the Winsock connection
    if (     !( __WSA_ScriptInit()           )         ; Init the Scriptvariables
          || !( __WSA_Startup()              ) ) {     ; Fire up the WSA
        WS2_CleanUp()         ; Do a premature cleanup
        return -1             ; and return an error indication
    }
    ; check the URI if it's valid
    if (RegExMatch(__WSA_lpszHostName,"[^\d.]+")) ; Must be different than IP
    {
        WS2_IPAddress := __WSA_GetHostByName(__WSA_lpszHostName)
    } else {     ; Let's check if the IP is valid
        StringSplit,__WSA_tmpIPFragment, __WSA_lpszHostName,.
        Loop,4
            If (    ( __WSA_tmpIPFragment%A_Index%<0   )
                 || ( __WSA_tmpIPFragment%A_Index%>255 )
                 || ( __WSA_tmpIPFragment0!=4          ) ) {
                __WSA_IPerror = 1
                Break
            }
        If (__WSA_IPerror=1)
            __WSA_ErrMsg .= "No valid IP Supplied"
        else
            WS2_IPAddress := __WSA_lpszHostName
    }

    ; CONVERSIONS

    ; The htons function returns the value in TCP/IP network byte order.
    ; http://msdn.microsoft.com/en-us/library/ms738557(VS.85).aspx
    __WSA_Port                := DllCall("Ws2_32\htons", "UShort", WS2_Port)

    ; The inet_addr function converts a string containing an IPv4 dotted-decimal
    ; address into a proper address for the IN_ADDR structure.
    ; inet_addr: http://msdn.microsoft.com/en-us/library/ms738563(VS.85).aspx
    ; IN_ADDR:   http://msdn.microsoft.com/en-us/library/ms738571(VS.85).aspx
    __WSA_InetAddr           := DllCall("Ws2_32\inet_addr", "Str", WS2_IPAddress)

    If (     ( __WSA_Socket:=__WSA_Socket() )
          && ( __WSA_Connect()              )   )
        return __WSA_Socket   ; All went OK, return the SocketID
    Else {
        WS2_CleanUp()         ; Do a premature cleanup
        return -1             ; and return an error indication
    }
}

; WS2 OnMessage - This function defines, whatever should happen when
; a Message is received on the socket.
; Expected Parameter:
;      Ws2_Socket    => Socket returned from WS2_Connect() Call
;      UDF           => An UserDefinedFunction to which the received
;                       Data will be passed to
; Optional Parameter:
;      WindowMessage => A number indicating upon which WM_Message to react
;
; Returns -1 on error, 0 on success

WS2_AsyncSelect(Ws2_Socket,UDF,WindowMessage="") {
    Global __WSA_ErrMsg
    If (    ( StrLen(Ws2_Socket)=0 )
         || ( StrLen(UDF)=0        ) ) {
        res := -1
    } else {
        If (    (StrLen(WindowMessage)=0)
             || (WindowMessage+0=0)      )
            WindowMessage := 0x5000
        res := __WSA_AsyncSelect(Ws2_Socket, UDF, WindowMessage)
    }
    return res
}

WS2_SendData(WS2_Socket, StringToSend) {
    Global __WSA_ErrMsg
    If (__WSA_send(WS2_Socket, &StringToSend, StrLen(StringToSend))=-1) {
        MsgBox, 16, %A_ScriptName%: Send-Error, % __WSA_ErrMsg
    }
}

WS2_SendDataEx(WS2_Socket, DataToSend, DataLength) {
    Global __WSA_ErrMsg
    If (__WSA_send(WS2_Socket, DataToSend, DataLength)=-1) {
        MsgBox, 16, %A_ScriptName%: Send-Error, % __WSA_ErrMsg
    }
}

WS2_SendNumber(WS2_Socket, Num, Type="UInt") {
    Global __WSA_ErrMsg
    VarSetCapacity(DataToSend, 8)
    DataLength := NumPut(Num, DataToSend, 0, Type) - &DataToSend
    If (__WSA_send(WS2_Socket, &DataToSend, DataLength)=-1) {
        MsgBox, 16, %A_ScriptName%: Send-Error, % __WSA_ErrMsg
    }
}

; WS2 Cleanup - This needs to be called whenever Your Script exits
; Usually this is invoked by some OnExit, Label subroutines.
WS2_CleanUp() {
    DllCall("Ws2_32\WSACleanup")
}

WS2_Disconnect(WS2_Socket) {
    Global __WSA_ErrMsg
    if (res := __WSA_CloseSocket(WS2_Socket))
        MsgBox, 16, %A_ScriptName%: CloseSocket-Error, % __WSA_ErrMsg
}

; WS2 ScriptInit - for internal use only
; Initializes neccessary variables for this Script.
__WSA_ScriptInit()
{
    ; CONTANTS

    ; We're working with version 2 of Winsock
    Local VersionRequested    := 2
    ; from http://msdn.microsoft.com/en-us/library/ms742212(VS.85).aspx
    Local AF_INET             := 2
    Local SOCK_STREAM         := 1
    Local IPPROTO_TCP         := 6
    Local FD_READ             := 0x1
    Local FD_CLOSE            := 0x20

    __AI_PASSIVE              := 1

    __WSA_WSVersion           := VersionRequested
    __WSA_SocketType          := SOCK_STREAM
    __WSA_SocketProtocol      := IPPROTO_TCP
    __WSA_SocketAF            := AF_INET
    __WSA_lEvent              := FD_READ|FD_CLOSE

    __WSA_WOULDBLOCK          := 10035  ; http://www.sockets.com/err_lst1.htm#WSAECONNRESET
    __WSA_CONNRESET           := 10054  ; http://www.sockets.com/err_lst1.htm#WSAECONNRESET

    return 1
}

; WS2 Startup - for internal use only
; Initializes the Winsock 2 Adapter
__WSA_Startup()
{
    Global WSAData, __WSA_ErrMsg, __WSA_WSVersion

    ; It's a good idea, to have a __WSA_ErrMsg Container, so any Error Msgs
    ; may be catched by the script.
    __WSA_ErrMsg := ""

    ; Generate Structure for the lpWSAData
    ; as stated on http://msdn.microsoft.com/en-us/library/ms742213.aspx
    ; More on WSADATA (structure) to be found here:
    ; http://msdn.microsoft.com/en-us/library/ms741563(VS.85).aspx
    VarSetCapacity(WSAData, 32)
    result := DllCall("Ws2_32\WSAStartup", "UShort", __WSA_WSVersion, "UInt", &WSAData)

    if (ErrorLevel)
        __WSA_ErrMsg .= "Ws2_32\WSAStartup could not be called due to error " ErrorLevel "`n"
                      . "Winsock 2.0 or higher is required.`n"
    if (result!=0)
        __WSA_ErrMsg .= "Ws2_32\WSAStartup " __WSA_GetLastError()

    If (StrLen(__WSA_ErrMsg)>0)
        Return -1
    Else
        Return 1
}

; WS2 Socket Descriptor - for internal use only
; Sets type and neccessary structures for a successfull connection
__WSA_Socket()
{
    Global __WSA_ErrMsg, __WSA_SocketProtocol, __WSA_SocketType, __WSA_SocketAF

    ; Supposed to return a descriptor referencing the new socket
    ; http://msdn.microsoft.com/en-us/library/ms742212(VS.85).aspx
    __WSA_Socket := DllCall("Ws2_32\socket"
                            , "Int", __WSA_SocketAF
                            , "Int", __WSA_SocketType
                            , "Int", __WSA_SocketProtocol)
    if (socket = -1)
        __WSA_ErrMsg .= "Ws2_32\socket " __WSA_GetLastError()

    If (StrLen(__WSA_ErrMsg)>0)
        Return -1
    Else
        Return __WSA_Socket

}

; WS2 Connection call - for internal use only
; Establishes a connection to a foreign IP at the specified port
__WSA_Connect()
{
    Global __WSA_ErrMsg, __WSA_Port, __WSA_Socket, __WSA_InetAddr, __WSA_SocketAF

    ; Generate socketaddr structure for the connect()
    ; http://msdn.microsoft.com/en-us/library/ms740496(VS.85).aspx
    __WSA_SockAddrNameLen  := 16
    VarSetCapacity(__WSA_SockAddr, __WSA_SockAddrNameLen)
    NumPut(__WSA_SocketAF, __WSA_SockAddr, 0, "UShort")
    NumPut(__WSA_Port,     __WSA_SockAddr, 2, "UShort")
    NumPut(__WSA_InetAddr, __WSA_SockAddr, 4)

    ; The connect function establishes a connection to a specified socket.
    ; http://msdn.microsoft.com/en-us/library/ms737625(VS.85).aspx
    result := DllCall("Ws2_32\connect"
                        , "UInt", __WSA_Socket
                        , "UInt", &__WSA_SockAddr
                        , "Int" , __WSA_SockAddrNameLen)
    if (result)
        __WSA_ErrMsg .= "Ws2_32\connect " __WSA_GetLastError()

    If (StrLen(__WSA_ErrMsg)>0)
        Return -1
    Else
        Return 1
}


/*
 This code based originally upon an example by DarviK
    http://www.autohotkey.com/forum/topic8871.html
 and on the modifcations by Tasman
    http://www.autohotkey.com/forum/viewtopic.php?t=9937
*/
; Resolves canonical domainname to IP
__WSA_GetHostByName(url)
{
    Global __WSA_ErrMsg
    ; gethostbyname returns information about a domainname into a Hostent Structure
    ; http://msdn.microsoft.com/en-us/library/ms738524(VS.85).aspx
    IP := ""
    if ((PtrHostent:=DllCall("Ws2_32\gethostbyname","str",url)) != 0) {
        Loop, 1 ; 3 is max No of retrieved addresses
            If (PtrTmpIP := NumGet(NumGet(PtrHostent+12)+(offset:=(A_Index-1)*4),offset)) {
                IP := (IP) ? IP "|" : ""
                Loop, 4 ; Read our IP address
                    IP .= NumGet(PtrTmpIP+offset,(A_Index-1 ),"UChar") "."
                IP := SubStr(IP,1,-1)
            } else ; No more IPs left
                Break
        result := IP
    } else {
        __WSA_ErrMsg .= "Ws2_32\gethostbyname failed`n "
        result := -1
    }
    return result
}

; Return the last Error with a lil bit o' text if neccessary
; Note: the txt variable is set to 0 when checking for received content
;
; Changes contributed by Lexikos
; http://www.autohotkey.com/forum/viewtopic.php?p=285164#285164
__WSA_GetLastError(txt=1)
{
    err := DllCall("Ws2_32\WSAGetLastError")
    if txt {
        VarSetCapacity(txt, 1024) ; "Limit" to 1024 chars.
        if DllCall("FormatMessage", uint, 0x1200, uint, 0, int, err
                                , uint, 1024, str, txt, uint, 1024, uint, 0)
            return "indicated Winsock error " . err . ":`n" . txt
    }
    return err
}


; WS2 AsyncSelect - for internal use only
; Sets up an Notification Handler for Receiving Messages
; Expected Parameters: Socket from Initialisation
; Optional: NotificationMsg   - default 0x5000
;           WSA_DataReiceiver - an different Name to standard
;                               wm_* processor function.
;                               default __WSA_ReceiveData
; Returns -1 on Error, 0 on success
__WSA_AsyncSelect(__WSA_Socket, UDF, __WSA_NotificationMsg=0x5000
                              ,__WSA_DataReceiver="__WSA_recv")
{
    Global

    __WSA_UDF := UDF

    OnMessage(__WSA_NotificationMsg, __WSA_DataReceiver)
    ; The WSAAsyncSelect function requests Windows message-based notification
    ; of network events for a socket.
    ; http://msdn.microsoft.com/en-us/library/ms741540(VS.85).aspx
    Result := DllCall("Ws2_32\WSAAsyncSelect"
                , "UInt", __WSA_Socket
                , "UInt", __WSA_GetThisScriptHandle()
                , "UInt", __WSA_NotificationMsg
                , "Int",  __WSA_lEvent)
    if (Result) {
        __WSA_ErrMsg .= "Ws2_32\WSAAsyncSelect() " . __WSA_GetLastError()
        Result := -1
    }
    Return Result
}

; WS2 Receive - for internal use only
; Triggers upon Notification Handler when Receiving Messages
;
; Changes contributed by Lexikos
; http://www.autohotkey.com/forum/viewtopic.php?p=285164#285164
__WSA_recv(wParam, lParam)
{
    Global __WSA_UDF, __WSA_ErrMsg
    ; __WSA_UDF containes the name of the UserDefinedFunction to call when the event
    ; has been triggered and text may be processed (allthough the reveived text might
    ; be inclomplete, especially when receiving large chunks of data, like in eMail-
    ; attachments or sometimes in IRC). The UDF needs to accept two parameter: socket
    ; and the received buffer

    __WSA_Socket := wParam
    __WSA_BufferSize = 4096
    Loop
    {
        VarSetCapacity(__WSA_Buffer, __WSA_BufferSize, 0)
        __WSA_BufferLength := DllCall("Ws2_32\recv"
                                        , "UInt", __WSA_Socket
                                        , "Str",  __WSA_Buffer
                                        , "Int",  __WSA_BufferSize
                                        , "Int",  0 )
        if (__WSA_BufferLength <= 0) ; 0 or -1 (probably never < -1)
        {
            __WSA_Err := __WSA_GetLastError(0)

            ; __WSA_WOULDBLOCK (from http://www.sockets.com/)
            ; The socket is marked as non-blocking (non-blocking operation mode), and
            ; the requested operation is not complete at this time. The operation is
            ; underway, but as yet incomplete.
            if (__WSA_Err = __WSA_WOULDBLOCK )
                return 1

            ; __WSA_CONNRESET: (from http://www.sockets.com/)
            ; A connection was forcibly closed by a peer. This normally results from
            ; a loss of the connection on the remote socket due to a timeout or a reboot.
            if (__WSA_UDF != "" && (__WSA_BufferLength = 0 || __WSA_Err = __WSA_CONNRESET))
                return 1, %__WSA_UDF%(__WSA_Socket, __WSA_Buffer:="", 0)

            __WSA_ErrMsg .= "Ws2_32\recv indicated Winsock error " __WSA_Err "`n"
            break
        }

        if __WSA_UDF != ; If set, call UserDefinedFunction and pass Buffer to it
            %__WSA_UDF%(__WSA_Socket, __WSA_Buffer, __WSA_BufferLength)
    }
    return 1
}

; WSA Send - for internal use only
; Users are encouraged to use the WS2_SendData() Function
;
; Changes contributed by Lexikos
; http://www.autohotkey.com/forum/viewtopic.php?p=285164#285164
__WSA_send(__WSA_Socket, __WSA_Data, __WSA_DataLen)
{
    Global __WSA_ErrMsg

    Result := DllCall("Ws2_32\send"
                       , "UInt", __WSA_Socket
                       , "UInt",  __WSA_Data
                       , "Int", __WSA_DataLen
                       , "Int", 0)
   If (Result = -1)
      __WSA_ErrMsg .=  "Ws2_32\send " __WSA_GetLastError()
   Return Result
}

; Closes Open Socket - for internal use only
; Returns 0 on success
__WSA_CloseSocket(__WSA_Socket)
{
    Global __WSA_ErrMsg

    Result := DllCall("Ws2_32\closesocket"
                       , "UInt", __WSA_Socket)
    If (Result != 0)
      __WSA_ErrMsg .=  "Ws2_32\closesocket " __WSA_GetLastError()

    Return result
}

; GetThisScriptHandle - for internal use only
; Returns the handle of the executing script
__WSA_GetThisScriptHandle()
{

    HiddenWindowsSave := A_DetectHiddenWindows

    DetectHiddenWindows On
    ScriptMainWindowId := WinExist("ahk_class AutoHotkey ahk_pid " DllCall("GetCurrentProcessId"))
    DetectHiddenWindows %HiddenWindowsSave%

    Return ScriptMainWindowId
}

; WinINet InternetCrackURL - for internal use only
; v 0.1 / (w) 25.07.2008 by derRaphael / zLib-Style release
; This routine was originally posted here:
; http://www.autohotkey.com/forum/viewtopic.php?p=209957#209957
__WinINet_InternetCrackURL(lpszUrl,arrayName="URL")
{
    local hModule, offset_name_length
    hModule := DllCall("LoadLibrary", "Str", "WinINet.Dll")

    ; SetUpStructures for URL_COMPONENTS / needed for InternetCrackURL
    ; http://msdn.microsoft.com/en-us/library/aa385420(VS.85).aspx
    offset_name_length:= "4-lpszScheme-255|16-lpszHostName-1024|28-lpszUserName-1024|"
                       . "36-lpszPassword-1024|44-lpszUrlPath-1024|52-lpszExtrainfo-1024"

    VarSetCapacity(URL_COMPONENTS,60,0)
    ; Struc Size               ; Scheme Size                  ; Max Port Number
    NumPut(60,URL_COMPONENTS,0), NumPut(255,URL_COMPONENTS,12), NumPut(0xffff,URL_COMPONENTS,24)
    Loop,Parse,offset_name_length,|
    {
        RegExMatch(A_LoopField,"(?P<Offset>\d+)-(?P<Name>[a-zA-Z]+)-(?P<Size>\d+)",iCU_)
        VarSetCapacity(%iCU_Name%,iCU_Size,0)
        NumPut(&%iCU_Name%,URL_COMPONENTS,iCU_Offset)
        NumPut(iCU_Size,URL_COMPONENTS,iCU_Offset+4)
    }

    ; Split the given URL; extract scheme, user, pass, authotity (host), port, path, and query (extrainfo)
    ; http://msdn.microsoft.com/en-us/library/aa384376(VS.85).aspx
    DllCall("WinINet\InternetCrackUrlA","Str",lpszUrl,"uInt",StrLen(lpszUrl),"uInt",0,"uInt",&URL_COMPONENTS)
    ; Update variables to retrieve results
    Loop,Parse,offset_name_length,|
    {
        RegExMatch(A_LoopField,"-(?P<Name>[a-zA-Z]+)-",iCU_)
        VarSetCapacity(%iCU_Name%,-1)
        %arrayName%_%iCU_Name% := % %iCU_Name%
    }
    %arrayName%_nPort:=NumGet(URL_COMPONENTS,24,"uInt")
    DllCall("FreeLibrary", "UInt", hModule)                    ; unload the library
}
