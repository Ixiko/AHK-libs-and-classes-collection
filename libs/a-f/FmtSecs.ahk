; Title:   	FmtSecs() : Converts Seconds to Days,Hours,Minutes,Seconds
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=77420&sid=5ecc4eae807a2ef87c09c774786a2792
; Author:	SKAN
; Date:   	17.06.2020
; for:     	AHK_L

/*

	MsgBox % FmtSecs(1219512)                                  ; 14d 02h 45m 12s
	. "`n" . FmtSecs(1219512, "{1:}d {2:}h {3:}m {4:}s")       ; 14d 2h 45m 12s
	. "`n" . FmtSecs(1219512, "{1:02}:{2:02}:{3:02}:{4:02}")   ; 14:02:45:12
	. "`n" . FmtSecs(1219512, "{5:04}h {3}m {4:}s")            ; 0338h 45m 12s
	. "`n" . FmtSecs(1219512, "{6:} minutes & {4:02} seconds") ; 20325 minutes & 12 seconds
	. "`n" . FmtSecs(1219512, "{6:06}:{4:02} mins")            ; 020325:12 mins

*/

FmtSecs(T, Fmt:="{:}d {:02}h {:02}m {:02}s") { ; v0.50 by SKAN on D36G/H @ tiny.cc/fmtsecs
Local D, H, M, HH, Q:=60, R:=3600, S:=86400
Return Format(Fmt, D:=T//S, H:=(T:=T-D*S)//R, M:=(T:=T-H*R)//Q, T-M*Q, HH:=D*24+H, HH*Q+M)
}
