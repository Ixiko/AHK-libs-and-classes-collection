/*! TheGood
    AHKsock - A simple AHK implementation of Winsock.
    AHKsock Example 2 - File Transfer
    http://www.autohotkey.com/forum/viewtopic.php?p=355775
    Last updated: August 24th, 2010
    
    In this example, the server sends a file to the client as soon as the latter connects.
    
    This example contains three different servers:
        - The "TransmitFile" server: This is the simplest server of the three. It relies on the TransmitFile() API call to
          perform the data transfer. It is also (slightly) faster than the "Single Client" server. However, there are a few
          disadvantages:
                - It can only handle one client at a time. Any other client that connects to the server while it is still
                  stuck in the TransmitFile() call of a previous client will be queued, and will have to wait for the
                  previous client to finish receiving the data.
                - The call to TransmitFile() is blocking. This means that it won't return before the file transfer is over.
                  Although it is possible to call it asynchronously, TransmitFile is limited to sending two files at a time.
                  See MSDN for details on those limitations.
                - It is not possible to monitor the file transfer progress when using TransmitFile().
                - Because TransmitFile() is blocking, no new threads can be launched (including the tray menu) while the
                  operation is in progress. This also causes the GUI to become unresponsive.
        - The "Single Client" server: This server handles its own reading from the file and sending it over to the client.
          However, it can only handle one client at a time, disconnecting any other client that connects if it's still
          connected to a previous client.
        - The "Multiple Clients" server: This is the most complex of the three. It is able to handle multiple clients at the
          same time. It uses almost the same algorithm as the "Single Client" server, but is adapted for multiple clients.
    
    No matter the server used, this is the general flow of the scenario:
        1. The server starts listening on port 27015 as soon as the user presses the "Listen" button.
        2. The client connects to the server as soon as the user presses the "Connect" button.
        3. As soon as the client connects, the server starts by sending the file's size in a 64-bit integer (8 bytes).
        4. The server then starts sending the file data in multiple chunks.
        5. As the client receives the data, it saves it straight to the target file.
        6. Once the file is completely sent, the server closes the connection.
        7. Once the connection closes, the client exits and shows the saved file in Explorer.
        8. The server goes back to idling on listening.
        9. The process repeats itself when the user presses the "Connect" button in a new client instance.
    
    This example uses OutputDebug to output its log (e.g. errors). See the command's docs for more details.
*/
    ;Needed if AHKsock isn't in one of your lib folders
    ;#Include %A_ScriptDir%\AHKsock.ahk
    
    ;Register OnExit subroutine so that AHKsock_Close is called before exit
    OnExit, CloseAHKsock
    
    ;Set up an error handler (this is optional)
    AHKsock_ErrorHandler("AHKsockErrors")
    
    ;Create the GUI
    Gui, Add, Text,, File to serve when client connects:
    Gui, Add, Edit, Section w600 ReadOnly -Wrap r1 vtxtFile, %A_ScriptFullPath%
    Gui, Add, Text, hp 0x200, Currently serving: ;0x200 = SS_CENTERIMAGE - Center text vertically
    
    ;Set the text to "000" but then rename it, just to make sure the width of the static can hold three digits
    Gui, Add, Text, x+2 hp vlblServing cBlue 0x200, 000 ;0x200 = SS_CENTERIMAGE - Center text vertically
    GuiControl,, lblServing, 0
    
    Gui, Add, Button, ys Section hp gbtnBrowse vbtnBrowse, ...
    
    ;Set the text to "Stop Listen" but then rename it, just to make sure the width of the button can hold "Stop Listen"
    Gui, Add, Button, hp x+5 gbtnListen vbtnListen, Stop Listen
    GuiControl,, btnListen, Listen
    
    Gui, Add, Text, xs hp 0x200, Clients served: ;0x200 = SS_CENTERIMAGE - Center text vertically
    
    ;Set the text to "000" but then rename it, just to make sure the width of the static can hold three digits
    Gui, Add, Text, x+2 hp vlblCount cBlue 0x200, 000 ;0x200 = SS_CENTERIMAGE - Center text vertically
    GuiControl,, lblCount, 0
    
    Gui, Show
Return

