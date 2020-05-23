; from here: http://www.autohotkey.com/forum/viewtopic.php?p=290253#290253
;########################################################################
;###### Initialize COM Subroutine #######################################
;########################################################################
Serial_Initialize(SERIAL_Settings){
  ;Global SERIAL_FileHandle      ;uncomment this if there is a problem

  ;###### Build COM DCB ######
  ;Creates the structure that contains the COM Port number, baud rate,...
  VarSetCapacity(DCB, 28)
  BCD_Result := DllCall("BuildCommDCB"
       ,"str" , SERIAL_Settings ;lpDef
       ,"UInt", &DCB)        ;lpDCB
  If (BCD_Result <> 1){
    error := DllCall("GetLastError")
    MsgBox, There is a problem with Serial Port communication. `nFailed Dll BuildCommDCB, BCD_Result=%BCD_Result% `nLasterror=%error%`nThe Script Will Now Exit.
    ExitApp
  }

  ;###### Extract/Format the COM Port Number ######
  StringSplit, SERIAL_Port_Temp, SERIAL_Settings, `:
  SERIAL_Port_Temp1_Len := StrLen(SERIAL_Port_Temp1)  ;For COM Ports > 9 \\.\ needs to prepended to the COM Port name.
  If (SERIAL_Port_Temp1_Len > 4)                   ;So the valid names are
    SERIAL_Port = \\.\%SERIAL_Port_Temp1%             ; ... COM8  COM9   \\.\COM10  \\.\COM11  \\.\COM12 and so on...
  Else                                          ;
    SERIAL_Port = %SERIAL_Port_Temp1%
  ;MsgBox, SERIAL_Port=%SERIAL_Port%

  ;###### Create COM File ######
  ;Creates the COM Port File Handle
  ;StringLeft, SERIAL_Port, SERIAL_Settings, 4  ; 7/23/08 This line is replaced by the "Extract/Format the COM Port Number" section above.
  SERIAL_FileHandle := DllCall("CreateFile"
       ,"Str" , SERIAL_Port     ;File Name
       ,"UInt", 0xC0000000   ;Desired Access
       ,"UInt", 3            ;Safe Mode
       ,"UInt", 0            ;Security Attributes
       ,"UInt", 3            ;Creation Disposition
       ,"UInt", 0            ;Flags And Attributes
       ,"UInt", 0            ;Template File
       ,"Cdecl Int")
  If (SERIAL_FileHandle < 1){
    error := DllCall("GetLastError")
    MsgBox, There is a problem with Serial Port communication. `nFailed Dll CreateFile, SERIAL_FileHandle=%SERIAL_FileHandle% `nLasterror=%error%`nThe Script Will Now Exit.
    ExitApp
  }

  ;###### Set COM State ######
  ;Sets the COM Port number, baud rate,...
  SCS_Result := DllCall("SetCommState"
       ,"UInt", SERIAL_FileHandle ;File Handle
       ,"UInt", &DCB)          ;Pointer to DCB structure
  If (SCS_Result <> 1){
    error := DllCall("GetLastError")
    MsgBox, There is a problem with Serial Port communication. `nFailed Dll SetCommState, SCS_Result=%SCS_Result% `nLasterror=%error%`nThe Script Will Now Exit.
    Serial_Close(SERIAL_FileHandle)
    ExitApp
  }

  ;###### Create the SetCommTimeouts Structure ######
  ReadIntervalTimeout        = 0xffffffff
  ReadTotalTimeoutMultiplier = 0x00000000
  ReadTotalTimeoutConstant   = 0x00000000
  WriteTotalTimeoutMultiplier= 0x00000000
  WriteTotalTimeoutConstant  = 0x00000000

  VarSetCapacity(Data, 20, 0) ; 5 * sizeof(DWORD)
  NumPut(ReadIntervalTimeout,         Data,  0, "UInt")
  NumPut(ReadTotalTimeoutMultiplier,  Data,  4, "UInt")
  NumPut(ReadTotalTimeoutConstant,    Data,  8, "UInt")
  NumPut(WriteTotalTimeoutMultiplier, Data, 12, "UInt")
  NumPut(WriteTotalTimeoutConstant,   Data, 16, "UInt")

  ;###### Set the COM Timeouts ######
  SCT_result := DllCall("SetCommTimeouts"
     ,"UInt", SERIAL_FileHandle ;File Handle
     ,"UInt", &Data)         ;Pointer to the data structure
  If (SCT_result <> 1){
    error := DllCall("GetLastError")
    MsgBox, There is a problem with Serial Port communication. `nFailed Dll SetCommState, SCT_result=%SCT_result% `nLasterror=%error%`nThe Script Will Now Exit.
    Serial_Close(SERIAL_FileHandle)
    ExitApp
  }

  Return SERIAL_FileHandle
}

;########################################################################
;###### Close COM Subroutine ############################################
;########################################################################
Serial_Close(SERIAL_FileHandle){
  ;###### Close the COM File ######
  CH_result := DllCall("CloseHandle", "UInt", SERIAL_FileHandle)
  If (CH_result <> 1)
    MsgBox, Failed Dll CloseHandle CH_result=%CH_result%
  Return
}

;########################################################################
;###### Write to COM Subroutines ########################################
;########################################################################
Serial_Write(SERIAL_FileHandle, Message){
  ;Global SERIAL_FileHandle

  SetFormat, Integer, DEC

  ;Parse the Message. Byte0 is the number of bytes in the array.
  StringSplit, Byte, Message, `,
  Data_Length := Byte0
  ;msgbox, Data_Length=%Data_Length% b1=%Byte1% b2=%Byte2% b3=%Byte3% b4=%Byte4%

  ;Set the Data buffer size, prefill with 0xFF.
  VarSetCapacity(Data, Byte0, 0xFF)

  ;Write the Message into the Data buffer
  i=1
  Loop %Byte0% {
    NumPut(Byte%i%, Data, (i-1) , "UChar")
    ;msgbox, %i%
    i++
  }
  ;msgbox, Data string=%Data%

  ;###### Write the data to the COM Port ######
  WF_Result := DllCall("WriteFile"
       ,"UInt" , SERIAL_FileHandle ;File Handle
       ,"UInt" , &Data          ;Pointer to string to send
       ,"UInt" , Data_Length    ;Data Length
       ,"UInt*", Bytes_Sent     ;Returns pointer to num bytes sent
       ,"Int"  , "NULL")
  If (WF_Result <> 1 or Bytes_Sent <> Data_Length)
    MsgBox, Failed Dll WriteFile to COM Port, result=%WF_Result% `nData Length=%Data_Length% `nBytes_Sent=%Bytes_Sent%
   
    Return Bytes_Sent
}

;########################################################################
;###### Read from COM Subroutines #######################################
;########################################################################
Serial_Read(SERIAL_FileHandle, Num_Bytes, byref Bytes_Received = ""){
  ;Global SERIAL_FileHandle
  ;Global SERIAL_Port
  ;Global Bytes_Received
  SetFormat, Integer, HEX

  ;Set the Data buffer size, prefill with 0x55 = ASCII character "U"
  ;VarSetCapacity won't assign anything less than 3 bytes. Meaning: If you
  ;  tell it you want 1 or 2 byte size variable it will give you 3.
  Data_Length  := VarSetCapacity(Data, Num_Bytes, 0)
  ;msgbox, Data_Length=%Data_Length%
	;Bytes_Received := 0

  ;###### Read the data from the COM Port ######
  ;msgbox, SERIAL_FileHandle=%SERIAL_FileHandle% `nNum_Bytes=%Num_Bytes%
  Read_Result := DllCall("ReadFile"
       ,"UInt" , SERIAL_FileHandle   ; hFile
       ,"Str"  , Data             ; lpBuffer
       ,"Int"  , Num_Bytes        ; nNumberOfBytesToRead
       ,"UInt*", Bytes_Received   ; lpNumberOfBytesReceived
       ,"Int"  , 0)               ; lpOverlapped
  ;MsgBox, Read_Result=%Read_Result% `nBR=%Bytes_Received% ,`nData=%Data%
  If (Read_Result <> 1){
    MsgBox, There is a problem with Serial Port communication. `nFailed Dll ReadFile on COM Port, result=%Read_Result% - The Script Will Now Exit.
    Serial_Close(SERIAL_FileHandle)
    Exit
  }

  ;###### Format the received data ######
  ;This loop is necessary because AHK doesn't handle NULL (0x00) characters very nicely.
  ;Quote from AHK documentation under DllCall:
  ;     "Any binary zero stored in a variable by a function will hide all data to the right
  ;     of the zero; that is, such data cannot be accessed or changed by most commands and
  ;     functions. However, such data can be manipulated by the address and dereference operators
  ;     (& and *), as well as DllCall itself."
  i = 0
  Data_HEX =
  Loop %Bytes_Received% {
    ;First byte into the Rx FIFO ends up at position 0

    Data_HEX_Temp := NumGet(Data, i, "UChar") ;Convert to HEX byte-by-byte
    StringTrimLeft, Data_HEX_Temp, Data_HEX_Temp, 2 ;Remove the 0x (added by the above line) from the front

    ;If there is only 1 character then add the leading "0'
    Length := StrLen(Data_HEX_Temp)
    If (Length =1)
      Data_HEX_Temp = 0%Data_HEX_Temp%

    i++

    ;Put it all together
    Data_HEX .= Data_HEX_Temp
  }
  ;MsgBox, Read_Result=%Read_Result% `nBR=%Bytes_Received% ,`nData_HEX=%Data_HEX%

  SetFormat, Integer, DEC
  Data := Data_HEX

  Return Data

}

;########################################################################
;###### Read from COM Subroutines #######################################
;########################################################################
Serial_Read_Raw(SERIAL_FileHandle, Num_Bytes, mode = "",byref Bytes_Received = ""){
  ;Global SERIAL_FileHandle
  ;Global SERIAL_Port
  ;Global Bytes_Received
  SetFormat, Integer, HEX

  ;Set the Data buffer size, prefill with 0x55 = ASCII character "U"
  ;VarSetCapacity won't assign anything less than 3 bytes. Meaning: If you
  ;  tell it you want 1 or 2 byte size variable it will give you 3.
  Data_Length  := VarSetCapacity(Data, Num_Bytes, 0)
  ;msgbox, Data_Length=%Data_Length%


  ;###### Read the data from the COM Port ######
  ;msgbox, SERIAL_FileHandle=%SERIAL_FileHandle% `nNum_Bytes=%Num_Bytes%
  Read_Result := DllCall("ReadFile"
       ,"UInt" , SERIAL_FileHandle   ; hFile
       ,"Str"  , Data             ; lpBuffer
       ,"Int"  , Num_Bytes        ; nNumberOfBytesToRead
       ,"UInt*", Bytes_Received   ; lpNumberOfBytesReceived
       ,"Int"  , 0)               ; lpOverlapped
  ;MsgBox, Read_Result=%Read_Result% `nBR=%Bytes_Received% ,`nData=%Data%
  If (Read_Result <> 1){
    MsgBox, There is a problem with Serial Port communication. `nFailed Dll ReadFile on COM Port, result=%Read_Result% - The Script Will Now Exit.
    Serial_Close(SERIAL_FileHandle)
    Exit
  }

  ;if you know the data coming back will not contain any binary zeros (0x00), you can request the 'raw' response
  If (mode = "raw")
    Return Data

  ;###### Format the received data ######
  ;This loop is necessary because AHK doesn't handle NULL (0x00) characters very nicely.
  ;Quote from AHK documentation under DllCall:
  ;     "Any binary zero stored in a variable by a function will hide all data to the right
  ;     of the zero; that is, such data cannot be accessed or changed by most commands and
  ;     functions. However, such data can be manipulated by the address and dereference operators
  ;     (& and *), as well as DllCall itself."
  i = 0
  Data_HEX =
  Loop %Bytes_Received% 
  {
    ;First byte into the Rx FIFO ends up at position 0

    Data_HEX_Temp := NumGet(Data, i, "UChar") ;Convert to HEX byte-by-byte
    StringTrimLeft, Data_HEX_Temp, Data_HEX_Temp, 2 ;Remove the 0x (added by the above line) from the front

    ;If there is only 1 character then add the leading "0'
    Length := StrLen(Data_HEX_Temp)
    If (Length =1)
      Data_HEX_Temp = 0%Data_HEX_Temp%

    i++

    ;Put it all together
    Data_HEX .= Data_HEX_Temp
  }
  ;MsgBox, Read_Result=%Read_Result% `nBR=%Bytes_Received% ,`nData_HEX=%Data_HEX%

  SetFormat, Integer, DEC
  Data := Data_HEX

  Return Data

}