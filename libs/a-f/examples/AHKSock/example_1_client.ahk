/*! TheGood
    AHKsock - A simple AHK implementation of Winsock.
    AHKsock Example 1 - Simple Scenario
    http://www.autohotkey.com/forum/viewtopic.php?p=355775
    Last updated: August 24th, 2010
    
    In this simple scenario:
        1.  First, the server starts listening for clients on port 27015.
        2.  As soon as the client is started, it attempts to connect to the server.
        3.  As soon as the connection is established, the CONNECTED/ACCEPTED event is fired on both client and server.
        4.  Once the server receives the SEND event, it will send some binary data to the client.
        5.  Once the binary data is successfully sent, the server will initiate shutdown.
        6.  The client receives a RECEIVED event with the data sent by the server.
        7.  As soon as the client receives the DISCONNECT event, it exits.
        8.  The server receives a DISCONNECT event as well, meaning that shutdown is complete.
        9.  The server goes back to listening for clients on port 27015.
        10. The client can be started up again to have the same process repeat.
    
    This example does not have a GUI, but uses OutputDebug to output its data. See the command's docs for more details.
    If the server isn't running on the same computer, change sServer to the IP address or hostname of the server.
*/
    ;Needed if AHKsock isn't in one of your lib folders
    ;#Include %A_ScriptDir%\AHKsock.ahk
    
    ;Allow multiple instances. This is to allow you to stress-test the server. For more info on how to perform the
    ;stress-test, see second comment block in the ACCEPTED event of the Send() function in the server script.
    #SingleInstance, Off
    
    ;Contains the IP address or hostname of the server we will connect to
    sServer := "localhost"
    
    ;Register OnExit subroutine so that AHKsock_Close is called before exit
    OnExit, CloseAHKsock
    
    ;Add menu item for exiting gracefully (see comment block in CloseAHKsock)
    Menu, Tray, Add
    Menu, Tray, Add, Exit Gracefully, CloseAHKsock
    
    ;Set up an error handler (this is optional)
    AHKsock_ErrorHandler("AHKsockErrors")
    
    ;Connect on this computer on port 27015
    If (i := AHKsock_Connect(sServer, 27015, "Recv")) {
        OutputDebug, % "AHKsock_Connect() failed with return value = " i " and ErrorLevel = " ErrorLevel
        ExitApp
    }
Return

CloseAHKsock:
    /*! If the user selects the "Exit" menu item from the tray menu, this sub will execute once, i.e. as the OnExit sub. In
    this situation, if we're still connected to the server, we will have no way of gracefully shutting down the connection.
    
    But if the user selects the "Exit Gracefully" menu item that we added at startup, this sub will execute twice: once as
    the label of the menu item, and once more right after as the OnExit sub (since ExitApp is called at the end of the sub).
    Therefore, during the first execution of those two, since the thread will be interruptible, calling AHKsock_Close will
    gracefully shutdown the connection. Note that the second call to AHKsock_Close during the OnExit sub then becomes
    useless by redundancy, but harmless (so there's no need to ensure that it is only called during the first of the two
    executions).
    
    If this application had a GUI, we could instead execute a graceful shutdown on the GuiClose event, as done in other
    AHKsock examples. Here, we have to rely on the tray menu because it is the only way for the user to exit while still
    being able to gracefully shutdown.
    
    Note however that in this example, the server shuts down the client as soon as it is done sending data to it (see the
    server's SEND event of the Send() function). Therefore, the conversation between server and client is very short. This
    means that when the user decides to exit the application, chances are, we are no longer connected to the server, and on
    our way to exiting anyway.
    
    However, if we want to guarantee a graceful shutdown, we must still be safe and consider the slim possibility that the
    user wants to exit before we are done receiving all the data from the server. This is why we are doing this here. This
    possibility can be much larger in applications that have longer conversations (or applications that stay connected until
    the user exits, like in AHKsock Example 3).
    
    See the section "NOTES ON CLOSING SOCKETS AND AHKsock_Close" in the documentation for more information on performing
    graceful shutdown.
    */
    AHKsock_Close()
ExitApp

Recv(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, iLength = 0) {
    
    If (sEvent = "CONNECTED") {
        
        ;Check if the connection attempt was succesful
        If (iSocket = -1) {
            OutputDebug, % "Client - AHKsock_Connect() failed. Exiting..."
            ExitApp
        } Else OutputDebug, % "Client - AHKsock_Connect() successfully connected!"
        
    } Else If (sEvent = "DISCONNECTED") {
        
        OutputDebug, % "Client - The server closed the connection. Exiting..."
        ExitApp
        
    } Else If (sEvent = "RECEIVED") {
        
        ;We received data. Output it.
        OutputDebug, % "Client - We received " iLength " bytes."
        OutputDebug, % "Client - Data: " Bin2Hex(&bData, iLength)
    }
}

;We're not actually handling errors here. This is here just to make us aware of errors if any do come up.
AHKsockErrors(iError, iSocket) {
    OutputDebug, % "Client - Error " iError " with error code = " ErrorLevel ((iSocket <> -1) ? " on socket " iSocket : "")
}

;By Laszlo, adapted by TheGood
;http://www.autohotkey.com/forum/viewtopic.php?p=377086#377086
Bin2Hex(addr,len) {
    Static fun, ptr 
    If (fun = "") {
        If A_IsUnicode
            If (A_PtrSize = 8)
                h=4533c94c8bd14585c07e63458bd86690440fb60248ffc2418bc9410fb6c0c0e8043c090fb6c00f97c14180e00f66f7d96683e1076603c8410fb6c06683c1304180f8096641890a418bc90f97c166f7d94983c2046683e1076603c86683c13049ffcb6641894afe75a76645890ac366448909c3
            Else h=558B6C241085ED7E5F568B74240C578B7C24148A078AC8C0E90447BA090000003AD11BD2F7DA66F7DA0FB6C96683E2076603D16683C230668916240FB2093AD01BC9F7D966F7D96683E1070FB6D06603CA6683C13066894E0283C6044D75B433C05F6689065E5DC38B54240833C966890A5DC3
        Else h=558B6C241085ED7E45568B74240C578B7C24148A078AC8C0E9044780F9090F97C2F6DA80E20702D1240F80C2303C090F97C1F6D980E10702C880C1308816884E0183C6024D75CC5FC606005E5DC38B542408C602005DC3
        VarSetCapacity(fun, StrLen(h) // 2)
        Loop % StrLen(h) // 2
            NumPut("0x" . SubStr(h, 2 * A_Index - 1, 2), fun, A_Index - 1, "Char")
        ptr := A_PtrSize ? "Ptr" : "UInt"
        DllCall("VirtualProtect", ptr, &fun, ptr, VarSetCapacity(fun), "UInt", 0x40, "UInt*", 0)
    }
    VarSetCapacity(hex, A_IsUnicode ? 4 * len + 2 : 2 * len + 1)
    DllCall(&fun, ptr, &hex, ptr, addr, "UInt", len, "CDecl")
    VarSetCapacity(hex, -1) ; update StrLen
    Return hex
}
