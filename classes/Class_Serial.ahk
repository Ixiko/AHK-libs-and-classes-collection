/*
Class Serial
Created by ShatterCoder
This class was built on the original work of the creator of Seral.ahk https://autohotkey.com/board/topic/26231-serial-com-port-console-script/page-2

Purpose:
	This class was created to make sending and recieving serial data as painless as possible using ASCII input and output. It was not desiged for efficiency, but rather ease of use.


Methods:

	***************************************************************************************************************************************************************
	Event_Parse_Start(Register_Function := "__NONE__", Delims := "`r`n", Omit_Chars := "", Seperator := "`n", Poll_Interval := 100)

	This Method is intended to continuously recieve and parse data from the COM port specified by the obj.COM_port property

		Resister_Function - Pass the name of a function no paren's () to register it to be called each time a "chunk" of data has been recieved
			Chunks are defined by the Delims Param defined below
			Default: No function is called, instead all data is stored in obj.AllRecieved and obj._Recieved_Partial will have any partial messages remaining
			if you specify a function name each time a chunk is parsed it will call your function and pass it the chunk (string) as the only parameter
			See Example Usage below for an example of this

		Delims - This parameter is used to pass the characters you would like to use to define the end of a "chunk" of serial communication
			Note: an array of delims may be passed if you desire to have the data parsed based on more than one criteria
			example: Event_Parse_Start("MyFunc",["`r`r", "%"])
			if the data stream contains:%CAN81NAC%%CAN42NAC%PP000500000000001P004000035000360`r`r
			MyFunc will be triggered 3 times with CAN81NAC, CAN42NAC, PP000500000000001P004000035000360 passed to it respectively
			or using Event_Parse_Start("MyFunc",["`r`r", "NAC%"], "%CAN") you would get 81, 42, PP000500000000001P004000035000360 passed to it respectively

			Defualt: `r`n

		Omit_Chars - Used to signify characters you would like to ommit from your comminication
			Default: by default no chars are ommited
		Seperator - Used to specify how chunks are seperated in this.AllRecieved
			Default: `n
		Poll_Interval - interval in ms to wait between each reading of the serial register
			Default: 100 ms

		Example Usage:
			Com3 := New SerialCOM("COM3")
			Com3.Event_Parse_Start("MyFunc", "`n")

			MyFunc(Input)
			{
				msgbox, % "sweet! just recieved the following: `n" Input
				return
			}

			Esc::
			Com3.Event_Parse_Stop()
			return


	***************************************************************************************************************************************************************
	Event_Parse_Stop()
		Simple method to stop the event reader, and disconnect from the COM device.

	***************************************************************************************************************************************************************
	Send_Message(asciiMessage)
		One stop method will open the COM port, send the message, then close the COM port once finished,
		meant for infrequently sent communications.

	***************************************************************************************************************************************************************
	Begin_Send_Stream() ; send_to_stream(asciiMessage) ; Close_Send_Stream()
		These 3 methods are used to send constant data, obj.Begin_Send_Stream() Opens the port and allows you to send data via
		obj.send_to_stream() When you are finished sending simply call the obj.Close_Send_Stream() method to Close out the port.

		asciiMessage - any number or string you wish to send over the COM port. it's automatically converted to hex and sent

		Example Usage:
			MyCom := New SerialCOM()
			MyCom.Begin_Send_Stream()

			Loop, 60
			{
				MyCom.send_to_stream(A_Now)
				sleep, 1000
			}

			MyCom.Close_Send_Stream()

	***************************************************************************************************************************************************************
	Properties:

		This.COM_FileHandle
			A pointer to the ComPort object -- this will be blank if not connected
		this.Chunk
			String -- Contains the last Chunk recieved while Event_Parse_Start() was active
		This.AllRecieved
			String -- Contains all data recieved while Event_Parse_Start() was active sperated by which ever seperator was specified (`n by default)

*/

