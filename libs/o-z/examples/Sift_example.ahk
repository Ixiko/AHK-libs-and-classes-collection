#Include Sift.ahk

Data =
(
Where can I find the official build, or older releases?
Why do some lines in my script never execute?
Why does my script run fine in XP but not in Vista or Windows 7 or 8?
I can't edit my script via tray icon because it won't start due to an error. Can I find my script somewhere else?
How can I find and fix errors in my code?
Can I run AHK from a USB drive?
Why is the Run command unable to launch my game or program?
How can the output of a command line operation be retrieved?
How can a script close, pause, or suspend other script(s)?
How can a repeating action be stopped without exiting the script?
How can performance be improved for games or at other times when the CPU is under heavy load?
How can context sensitive help for AutoHotkey commands be used in any editor?
How to detect when a web page is finished loading?
How can dates and times be compared or manipulated?
How can I send the current Date and/or Time?
How can I send text to a window which isn't active or isn't visible?
Why don't Hotstrings, Send, and MouseClick work in certain games?
How can Winamp be controlled even when it isn't active?
How can MsgBox's button names be changed?
How can I change the default editor, which is accessible via context menu or tray icon?
How can I save the contents of my GUI associated variables?
Can I draw something with AHK?
How can I start an action when a window appears, closes or becomes [in]active?
My antivirus program flagged AHK as malware. Does it really contain a virus?
How do I put my hotkeys and hotstrings into effect automatically every time I start my PC?
I'm having trouble getting my mouse buttons working as hotkeys. Any advice?
How can tab and space be defined as hotkeys?
How can keys or mouse buttons be remapped so that they become different keys?
How do I detect the double press of a key or button?
How can a hotkey or hotstring be made exclusive to certain program(s)? In other words, I want a certain key to act as it normally does except when a specific window is active.
How can a prefix key be made to perform its native function rather than doing nothing?
How can the built-in Windows shortcut keys, such as Win+U (Utility Manager) and Win+R (Run), be changed or disabled?
Can I use wildcards or regular expressions in Hotstrings?
How can I use a hotkey that is not in my keyboard layout?
My keypad has a special 000 key. Is it possible to turn it into a hotkey?
)

Display := Data
Options := "in"
NgramSize := 3
NgramLimit := .50
DisplayLimit := 0

Gui, Font, s10 bold
Gui, Add, Text, x78 y11 w120 h20, Query?
Gui, Font, s10 bold underline
Gui, Add, Text, x8 y50 w120 h20, Search Options
Gui, Font, norm
Gui, Add, Edit, x130 y10 w600 h20 vQueryText gQuery
Gui, Add, Radio, x5 yp+60 w120 h15 +Center vRadio gRadio Checked, IN
Gui, Add, Radio, x5 w120 h20 +Center gRadio, LEFT
Gui, Add, Radio, x5 w120 h20 +Center gRadio, RIGHT
Gui, Add, Radio, x5 w120 h20 +Center gRadio, EXACT
Gui, Add, Radio, x5 w120 h20 +Center gRadio, REGEX
Gui, Add, Radio, x5 w120 h40 +Center gRadio, ORDERED`nCHARACTERS
Gui, Add, Radio, x5 w120 h40 +Center gRadio, UNORDERED`nCHARACTERS
Gui, Add, Radio, x5 w120 h40 +Center gRadio, ORDERED`nWORDS
Gui, Add, Radio, x5 w120 h40 +Center gRadio, UNORDERED`nWORDS
Gui, Add, Radio, x5 w120 h40 +Center gRadio, Ngram
Gui, Add, ComboBox, yp40 w40 vNgramSize gNgramSize Choose2, 2|3|4|5
Gui, Add, Text, x48 yp+3, Size
Gui, Add, ComboBox, x5 w40 vNgramLimit gNgramLimit Choose3, 1.00|.70|.50|.30|.10|0
Gui, Add, Text, x48 yp+3, Result Limit
Gui, Add, ComboBox, x5 w40 vDisplayLimit gDisplayLimit Choose1, 0|1|2|3|4|5
Gui, Add, Text, x48 yp+3, Result #
Gui, Add, Checkbox, x5 w120 h40 +Center vNgramResult gNgramResult, SHOW NGRAM RESULT
Gui, Add, Text, x5 w120 h2 0x7 ; Line
Gui, Add, Checkbox, x5 w120 h40 +Center vCase gCheckboxCase, CASE SENSITIVE
Gui, Add, Text, x5 yp-190 w120 h2 0x7 ; Line
Gui, Add, Edit, w600 h570 x130 y40 vGui_Display ReadOnly +0x300000 -wrap, %Display%
Gui, Show, w740 h620

Esc::ExitApp

Query:
	Gui, Submit, NoHide
	if (Options = "NGRAM")
	{
		if (StrLen(QueryText)<NgramSize)
			Display := Sift_Regex(Data,QueryText, "in")
		else
		{
			Display := ""
			if NgramResult
			{
				for key, element in Sift_Ngram(Data, QueryText, NgramLimit, Data_Ngram_Matrix, NgramSize, "S")
					Display .= element.delta "`t" element.data "`n"
				Display := SubStr(Display,1,-1)
			}
			else
				Display := Sift_Ngram(Data, QueryText, NgramLimit, Data_Ngram_Matrix, NgramSize)
			If DisplayLimit 
				Display := SubStr(Display, 1, InStr(Display,"`n",,, DisplayLimit))
		}
	}
	else
		Display := Sift_Regex(Data, QueryText, Options)
	GuiControl,, Gui_Display, %Display%
return

CheckboxCase:
	Gui, Submit, NoHide
	if (Options = "NGRAM")
	{
		Case := 0
		GuiControl,, Case, 0
	}
	if Case
		StringUpper, Options, Options
	else
		StringLower, Options, Options
	gosub Query
return

Radio:
	Gui, Submit, NoHide
	if (Radio = 1)
		Options := "IN"
	else if (Radio = 2)
		Options := "LEFT"
	else if (Radio = 3)
		Options := "RIGHT"
	else if (Radio = 4)
		Options := "EXACT"
	else if (Radio = 5)
		Options := "REGEX"
	else if (Radio = 6)
		Options := "OC"
	else if (Radio = 7)
		Options := "UC"
	else if (Radio = 8)
		Options := "OW"
	else if (Radio = 9)
		Options := "UW"
	else if (Radio = 10)
	{
		if Case
		{
			Case := 0
			GuiControl,, Case, 0
		}
		Options := "NGRAM"
	}
	gosub CheckboxCase
return

NgramSize:
	Gui, Submit, NoHide
	Data_Ngram_Matrix := ""
	gosub Query
return

NgramLimit:
	Gui, Submit, NoHide
	gosub Query
return

DisplayLimit:
	Gui, Submit, NoHide
	gosub Query
return

NgramResult:
	Gui, Submit, NoHide
	gosub Query
return