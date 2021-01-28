#Persistent
#SingleInstance
#NoEnv

MPCCurrentTimeControl := "Static2"
baseTime := "20000101000000"

Gui, AC1:new, +AlwaysOnTop +ToolWindow				;kein Rand, kein TaskbarIcon, immer OnTop
Gui, AC1:Font, S12 CDefault, Verdana,
Gui, AC1:Color, Green
Gui, AC1:+LastFound
Gui, AC1:-Caption
Gui, AC1:Add, Text, x0 y0 w990 h490 vMeinText cBlack, XXXXX YYYYY 				;XXXXX YYYYY steht für automatische Anpassung der OVerlay-Fenstergröße
Gui, AC1:Show, x1000 y20 w1000 h500 NA, TOverlay 



SetTimer, LoadTimeCode, 500


return


LoadTimeCode:
	;whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	;		whr.Open("GET", "http://localhost:13579/info.html", true)
	;		whr.Send()
			; Durch das 'true' oben und dem Aufruf unten bleibt das Skript ansprechbar.
	;		whr.WaitForResponse()
	;		TimeCode := whr.ResponseText
	
	ControlGetText, MPCCurrentTime, %MPCCurrentTimeControl%, ahk_class MediaPlayerClassicW
	StringLeft, MPCCurrentTime, MPCCurrentTime, % InStr(MPCCurrentTime, " /") - 1
	unformattedTime := ""  ; is there a more direct way of deleting all ':' ?
	Loop, Parse, formattedTime, :
		unformattedTime .= A_LoopField

	StringTrimRight, prefix, baseTime, % StrLen(unformattedTime)
	eTime := prefix . unformattedTime
	
	
	GuiControl,AC1:, MeinText,   %eTime%

return