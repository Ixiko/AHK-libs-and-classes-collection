; Get milliseconds from a 4 to 6 digit time "hhmmss or "hhmmss"
; by None
; http://www.autohotkey.com/forum/viewtopic.php?p=340991#340991
msTill(Time) {
ST_Hour:=SubStr(Time, 1 ,2)
ST_Min:=SubStr(Time, 3 ,2)
ST_Sec:=(SubStr(Time, 5 ,2)<>"" ? SubStr(Time, 5 ,2) : "00")
STime:=(((ST_Hour-A_Hour)*60+(ST_Min-A_Min))*60+(ST_Sec-A_Sec))*1000
STime:=STime<0 ? STime+86400000 : STime
Return %STime%
}