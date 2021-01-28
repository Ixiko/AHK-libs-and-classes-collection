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
    
    /*! Allow multiple instances. This is to allow you to see how the "Multiple Clients" server handles multiple concurrent
    clients. You can also launch multiple instances while using the "Single Client" server to see in the OutputDebug log the
    the server rejecting any client that connects while another client is present. If the file to send is small, you might
    have to launch the clients rapidly in order to see this happening.
    
    Set bSilent to True to keep the GUI hidden and to connect right away. This way it's easier to launch multiple instance
    quickly. A folder called "Client Recv" will be created on the desktop if it doesn't exist and the files received will be
    saved there with a random filename. If the server is on another computer, change sServer to the server's hostname/IP.
    */
    #SingleInstance, Off
    bSilent := False
    
    ;Set the default server address to localhost
    sServer := "localhost"
    
    ;Register OnExit subroutine so that AHKsock_Close is called before exit
    OnExit, CloseAHKsock
    
    ;Set up an error handler (this is optional)
    AHKsock_ErrorHandler("AHKsockErrors")
    
    ;This is only used in order to OutputDebug the average speed of the file transfer at the end
    DllCall("QueryPerformanceFrequency", "int64*", qpFreq)
    
    ;Check if we're silent
    If bSilent {
        FileCreateDir, %A_Desktop%\Client Recv
        Random, sPath
        sPath = %A_Desktop%\Client Recv\%sPath%.dat
    } Else sPath = %A_Desktop%\File.dat
    
    ;Create the GUI
    Gui, Add, Text,, File to save to when data is received:
    Gui, Add, Edit, Section w600 ReadOnly -Wrap r1 vtxtFile, %sPath% ;Default Save To path
    Gui, Add, Progress, hp wp cBlue vpgrTransfer Range0-600
    
    Gui, Add, Button, ys hp gbtnBrowse vbtnBrowse, ...
    
    ;Set the text to "Stop Listen" so that it matches the length of the server GUI
    Gui, Add, Button, Section hp x+5 gbtnConnect vbtnConnect, Stop Listen
    GuiControl,, btnConnect, Connect ;Rename it now
    
    Gui, Add, Button, xs hp wp gbtnServer, Set Server
    
    ;Start connection right away if we're silent
    If bSilent
        Gosub, btnConnect
    Else Gui, Show
Return

btnBrowse:
    Gui, +OwnDialogs ;Make the dialog modal
    FileSelectFile, sFile, S24 ;S24 = Prompt to create new file and prompt to overwrite file
    If Not ErrorLevel ;Check for Cancel
        GuiControl,, txtFile, %sFile%
Return

btnServer:
    Gui, +OwnDialogs ;Make the dialog modal
    InputBox, sNewServer, Server hostname or IP address, Please enter the server's hostname or IP address:,
            ,, 100,,,,, %sServer%
    If Not ErrorLevel ;Change the address only if the user didn't press Cancel
        sServer := sNewServer
Return

btnConnect:
    
    ;The user just pressed the Connect button. We should disable the Connect button until the file transfer is over. This
    ;ensures that we don't end up with more than one connected socket if the user clicks the Connect button more than once.
    GuiControl, Disable, btnConnect
    
    ;Connect to the server on port 27015
    If (i := AHKsock_Connect(sServer, 27015, "Recv")) {
        OutputDebug, % "Client - AHKsock_Connect() failed with return value = " i " and ErrorLevel = " ErrorLevel
        ExitApp
    }
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

