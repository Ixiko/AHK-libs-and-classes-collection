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
    
    ;Register OnExit subroutine so that AHKsock_Close is called before exit
    OnExit, CloseAHKsock
    
    ;Add menu item for exiting gracefully (see comment block in CloseAHKsock)
    Menu, Tray, Add
    Menu, Tray, Add, Exit Gracefully, CloseAHKsock
    
    ;Set up an error handler (this is optional)
    AHKsock_ErrorHandler("AHKsockErrors")
    
    ;Create the binary data which will be sent to any client that connects.
    ;It is just an example; you can change it if you want.
    VarSetCapacity(bData, bDataLength := 10, 0xFF)
    
    ;Listen on port 27015
    If (i := AHKsock_Listen(27015, "Send")) {
        OutputDebug, % "AHKsock_Listen() failed with return value = " i " and ErrorLevel = " ErrorLevel
        ExitApp
    }
Return

CloseAHKsock:
    /*! If the user selects the "Exit" menu item from the tray menu, this sub will execute once, i.e. as the OnExit sub. In
    this situation, if a client is still connected, we will have no way of gracefully shutting down the connection.
    
    But if the user selects the "Exit Gracefully" menu item that we added at startup, this sub will execute twice: once as
    the label of the menu item, and once more right after as the OnExit sub (since ExitApp is called at the end of the sub).
    Therefore, during the first execution of those two, since the thread will be interruptible, calling AHKsock_Close will
    gracefully shutdown any client connected. Note that the second call to AHKsock_Close during the OnExit sub then becomes
    useless by redundancy, but harmless (so there's no need to ensure that it is only called during the first of the two
    executions).
    
    If this application had a GUI, we could instead execute a graceful shutdown on the GuiClose event, as done in other
    AHKsock examples. Here, we have to rely on the tray menu because it is the only way for the user to exit while still
    being able to gracefully shutdown.
    
    Note however that in this example, the server shuts down the client as soon as it is done sending data to it (see the
    server's SEND event of the Send() function). Therefore, the conversation between server and client is very short. This
    means that when the user decides to exit the application, chances are, there are no clients connected, and thus, no
    sockets to gracefully close.
    
    However, if we want to guarantee a graceful shutdown, we must still be safe and consider the slim possibility that the
    user wants to exit before we are done sending all the data to a connected client and closing the connection. This is why
    we are doing this here. This possibility can be much larger in applications that have longer conversations (or
    applications that stay connected until the user exits, like in AHKsock Example 3).
    
    See the section "NOTES ON CLOSING SOCKETS AND AHKsock_Close" in the documentation for more information on performing
    graceful shutdown.
    */
    AHKsock_Close() 
ExitApp

Send(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bRecvData = 0, bRecvDataLength = 0) {
    Global bData, bDataLength
    Static bDataSent, bConnected
    
    If (sEvent = "ACCEPTED") {
        OutputDebug, % "Server - A client connected!"
        
        /*! We need to check if we are already connected to another client because we can't handle more than one client at a
        time. This is because the static variable bDataSent only represents the data sending progress of one client. See the
        comment block in the SEND event for more information.
        
        To handle multiple clients, we would need a way of keeping track of how much of the data has already been sent to
        each individual client. For an example of this, see the "Multiple Clients" server of AHKsock Example 2.
        */
        
        /* Check if we're already connected. Because the conversation is so fast, this will only happen when a lot of
        clients try to connect at the same time. You can witness this by launching the client script multiple times as
        quickly as possible (e.g. hold down the Enter key while selecting the file in Explorer). Hold on for long enough and
        you'll eventually see the OutputDebug below in the log.
        */
        If bConnected {
            OutputDebug, % "Server - Disconnected new client because we are still serving a previous client."
            AHKsock_Close(iSocket)
            
        ;If we weren't connected before, we are now!
        } Else bConnected := True
        
    } Else If (sEvent = "DISCONNECTED") {
        OutputDebug, % "Server - The client disconnected. Going back to listening..."
        bConnected := False
        
    } Else If (sEvent = "SEND") {
        
        /*! Now we need to send the data. Since here we only need to send 10 bytes, the first AHKsock_Send called will
        probably successfully send all the data. This may not be the case the larger the amount of data to send. Therefore,
        we must always, no matter how long the data, be prepared to handle cases where:
            1. We receive WSAEWOULDBLOCK (i.e. we get -2 from AHKsock_Send).
            2. We were only able to send part of the data.
        
        To handle these two possible cases, we use a loop and an offset method. Everytime AHKsock_Send is called, we check
        how much data was able to go through. If all of it went through, we can exit the loop. If only part of it went
        through, we adjust the offset so that when we call AHKsock_Send on the next loop iteration, it will try to send only
        the data after what was previously successfully sent. Therefore, the variable bDataSent simply contains the number
        of bytes that were successfully sent so far.
        
        If we get WSAEWOULDBLOCK, we simply exit and wait for the next SEND event. Once we receive the event, we continue
        sending from where we left off by using the offset. This is why bDataSent must be made static.
        */
        
        bDataSent := 0
        Loop {
            
            ;Try to send the data
            If ((i := AHKsock_Send(iSocket, &bData + bDataSent, bDataLength - bDataSent)) < 0) {
                
                ;Check if we received WSAEWOULDBLOCK.
                If (i = -2) {
                    ;That's ok. We can leave and we'll keep sending from
                    ;where we left off the next time we get the SEND event.
                    Return
                    
                ;Something bad has happened with AHKsock_Send
                } Else OutputDebug, % "Server - AHKsock_Send failed with return value = " i " and ErrorLevel = " ErrorLevel
                
            ;We were able to send bytes!
            } Else OutputDebug, % "Server - Sent " i " bytes!"
            
            ;Check if everything was sent
            If (i < bDataLength - bDataSent)
                bDataSent += i ;Advance the offset so that at the next iteration, we'll start sending from where we left off
            Else Break ;We're done
        }
        
        ;Reset the static variable
        bDataSent := 0
        
        OutputDebug, % "Server - Closing the client connection now..."
        If (i := AHKsock_Close(iSocket))
            OutputDebug, % "Server - The shutdown() call failed. ErrorLevel = " ErrorLevel
        
        ;Reset the connection status so that we can accept new clients.
        ;We don't need to actually wait for the client we just served to disconnect because as long as we are done sending
        ;data to it, we can use the bDataSent variable to track the data sending progress with another client!
        bConnected := False
    }
}

;We're not actually handling errors here. This is here just to make us aware of errors if any do come up.
AHKsockErrors(iError, iSocket) {
    OutputDebug, % "Server - Error " iError " with error code = " ErrorLevel ((iSocket <> -1) ? " on socket " iSocket : "")
}
