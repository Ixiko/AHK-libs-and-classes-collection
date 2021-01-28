/* Title:	IPC
			*Inter-Process Communication*.
 :
			An AHK script or DotNet application can use this module to send text or binary data to another AHK script or DotNet application using WM_COPYDATA message.
			AHK module is implemented in IPC.ahk. DotNet library is implemented in IPC.cs. API is the same up to the language differences.

 */

/*
 Function:	 Send
			 Send the message to another process (receiver).

 Parameters:
			 Hwnd	- Handle of the receiver.
			 Data	- Data to be sent, by default empty. Optional.
			 Port	- Port, by default 100. Positive integer. Optional.
			 DataSize - If this parameter is used, Data contains pointer to the buffer holding binary data.
						Omit this parameter to send textual messages to the receiver.					 

 Remarks:
			The data being passed must not contain pointers or other references to objects not accessible to the script receiving the data. 
			While this message is being sent, the referenced data must not be changed by another thread of the sending process. 
			The receiving script should consider the data read-only. The receiving script should not free the memory referenced by Data parameter.
			If the receiving script must access the data after function returns, it must copy the data into a local buffer.

			This function uses Gui +Lastfound to obtain the handle of the sender.

 Returns:
			Returns TRUE if message was or FALSE if sending failed. Error message is returned on invalid usage.
 */
IPC_Send(Hwnd, Data="", Port=100, DataSize="") {
	static WM_COPYDATA = 74, INT_MAX=2147483647
	if Port not between 0 AND %INT_MAX%
		return A_ThisFunc "> Port number is not in a positive integer range: " Port

	if (DataSize = "")
		 DataSize := StrLen(Data)+1, pData := &Data, Port := -Port			;use negative port for textual messages
	else pData := Data

	VarSetCapacity(COPYDATA, 12)
	 , NumPut(Port,		COPYDATA, 0)
	 , NumPut(DataSize, COPYDATA, 4)             
	 , NumPut(pData,	COPYDATA, 8)             
	
	Gui, +LastFound	 
   	SendMessage, WM_COPYDATA, WinExist(), &COPYDATA,, ahk_id %Hwnd%
	return ErrorLevel="FAIL" ? false : true
}

/*
  Function:	 SetHandler
 			 Set the data handler.
 
  Parameters:
 			 Handler - Function that will be called when data is received. 					 
 
  Handler:
  >			 Handler(Hwnd, Data, Port, DataSize)

			 Hwnd	- Handle of the window passing data.
			 Data	- Data that is received.
			 Port	- Data port.
			 DataSize - If DataSize is not empty, Data is pointer to the actuall data. Otherwise Data is textual message.
 */
IPC_SetHandler( Handler ){
	static WM_COPYDATA = 74

	if !IsFunc( Handler )
		return A_ThisFunc "> Invalid handler: " Handler
	
	OnMessage(WM_COPYDATA, "IPC_onCopyData")
	IPC_onCopyData(Handler, "")
}


IPC_onCopyData(WParam, LParam) {
	static Handler
	if Lparam =
		return  Handler := WParam
		
	port := NumGet(Lparam+0, 0, "Int"), data := NumGet(Lparam+8)
	if port < 0
		 data := DllCall("MulDiv", "Int", data, "Int",1, "Int", 1, "str"), port := -port
	else size := NumGet(LParam+4)

	%handler%(WParam, data, port, size)
	return 1
}

/* 
 Group: About 
 	o IPC AHK & .Net library ver 2.6 by majkinetor.
	o Fixes for 64b systems of IPC.cs made by Lexikos.
	o MSDN Reference: <http://msdn.microsoft.com/en-us/library/ms649011(VS.85).aspx>
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>
 */