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
    Gui, Add, Progress, hp wp cBlue vpgrTransfer Range0-600
    
    Gui, Add, Button, Section ys hp gbtnBrowse vbtnBrowse, ...
    
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
    Static hFile := -1 ;Handle of the file to send
    Static iFileSize ;Size of the file to send
    Static iIgnoreDisconnect ;Keeps track of the disconnections from clients we couldn't serve
    Static bFileSize, bFileSizeSent ;These are used when sending iFileSize to the client
    Static bFile, bFileLength, bFileSent ;These are used when sending file data
    
    If (sEvent = "ACCEPTED") {
        OutputDebug, % "Server - A client connected!"
        
        ;Check if the file is already open
        If (hFile <> -1) {
            
            /*! If the file is already open, then it means that we're still serving a previous client. We have to disconnect
            this new client because we can't handle more than one client at a time. The reason we can't handle more than one
            client is that the file pointer of the open file not only represents the amount of bytes read so far, but it
            also represents the amount of bytes sent to the client so far.
            
            If we had to handle more than one client at a time, we would have to keep a record of how many bytes were sent
            to each client to date. To see an example of this, see the "Multiple Clients" server of AHKsock Example 2.
            */
            
            ;Close the socket
            AHKsock_Close(iSocket)
            
            OutputDebug, % "Server - Disconnected new client because we are still serving a previous client."
            
            ;Increase the number of forthcoming disconnects to ignore (i.e. so we don't increment the clients served count
            ;Text control when they disconnect).
            iIgnoreDisconnect += 1
            
        } Else {
            
            ;We need to get ready to serve this client!
            
            ;Open the file for reading
            GuiControlGet, sFile,, txtFile
            hFile := File_Open("ReadSeq", sFile) ;Add the Sequential option since reading will be sequential
            If (hFile = -1) { ;Check for error
                OutputDebug, % "Server - Could not open the file! ErrorLevel = " ErrorLevel
                
                ;Disconnect the client
                AHKsock_Close(iSocket)
                Return
            }
            
            ;Get the size
            iFileSize := File_Size(hFile)
            If (iFileSize = -1) { ;Check for error
                OutputDebug, % "Server - Could not get the file size! ErrorLevel = " ErrorLevel
                
                ;Close the file
                File_Close(hFile)
                
                ;Disconnect the client
                AHKsock_Close(iSocket)
                Return
            }
            
            ;Prepare the integer containing the file size which we will send to the client
            ;We need to create an actual 64-bit integer manually, because AHK keeps variables as strings
            VarSetCapacity(bFileSize, 8, 0)
            NumPut(iFileSize, bFileSize, 0, "int64")
            
            ;Set to False to indicate that we haven't sent the file size 64-bit integer to the client yet
            bFileSizeSent := False
            
            ;Set to 0 to indicate that we can start reading from the file
            bFileLength := 0
        }
        
    } Else If (sEvent = "DISCONNECTED") {
        OutputDebug, % "Server - A client disconnected!"
        
        ;Check if we should ignore this disconnection or not
        If Not iIgnoreDisconnect {
            
            ;Check if the file is still open. If the file is still open, then it means that the connection with the client
            ;we were serving was abruptly closed before the file was done transferring.
            If (hFile <> -1) {
                
                ;Reset everything for the next client.
                File_Close(hFile)
                VarSetCapacity(bFile, 0)
                hFile := -1
                GuiControl,, pgrTransfer, 0
                
            } Else {
                
                ;Update client served count
                GuiControlGet, iCount,, lblCount
                GuiControl,, lblCount, % (iCount + 1)
            }
            
        ;We ignored this disconnection so we need to decrease the counter
        } Else iIgnoreDisconnect -= 1
        
    } Else If (sEvent = "SEND") {
        
        /*! This is where we send the file data (including the file size 64-bit integer) to the client. The loop below is
        very similar to the loop and offset method used in the server of AHKsock Example 1. Read the comment block in the
        SEND event there for more information about how the loop works.
        
        The only twist here is that we are progressively reading from the file. The file is sent to the client in small
        chunks of data. So we first read a chunk from the file, then we keep trying to send that chunk using the usual loop
        and offset method, and once it's sent, we read the next chunk from the file and so on...
        
        The problem is choosing the size of the chunk of data to read from the file and send. There are many points to take
        into account when making such a choice:
            - The larger the chunk of data, the faster the transfer will be.
            - The larger the chunk of data, the more data will have to be resent in the event of a packet going missing.
            - The chunk of data must be smaller than the send buffer allocated by Winsock (which can be retrieved or
              modified through AHKsock_SockOpt), or performance will majorly suffer. The default buffer size is 8 KB.
              See http://support.microsoft.com/kb/823764 for more details on the cause of this issue.
        
        In this example, we'll use a chunk size of 8 KB - 1 B = 8191 bytes so that we can use the largest chunk possible
        without the performance hit. This will work fine when testing the file transfer on the same machine, or across a
        LAN, but you might want to use a smaller number in applications which will be used across the Internet (where the
        chances of lost packets are much greater).
        
        Here is a breakdown of the static variables used:
            - bFile: the current chunk of data from the file that we are trying to send.
            - bFileLength: the actual length of bFile (which may be less than 8191 bytes if this is the last chunk of the
              file, or if the file is smaller than 8191 bytes).
            - bFileSent: the number of bytes from bFile which have successfully been sent so far. Used as the offset.
        */
        
        ;Check if we haven't sent the file size yet
        If Not bFileSizeSent {
            
            /*! We haven't sent the 64-bit file size integer yet. This means that we also haven't started sending file data.
            Because we need to first send the integer before the file data to the client, we will prepare the first chunk of
            data of 8191 bytes so that it contains the 8 bytes of the file size integer first, and then 8191 - 8 = 8183
            bytes from the file.
            
            The loop below will then take care of sending the chunk, as if it was any other chunk of data from the file.
            This method is also more efficient, because we are not calling AHKsock_Send separately for bFileSize, which
            would likely result in a single packet of only 8 bytes.
            */
            
            ;Read only (up to) 8191 - 8 = 8183 bytes from the file
            bFileLengthTemp := File_Read(hFile, bFileTemp, 8183)
            If (bFileLengthTemp = -1) { ;Check for error
                OutputDebug, % "Server - File couldn't be read! ErrorLevel = " ErrorLevel
                
                ;Close the file and reset the file handle value
                File_Close(hFile)
                hFile := -1
                Return
            }
            
            ;Prepare the bFile to hold the bytes read + the 64-bit int
            VarSetCapacity(bFile, bFileLengthTemp + 8)
            
            ;Copy the 64-bit int at the first 8 bytes of bFile
            CopyBinData(&bFileSize, &bFile, 8)
            
            ;Copy the bytes read from the file after the first 8 bytes of bFile
            CopyBinData(&bFileTemp, &bFile + 8, bFileLengthTemp)
            
            ;Set the length of the chunk bFile
            bFileLength := bFileLengthTemp + 8
            
            ;Set to 0 to indicate that no bytes from bFile have been sent yet
            bFileSent := 0
            
            ;Set to True to indicate that we will not need to prepend the
            ;64-bit file size integer on the next file chunk we will read
            bFileSizeSent := True
        }
        
        ;Keep trying to send file data until we get WSAEWOULDBLOCK
        Loop {
            
            ;Check if we're done sending the chunk in bFile
            If Not bFileLength {
                
                ;Read the next 8 KB from the file
                bFileLength := File_Read(hFile, bFile, 8191)
                If (bFileLength = -1) { ;Check for error
                    OutputDebug, % "Server - File couldn't be read! ErrorLevel = " ErrorLevel
                    Break ;Leave the loop so that we close the socket and the file handle
                }
                
                ;Set to 0 to indicate that no bytes from this new chunk of 8 KB have been sent yet
                bFileSent := 0
            }
            
            ;Send the data
            If ((i := AHKsock_Send(iSocket, &bFile + bFileSent, bFileLength - bFileSent)) < 0) {
                
                ;Check if we received WSAEWOULDBLOCK
                If (i = -2)
                    Return ;We'll keep sending data the next time we get the SEND event
                Else { ;Something bad has happened
                    OutputDebug, % "Server - AHKsock_Send failed with return value = " i " and ErrorLevel = " ErrorLevel
                    Break ;Leave the loop so that we close the socket and the file handle
                }
            }
            
            ;Don't uncomment this line if sending large files, or otherwise the log will quickly fill up.
            ;OutputDebug, % "Server - Sent " i " bytes!"
            
            ;Get current file pointer, which represents the amount of bytes read from the file to date
            iPointer := File_Pointer(hFile)
            
            ;Update progress bar with the actual amount of bytes sent to the client to date
            GuiControl,, pgrTransfer, % (iPointer - bFileLength + i) * 600 / iFileSize
            
            ;Check if we were able to send all the data in bFile that was still unsent before
            If (i < bFileLength - bFileSent) {
                
                ;The send() operation could only send part of the 8 KB block we read.
                ;We need to move up the offset so that we try to send the remaining portion on the next iteration
                bFileSent += i
                Continue ;Skip to the next iteration
                
            ;We sent all the data in bFile successfully! Set bFileLength to 0 to indicate that we're ready to read the next
            ;chunk of 8 KB from the file on the next iteration.
            } Else bFileLength := 0
            
            ;Check if we sent the whole file
            If (iPointer >= iFileSize)
                Break ;Leave the loop so that we close the socket and the file handle
        }
        
        ;We can close the connection and the file
        OutputDebug, % "Server - Closing the client connection now"
        If (i := AHKsock_Close(iSocket))
            OutputDebug, % "Server - The shutdown() call failed. ErrorLevel = " ErrorLevel
        
        ;Close the file
        File_Close(hFile)
        
        ;Free any memory related to the last chunk of file data we read
        VarSetCapacity(bFile, 0)
        
        ;We can reset the file handle variable now so that we can accept new clients. 
        ;We don't need to actually wait for the client we just served to disconnect because as long as we are done sending
        ;data to it, we can use our static variables to track the data sending progress with another client!
        hFile := -1
    }
}

AHKsockErrors(iError, iSocket) {
    OutputDebug, % "Server - Error " iError " with error code = " ErrorLevel ((iSocket <> -1) ? " on socket " iSocket : "") 
}

CopyBinData(ptrSource, ptrDestination, iLength) {
    If iLength ;Only do it if there's anything to copy
        DllCall("RtlMoveMemory", "Ptr", ptrDestination, "Ptr", ptrSource, "UInt", iLength)
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
