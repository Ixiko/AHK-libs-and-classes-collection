; Ping() - http://ahkscript.org/boards/viewtopic.php?f=5&t=349#p3292

Ping(Address="8.8.8.8",Timeout = 1000,ByRef Data = "",Length = 0,ByRef Result = "",ByRef ResultLength = 0) {
	NumericAddress := DllCall("ws2_32\inet_addr","AStr",Address,"UInt")
	If NumericAddress = 0xFFFFFFFF ;INADDR_NONE
		Return 0 ;throw Exception("Could not convert IP address string to numeric format.")

	If DllCall("LoadLibrary","Str","icmp","UPtr") = 0 ;NULL
		Return 0 ;throw Exception("Could not load ICMP library.")

	hPort := DllCall("icmp\IcmpCreateFile","UPtr") ;open port
	If hPort = -1 ;INVALID_HANDLE_VALUE
		Return 0 ;throw Exception("Could not open port.")

	StructLength := 278 ;ICMP_ECHO_REPLY structure
	VarSetCapacity(Reply,StructLength)
	Count := DllCall("icmp\IcmpSendEcho","UPtr",hPort,"UInt",NumericAddress,"UPtr",&Data,"UShort",Length,"UPtr",0,"UPtr",&Reply,"UInt",StructLength,"UInt",Timeout)

	If NumGet(Reply,4,"UInt") = 11001 ;IP_BUF_TOO_SMALL
	{
		VarSetCapacity(Reply,StructLength * Count)
		DllCall("icmp\IcmpSendEcho","UPtr",hPort,"UInt",NumericAddress,"UPtr",&Data,"UShort",Length,"UPtr",0,"UPtr",&Reply,"UInt",StructLength * Count,"UInt",Timeout)
	}

	If NumGet(Reply,4,"UInt") != 0 ;IP_SUCCESS
		Return 0 ;throw Exception("Could not send echo.")

	If !DllCall("icmp\IcmpCloseHandle","UInt",hPort) ;close port
		Return 0 ;throw Exception("Could not close port.")

	ResultLength := NumGet(Reply,12,"UShort")
	VarSetCapacity(Result,ResultLength)
	DllCall("RtlMoveMemory","UPtr",&Result,"UPtr",NumGet(Reply,16),"UPtr",ResultLength)
	Return, NumGet(Reply,8,"UInt")
}