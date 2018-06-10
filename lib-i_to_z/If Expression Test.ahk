FormatTime, PDate, ,ddd, dd.MM.yy
FormatTime, PTime, ,HH:mm
StringGetPos, Position, PDate, `,
	StringLeft, Tag, PDate, Position
	StringLeft, Stunde, PTime, 2
	StringRight, Minute, PTime, 2
	Zeitmin:=Stunde * 60
	Zeitmin:=Zeitmin + Minute
	
;MsgBox, Zeitmin ist %Zeitmin%`nTag ist `"%Tag%`" 


;If (Tag="Sa") And Zeitmin>600																								;funktioniert so
;		MsgBox, Es ist %Tag% und mehr als 600 Minuten sind schon vergangen

Samstag:="Fr"																														;funktioniert so
If (Tag <> Samstag) 
		MsgBox, Es ist %Tag% aber nicht %Samstag%
		
Firstrun:= 0
If Firstrun <> 1 
		MsgBox, FirstRun ist ungleich 1