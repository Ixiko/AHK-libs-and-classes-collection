#NoEnv

/*
SimplePing
==========
AHK library providing a variety of ICMP pinging-related functionality.

Examples
--------

Ping a Google DNS server:

    MsgBox % "Round trip time: " . RoundTripTime("8.8.8.8")

Ping two different Google DNS servers at the same time:

    Addresses := ["8.8.8.8", "8.8.4.4"]
    Value := ""
    For Index, PingTime In RoundTripTimeList(Addresses)
        Value .= "Server: "List[Index] . ", Round trip time: " . PingTime . "ms`n"
    MsgBox %Value%

Send an ICMP request to a Google DNS server:

    MsgBox % "Round trip time: " . Ping("8.8.8.8") . "ms"

Ping example.com with some data and show the response (the SubStr causes the result to be interpreted as a string):

    MsgBox % "Round trip time: " . Ping("192.0.43.10",800,"Hello!",6,Value,Length) . "ms, Response: " . SubStr(Value,1)

Overview
--------
All functions throw exceptions on failure.

### RTT := Ping(Address,Timeout = 800,ByRef Data = "",Length = 0,ByRef Result = "",ByRef ResultLength = 0)
Pings an address and waits for a response.
Useful for sending custom pings supporting messages and responses.

### RTT := PingAsync(Address,Timeout = 800,ByRef Data = "",Length = 0,ByRef Result = "",ByRef ResultLength = 0)
Works exactly the same as Ping(), but uses an asynchronous event-based method.
Intended only as a technology demo, avoid using as it may change or be removed in the future.

### RTT := RoundTripTime(Address,Timeout = 800)
Determines the round trip time (sometimes called the "ping") from the local machine to the address.
Useful for pinging a server to determine latency.

### RTT := RoundTripTimeList(AddressList,Timeout = 800)
Determines the round trip time (sometimes called the "ping") from the local machine to a list of 64 or fewer addresses.
Useful for quickly pinging an entire server list to find the amount of latency in the connection to each.

Parameters
----------
RTT:          The round trip time in milliseconds (e.g., 76). If unknown or timed out, this value is -1.
Address:      IPv4 address as a string in dotted number format (e.g., "127.0.0.1").
AddressList:  Array of IPv4 addresses as strings in dotted number format (e.g., ["127.0.0.1", "8.8.4.4"]).
Timeout:      How long the function should wait, in milliseconds, before giving an error (e.g., 400).
Data:         The data to send with the ping (e.g., "Hello"). Can be binary data as well.
Length:       The length of the data to send with the ping (e.g., 5).
Result:       The data in the response to the ping (e.g., "Salutations"). Can be binary data as well.
ResultLength: The length of the data in the response to the ping (e.g., 11).
*/