btnBrowse:
    Gui, +OwnDialogs ;Make dialog modal
    FileSelectFile, sFile, 1 + 2 + 8 ;File Must Exist + Path Must Exist + Prompt to Create New File
    If Not ErrorLevel
        GuiControl,, txtFile, %sFile%
Return

btnListen:
    
    ;Check if we need to stop or start listening
    If Not bListening {
        
        ;Listen on this computer on port 27015
        If (i := AHKsock_Listen(27015, "Send")) {
            OutputDebug, % "AHKsock_Listen() failed with return value = " i " and ErrorLevel = " ErrorLevel
            ExitApp
        }
        
        ;Change button name
        GuiControl,, btnListen, Stop Listen
        
    } Else  {
        
        ;Stop listening
        If (i := AHKsock_Listen(27015)) {
            OutputDebug, % "AHKsock_Listen() failed with return value = " i " and ErrorLevel = " ErrorLevel
            ExitApp
        }
        
        ;Change button name
        GuiControl,, btnListen, Listen
    }
    
    ;Update listening status
    bListening := Not bListening
Return

GuiClose:
GuiEscape:
CloseAHKsock:
    /*! If the user selects the Exit menu item from the tray menu, this sub will execute only once as the OnExit sub, and
    therefore, graceful shutdown will be impossible.
    
    But if the user closes the GUI, this sub will execute twice: once as the label for the GUI event, and once more right
    after as the OnExit sub (since ExitApp is called at the end of the sub). Therefore, during the first execution of those
    two, since the thread will be interruptible, calling AHKsock_Close will gracefully shutdown the connection. Note that
    the second call to AHKsock_Close during the OnExit sub then becomes useless by redundancy, but harmless (so there's no
    need to ensure that it is only called during the first of the two executions).
    */
    AHKsock_Close()
ExitApp

