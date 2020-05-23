; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=60367&sid=858159eb8d20e046bf05feb1a0b9428d

;~ Msgbox % Ping0("www.google.com")Ping0("www.youtube.com")Ping0("www.idontexist.org")

;~ For k, v in Ping("www.google.com www.yahoo.com www.autohotkey.com 192.168.2.1 www.idontexist.org")
	;~ MsgBox % v.1 "`n" v.2

;~ Msgbox % Ping("www.google.com")[1].1
;~ Msgbox % Ping("127.0.0.1")[1].1 	; replace with your host ip

Ping(addresses) {
	rVal := []
	Loop, Parse, addresses, % A_Space
		addr .= addr ? A_Space "or Address = '" A_LoopField "'" : "Address = '" A_LoopField "'"
	colPings := ComObjGet( "winmgmts:" ).ExecQuery("Select * From Win32_PingStatus where " addr "")._NewEnum
	While colPings[objStatus]
		rVal.Push( [((oS:=(objStatus.StatusCode="" or objStatus.StatusCode<>0)) ? "0" : "1" ), objStatus.Address] )
	Return rVal
}

Ping0(addr) {	;ping only one addresses, alternative for a simplified return value,but only one address supported
	colPings := ComObjGet( "winmgmts:" ).ExecQuery("Select * From Win32_PingStatus where Address = '" addr "'")._NewEnum
	While colPings[objStatus]
		Return ((oS:=(objStatus.StatusCode="" or objStatus.StatusCode<>0)) ? "0" : "1")
}Msgbox % Ping0("www.google.com")Ping0("www.youtube.com")Ping0("www.idontexist.org")
