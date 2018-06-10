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
    
    Note that in this particular example, because we're using TransmitFile() synchronously to send the file over, no new
    threads can launch while the operation is in progress. Therefore, while the file is transferring, the only way the user
    can force an immediate exit is by killing the AutoHotkey process itself.
    */
    AHKsock_Close()
ExitApp

Send(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, iLength = 0) {
    
    If (sEvent = "ACCEPTED") {
        OutputDebug, % "Server - A client connected!"
        
    } Else If (sEvent = "DISCONNECTED") {
        OutputDebug, % "Server - A client disconnected!"
        
        ;Update client served count
        GuiControlGet, iCount,, lblCount
        GuiControl,, lblCount, % (iCount + 1)
        
    } Else If (sEvent = "SEND") {
        
        ;Open the file for reading
        GuiControlGet, sFile,, txtFile
        hFile := File_Open("ReadSeq", sFile)
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
            
            ;Disconnect the client and close the file
            File_Close(hFile)
            AHKsock_Close(iSocket)
            Return
        }
        
        ;Prep the TRANSMIT_FILE_BUFFERS struct so that the size of the file will be sent before sending the file (see MSDN
        ;of TransmitFile() for details).
        
        ;We need to create an actual 64-bit integer manually, because AHK keeps variables as strings
        VarSetCapacity(bFileSize, 8, 0)
        NumPut(iFileSize, bFileSize, 0, "Int64")
        
        VarSetCapacity(fTransmitFileBuffers, 4 * A_PtrSize, 0)
        NumPut(&bFileSize, fTransmitFileBuffers)
        NumPut(8, fTransmitFileBuffers, A_PtrSize)
        
        ;Call TransmitFile
        r := DllCall("mswsock\TransmitFile", "Ptr", iSocket, "Ptr", hFile, "UInt", 0, "UInt", 0, "UInt", 0
                                           , "Ptr", &fTransmitFileBuffers, "UInt", 0)
        If (Not r Or ErrorLevel) {
            ErrorLevel := ErrorLevel ? ErrorLevel : AHKsock_LastError()
            OutputDebug, % "Server - TransmitFile() failed with error code = " ErrorLevel
        }
        
        ;Close the file and the socket
        File_Close(hFile)
        AHKsock_Close(iSocket)
    }
}

AHKsockErrors(iError, iSocket) {
    OutputDebug, % "Server - Error " iError " with error code = " ErrorLevel ((iSocket <> -1) ? " on socket " iSocket : "") 
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