Send(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, iLength = 0) {
    Static hFile := -1, iFileSize, bFileSize
    
    If (sEvent = "ACCEPTED") {
        OutputDebug, % "Server - A client connected!"
        
        ;Make sure the the file is already open
        If (hFile = -1) {
            
            ;Open the file for reading
            GuiControlGet, sFile,, txtFile
            hFile := File_Open("ReadSeq", sFile)
            If (hFile = -1) {
                OutputDebug, % "Server - Could not open the file! ErrorLevel = " ErrorLevel
                
                ;Disconnect the client
                AHKsock_Close(iSocket)
                Return
            }
            
            ;Get the size
            iFileSize := File_Size(hFile)
            If (iFileSize = -1) {
                OutputDebug, % "Server - Could not get the file size! ErrorLevel = " ErrorLevel
                
                ;Disconnect the client
                AHKsock_Close(iSocket)
                Return
            }
            
            ;Prepare the integer containing the file size which we'll send to the client
            ;We need to create an actual 64-bit integer manually, because AHK keeps variables as strings
            VarSetCapacity(bFileSize, 8, 0)
            NumPut(iFileSize, bFileSize, 0, "int64")
        }
        
        ;Add client socket to array
        SocketPointer(iSocket, "Add")
        
        ;Update clients serving count
        GuiControlGet, iCount,, lblServing
        GuiControl,, lblServing, % (iCount + 1)
        
    } Else If (sEvent = "DISCONNECTED") {
        OutputDebug, % "Server - A client disconnected!"
        
        ;Delete client socket from array
        SocketPointer(iSocket, "Delete")
        
        ;Close the file if there are no more clients connected
        If Not SocketPointer() {
            File_Close(hFile)
            hFile := -1
        }
        
        ;Update client served count
        GuiControlGet, iCount,, lblCount
        GuiControl,, lblCount, % (iCount + 1)
        
        ;Update clients serving count
        GuiControlGet, iCount,, lblServing
        GuiControl,, lblServing, % (iCount - 1)
        
    } Else If (sEvent = "SEND") {
        
        ;Check if we fully sent the 64-bit file size integer yet to this client
        bFileSizeSent := SocketPointer(iSocket, "GetSizeSent")
        If (bFileSizeSent >= 0) {
            
            /*! Unfortunately here, we can't use the same trick as in the "Single Client" server to send the file size.
            We need to separately make sure that the integer is sent first before we start sending file data. This is
            because here, the current chunk is not stored in a static variable, like in the "Single Client" server, so we
            can't just prepend the 8 bytes to the first chunk and assume it'll all go through. Having to prepare for
            WSAEWOULDBLOCK would have gotten complicated.
            */
            
            /*! This is almost the same loop and offset method used in the server of AHKsock Example 1. Read the comment
            block in the SEND event there for more information about how the loop works. The only difference is that our
            offset variable bFileSizeSent is not static, but instead kept in SocketPointer because we're handling
            multiple clients.
            */
            
            ;Keep trying to send it until we succeed or until we get WSAEWOULDBLOCK
            Loop {
                If ((i := AHKsock_Send(iSocket, &bFileSize + bFileSizeSent, 8 - bFileSizeSent)) < 0) {
                    
                    ;Check if we received WSAEWOULDBLOCK
                    If (i = -2) {
                        SocketPointer(iSocket, "SetSizeSent", bFileSizeSent) ;Save the number of bytes we were able to send
                        Return ;We'll keep sending data the next time we get the SEND event
                        
                    } Else { ;Something bad has happened
                        OutputDebug, % "Server - AHKsock_Send failed with return value = " i " and ErrorLevel = " ErrorLevel
                        AHKsock_Close(iSocket) ;Close the socket
                    }
                }
                
                ;Check if all of it could be sent
                If (i < 8 - bFileSizeSent)
                    bFileSizeSent += i
                Else {
                    SocketPointer(iSocket, "SetSizeSent", -1) ;We sent all of it
                    Break
                }
            }
        }
        
        /*! The method used here to send the file data is very similar to the one used in the "Single Client" server. The
        only difference is that because we are serving multiple clients, we can't keep bFile, bFileLength, and bFileSent as
        static variables, because these can only be associated with a single client at a time.
        
        So that's why we need to use the SocketPointer function to remember how much of the file we sent to each client.
        The first thing we do before sending data to the client with the socket iSocket is to retrieve the file pointer for
        that client using the "GetPointer" action. This file pointer represents how much data we sent so far to this client.
        
        So we then set the file pointer of the file itself so that when we enter the loop, the chunk of 8 KB read from the
        file will be from where we left off for that particular client. From there on, the loop is very much similar to the
        one used in the "Single Client" server, except that when we receive WSAEWOULDBLOCK, we call SocketPointer to store
        how many bytes from the file have been sent so far by using the "SetPointer" action. This way, the next time we
        receive the SEND event for this same client, we will set the file pointer of the file to where necessary.
        */
        
        ;Get the file pointer for this client (i.e. the number of bytes we sent so far to this client)
        iPointer := SocketPointer(iSocket, "GetPointer")
        
        ;Set the file pointer to the current pointer for this client (if it's currently different) so that the next 8 KBs
        ;chunk of data we read will start off at the data we haven't sent yet.
        If (File_Pointer(hFile) <> iPointer)
            File_Pointer(hFile, iPointer)
        
        ;This will be our offset variable to keep track of how much data of the current chunk we already sent.
        bFileSent := 0
        
        ;Keep trying to send file data until we get WSAEWOULDBLOCK
        Loop {
            
            ;Read up to 8 KB from the file
            If Not bFileSent {
                bFileLength := File_Read(hFile, bFile, 8191)
                If (bFileLength = -1) { ;Check for error
                    OutputDebug, % "Server - File couldn't be read! ErrorLevel = " ErrorLevel
                    Break ;Leave the loop so that we close the socket
                }
            }
            
            ;Send the data
            If ((i := AHKsock_Send(iSocket, &bFile + bFileSent, bFileLength - bFileSent)) < 0) {
                
                ;Check if we received WSAEWOULDBLOCK
                If (i = -2) {
                    
                    /*! We are about to leave because we can't send any more data to the client. But before, we need to use
                    the SocketPointer function to store the number of bytes of the file we were able to send to this client
                    so far. To find out this number, we need to reconcile the current file pointer with where we actually
                    stopped sending.
                    
                    Because every File_Read operation moves the file pointer forward by the amount of bytes read, we first
                    subtract the amount of bytes read from the file during the last call (i.e. we subtract by the length of
                    bFile). We then need to add the number of bytes of bFile that we were able to send so far.
                    */ 
                    SocketPointer(iSocket, "SetPointer", File_Pointer(hFile) - bFileLength + bFileSent)
                    Return ;We'll keep sending data the next time we get the SEND event
                    
                } Else { ;Something bad has happened
                    OutputDebug, % "Server - AHKsock_Send failed with return value = " i " and ErrorLevel = " ErrorLevel
                    Break ;Leave the loop so that we close the socket
                }
            }
            
            ;Don't uncomment this line if sending large files, or otherwise the log will quickly fill up.
            ;OutputDebug, % "Server - Sent " i " bytes!"
            
            ;Check if we were able to send all the data in bFile that was still unsent before
            If (i < bFileLength - bFileSent) {
                
                ;The send() operation could only send part of the 8 KB block we read.
                ;We need to move up the offset so that we try to send the remaining portion on the next iteration
                bFileSent += i
                Continue ;Skip to the next iteration
                
            ;We sent all the data in bData successfully! Set bFileLength to 0 to indicate that we're ready to read the next
            ;chunk of 8 KBs from the file on the next iteration.
            } Else bFileSent := 0
            
            ;Check if we're done sending the whole file
            If (File_Pointer(hFile) >= iFileSize)
                Break ;Leave the loop so that we close the socket
        }
        
        OutputDebug, % "Server - Closing the client connection now"
        If (i := AHKsock_Close(iSocket))
            OutputDebug, % "Server - The shutdown() call failed. ErrorLevel = " ErrorLevel
    }
}

AHKsockErrors(iError, iSocket) {
    OutputDebug, % "Server - Error " iError " with error code = " ErrorLevel ((iSocket <> -1) ? " on socket " iSocket : "")
}

/*! This function keeps track of the file transfer progress for each socket. This is needed because the server may be
    sending the file to multiple clients at the same time and needs to know how much of the file was transferred to each
    client to start off from there.
    
    In comparison to the "Single Client" server, think of this function as the equivalent of storing the static variables
    used to keep track of the sending progress (bFileSizeSent and bFileSent) but for multiple clients. Here they're called
    aSockets%index%_SizeSent and aSockets%index%_Pointer. The indexes are not accessed directly, but rather through the
    socket they are associated with.
    
    Here is a breakdown of the different actions that sAction can take:
        Count       -> Retrieves the number of elements in the array
        Add         -> Adds the socket iSocket to the array
        Delete      -> Deletes the socket iSocket from the array
        GetPointer  -> Retrieves the file pointer for the socket iSocket
        SetPointer  -> Sets the file pointer for the socket iSocket (iValue is the new file pointer)
        GetSizeSent -> Retrieves the number of bytes of bFileSize sent to data on the socket iSocket
        SetSizeSent -> Sets the number of bytes of bFileSize sent to data on the socket iSocket (iValue is the new number)
        Index       -> Used internally only (i.e. by SocketPointer itself) to get the a socket's index in the array
*/
SocketPointer(iSocket = -1, sAction = "Count", iValue = -1) {
    Static ;Assume static mode
    Static aSockets0 := 0
    Local i
    
    ;Check which action it is
    If (sAction = "Count") {
        Return aSockets0
    
    } Else If (sAction = "Add") {
        aSockets0 += 1
        aSockets%aSockets0% := iSocket
        aSockets%aSockets0%_Pointer := 0
        aSockets%aSockets0%_SizeSent := 0
        
    } Else If (sAction = "Delete") {
        
        ;Get the socket index (and make sure the socket is in the array)
        If Not (i := SocketPointer(iSocket, "GetIndex"))
            Return
        
        ;Replace with the last in line if not already last
        If (i < aSockets0) {
            aSockets%i% := aSockets%aSockets0%
            aSockets%i%_Pointer := aSockets%aSockets0%_Pointer
            aSockets%i%_SizeSent := aSockets%aSockets0%_SizeSent
        }
        
        ;Reduce array count
        aSockets0 -= 1
        
    } Else If (sAction = "GetPointer") {
        
        ;Get the socket index (and make sure the socket is in the array)
        If Not (i := SocketPointer(iSocket, "GetIndex"))
            Return
        Else Return aSockets%i%_Pointer
        
    } Else If (sAction = "SetPointer") {
        
        ;Get the socket index (and make sure the socket is in the array)
        If Not (i := SocketPointer(iSocket, "GetIndex"))
            Return
        Else aSockets%i%_Pointer := iValue
        
    } Else If (sAction = "GetSizeSent") {
        
        ;Get the socket index (and make sure the socket is in the array)
        If Not (i := SocketPointer(iSocket, "GetIndex"))
            Return
        Else Return aSockets%i%_SizeSent
        
    } Else If (sAction = "SetSizeSent") {
        
        ;Get the socket index (and make sure the socket is in the array)
        If Not (i := SocketPointer(iSocket, "GetIndex"))
            Return
        Else aSockets%i%_SizeSent := iValue
        
    } Else If (sAction = "GetIndex") {
        Loop % aSockets0
            If (aSockets%A_Index% = iSocket)
                Return A_Index
    }
}

/*! TheGood
    Simple file functions
    http://www.autohotkey.com/forum/viewtopic.php?t=56510
*/

File_Open(sType, sFile) {
    
    bRead := InStr(sType, "READ")
    bSeq  := sType = "READSEQ"
    
    ;Open the file for writing with GENERIC_WRITE/GENERIC_READ, NO SHARING/FILE_SHARE_READ & FILE_SHARE_WRITE, and
    ;OPEN_ALWAYS/OPEN_EXISTING, and FILE_FLAG_SEQUENTIAL_SCAN
    hFile := DllCall("CreateFile", "Str", sFile, "UInt", bRead ? 0x80000000 : 0x40000000, "UInt", bRead ? 3 : 0, "Ptr", 0
                                 , "UInt", bRead ? 3 : 4, "UInt", bSeq ? 0x08000000 : 0, "Ptr", 0, "Ptr")
    If (hFile = -1 Or ErrorLevel) { ;Check for any error other than ERROR_FILE_EXISTS
        ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
        Return -1 ;Return INVALID_HANDLE_VALUE
    } Else Return hFile
}

File_Read(hFile, ByRef bData, iLength = 0) {
    
    ;Check if we're reading up to the rest of the file
    If Not iLength ;Set the length equal to the remaining part of the file
        iLength := File_Size(hFile) - File_Pointer(hFile)
    
    ;Prep the variable
    VarSetCapacity(bData, iLength, 0)
    
    ;Read the file
    r := DllCall("ReadFile", "Ptr", hFile, "Ptr", &bData, "UInt", iLength, "UInt*", iLengthRead, "Ptr", 0)
    If (Not r Or ErrorLevel) {
        ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
        Return -1
    } Else Return iLengthRead
}

File_Write(hFile, ptrData, iLength) {
    
    ;Write to the file
    r := DllCall("WriteFile", "Ptr", hFile, "Ptr", ptrData, "UInt", iLength, "UInt*", iLengthWritten, "Ptr", 0)
    If (Not r Or ErrorLevel) {
        ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
        Return -1
    } Else Return iLengthWritten
}

File_Pointer(hFile, iOffset = 0, iMethod = -1) {
    
    ;Check if we're on auto
    If (iMethod = -1) {
        
        ;Check if we should use FILE_BEGIN, FILE_CURRENT, or FILE_END
        If (iOffset = 0)
            iMethod := 1 ;We're just retrieving the current pointer. FILE_CURRENT
        Else If (iOffset > 0)
            iMethod := 0 ;We're moving from the beginning. FILE_BEGIN
        Else If (iOffset < 0)
            iMethod := 2 ;We're moving from the end. FILE_END
    } Else If iMethod Is Not Integer
        iMethod := (iMethod = "BEGINNING" ? 0 : (iMethod = "CURRENT" ? 1 : (iMethod = "END" ? 2 : 0)))
    
    r := DllCall("SetFilePointerEx", "Ptr", hFile, "Int64", iOffset, "Int64*", iNewPointer, "UInt", iMethod)
    If (Not r Or ErrorLevel) {
        ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
        Return -1
    } Else Return iNewPointer
}

File_Size(hFile) {
    r := DllCall("GetFileSizeEx", "Ptr", hFile, "Int64*", iFileSize)
    If (Not r Or ErrorLevel) {
        ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
        Return -1
    } Else Return iFileSize
}

File_Close(hFile) {
    If Not (r := DllCall("CloseHandle", "Ptr", hFile)) {
        ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
        Return False
    } Return True
}
