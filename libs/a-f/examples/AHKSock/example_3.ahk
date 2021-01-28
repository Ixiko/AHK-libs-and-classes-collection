/*! TheGood
    AHKsock - A simple AHK implementation of Winsock.
    AHKsock Example 3 - Chatting
    http://www.autohotkey.com/forum/viewtopic.php?p=355775
    Last updated: August 24th, 2010
    
    In this example, the two programs exchange messages with each other. There are no predefined server and client here. If
    the first instance can't seem to connect to the peer, it'll start listening for a peer. Then, once the second instance
    is started and given the address of the first peer, a connection is established and chatting may begin.
    
    This is the flow of execution:
        1. When started, an InputBox asks the user for the peer's address.
        2. An attempt to connect to the given address on port 27015 is then made.
        3. a> If the connect attempt fails, the program starts listening on port 27015 for a peer. Once a peer connects on
              port 27015, a connection is established.
           b> If the connect attempt succeeds, a connection is established.
        4. Once the program receives the CONNECTED event, the Edit control is enabled to allow input.
        5. As the user types text and sends it, the program sends the data to the connected peer using AHKsock_ForceSend.
        6. When one of the peer exits, the connection is closed.
        7. Once the remaining peer receives the DISCONNECTED event, it disables the Edit control and starts listening for
           another peer.
    
    As you can see from the flow of execution, the first peer to start up will always fail to connect because the second
    peer hasn't been started yet. Once the second peer is started, it attempts to connect to the first peer, and a
    connection is thus established.
    
    This example uses OutputDebug to output its log (e.g. errors). See the command's docs for more details.
*/
    ;We'll need to allow more than one instance to test it on the same machine
    #SingleInstance, Off
    
    ;Needed if AHKsock isn't in one of your lib folders
    ;#Include %A_ScriptDir%\AHKsock.ahk
    
    ;Set up an error handler (this is optional)
    AHKsock_ErrorHandler("AHKsockErrors")
    
    ;Set up an OnExit routine
    OnExit, GuiClose
    
    ;Set default value to invalid handle
    iPeerSocket := -1
    
    ;Set up the GUI
    Gui, +Resize +OwnDialogs
    Gui, Add, Edit, r10 w300 vtxtDialog ReadOnly hwndhtxtDialog
    
    /*! Limit the edit control text length to 65535 because that's the maximum length we can express with the stream
    processing we use here, because the string's length must fit in the low-word of a 32-bit integer. See the comment block
    in the StreamProcessor function for more details
    */
    Gui, Add, Edit, xm w250 vtxtInput hwndhtxtInput ReadOnly gtxtInput Limit65535
    Gui, Add, Button, x+5 w45 hp vbtnSend hwndhbtnSend Default Disabled gbtnSend, Send
    Gui, Add, Text, xm w300 vlblStatus hwndhlblStatus, Not connected...
    Gui, +MinSize
    Gui, Show
    
    ;Ask for peer address
    InputBox, sName, Peer hostname or IP address, Please enter your peer's hostname or IP address:,,, 100,,,,, localhost
    If ErrorLevel
        ExitApp
    
    ;Try to connect
    GuiControl,, lblStatus, Trying to connect to %sName%... ;Update status
    If (i := AHKsock_Connect(sName, 27015, "Peer"))
        OutputDebug, % "AHKsock_Connect() failed with return value = " i " and ErrorLevel = " ErrorLevel
    
    /*! While the connection is attempted, we should start listening for peers. The reason we should start listening before
    the connect operation is over is because otherwise, the second client to start might not be able to connect to its peer
    if it (the peer) is still waiting for the connect operation to finish, and is thus not listening for connections yet.
    
    The only time we shouldn't start listening before the connection attempt is over is if we're trying to connect on the
    same machine. Otherwise, the listening socket we would create would accept the client socket we created inside the same
    script. In other words, the script would be connected to itself.
    */
    
    /*! We need to find out if the target computer is the same machine. The method used below will cover most common ways to
    connect to the same machine, but it is not foolproof. For example, if the computer is on a LAN and port 27015 is
    forwarded to this machine, then connecting on the router's address will not be seen as the same machine, which would
    result in the script connecting to itself. However, because of the fail-safes we have in place, the connection will be
    immediately closed as soon as it is established (see the comment block in the ACCEPTED event in the Peer() function).
    */
    
    ;First we have to translate sName to an IP address if it is not already one (AHKsock_GetAddrInfo would return the same
    ;IP address if sName is already an IP). Note that here, we do not do any error-checking because if AHKsock_Connect
    ;accepted sName with no error, then AHKsock_GetAddrInfo will work fine as well.
    AHKsock_GetAddrInfo(sName, sConnectIP, True)
    
    ;Then, we also get the IP address of the computer
    AHKsock_GetAddrInfo(A_ComputerName, sComputerIP, True)
    
    /*! The connection attempt is to same machine if
        - the target IP is the loopback address, or
        - the target IP is the computer's IP
    */
    bSameMachine := (sConnectIP = "127.0.0.1") Or (sConnectIP = sComputerIP)
    
    ;Only start listening if we're not trying to connect to the same machine
    If Not bSameMachine And (i := AHKsock_Listen(27015, "Peer")) {
        OutputDebug, % "AHKsock_Listen() failed with return value = " i " and ErrorLevel = " ErrorLevel
        bCantListen := True ;So that if the connect() attempt fails, we exit.
    }
