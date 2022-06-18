; **************************************************************************************
; Interprocess communication (IPC) library
; 
; Notes:
; On creation, this class creates a memory mapped file (with what ever name you wish)
; and you can turn on the function to starts listening to system messages. Once 
; received, the class will read the message that should be present on the memory mapped 
; file and run a function with the passed function name and arguements. It responds 
; with a "read" mesasge and a return value, if one is present.
; **************************************************************************************

; *********************
; Functions and classes
; *********************

; Handle messages from VBA sent via System messages
VBA_message_read(wParam, lParam, msg)
{
	global V2AMessages

	if (wParam = 11 and lParam = 11)
	{
		V2AMessages.grabNewMessage(wParam, lParam, msg)
	}
	return
}




; Memory mapped file class
Class MemoryMappedFile_IPC
{
	; Class variables
	ptr := A_PtrSize ? "ptr" : "Uint" 	; determine if 32 or 64 system when using Windows DLL API
	BUFFER_SIZE:= 1000000
	INVALID_HANDLE_VALUE := -1
	PAGE_READWRITE := 0x4
	FILE_MAP_WRITE := 0x2
	FILE_MAP_ALL_ACCESS := 0xF001F
	V2AMessage := ""
	V2AMessageSplit := ""
	V2AMessages := ""
	SEPARATOR := "|"
	messageNumber := 5000
	startMsg := "Started"
	readMsg := "Read"
	closedMsg := "Closed"
	
	
	; Initialise class
	__New(MMFNameTemp = "VBA_2_QS_IPC", listening := True)
	{
		this.MMFName := MMFNameTemp
		this.createMapping()
		this.send(this.startMsg)
		if listening
			OnMessage(this.messageNumber, "VBA_message_read")
		return this
	}


	; Functions
	
	createMapping()
	{
		hMMF := DllCall("CreateFileMapping", this.ptr, this.INVALID_HANDLE_VALUE, this.ptr, 0, "int", this.PAGE_READWRITE, "int", 0, "int", this.BUFFER_SIZE, "Str", this.MMFName)
            
		if (hMMF == 0)
		{
			MsgBox, Error 1
			return 0
		}

		pMemFile := DllCall("MapViewOfFile", this.ptr, hMMF, "int", this.FILE_MAP_ALL_ACCESS, this.ptr, 0, this.ptr, 0, this.ptr, 0)
            
		if (pMemFile == 0)
		{
			MsgBox, Error 2
			return 0
		}
            
		this.hMMF := hMMF
		this.pMemFile := pMemFile
		return			
	}


	send(Func, Argument = "")
	{
		Func := StrReplace(Func, "<", "")
		Func := StrReplace(Func, ">", "")
		Func := StrReplace(Func, "|", "")


		Argument := StrReplace(Argument, "<", "less than")
		Argument := StrReplace(Argument, ">", "more than")
		Argument := StrReplace(Argument, "|", "pipe")
            
		if (Argument == "")
		{
			bufferSend := "<" . Func . ">"
		}
		else
		{
			bufferSend := "<" . Func . this.SEPARATOR . Argument . ">"
		}

		if (StrLen(bufferSend)*(A_Isunicode ? 2 : 1) < this.BUFFER_SIZE)
		{
			strput(bufferSend, this.pMemFile, "UTF-8")
		}
		else
		{
			MsgBox, % "String is larger than allocated memory space"
		}
			
		return
	}
 
 
	read()
	{
		bufferReceived:= strget(this.pMemFile, "UTF-8")
		
		if(InStr(bufferReceived, "<") = 1)
		{
			EndMarkerPosition := InStr(bufferReceived, ">")
        
			if (EndMarkerPosition <> 0)
			{
				return SubStr(bufferReceived, 2, EndMarkerPosition - 2)
			}
			else
			{
				;MsgBox, End marker is missing!
			}      
		}
		else
		{
			;MsgBox, Beginning marker is missing!
		}
			
		return
	}
	  
	  
	grabNewMessage()
	{
		global Developing
		
		newMessage := False

		Loop, 1200 ; = 1 minutes if using 50 msec sleep
		{
			V2AMessage :=  this.Read()
			V2AMessageSplit := StrSplit(V2AMessage, this.SEPARATOR)
			
			if V2AMessageSplit[1] != this.readMsg and V2AMessageSplit[1] != this.startMsg
			{
				newMessage := True
				break
			}
			
			sleep 50
		}
		
		if (newMessage == False)
		{
			MsgBox, % "No new message was ever received from VBA!"
			return False
		}
		
		if (V2AMessageSplit[1] = "close")
		{
			this.send(this.readMsg)
			Msgbox, % "Closing down Quick Spiritum..."
			ExitApp
		}
		else if (V2AMessageSplit[1] <> this.readMsg and V2AMessageSplit[1] <> this.startMsg)
		{
			function := V2AMessageSplit[1]
			
			if (function != "confirmStatus" and Developing)
			{
				TrayTip, %TrayTipTitle%, % " Spiritum database call for function: " . function
			}
			
			returnResult := %function%(V2AMessageSplit[2])

			if (StrLen(returnResult) = 0)
			{ 
				this.send(this.readMsg)
			}
			else
			{
				this.send(this.readMsg,  returnResult)
			}
		}

		return True
	}
	
	
	__Delete()
	{
		this.Send(this.closed.msg)
		DllCall("UnmapViewOfFile", "Ptr", this.pMemFile)
		DllCall("CloseHandle", "Ptr", this.hMMF)
		return
	}
}




confirmStatus(nothing)
{
	return "Running;" . A_ScriptFullPath
}



	
; Used for IPC testing purposes
DisplayMessage(message)
{
      MsgBox, ,Test Message, % message , 3
      return "complete"
}