Recv(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bNewData = 0, bNewDataLength = 0) {
    Static bPastData, bPastDataLength
    Static hFile := -1, iFileSize, qpTstart
    Global qpFreq, bSilent
    
    If (sEvent = "CONNECTED") {
        
        ;Check if the connection attempt was succesful
        If (iSocket = -1) {
            OutputDebug, % "Client - AHKsock_Connect() failed."
            
            ;Here, we can afford to use an MsgBox because there is no other activity going on
            Gui, +OwnDialogs
            MsgBox, 0x10, Error, Could not connect to the server at: %sName%`nEither try again or change the server address.
            
            ;Re-enable the Connect button
            GuiControl, Enable, btnConnect
        }
        
        OutputDebug, % "Client - AHKsock_Connect() successfully connected!"
        
    } Else If (sEvent = "DISCONNECTED") {
        
        OutputDebug, % "Client - The server closed the connection."
        
        ;If the file isn't closed, then it means that we abruptly ended the transfer
        If (hFile <> -1) {
            File_Close(hFile)
            hFile := -1 ;Reset value to indicate that we closed the file
            
            ;Delete the incomplete file
            GuiControlGet, sFile,, txtFile
            FileDelete, %sFile%
        }
        
        If Not bSilent {
            
            ;Open and select the file in Windows Explorer
            
            GuiControlGet, sFile,, txtFile
            If FileExist(sFile) ;Make sure it exists
                Run % "explorer.exe /select," sFile
        }
        
        ExitApp
        
    } Else If (sEvent = "RECEIVED") {
        ;Don't uncomment this line if receiving large files, or otherwise the log will quickly fill up.
        ;OutputDebug, % "Client - We received " bNewDataLength " bytes." ;FOR DEBUGGING PURPOSES ONLY
        
        ;Check if the target file is ready for writing
        If (hFile = -1) {
            
            ;We need to get the file ready for writing
            
            ;Get the file name
            GuiControlGet, sFile,, txtFile
            
            ;Delete the target file if it exists
            FileDelete, %sFile%
            
            ;Open the file for writing
            hFile := File_Open("Write", sFile)
            If (hFile = -1) { ;Check for error
                OutputDebug, % "Client - Could not open the file! ErrorLevel = " ErrorLevel
                
                ;Disconnect the client
                AHKsock_Close(iSocket)
                ExitApp
            }
        }
        
        /*! The 64-bit file size integer is the first thing the server will send us. Although unlikely, we must be prepared
        for the case where only part of the 8 bytes make it on the first call. Read the section titled "NOTES ON RECEIVING
        AND SENDING DATA" in the documentation to learn more about the streaming nature of data.
        
        In order to handle cases where the 8 bytes are spread over multiple RECEIVE events, we keep a static variable named
        bPastData. This variable will hold the data received from the previous RECEIVE event if we did not receive the full
        8 bytes of the file size integer. The static variable bPastDataLength keeps track of the length of bPastData.
        
        So for example, imagine we receive three RECEIVE events, where in the first one we only receive 4 bytes of the
        8-byte integer, in the second one we receive 2 more bytes, and finally in the third one we receive 10 bytes of
        which the first 2 are the last 2 bytes of the 8-byte integer. Here's what will happen:
            - On the first RECEIVE event, we save the 4 bytes received in bPastData and leave.
            - On the second RECEIVE event, we first prepend the 4 bytes in bPastData to the 2 new bytes received. This gives
              us a total of 6 bytes. Since we are still missing 8 - 6 = 2 bytes, we save the 6 bytes in bPastData and leave.
            - On the third RECEIVE event, we first prepend the 6 bytes in bPastData to the 10 new bytes received. This gives
              us a total of 16 bytes. We then extract the 64-bit integer from the first 8 bytes. We then proceed to writing
              the remaining 8 bytes to the target file.
            - Any data received in subsequent RECEIVE events will be directly written to the file.
        */
        
        ;Check if we have any data to prepend
        If bPastDataLength {
            
            bDataLength := bNewDataLength + bPastDataLength
            
            ;Prep the variable which will hold past and new data
            VarSetCapacity(bData, bDataLength, 0)
            
            ;Copy old data and then new data
            CopyBinData(&bPastData, &bData, bPastDataLength)
            CopyBinData(&bNewData, &bData + bPastDataLength, bNewDataLength)
            
            ;We can now delete the old data
            VarSetCapacity(bPastData, 0) ;Clear the variable to free some memory since it won't be used
            bPastDataLength := 0 ;Reset the value
            
            ;Set the data pointer to the new data we just created
            bDataPointer := &bData
            
            /*! The advantage of using a data pointer is so that the code that follows after can work regardless of whether
            the data to process is in bNewData (if we had nothing to prepend), or in bData (if we had to create it to
            prepend some past data). The variable bDataLength holds the length of the data to which bDataPointer points.
            */
            
        ;Set the data pointer to the newly arrived data
        } Else bDataPointer := &bNewData, bDataLength := bNewDataLength
        
        ;Check if we fully received the 8-byte file size integer yet.
        If Not iFileSize {
            
            ;Check if only part of the 8 bytes are here
            If (bDataLength < 8) {
                
                ;Save what we have and leave
                VarSetCapacity(bPastData, 8, 0)
                CopyBinData(bDataPointer, &bPastData, bDataLength)
                Return
            }
            
            ;Extract the 8 bytes
            iFileSize := NumGet(bDataPointer + 0, 0, "int64")
            
            OutputDebug, % "Client - File size is " iFileSize " bytes!"
            
            ;Check if there is data after the 64-bit integer that we have to write to the file
            If (bDataLength = 8) {
                
                ;Reset the performance counter value so that it will be
                ;queried just before writing the first bytes to the file
                qpTstart := -1
                
                Return ;Nothing to write
            }
            
            ;We're about to write the first bytes. Query the performance counter before!
            DllCall("QueryPerformanceCounter", "int64*", qpTstart)
            
            ;Write the data after the 64-bit integer to the file (that's why we do + 8)
            iWritten := File_Write(hFile, bDataPointer + 8, bDataLength - 8)
            
        } Else {
            
            If (qpTstart = -1) ;Check if it hasn't already been queried
                DllCall("QueryPerformanceCounter", "int64*", qpTstart)
            
            ;Append the data we received to the file
            iWritten := File_Write(hFile, bDataPointer, bDataLength)
        }
        
        ;Don't uncomment this line if receiving large files, or otherwise the log will quickly fill up.
        ;OutputDebug, % "Client - Data written to file: " iWritten ;FOR DEBUGGING PURPOSES ONLY
        
        ;Get the current file pointer (i.e. the number of bytes written to file so far)
        iPointer := File_Pointer(hFile)
        
        ;Check if we have received the whole file
        If (iPointer >= iFileSize) {
            
            ;We can close the file handle and reset the value
            File_Close(hFile)
            hFile := -1 ;Reset value to indicate that we closed the file
            
            ;Output the average speed for the transfer
            DllCall("QueryPerformanceCounter", "int64*", qpTend)
            OutputDebug, % "Average speed = " Round((iFileSize / 1024) / ((qpTend - qpTstart) / qpFreq)) " kB/s"
        }
        
        ;Update progress bar
        GuiControl,, pgrTransfer, % iPointer * 600 / iFileSize
    }
}

AHKsockErrors(iError, iSocket) {
    OutputDebug, % "Client - Error " iError " with error code = " ErrorLevel ((iSocket <> -1) ? " on socket " iSocket : "") 
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
