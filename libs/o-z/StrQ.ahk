StrQ( List, Item, Max:=10, D:="`n", F:=0  ) { ; by SKAN | 15-Sep-2017 | Topic: goo.gl/R4QrF4
Return ( StrLen(Item) ? (Max := InStr( (List := Trim(Item D Trim( StrReplace((List := D List D)
, (F := InStr(List,D Item D)) ? D Item D : "", D),D),D)),D,,,Max)) ? SubStr(List,1,Max-1) : List : List)
}

; Usage examples:


#SingleInstance, Force

MAXQ := 10

Que := ""
Loop 9
 Que := StrQ( Que, "Item" A_Index, MAXQ, "`n" )
Msgbox % Que

Que := StrQ( Que, "Item10", MAXQ, "`n" ) ; add a new item to Que 
MsgBox % Que

Que := StrQ( Que, "Item11", MAXQ, "`n" ) ; add a new item to Que.. oldest item "Item1" is dequeued  
MsgBox % Que

Que := StrQ( Que, "Item5", MAXQ, "`n" ) ; Bump up an existing item to top of Que 
MsgBox % Que

MAXQ := 5                               ; Reduce capacity of Queue
Que := StrQ( Que, "`n",    MAXQ, "`n" ) ; Apply the changes, Note: Parameter 2 should be the delimiter 
MsgBox % Que

Latest := StrQ( Que,"`n", 1, "`n" )     ; Retrieve the "top-most = latest = first" item in queue 
MsgBox % Latest