Return

GuiSize:
    Anchor(htxtDialog, "wh")
    Anchor(htxtInput, "wy")
    Anchor(hbtnSend, "xy")
    Anchor(hlblStatus, "wy", 1)
Return

GuiEscape:
GuiClose:
    
    ;So that we don't go back to listening on disconnect
    bExiting := True
    
    /*! If the GUI is closed, this function will be called twice:
        - Once non-critically when the GUI event fires (GuiEscape or GuiClose) (graceful shutdown will occur), and
        - Once more critically during the OnExit sub (after the previous GUI event calls ExitApp)
        
        But if the application is exited using the Exit item in the tray's menu, graceful shutdown will be impossible
        because AHKsock_Close() will only be called once critically during the OnExit sub.
    */
    AHKsock_Close()
ExitApp

txtInput:
    
    /*! This GUI event will be called everytime the text in the Edit control changes. The idea is to send a notification to
    the peer when the user starts/stops typing. We do this using the typing update frame. See the StreamProcessor function
    for more information on frames.
    */
    
    ;Check if we're connected
    If (iPeerSocket = -1)
        Return
    
    ;Get text entered, if any
    GuiControlGet, sText,, txtInput
    
    ;Create a boolean value
    bTypingUpdate := sText <> ""
    
    ;Send a typing update frame only if the boolean value is different from the last one we sent. We do this check so that
    ;we don't drown the peer with updates everytime the user types an additional character in the Edit control box.
    If (bTypingUpdate = bLastTypingUpdate)
        Return
    
    /*! It is more appropriate to use AHKsock_ForceSend here because the thread is not critical, and because the amount of
    data to send is very small. We thus don't have to worry about the function taking time to return.
    */
    
    ;Send a typing update frame: high-word is 1, low-word is a boolean value (False = 0, True = 1)
    VarSetCapacity(iFrame, 4, 0), NumPut((1 << 16) + bTypingUpdate, iFrame, 0, "UInt")
    If (i := AHKsock_ForceSend(iPeerSocket, &iFrame, 4)) {
        OutputDebug, % "AHKsock_ForceSend failed with return value = " i " and error code = " ErrorLevel " at line " A_LineNumber
        ExitApp
    }
    
    ;Remember the boolean value of the typing update frame we just sent
    bLastTypingUpdate := sText ? 1 : 0
    
Return

btnSend:
    
    /*! This GUI event will be called everytime the user clicks on the Send button, or when he presses the Enter key after
    typing text in the Edit control. The logic is rather straight-forward. We first send a string length frame to tell the
    peer how long the string coming will be, and we then send the string. See the StreamProcessor function for more
    information on frames.
    */
    
    ;Check if we're connected
    If (iPeerSocket = -1)
        Return
    
    ;Get the text to send
    GuiControlGet, sText,, txtInput
    
    ;Make sure we even have something to send
    If Not sText
        Return
    
    ;Get text length
    iTextLength := StrLen(sText) * 2
    
    ;First send a string length frame: high-word is 2, low-word is the length of the string
    VarSetCapacity(iFrame, 4, 0), NumPut((2 << 16) + iTextLength, iFrame, 0, "UInt")
    If (i := AHKsock_ForceSend(iPeerSocket, &iFrame, 4)) {
        OutputDebug, % "AHKsock_ForceSend failed with return value = " i " and error code = " ErrorLevel " at line " A_LineNumber
        ExitApp
    }
    
    ;Send the actual string now, excluding the null terminator
    If (i := AHKsock_ForceSend(iPeerSocket, &sText, iTextLength)) {
        OutputDebug, % "AHKsock_ForceSend failed with return value = " i " and error code = " ErrorLevel " at line " A_LineNumber
        ExitApp
    }
    
    ;Data was sent. Add it to the dialog.
    AddDialog(&sText)
    
    ;Clear the Edit control and give focus
    GuiControl,, txtInput
    GuiControl, Focus, txtInput
    
