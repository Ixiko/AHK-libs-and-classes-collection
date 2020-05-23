/*
---------------------------------------------------------------------------
Function:
    Serial ( COM ) Port Console Script
---------------------------------------------------------------------------
*/

class SerialPort {
    __New( _Number, _Baud, _Parity, _Data, _Stop ) {
        _Settings := _Number ":baud=" _Baud
        _Settings .= " parity=" _Parity
        _Settings .= " data=" _Data
        _Settings .= " stop=" _Stop
        _Settings .= " dtr=off" ; to=off xon=off odsr=off octs=off rts=off idsr=off

        ; ###### Build COM DCB ######
        ; Creates the structure that contains the COM Port number, baud rate,...
        VarSetCapacity( DCB, 28 )
        BCD_Result := DllCall( "BuildCommDCB"
            , "str" , _Settings ; lpDef
            , "UInt", &DCB )    ; lpDCB
        if ( BCD_Result <> 1 )
            this._Error( "Failed Dll BuildCommDCB`nBCD_Result=" BCD_Result )

        ; ###### Extract/Format the COM Port Number ######
        SERIAL_Port_Temp := StrSplit( _Settings, "`:" )
        if ( StrLen( SERIAL_Port_Temp[1] ) > 4 )      ; For COM Ports > 9 \\.\ needs to prepended to the COM Port name.
            SERIAL_Port := "\\.\" SERIAL_Port_Temp[1] ; So the valid names are        
        else                                          ;  ... COM8  COM9   \\.\COM10  \\.\COM11  \\.\COM12 and so on...
            SERIAL_Port := SERIAL_Port_Temp[1]
        ; MsgBox, SERIAL_Port=%SERIAL_Port%

        ; ###### Create COM File ######
        ; Creates the COM Port File Handle
        this.FileHandle := DllCall( "CreateFile"
            , "Str" , SERIAL_Port ; File Name
            , "UInt", 0xC0000000  ; Desired Access
            , "UInt", 3           ; Safe Mode
            , "UInt", 0           ; Security Attributes
            , "UInt", 3           ; Creation Disposition
            , "UInt", 0           ; Flags And Attributes
            , "UInt", 0           ; Template File
            , "Cdecl Int" )
        if ( this.FileHandle < 1 )
            this._Error( "Failed Dll CreateFile`nSerial_FileHandle=" this.FileHandle )

        ; ###### Set COM State ######
        ; Sets the COM Port number, baud rate,...
        SCS_Result := DllCall( "SetCommState"
            , "UInt", this.FileHandle ; File Handle
            , "UInt", &DCB )          ; Pointer to DCB structure
        if ( SCS_Result <> 1 )
            this._Error( "Failed Dll SetCommState`nSCS_Result=" SCS_Result, true )

        ; ###### Create the SetCommTimeouts Structure ######
        ReadIntervalTimeout        = 0xffffffff
        ReadTotalTimeoutMultiplier = 0x00000000
        ReadTotalTimeoutConstant   = 0x00000000
        WriteTotalTimeoutMultiplier= 0x00000000
        WriteTotalTimeoutConstant  = 0x00000000

        VarSetCapacity( Data, 20, 0 ) ; 5 * sizeof( DWORD )
        NumPut( ReadIntervalTimeout,         Data,  0, "UInt" )
        NumPut( ReadTotalTimeoutMultiplier,  Data,  4, "UInt" )
        NumPut( ReadTotalTimeoutConstant,    Data,  8, "UInt" )
        NumPut( WriteTotalTimeoutMultiplier, Data, 12, "UInt" )
        NumPut( WriteTotalTimeoutConstant,   Data, 16, "UInt" )

        ;###### Set the COM Timeouts ######
        SCT_Result := DllCall( "SetCommTimeouts"
            , "UInt", this.FileHandle ; File Handle
            , "UInt", &Data )         ; Pointer to the data structure
        if ( SCT_Result <> 1 )
            this._Error( "Failed Dll SetCommTimeouts`nSCT_Result=" SCT_Result, true )
    }

    Close() {
        ; ###### Close the COM File ######
        CH_Result := DllCall( "CloseHandle", "UInt", this.FileHandle )
        if ( CH_Result <> 1 )
            this._Error( "Failed Dll CloseHandle`nCH_Result=" CH_Result, false, false )
    }