Ping(Address,Timeout = 800,ByRef Data = "",Length = 0,ByRef Result = "",ByRef ResultLength = 0)
{
    If DllCall("LoadLibrary","Str","ws2_32","UPtr") = 0 ;NULL
        throw Exception("Could not load WinSock 2 library.")
    If DllCall("LoadLibrary","Str","icmp","UPtr") = 0 ;NULL
        throw Exception("Could not load ICMP library.")

    NumericAddress := DllCall("ws2_32\inet_addr","AStr",Address,"UInt")
    If NumericAddress = 0xFFFFFFFF ;INADDR_NONE
        throw Exception("Could not convert IP address string to numeric format.")

    hPort := DllCall("icmp\IcmpCreateFile","UPtr") ;open port
    If hPort = -1 ;INVALID_HANDLE_VALUE
        throw Exception("Could not open port.")

    StructLength := 270 + (A_PtrSize * 2) ;ICMP_ECHO_REPLY structure
    VarSetCapacity(Reply,StructLength)
    Count := DllCall("icmp\IcmpSendEcho"
        ,"UPtr",hPort ;ICMP handle
        ,"UInt",NumericAddress ;IP address
        ,"UPtr",&Data ;request data
        ,"UShort",Length ;length of request data
        ,"UPtr",0 ;pointer to IP options structure
        ,"UPtr",&Reply ;reply buffer
        ,"UInt",StructLength ;length of reply buffer
        ,"UInt",Timeout) ;ping timeout
    If NumGet(Reply,4,"UInt") = 11001 ;IP_BUF_TOO_SMALL
    {
        StructLength *= Count
        VarSetCapacity(Reply,StructLength)
        DllCall("icmp\IcmpSendEcho"
            ,"UPtr",hPort ;ICMP handle
            ,"UInt",NumericAddress ;IP address
            ,"UPtr",&Data ;request data
            ,"UShort",Length ;length of request data
            ,"UPtr",0 ;pointer to IP options structure
            ,"UPtr",&Reply ;reply buffer
            ,"UInt",StructLength ;length of reply buffer
            ,"UInt",Timeout) ;ping timeout
    }

    If !DllCall("icmp\IcmpCloseHandle","UInt",hPort) ;close port
        throw Exception("Could not close port.")

    If Status In 11002,11003,11004,11005,11010 ;IP_DEST_NET_UNREACHABLE, IP_DEST_HOST_UNREACHABLE, IP_DEST_PROT_UNREACHABLE, IP_DEST_PORT_UNREACHABLE, IP_REQ_TIMED_OUT
    {
        VarSetCapacity(Result,0)
        Return, -1
    }
    If NumGet(Reply,4,"UInt") != 0 ;IP_SUCCESS
        throw Exception("Could not send echo.")

    ResultLength := NumGet(Reply,12,"UShort")
    VarSetCapacity(Result,ResultLength)
    DllCall("RtlMoveMemory","UPtr",&Result,"UPtr",NumGet(Reply,16),"UPtr",ResultLength)
    Return, NumGet(Reply,8,"UInt")
}

PingAsync(Address,Timeout = 800,ByRef Data = "",Length = 0,ByRef Result = "",ByRef ResultLength = 0)
{
    If DllCall("LoadLibrary","Str","ws2_32","UPtr") = 0 ;NULL
        throw Exception("Could not load WinSock 2 library.")
    If DllCall("LoadLibrary","Str","icmp","UPtr") = 0 ;NULL
        throw Exception("Could not load ICMP library.")

    hPort := DllCall("icmp\IcmpCreateFile","UPtr") ;open port
    If hPort = -1 ;INVALID_HANDLE_VALUE
        throw Exception("Could not open port.")

    hEvent := DllCall("CreateEvent"
        ,"UPtr",0 ;security attributes structure
        ,"UInt",True ;manual reset event
        ,"UInt",False ;initially not signalled
        ,"UPtr",0 ;event name
        ,"UPtr")
    If !hEvent
    {
        DllCall("icmp\IcmpCloseHandle","UInt",hPort) ;close port
        throw Exception("Could not create event.")
    }

    NumericAddress := DllCall("ws2_32\inet_addr","AStr",Address,"UInt")
    If NumericAddress = 0xFFFFFFFF ;INADDR_NONE
        throw Exception("Could not convert IP address string to numeric format.")

    StructLength := 250 + 20 + (A_PtrSize * 2) ;ICMP_ECHO_REPLY structure
    VarSetCapacity(Reply,StructLength)
    DllCall("icmp\IcmpSendEcho2"
        ,"UPtr",hPort ;ICMP handle
        ,"UPtr",hEvent ;event handle
        ,"UPtr",0 ;APC routine handle
        ,"UPtr",0 ;APC routine context
        ,"UInt",NumericAddress ;IP address
        ,"UPtr",&Data ;request data
        ,"UShort",Length ;length of request data
        ,"UPtr",0 ;pointer to IP options structure
        ,"UPtr",&Reply ;reply buffer
        ,"UInt",StructLength ;length of reply buffer
        ,"UInt",Timeout) ;ping timeout
    If A_LastError != 0x3E5 ;ERROR_IO_PENDING
    {
        DllCall("CloseHandle","UPtr",hEvent) ;close event
        DllCall("icmp\IcmpCloseHandle","UInt",hPort) ;close port
        throw Exception("Could not send echo.")
    }
    If DllCall("WaitForSingleObject","UPtr",hEvent,"UInt",Timeout) != 0 ;WAIT_OBJECT_0
    {
        DllCall("CloseHandle","UPtr",hEvent) ;close event
        DllCall("icmp\IcmpCloseHandle","UInt",hPort) ;close port
        throw Exception("Could not detect ping completion.")
    }
    Status := NumGet(Reply,4,"UInt")

    If Status = 11001 ;IP_BUF_TOO_SMALL
    {
        StructLength *= Count
        VarSetCapacity(Reply,StructLength)
        DllCall("icmp\IcmpSendEcho"
            ,"UPtr",hPort ;ICMP handle
            ,"UInt",NumericAddress ;IP address
            ,"UPtr",&Data ;request data
            ,"UShort",Length ;length of request data
            ,"UPtr",0 ;pointer to IP options structure
            ,"UPtr",&Reply ;reply buffer
            ,"UInt",StructLength ;length of reply buffer
            ,"UInt",Timeout) ;ping timeout
        If A_LastError != 0x3E5 ;ERROR_IO_PENDING
        {
            DllCall("CloseHandle","UPtr",hEvent) ;close event
            DllCall("icmp\IcmpCloseHandle","UInt",hPort) ;close port
            throw Exception("Could not send echo.")
        }
        If DllCall("WaitForSingleObject","UPtr",hEvent,"UInt",Timeout) != 0 ;WAIT_OBJECT_0
        {
            DllCall("CloseHandle","UPtr",hEvent) ;close event
            DllCall("icmp\IcmpCloseHandle","UInt",hPort) ;close port
            throw Exception("Could not detect ping completion.")
        }
        Status := NumGet(Reply,4,"UInt")
    }

    If !DllCall("CloseHandle","UPtr",hEvent) ;close event
        throw Exception("Could not close event.")
    If !DllCall("icmp\IcmpCloseHandle","UInt",hPort) ;close port
        throw Exception("Could not close port.")

    If Status In 11002,11003,11004,11005,11010 ;IP_DEST_NET_UNREACHABLE, IP_DEST_HOST_UNREACHABLE, IP_DEST_PROT_UNREACHABLE, IP_DEST_PORT_UNREACHABLE, IP_REQ_TIMED_OUT
    {
        VarSetCapacity(Result,0)
        Return, -1
    }
    If Status != 0 ;IP_SUCCESS
        throw Exception("Could not retrieve echo response.")

    ResultLength := NumGet(Reply,12,"UShort")
    VarSetCapacity(Result,ResultLength)
    DllCall("RtlMoveMemory","UPtr",&Result,"UPtr",NumGet(Reply,16),"UPtr",ResultLength)

    Return, NumGet(Reply,8,"UInt")
}