Return

AddDialog(ptrText, bYou = True) {
    Global htxtDialog
    
    ;Append the interlocutor
    sAppend := bYou ? "You > " : "Peer > "
    InsertText(htxtDialog, &sAppend)
    
    ;Append the new text
    InsertText(htxtDialog, ptrText)
    
    ;Append a new line
    sAppend := "`r`n"
    InsertText(htxtDialog, &sAppend)
    
    ;Scroll to bottom
    SendMessage, 0x0115, 7, 0,, ahk_id %htxtDialog% ;WM_VSCROLL
}

Peer(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, bDataLength = 0) {
    Global iPeerSocket, bExiting, bSameMachine, bCantListen
    Static iIgnoreDisconnect
    
    If (sEvent = "ACCEPTED") {
        OutputDebug, % "A client with IP " sAddr " connected!"
        
        ;We now have an established connection with a peer
        
        /*! As a fail-safe, we need to make sure that AHKsock_Connect didn't also succeed (which would mean that we are
        already connected to another peer). This should (in theory) never happen because if the CONNECTED event fires before
        an ACCEPTED event, then we would stop listening (see comment block in CONNECTED event), which means that we would
        not be able to accept any other peer. Similarly, if the ACCEPTED event fires before the CONNECTED event, then it
        means that the peer has received the CONNECTED event before an ACCEPTED event, and the same logic applies. 
        
        But to be on the safe side, if somehow both an ACCEPTED and a CONNECTED event occur, the socket reported in the
        second event to occur between the two will be closed, and the other socket (which was reported in the first event)
        will be kept.
        
        This also allows us to prevent cases where the connection attempt was to the same machine, but we could not detect
        it (bSameMachine is False). In such a case, both events will fire (referring to each other's endpoint socket), which
        means that the fail-safe will close the connection when the second of the two events fire.
        */
        If (iPeerSocket <> -1) {
            OutputDebug, % "We already have a peer! Disconnecting..."
            AHKsock_Close(iSocket) ;Close the socket
            iIgnoreDisconnect += 1 ;So that we don't react when this peer disconnects
            Return
        }
        
        ;Remember the socket
        iPeerSocket := iSocket
        
        ;Stop listening (see comment block in CONNECTED event)
        AHKsock_Listen(27015)
        
        ;Allow input and set focus
        GuiControl, Enable, btnSend
        GuiControl, -ReadOnly, txtInput
        GuiControl, Focus, txtInput
        
        ;Update status
        GuiControl,, lblStatus, Connected to %sAddr%!
        
    } If (sEvent = "CONNECTED") {
        
        ;Check if the connection attempt was successful
        If (iSocket = -1) {
            OutputDebug, % "AHKsock_Connect() failed."
            
            ;Check if we are not currently listening, and if we already tried to listen and failed.
            If bCantListen
                ExitApp
            
            OutputDebug, % "Listening for a peer..."
            GuiControl,, lblStatus, Waiting for a peer... ;Update status
            
            ;If the connection attempt was on this computer, we can start listening now since the connect attempt is
            ;over and we thus run no risk of ending up connected to ourselves. 
            If bSameMachine {
                If (i := AHKsock_Listen(27015, "Peer")) {
                    OutputDebug, % "AHKsock_Listen() failed with return value = " i " and ErrorLevel = " ErrorLevel
                    ExitApp
                }
            }
            
            ;The connect attempt failed, but we are now listening for clients. We can leave now.
            Return
            
        } Else OutputDebug, % "AHKsock_Connect() successfully connected on IP " sAddr "."
        
        ;We now have an established connection with a peer
        
        ;This is the same fail-safe as in the ACCEPTED event (see comment block there)
        If (iPeerSocket <> -1) {
            OutputDebug, % "We already have a peer! Disconnecting..."
            AHKsock_Close(iSocket) ;Close the socket
            iIgnoreDisconnect += 1 ;So that we don't react when this peer disconnects
            Return
        }
        
        ;Remember the socket
        iPeerSocket := iSocket
        
        /*! We can stop listening now, because we don't want to have more than one peer connnected to us. Note that it's
        possible that we are not even listening anyways (for example, if the connect attempt succeeded, but we weren't
        listening because it's on the same machine). In such a case, calling AHKsock_Listen to stop listening is useless but
        harmless. Therefore, there's no point in checking if we're actually listening before stopping.
        */
        AHKsock_Listen(27015)
        
        ;Allow input and set focus
        GuiControl, Enable, btnSend
        GuiControl, -ReadOnly, txtInput
        GuiControl, Focus, txtInput
        
        ;Update status
        GuiControl,, lblStatus, Connected to %sName%!
        
    } Else If (sEvent = "DISCONNECTED") {
        
        ;Check if we're supposed to ignore this event
        If iIgnoreDisconnect {
            iIgnoreDisconnect -= 1
            Return
        }
        
        ;Reset variable
        iPeerSocket := -1
        
        ;Delete any past data the stream processor had stored
        StreamProcessor()
        
        ;We should go back to listening (unless we're in the process of leaving)
        If Not bExiting {
            
            OutputDebug, % "The peer disconnected! Going back to listening..."
            
            GuiControl,, lblStatus, Waiting for a peer... ;Update status
            If (i := AHKsock_Listen(27015, "Peer")) {
                OutputDebug, % "AHKsock_Listen() failed with return value = " i " and ErrorLevel = " ErrorLevel
                ExitApp
            }
            
            ;Disable input and clear textbox
            GuiControl, Disable, btnSend
            GuiControl, +ReadOnly, txtInput
            GuiControl,, txtInput
            
        } Else OutputDebug, % "The peer disconnected! Exiting..."
        
    } Else If (sEvent = "RECEIVED") {
        
        ;OutputDebug, % "Received " bDataLength " bytes" ;FOR DEBUGGING PURPOSES ONLY
        ;OutputDebug, % "bData = " MCode_Bin2Hex(&bData, bDataLength) ;FOR DEBUGGING PURPOSES ONLY
        
        ;Send to the stream processor
        StreamProcessor(bData, bDataLength)
    }
}

/*! The StreamProcessor is, in abstract terms, a function that receives as input the data from RECEIVE events, and that
    outputs and processes frames. The idea is that no matter how the data frames that the peer sends is broken up across
    RECEIVE events, the StreamProcessor will properly cut and put together the pieces into the individual frames to process.
    
    More specifically, the StreamProcessor's role is in threefold:
    - To stock up data that we received in past RECEIVE events but that could not be processed because it didn't represent
      a complete data frame.
    - To append newly arrived data to any incomplete data frame that we stocked up in past RECEIVE events.
    - To process any complete frame, whether it be from multiple past RECEIVE events, or wholly contained in the data from
      the RECEIVE event that just arrived.
    
    The static variable bPastData is the variable used to stock up data from past RECEIVE events that could not be
    processed, and the static variable bPastDataLength holds the length of bPastData.
    
    Frame are 4 bytes long. There are two types of frames:
    - Typing update (TU) frames: Updates the typing status of the peer. These frames occur when the peer starts typing in
      the Edit control, or empties the Edit control. See the code found in the txtInput label to see it made and sent.
    - String length (SL) frames: Frames that contain the length of the string that follows it. These frames occur when the
      peer sends a string of text (by pressing the Send button or the Enter key). See the code found in the btnSend label to
      see it made and sent.
*/

/*! To better understand how StreamProcessor works, imagine the following scenario (which is entirely possible, given the
    streaming nature of TCP):
        A) We first receive a RECEIVE event with 2 bytes, which is half of a TU frame.
        B) We then receive a RECEIVE event with 3 bytes, the first 2 bytes belonging to the other half of the TU frame, and
           the last 1 byte belonging to the first first byte of an SL frame.
        C) We then receive a RECEIVE event with 7 bytes, the first 3 bytes belonging to the last 3 bytes of the SL
           frame and the following 4 bytes representing the beginning of a string of 8 bytes.
        D) And finally we receive a RECEIVE event with 4 bytes, representing the end of the string.
    
    This is what would happen in the StreamProcessor after each RECEIVE event occurs (following the flow of the function):
        A) 1. There is no past data stored in bPastData to prepend.
           2. Since 2 < 4, we have less than a frame to process. We keep the 2 bytes we have in bPastData, and leave.
           
        B) 1. We prepend the 2 bytes in bPastData to the 3 bytes we just received. In total, we now have 5 bytes to process.
           2. We enter the processing loop and process the TU frame. There is 1 byte left to process. Since 1 < 4, we exit
              the While loop.
           3. We could not process the 1 byte, which is part of an incomplete frame, so we save it in bPastData and leave.
           
        C) 1. We prepend the 1 byte in bPastData to the 7 bytes we just received. In total, we now have 8 bytes to process.
           2. We enter the processing loop and try to process the SL frame. Because only part of the string is present, we
              can't process the frame. So we save all 8 bytes in bPastData and leave.
              
        D) 1. We prepend the 8 bytes in bPastData to the 4 bytes we just received.
           2. We enter the processing loop and try to process the SL frame. The whole string is present, so we add the
              string to the dialog textbox and exit the loop.
           3. There are no bytes that we could not process, so there's nothing to save in bPastData. We leave.
*/
StreamProcessor(ByRef bNewData = 0, bNewDataLength = -1) {
    Static bPastData, bPastDataLength := 0
    
    ;Check if we're just erasing any previous data we had
    If (bNewDataLength = -1) {
        If bPastDataLength { ;Check if there's data to erase
            VarSetCapacity(bPastData, 0)
            bPastDataLength := 0
        }
        
        ;OutputDebug, % "SP - Deleting any previous data" ;FOR DEBUGGING PURPOSES ONLY
        Return
    }
    
    ;Check if we have any past data to prepend before entering the processing loop
    If bPastDataLength {
        
        ;OutputDebug, % "SP - Prepending previous data of " bPastDataLength " bytes" ;FOR DEBUGGING PURPOSES ONLY
        
        ;The length of the data to process will be the length of both old and new data combined
        bDataLength := bPastDataLength + bNewDataLength
        
        ;Prep the variable which will hold both the previous data and the new data
        VarSetCapacity(bData, bDataLength)
        
        ;Copy the old data into the beginning of bData, and then the new data right after
        CopyBinData(&bPastData, &bData, bPastDataLength)
        CopyBinData(&bNewData, &bData + bPastDataLength, bNewDataLength)
        
        ;We can now delete any old data we had because we're about to process it
        VarSetCapacity(bPastData, 0) ;Clear the variable to free some memory since it won't be used
        bPastDataLength := 0 ;Reset the value
        
        ;Now bData contains the newly received data as well as any previous data that could not be fully processed before
        
        ;Set the data pointer to the new data we just created
        bDataPointer := &bData
        
        /*! The advantage of using a data pointer is so that the code that follows after can work regardless of whether
        the data to process is in bNewData (if we had nothing to prepend), or in bData (if we had to create it to
        prepend some past data). The variable bDataLength holds the length of the data to which bDataPointer points.
        */        
        
    ;Set the data pointer to the newly arrived data
    } Else bDataPointer := &bNewData, bDataLength := bNewDataLength
    
    ;Now bDataPointer points to the data to process, whether it be only the new data that arrived, or old and new data which
    ;have been concatenated. The length of the data to which bDataPointer points is in bDataLength.
    
    ;Check if we have at least one frame to process
    If (bDataLength < 4) {
        
        ;OutputDebug, % "SP - Less than a frame to process. Saving " bDataLength " bytes and leaving" ;FOR DEBUGGING PURPOSES ONLY
        
        ;We only have part of one frame. Keep what we have and leave.
        VarSetCapacity(bPastData, bPastDataLength := bDataLength)
        CopyBinData(bDataPointer, &bPastData, bDataLength)
        Return
    }
    
    ;Start processing the stream of frames
    iOffset := 0
    While (iOffset + 4 <= bDataLength) {
        
        ;Get frame type and data
        iFrame     := NumGet(bDataPointer+0, iOffset, "UInt")
        iFrameType := iFrame >> 16 ;High-word
        iFrameData := iFrame & 0xFFFF ;Low-word        
        
        /*! The type of the frame is in the high-word, and the data of the frame is in the low-word:
            - Typing update frames have a high-word of 1, and a boolean value in the low-word indicating typing status
            - String length frames have a high-word of 2, and the length of the string that follows in the low-word
        */
        
        ;Check what kind of frame it is
        If (iFrameType = 1) { ;It's a typing update frame
            GuiControl,, lblStatus, % iFrameData ? "Peer is typing..." : "Connected!" ;Update
            iOffset += 4 ;Increase the offset to be at the beginning of the next frame
        } Else If (iFrameType = 2) { ;It's a string length frame
            
            ;Check if the whole string is present
            ;We do + 4 because the string starts right after the frame we're currently processing
            If Not (iFrameData <= bDataLength - (iOffset + 4)) {
                
                ;OutputDebug, % "SP - Part of string missing. Saving " (bDataLength - iOffset) " bytes and leaving" ;FOR DEBUGGING PURPOSES ONLY
                
                ;We only have part of a string. Keep what we have (including the string length frame) and leave.
                ;We include the string length frame so that this loop will be able to handle it the next time
                ;it processes the same data but with more of the string at the end
                VarSetCapacity(bPastData, bPastDataLength := bDataLength - iOffset)
                CopyBinData(bDataPointer + iOffset, &bPastData, bDataLength - iOffset)
                Return
            }
            
            ;Increase the offset to where the string starts (right after the frame we're processing)
            iOffset += 4
            
            ;Get the string and add to dialog
            VarSetCapacity(sTextData, iFrameData + 2, 0)
            CopyBinData(bDataPointer + iOffset, &sTextData, iFrameData)
            
            ;Add the string to the dialog textbox
            AddDialog(&sTextData, False)
            
            ;Move the offset by the length of the string to be at the beginning of the next frame
            iOffset += iFrameData
        }
    }

    ;Check if there are bytes part of an incomplete frame at the end of the stream that could not be processed
    If (n := (bDataLength - iOffset)) And (n < 4) {
        
        ;OutputDebug, % "SP - Less than a frame left at the end of the stream. Saving " n " bytes and leaving" ;FOR DEBUGGING PURPOSES ONLY
        
        ;We only have part of one frame. Keep what we have and leave.
        VarSetCapacity(bPastData, bPastDataLength := n)
        CopyBinData(bDataPointer + iOffset, &bPastData, n)
        Return
    }
}

AHKsockErrors(iError, iSocket) {
    OutputDebug, % "Error " iError " with error code = " ErrorLevel ((iSocket <> -1) ? " on socket " iSocket "." : ".") 
}

CopyBinData(ptrSource, ptrDestination, iLength) {
    If iLength ;Only do it if there's anything to copy
        DllCall("RtlMoveMemory", "Ptr", ptrDestination, "Ptr", ptrSource, "UInt", iLength)
}

/*! TheGood
    Append text to an Edit control
    http://www.autohotkey.com/forum/viewtopic.php?t=56717
*/
InsertText(hEdit, ptrText, iPos = -1) {
    
    If (iPos = -1) {
        SendMessage, 0x000E, 0, 0,, ahk_id %hEdit% ;WM_GETTEXTLENGTH
        iPos := ErrorLevel
    }
    
    SendMessage, 0x00B1, iPos, iPos,, ahk_id %hEdit% ;EM_SETSEL
    SendMessage, 0x00C2, False, ptrText,, ahk_id %hEdit% ;EM_REPLACESEL
}

;Anchor by Titan, adapted by TheGood
;http://www.autohotkey.com/forum/viewtopic.php?p=377395#377395
Anchor(i, a = "", r = false) {
	static c, cs = 12, cx = 255, cl = 0, g, gs = 8, gl = 0, gpi, gw, gh, z = 0, k = 0xffff, ptr
	If z = 0
		VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), ptr := A_PtrSize ? "Ptr" : "UInt", z := true
	If (!WinExist("ahk_id" . i)) {
		GuiControlGet, t, Hwnd, %i%
		If ErrorLevel = 0
			i := t
		Else ControlGet, i, Hwnd, , %i%
	}
	VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), ptr, &gi)
		, giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
	If (gp != gpi) {
		gpi := gp
		Loop, %gl%
			If (NumGet(g, cb := gs * (A_Index - 1)) == gp, "UInt") {
				gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
				Break
			}
		If (!gf)
			NumPut(gp, g, gl, "UInt"), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
	}
	ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
	Loop, %cl%
		If (NumGet(c, cb := cs * (A_Index - 1), "UInt") == i) {
			If a =
			{
				cf = 1
				Break
			}
			giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
				, cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
			Loop, Parse, a, xywh
				If A_Index > 1
					av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
						, d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
			DllCall("SetWindowPos", "UInt", i, "UInt", 0, "Int", dx, "Int", dy
				, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
			If r != 0
				DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
			Return
		}
	If cf != 1
		cb := cl, cl += cs
	bx := NumGet(gi, 48, "UInt"), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52, "UInt")
	If cf = 1
		dw -= giw - gw, dh -= gih - gh
	NumPut(i, c, cb, "UInt"), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
		, NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
	Return, true
}
