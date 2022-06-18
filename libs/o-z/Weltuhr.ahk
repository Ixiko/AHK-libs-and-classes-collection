SetTimer, UpdateUI, 1000

Gui, -AlwaysOnTop +ToolWindow -Caption +Border
Gui, Color, gray
Gui, Font, s25 white, Segoe UI Light
Gui, Margin, 10, 5

Gui, Add, Text, Section vtxtItIs, % "ES IST"
Gui, Add, Text, ys vtxtA, % ""
Gui, Add, Text, ys vtxtMinuteIdHalf, % "HALB"
Gui, Add, Text, ys vtxtMinuteIdTen, % "ZEHN"

Gui, Add, Text, xm Section vtxtMinuteIdQuarter, % "VIERTEL"
Gui, Add, Text, ys vtxtMinuteIdTwenty, % "ZWANZIG"

Gui, Add, Text, xm Section vtxtMinuteIdFive, % "FÜNF"
Gui, Add, Text, ys vtxtMinuteIdMinutes, % "MINUTEN"
Gui, Add, Text, ys vtxtMinuteIdTo, % "VOR"

Gui, Add, Text, xm Section vtxtMinuteIdPast, % "NACH"
Gui, Add, Text, ys vtxtHour01, % "EINS"
Gui, Add, Text, ys vtxtHour03, % "DREI"

Gui, Add, Text, xm Section vtxtHour02, % "ZWEI"
Gui, Add, Text, ys vtxtHour04, % "VIER"
Gui, Add, Text, ys vtxtHour05, % "FÜNF"

Gui, Add, Text, xm Section vtxtHour06, % "SECHS"
Gui, Add, Text, ys vtxtHour07, % "SIEBEN"
Gui, Add, Text, ys vtxtHour08, % "ACHT"

Gui, Add, Text, xm Section vtxtHour09, % "NEUN"
Gui, Add, Text, ys vtxtHour10, % "ZEHN"
Gui, Add, Text, ys vtxtHour11, % "ELF"

Gui, Add, Text, xm Section vtxtHour12, % "ZWÖLF"
Gui, Add, Text, ys vtxtOClock, % "UHR"
Gui, Show, AutoSize Center, Word Clock
WinSet, Trans, 230, Word Clock
return

UpdateUI:
{
	; Reset all colors back to black
	Gui, Font, Black
	WinGet, controls, ControlList, Word Clock
	Loop, Parse, controls, `n
		GuiControl, Font, %A_LoopField%

	; Set correct words to white
	Gui, Font, cWhite
	GuiControl, Font, txtItIs
	if A_Min between 00 and 04
		GuiControl, Font, txtOClock
	else if A_Min between 05 and 09
	{
		GuiControl, Font, txtMinuteIdFive
		GuiControl, Font, txtMinuteIdMinutes
		GuiControl, Font, txtMinuteIdPast
	}
	else if A_Min between 10 and 14
	{
		GuiControl, Font, txtMinuteIdTen
		GuiControl, Font, txtMinuteIdMinutes
		GuiControl, Font, txtMinuteIdPast
	}
	else if A_Min between 15 and 19
	{
		GuiControl, Font, txtA
		GuiControl, Font, txtMinuteIdQuarter
		GuiControl, Font, txtMinuteIdPast
	}
	else if A_Min between 20 and 24
	{
		GuiControl, Font, txtMinuteIdTwenty
		GuiControl, Font, txtMinuteIdMinutes
		GuiControl, Font, txtMinuteIdPast
	}
	else if A_Min between 25 and 29
	{
		GuiControl, Font, txtMinuteIdTwenty
		GuiControl, Font, txtMinuteIdFive
		GuiControl, Font, txtMinuteIdMinutes
		GuiControl, Font, txtMinuteIdPast
	}
	else if A_Min between 30 and 34
	{
		GuiControl, Font, txtMinuteIdHalf
		GuiControl, Font, txtMinuteIdPast
	}
	else if A_Min between 35 and 39
	{
		GuiControl, Font, txtMinuteIdTwenty
		GuiControl, Font, txtMinuteIdFive
		GuiControl, Font, txtMinuteIdMinutes
		GuiControl, Font, txtMinuteIdTo
	}
	else if A_Min between 40 and 44
	{
		GuiControl, Font, txtMinuteIdTwenty
		GuiControl, Font, txtMinuteIdMinutes
		GuiControl, Font, txtMinuteIdTo
	}
	else if A_Min between 45 and 49
	{
		GuiControl, Font, txtA
		GuiControl, Font, txtMinuteIdQuarter
		GuiControl, Font, txtMinuteIdTo
	}
	else if A_Min between 50 and 54
	{
		GuiControl, Font, txtMinuteIdTen
		GuiControl, Font, txtMinuteIdMinutes
		GuiControl, Font, txtMinuteIdTo
	}
	else if A_Min between 55 and 59
	{
		GuiControl, Font, txtMinuteIdFive
		GuiControl, Font, txtMinuteIdMinutes
		GuiControl, Font, txtMinuteIdTo
	}

	if A_Min between 00 and 34
	{
		currentHour := A_Hour
		if A_Hour between 13 and 24
			currentHour := currentHour-12
		currentHour := currentHour < 10 ? 0 currentHour : currentHour
		GuiControl, Font, txtHour%currentHour%
	}
	else
	{
		nextHour := (A_Hour+1)-12
		nextHour := nextHour < 10 ? 0 nextHour : nextHour
		GuiControl, Font, % "txtHour" nextHour
	}
	return
}

GuiClose:
	ExitApp
