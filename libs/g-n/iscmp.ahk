; Link:
; Author:
; Date:
; for:     	AHK_L

/*


*/

#NoEnv
SetBatchLines -1
ListLines Off


DllCall("LoadLibrary", "Str", "msvcrt.dll", "Ptr")

gui, add, text, w200 h100, please wait
gui, show



VarSetCapacity(temp_a, (temp_chars := 100000) * 2)
Loop % temp_chars
	temp_a .= "a"

global NUM_CHARS := 2000 * 1000000 ; in millions
VarSetCapacity(x, NUM_CHARS * 2 + 2)
loop % NUM_CHARS / temp_chars
x .= temp_a

VarSetCapacity(y, NUM_CHARS * 2 + 2)
y := x

x .= "a"
y .= "a"
; y .= "b"
++NUM_CHARS

Start := A_TickCount

if (x = y)
{
gui, hide
msgbox, % "yes (" A_TickCount - Start " milliseconds)"
}
else
{
gui, hide
msgbox, % "no (" A_TickCount - Start " milliseconds)"
}

gui, show

msgbox, % Is(x, "=", y)

guiclose:	;_______________
exitapp



Is(ByRef String_1, Operator, ByRef String_2)	;___________________
{

	Start := A_TickCount

	if DllCall("msvcrt.dll\memcmp", "Ptr", &String_1, "Ptr", &String_2, "Int", NUM_CHARS * (A_IsUnicode ? 2 : 1), "Int")
	{
	gui, hide
	return "no (" A_TickCount - Start " milliseconds)"
	}
	else
	{
	gui, hide
	return "yes (" A_TickCount - Start " milliseconds)"
	}
}