RoundTripTime(Address,Timeout = 800)
{
    If DllCall("LoadLibrary","Str","ws2_32","UPtr") = 0 ;NULL
        throw Exception("Could not load WinSock 2 library.")
    If DllCall("LoadLibrary","Str","icmp","UPtr") = 0 ;NULL
        throw Exception("Could not load ICMP library.")

    NumericAddress := DllCall("ws2_32\inet_addr","AStr",Address,"UInt")
    If NumericAddress = 0xFFFFFFFF ;INADDR_NONE
        throw Exception("Could not convert IP address string to numeric format.")

    hPort := DllCall("icmp\IcmpCreateFile","UPtr") ;open port
    If hPort = -1 ;INVALID_HANDLE_VALUE
        throw Exception("Could not open port.")

    StructLength := 270 + (A_PtrSize * 2) ;ICMP_ECHO_REPLY structure
    VarSetCapacity(Reply,StructLength)
    Count := DllCall("icmp\IcmpSendEcho"
        ,"UPtr",hPort ;ICMP handle
        ,"UInt",NumericAddress ;IP address
        ,"Str","" ;request data
        ,"UShort",0 ;length of request data
        ,"UPtr",0 ;pointer to IP options structure
        ,"UPtr",&Reply ;reply buffer
        ,"UInt",StructLength ;length of reply buffer
        ,"UInt",Timeout) ;ping timeout

    If !DllCall("icmp\IcmpCloseHandle","UInt",hPort) ;close port
        throw Exception("Could not close port.")

    Status := NumGet(Reply,4,"UInt")
    If Status In 11002,11003,11004,11005,11010 ;IP_DEST_NET_UNREACHABLE, IP_DEST_HOST_UNREACHABLE, IP_DEST_PROT_UNREACHABLE, IP_DEST_PORT_UNREACHABLE, IP_REQ_TIMED_OUT
    {
        VarSetCapacity(Result,0)
        Return, -1
    }
    If Status != 0 ;IP_SUCCESS
        throw Exception("Could not send echo.")

    Return, NumGet(Reply,8,"UInt")
}