Class Serial
{
	__AscToHex(str) {
		Return str="" ? "":Chr((Asc(str)>>4)+48) Chr((x:=Asc(str)&15)+(x>9 ? 55:48)) this.__AscToHex(SubStr(str,2))
	}

	__New( Port := "COM1", Baud := 9600, Parity := "N", Data := 8, Stop := 1)
	{
		this._Recieved_Partial := ""
		this.COM_Port := Port
		this.Baud_Rate := Baud
		this.Parity := Parity
		this.Data_Bits := Data
		this.Stop_Bits := Stop
		this.COM_FileHandle := ""
		this.Bytes_Recieved := ""
	}

	__Delete()
	{
		if  this.COM_FileHandle != ""
			this.__Close_COM()
	}
	__Open_Port()
	{
		if this.COM_FileHandle != ""
			return -1
		Settings_String := this.COM_Port ":baud=" this.Baud_Rate " parity=" this.Parity " data=" this.Data_Bits " stop=" this.Stop_Bits " dtr=Off"
		;###### Build COM DCB ######
		;Creates the structure that contains the COM Port number, baud rate,...
		VarSetCapacity(DCB, 28)
		While (BCD_Result != 1)
		{
			BCD_Result := DllCall("BuildCommDCB" ,"str" , Settings_String,"UInt", &DCB)
			if (BCD_Result != 1)
			{
				MsgBox, 262196,COM failure ,it appears that the device may not be connected to %COM_Port%. Would you like to change COM ports?
				IfMsgBox, Yes
				{
					InputBox, COM_Port, Select New COM port, Which COM port should be selected(COM1`, COM2 etc. Note ALLCAPS and no spaces)?
				}
				IfMsgBox, No
					return 0
			}
		}
		COM_Port_Len := StrLen(This.COM_Port)  ;For COM Ports > 9 \\.\ needs to prepended to the COM Port name.
		If COM_Port_Len > 4)                   ;So the valid names are
			This.COM_Port := "\\.\" This.COM_Port             ; ... COM8  COM9   \\.\COM10  \\.\COM11  \\.\COM12 and so on...
		Else                                          ;
			This.COM_Port := This.COM_Port


		This.COM_FileHandle := DllCall("CreateFile"
       ,"Str" , This.COM_Port     ;File Name
       ,"UInt", 0xC0000000   ;Desired Access
       ,"UInt", 3            ;Share Mode
       ,"UInt", 0            ;Security Attributes
       ,"UInt", 3            ;Creation Disposition
       ,"UInt", 0            ;Flags And Attributes
       ,"UInt", 0            ;Template File
       ,"Cdecl Int")
		While (this.COM_FileHandle < 1)
		{
			This.COM_FileHandle := DllCall("CreateFile"
		   ,"Str" , This.COM_Port     ;File Name
		   ,"UInt", 0xC0000000   ;Desired Access
		   ,"UInt", 3            ;Share Mode
		   ,"UInt", 0            ;Security Attributes
		   ,"UInt", 3            ;Creation Disposition
		   ,"UInt", 0            ;Flags And Attributes
		   ,"UInt", 0            ;Template File
		   ,"Cdecl Int")
		   if (A_index > 20) ;times out after ~ 2 seconds
			{
				MsgBox, % "There is a problem with Serial Port communication. `nFailed Dll CreateFile, COM_FileHandle=" this.COM_FileHandle " `nThe Script Will Now Exit."
				Exit
			}
			sleep, 100
		}
		SCS_Result := DllCall("SetCommState"
			   ,"UInt", this.COM_FileHandle ;File Handle
			   ,"UInt", &DCB)          ;Pointer to DCB structure
		If (SCS_Result <> 1)
		{
			MsgBox, There is a problem with Serial Port communication. `nFailed Dll SetCommState, SCS_Result=%SCS_Result% `nThe Script Will Now Exit.
			this.__Close_COM()
			ErrorDrivenRetry := 1
			return
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
			 ,"UInt", this.COM_FileHandle ;File Handle
			 ,"UInt", &Data)         ;Pointer to the data structure
		If (SCT_result <> 1)
		{
			MsgBox, There is a problem with Serial Port communication. `nFailed Dll SetCommState, SCT_result=%SCT_result% `nThe Script Will Now Exit.
			this.__Close_COM()
			Exit
		}

	}

	__Close_COM()
	{
		;###### Close the COM File ######
		CH_result := DllCall("CloseHandle", "UInt", this.COM_FileHandle)
		If (CH_result <> 1)
			MsgBox, % "Failed Dll CloseHandle CH_result=" CH_result
		this.COM_FileHandle := ""
	  Return
	}

	__Write_to_COM(Message)
	{
		Data_Length := 1
		Loop, Parse, Message, `,
		{
			Data_Length ++
		}

	  ;Set the Data buffer size, prefill with 0xFF.
		VarSetCapacity(Data, Data_Length, 0xFF)

		Loop, Parse, Message, `,
		{
			NumPut(A_loopfield, Data, (A_index-1), "UChar")
		}
	  ;###### Write the data to the COM Port ######
		WF_Result := DllCall("WriteFile"
		   ,"UInt" , this.COM_FileHandle ;File Handle
		   ,"UInt" , &Data          ;Pointer to string to send
		   ,"UInt" , Data_Length    ;Data Length
		   ,"UInt*", Bytes_Sent     ;Returns pointer to num bytes sent
		   ,"Int"  , "NULL")
		If (WF_Result != 1 or Bytes_Sent != Data_Length)
		{
			Sleep, 10
			WF_Result := DllCall("WriteFile"
			   ,"UInt" , this.COM_FileHandle ;File Handle
			   ,"UInt" , &Data          ;Pointer to string to send
			   ,"UInt" , Data_Length    ;Data Length
			   ,"UInt*", Bytes_Sent     ;Returns pointer to num bytes sent
			   ,"Int"  , "NULL")
			If (WF_Result <> 1 or Bytes_Sent <> Data_Length)
				MsgBox, % "Failed Dll WriteFile to " this.COM_Port ", result=" WF_Result " `nData Length=" Data_Length " `nBytes_Sent=" Bytes_Sent
		}
	}

	__Read_from_COM(Num_Bytes)
	{
		this.Bytes_Received := 0
	  ;Set the Data buffer size, prefill with 0x55 = ASCII character "U"
		VarSetCapacity(Data, Num_Bytes, 0x55)
		;~ Num_Bytes := Format("{:X}", Num_Bytes)
	  ;###### Read the data from the COM Port ######
		Read_Result := DllCall("ReadFile"
		   ,"UInt" , this.COM_FileHandle   ; hFile
		   ,"Str"  , Data             ; lpBuffer
		   ,"Int"  , Num_Bytes        ; nNumberOfBytesToRead
		   ,"UInt*", Bytes_Received   ; lpNumberOfBytesReceived
		   ,"Int"  , 0)               ; lpOverlapped
		   sleep, 10
		   this.Bytes_Received := Bytes_Received
		If (Read_Result != 1)
		{
			MsgBox, % "There is a problem with Serial Port communication. `nFailed Dll ReadFile on " COM_Port ", result=" Read_Result " - The Script Will Now Exit."
			this.__Close_COM()
			Exit
		}
		i := 0
		Data_HEX := ""
		Loop % this.Bytes_Received
		{
			;First byte into the Rx FIFO ends up at position 0
			Data_HEX_Temp := Format("{:x}", NumGet(Data, i, "UChar")) ;Convert to HEX byte-by-byte
			Length := StrLen(Data_HEX_Temp)
			If (Length =1)
				Data_HEX_Temp := "0" Data_HEX_Temp
			i++
			;Put it all together
			Data_HEX := Data_HEX  Data_HEX_Temp
		}
		if (Data_HEX != "")
			this.Last_Recieved_HEX := Data_HEX
		Return Data_HEX
	}

	Event_Parse_Start(Register_Function := "__NONE__", Delims := "`r`n", Omit_Chars := "", Seperator := "`n", Poll_Interval := 100)
	{
		this._Event_delims := Delims
		this._Event_Omit_Chars := Omit_Chars
		this._Event_Registered_Function := Register_Function
		this._Event_Seperator := Seperator
		this.__Open_Port()
		this.__start_timer(Poll_Interval)
	}

	__start_timer(Poll_Interval)
	{
		this.__timer_handle := mthd := this.__Check_Read_Register.bind(this)
		SetTimer, % mthd, % Poll_Interval
	}

	Event_Parse_Stop()
	{
		if (this.__timer_handle != "")
		{
			mthd := this.__timer_handle
			settimer, % mthd, off
			this.__timer_handle := ""
		}
		if (this.COM_FileHandle != "")
			this.__Close_COM()
	}

	__Check_Read_Register() ;called by the timer, this function reads the serial buffer and updates this.AllRecieved and this._Recieved_Partial. Also watches for "chunks" defined by delims and calls registered function when a chunk is found (passing the chunk to the function)
	{
		static Partial
		mthd := this.__timer_handle
		settimer, % mthd, off
		ReceivedMessage := this.__Read_from_COM("0xFF")
		partial := this._Recieved_Partial .= Translated := this.__HexToASCII(ReceivedMessage)
		Registered_Function := this._Event_Registered_Function
		if (!IsObject(this._Event_delims))
		{
			if (InStr(this._Recieved_Partial, this._Event_delims))
			{
				parts := StrSplit(this._Recieved_Partial, this._Event_delims, this._Event_Omit_Chars )
				loop, % parts.count()
				{
					if (A_index = parts.count() && A_index > 1)
					  this._Recieved_Partial := parts[A_index]
					else
					{
						var := parts[A_index]
						if var is not space
						{
							this.AllRecieved .= this.Chunk := parts[A_index] this._Event_Seperator
							if (this._Event_Registered_Function != "__NONE__")
								%Registered_Function%(this.Chunk)
						}
					}
				}
			}
		}
		else
		{
			loop, % this._Event_delims.count()
			{
				if (InStr(this._Recieved_Partial, this._Event_delims[A_index]))
				{
					parts := StrSplit(this._Recieved_Partial, this._Event_delims[A_index], this._Event_Omit_Chars)
					loop, % parts.count()
					{
						if (A_index = parts.count() && A_index > 1)
						{
							obj := this.__Check_Delims(parts[A_index], this._Event_delims)
							if (obj[1] != "")
								for k, v in obj[1]
								{
									this.AllRecieved .= this.Chunk := v this._Event_Seperator
									if (this._Event_Registered_Function != "__NONE__")
										%Registered_Function%(v)
								}
							this._Recieved_Partial := obj[2]
						}
						else if parts[A_index] != ""
						{
							obj := this.__Check_Delims((this.Chunk := parts[A_index]), this._Event_delims)
							if (obj[1] != "")
								for k, v in obj[1]
								{
									this.Chunk := v
									this.AllRecieved .= v this._Event_Seperator
									if (this._Event_Registered_Function != "__NONE__")
										%Registered_Function%(this.Chunk)
								}
							this.Chunk := obj[2]
							this.AllRecieved .= obj[2] this._Event_Seperator
							if (this._Event_Registered_Function != "__NONE__")
								%Registered_Function%(obj[2])
						}

					}
				}
			}
		}
		SetTimer, % mthd, % Poll_Interval
		return
	}

	__Check_Delims(str, delims)
	{
		ret_obj := []
		chunk := []
		Partial := str
		loop, % delims.count() - 1
		{
			if (pos := InStr(str, delims[A_index + 1]))
			{
				parts := StrSplit(str, delims[A_index + 1])
				loop, % parts.count()
				{
					if (A_index = parts.count() && A_index > 1)
						Partial := parts[A_index]
					else if parts[A_index] != ""
						chunk.push(parts[A_index])
				}
				return ret_obj := [chunk, Partial]
			}
		else
            Partial := str
		}
		return ret_obj := [chunk, Partial]
    }

	__HexToASCII(ReceivedMessage)
	{
		loopcount := StrLen(ReceivedMessage) / 2
		AsciiTranslation := ""
		loop, % loopcount
		{
			CurrentAscii := chr(CurrentHex := "0x" SubStr(ReceivedMessage, 1, 2)) ;take a byte, convert from Hex to Ascii
			ReceivedMessage := SubStr(ReceivedMessage, 3) ;remove translated byte
			AsciiTranslation .= CurrentAscii ;creates a single raw string of translated (into ASCII) text. Further formating may be needed
		}
		return AsciiTranslation
	}

	Send_Message(asciiMessage)
	{

		this.__Open_Port()
		this.send_to_stream(asciiMessage)
		this.__Close_COM()
	}

	Begin_Send_Stream()
	{
		this.__Open_Port()
		return 1
	}

	Close_Send_Stream()
	{
		this.__Close_COM()
		return 1
	}

	send_to_stream(asciiMessage)
	{
		rawHex := this.__AscToHex(asciiMessage)
		hexLngth := Floor(StrLen(rawHex)/2)
		Message := "0x"
		while, hexLngth>A_Index-1
		{
			if(A_index > 1)
				Message .= ", 0x"
			ValueToAdd := substr(rawHex, A_index *2-1, 2)
			Message .= ValueToAdd
		}
		this.__Write_to_COM(Message)
	}
}
