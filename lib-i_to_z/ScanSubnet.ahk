;ScanSubnet() Basically Does what all those IP scanners do,with WMI...Pretty Darn Fast Too,almost as fast as Nmap.

Msgbox % ScanSubnet()	;scan all active network adapters for active IP's... if no ip's were specified...
;Msgbox % ScanSubnet("192.168.2.1 192.168.43.1 192.168.56.1")	;find all ip's in the specified address subnets...ex. 192.168.2.(1-255)


ScanSubnet(addresses:="") {	;pings IP ranges & returns active IP's
	BL := A_BatchLines
	SetBatchLines, -1
	If !addresses{	;scan all active network adapters/connections for active IP's... if no ip's were specified...
		colItems := ComObjGet( "winmgmts:" ).ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
		while colItems[objItem]
			addresses .= addresses ? " " objItem.IPAddress[0] : objItem.IPAddress[0]
	}
	
	Loop, Parse, addresses, % A_Space
	{
		If ( A_LoopField && addrArr := StrSplit(A_LoopField,".") )
			Loop 256
				addr .= addr ? A_Space "or Address = '" addrArr.1 "." addrArr.2 "." addrArr.3 "." A_Index-1 "'" : "Address = '" addrArr.1 "." addrArr.2 "." addrArr.3 "." A_Index-1 "'"
		colPings := ComObjGet( "winmgmts:" ).ExecQuery("Select * From Win32_PingStatus where " addr "")._NewEnum
		While colPings[objStatus]
			rVal .= (oS:=(objStatus.StatusCode="" or objStatus.StatusCode<>0)) ? "" : (rVal ? "`n" objStatus.Address : objStatus.Address)
		addr := ""	;the quota on Win32_PingStatus prevents more than roughtly two ip ranges being scanned simultaneously...so each range is scanned individually.
	}
	SetBatchLines, % BL
	Return rVal
}