    Write( _Message ) {
        ; Parse the Message.
        Byte := StrSplit( _Message, "," )
        Data_Length := Byte.MaxIndex() ? Byte.MaxIndex() : 0

        ; Set the Data buffer size, prefill with 0xFF.
        VarSetCapacity( Data, Data_Length, 0xFF )

        ; Write the Message into the Data buffer
        Loop % Data_Length
            NumPut( Byte[ A_Index ], Data, A_Index - 1, "UChar" )
        ; MsgBox, Data string=%Data%

        ; ###### Write the data to the COM Port ######
        WF_Result := DllCall( "WriteFile"
            , "UInt" , this.FileHandle ; File Handle
            , "UInt" , &Data           ; Pointer to string to send
            , "UInt" , Data_Length     ; Data Length
            , "UInt*", Bytes_Sent      ; Returns pointer to num bytes sent
            , "Int"  , "NULL" )
        if ( WF_Result <> 1 or Bytes_Sent <> Data_Length )
            this._Error( "Failed Dll WriteFile`nWF_Result=" WF_Result, false, false )

        return Bytes_Sent
    }

    Read( _Num_Bytes, _Mode = "" ) {
        ; Set the Data buffer size, prefill with 0x55 = ASCII character "U"
        ; VarSetCapacity won't assign anything less than 3 bytes.
        ; Meaning: If you tell it you want 1 or 2 byte size variable it will give you 3.
        VarSetCapacity( Data, _Num_Bytes, 0 )
        ; MsgBox, Data_Length=%Data_Length%

        ; ###### Read the data from the COM Port ######
        ; MsgBox, this.FileHandle=%this.FileHandle% `nNum_Bytes=%_Num_Bytes%
        RF_Result := DllCall( "ReadFile"
            , "UInt" , this.FileHandle ; hFile
            , "Str"  , Data            ; lpBuffer
            , "Int"  , _Num_Bytes       ; nNumberOfBytesToRead
            , "UInt*", Bytes_Received  ; lpNumberOfBytesReceived
            , "Int"  , 0 )             ; lpOverlapped
        if ( RF_Result <> 1 ) {
            this._Error( "Failed Dll ReadFile`nRF_Result=" RF_Result, false, false )
        }

        ; if you know the data coming back will not contain any binary zeros (0x00), you can request the 'raw' response
        if ( _Mode = "raw" )
            return Data

        ; ###### Format the received data ######
        ; This loop is necessary because AHK doesn't handle NULL (0x00) characters very nicely.
        ; Quote from AHK documentation under DllCall:
        ;      "Any binary zero stored in a variable by a function will hide all data to the right
        ;      of the zero; that is, such data cannot be accessed or changed by most commands and
        ;      functions. However, such data can be manipulated by the address and dereference operators
        ;      (& and *), as well as DllCall itself."
        Loop %Bytes_Received% {
            ; First byte into the Rx FIFO ends up at position 0
            Data_HEX_Temp := Format( "{:x}", NumGet( Data, A_Index - 1, "UChar" ) ) ; Convert to HEX byte-by-byte

            ; If there is only 1 character then add the leading "0'
            if ( StrLen( Data_HEX_Temp ) == 1 )
                Data_HEX_Temp = 0%Data_HEX_Temp%

            ; Put it all together
            Data_HEX .= Data_HEX_Temp
        }
        ; MsgBox, Read_Result=%Read_Result% `nBR=%Bytes_Received% ,`nData_HEX=%Data_HEX%

        return Data_HEX
    }

    Send( _Data ) {
        Loop, Parse, _Data     
            str .= "," Asc( A_LoopField )

        str := SubStr( str, 2, StrLen( str ) - 1 )
        str .= "," 10

        return this.Write( str )
    }

    Receive( _Length ) {
        Read_Data := this.Read( _Length )

        Loop % StrLen( Read_Data ) / 2
        { 
            Byte := SubStr( Read_Data, 1, 2 )
            Read_Data := SubStr( Read_Data, 3, StrLen( Read_Data ) )
            Byte := "0x" Byte

            if ( Byte == "0x09" )
                ASCII_Chr = #Tab#
            else if ( Byte == "0x20" )
                ASCII_Chr = #Space#
            else
                ASCII_Chr := Chr( Byte )

            ASCII .= ASCII_Chr
        }

        ASCII := StrReplace( ASCII, "#Tab#", A_Tab )
        ASCII := StrReplace( ASCII, "#Space#", A_Space )

        return ASCII
    }

    _Error( _Message, _Close = false, _Exit = true ) {
        Final_Message :="There is a problem with Serial Port communication.`n`n" _Message "`n`n"

        if _Close
            this.Close()

        if _Exit
            Final_Message .= "This script will now exit. "

        Final_Message .= "Error: " DllCall( "GetLastError" )

        MsgBox % Final_Message

        if _Exit
            ExitApp
    }
}