RoundTripTimeList(AddressList,Timeout = 800)
{
    Count := AddressList.MaxIndex()
    If Count > 64 ;MAXIMUM_WAIT_OBJECTS
        throw Exception("Could not send over 64 requests.")

    If DllCall("LoadLibrary","Str","ws2_32","UPtr") = 0 ;NULL
        throw Exception("Could not load WinSock library.")
    If DllCall("LoadLibrary","Str","icmp","UPtr") = 0 ;NULL
        throw Exception("Could not load ICMP library.")

    hPort := DllCall("icmp\IcmpCreateFile","UPtr") ;open port
    If hPort = -1 ;INVALID_HANDLE_VALUE
        throw Exception("Could not open port.")

    Replies := []
    Result := []

    StructLength := 250 + 20 + (A_PtrSize * 2) ;ICMP_ECHO_REPLY structure
    VarSetCapacity(Events,Count * A_PtrSize)
    For Index, Address In AddressList
    {
        NumericAddress := DllCall("ws2_32\inet_addr","AStr",Address,"UInt")
        If NumericAddress = 0xFFFFFFFF ;INADDR_NONE
            throw Exception("Could not convert IP address string to numeric format.")

        hEvent := DllCall("CreateEvent"
            ,"UPtr",0 ;security attributes structure
            ,"UInt",True ;manual reset event
            ,"UInt",False ;initially not signalled
            ,"UPtr",0 ;event name
            ,"UPtr")
        If !hEvent
            throw Exception("Could not create event.")
        NumPut(hEvent,Events,(Index - 1) * A_PtrSize)

        Replies.SetCapacity(Index,StructLength)
        DllCall("icmp\IcmpSendEcho2"
            ,"UPtr",hPort ;ICMP handle
            ,"UPtr",hEvent ;event handle
            ,"UPtr",0 ;APC routine handle
            ,"UPtr",0 ;APC routine context
            ,"UInt",NumericAddress ;IP address
            ,"Str","" ;request data
            ,"UShort",0 ;length of request data
            ,"UPtr",0 ;pointer to IP options structure
            ,"UPtr",Replies.GetAddress(Index) ;reply buffer
            ,"UInt",StructLength ;length of reply buffer
            ,"UInt",Timeout) ;ping timeout
        If A_LastError != 0x3E5 ;ERROR_IO_PENDING
            throw Exception("Could not send echo.")
    }

    While, Replies.MaxIndex()
    {
        Index := DllCall("WaitForMultipleObjects","UInt",Count,"UPtr",&Events,"UInt",False,"UInt",Timeout * 2)
        If (Index < 0 || Index >= Count) ;WAIT_OBJECT_0, WAIT_OBJECT_0 + Count - 1
            throw Exception("Could not detect ping completions." . Index . " " . A_LastError)

        If !DllCall("ResetEvent","UPtr",NumGet(Events,Index * A_PtrSize)) ;reset event to nonsignalled state
            throw Exception("Could not reset ping event.")

        Index ++ ;zero based index to one based
        Status := NumGet(Replies.GetAddress(Index),4,"UInt")
        If Status In 11002,11003,11004,11005,11010 ;IP_DEST_NET_UNREACHABLE, IP_DEST_HOST_UNREACHABLE, IP_DEST_PROT_UNREACHABLE, IP_DEST_PORT_UNREACHABLE, IP_REQ_TIMED_OUT
            Result[Index] := -1
        Else If Status = 0 ;IP_SUCCESS
            Result[Index] := NumGet(Replies.GetAddress(Index),8,"UInt") ;obtain round trip time
        Else
            throw Exception("Could not retrieve echo response." . Status)
        Replies.Remove(Index,"") ;remove reply entry to signify ping completion
    }

    Loop, %Count%
    {
        If !DllCall("CloseHandle","UPtr",NumGet(Events,(A_Index - 1) * A_PtrSize)) ;close event
            throw Exception("Could not close event.")
    }
    If !DllCall("icmp\IcmpCloseHandle","UInt",hPort) ;close port
        throw Exception("Could not close port.")

    Return, Result
}