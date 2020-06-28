; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

#Persistent

MsgBox % fs(7384) 				; 7384 = 2 hours + 3 minutes + 4 seconds. It yields: 2h03m04s
MsgBox % gms("2h03m04s")		; 2h03m04s = 7384000 ms
MsgBox % gms("1m1s")			; 1m1s = 61000 ms

SetTimer, label, % gms("23h59m59s")	; so, mal warten wann es beeped ...
Return

label:
	SoundBeep
	Return

fs(NumberOfSeconds) { ; Convert the specified number of seconds "_h_m_s" format.
    time := 19990101  ; *Midnight* of an arbitrary date.
    time += NumberOfSeconds, seconds
    FormatTime, mmss, %time%, mm'm'ss's'
    return NumberOfSeconds//3600 "h" mmss
	}

gms(time) {
	t := StrSplit(time,["h","m","s"])
	res :=	(t.Length() = 4) ? ((t[1]*3600)+(t[2]*60)+(t[3]))*1000 
		:	(t.Length() = 3) ? ((t[1]*60)+(t[2]))*1000
		:	(t.Length() = 2) ? (t[1]*1000) : ""
	Return res
	}
