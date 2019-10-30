#include %A_ScriptDir%\..\LastKey.ahk
LastKeyMode := 2
SetTimer LastKey_show, 100

LastKey_show:
	If (asc(LastKey_before) != asc(Lastkey)) || ((Strlen(LastKey) > 1) && (LastKey_before != Lastkey))
		ToolTip, LastKey = %LastKey%`nbefore = %LastKey_before%
	LastKey_before := LastKey
return

esc::
ExitApp