#NoEnv
#SingleInstance force
Loop, Read, %A_ScriptDir%\TheBeatles-Lyrics.txt
	if (A_Index = 1)
		MsgBox, Header: %A_LoopReadLine%
	else
		Loop, Parse, A_LoopReadLine, CSV
			MsgBox, Field #%A_Index%:`n`n%A_LoopField%
return
