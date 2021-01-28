RapidHotkey(keystroke, times:="2", delay:=0.2, IsLabel:=0)
{
  hotkey := RegExReplace(A_ThisHotkey, "[\*\~\$\#\+\!\^]")
  ,thishotkey:=A_ThisHotkey
	,Pattern := Morse(delay*1000)
	If (StrLen(Pattern) < 2 && Chr(Ord(times)) != "1")
		Return
	If (times = "" && InStr(keystroke, "`""))
	{
		LoopParse, %keystroke%,`"	
			If (StrLen(Pattern) = A_Index+1)
				continue := A_Index, times := StrLen(Pattern)
	}
	Else if (RegExMatch(times, "^\d+$") && InStr(keystroke, "`""))
	{
		LoopParse, %keystroke%,`"
			If (StrLen(Pattern) = A_Index+times-1)
				times := StrLen(Pattern), continue := A_Index
	}
	Else if InStr(times, "`"")
	{
		LoopParse, %times%,`"
			If (StrLen(Pattern) = A_LoopField)
				continue := A_Index, times := A_LoopField
	}
	Else if (times = "")
		continue := 1, times := 2
	Else if (times = StrLen(Pattern))
		continue := 1
	If !continue
		Return
	LoopParse, %keystroke%,`"
		If (continue = A_Index)
			keystr := A_LoopField
	LoopParse, %IsLabel%,`"
		If (continue = A_Index)
			IsLabel := A_LoopField
	If InStr(hotkey, A_Space)
		hotkey:=SubStr(hotkey,InStr(hotkey,A_Space,1,0)+1)
  Loop % times
		backspace .= "{Backspace}"
	LoopParse, Ctrl|Alt|Shift|LWin|RWin, |
		KeyWait, %A_LoopField%
  KeyWait % hotkey
  If thishotkey!=A_ThisHotkey
		Return
	If ((!IsLabel or (IsLabel && IsLabel(keystr))) && InStr(A_ThisHotkey, "~") && !RegExMatch(A_ThisHotkey
	, "i)\^[^\!\d]|![^\d]|#|Control|Ctrl|LCtrl|RCtrl|Shift|RShift|LShift|RWin|LWin|Alt|LAlt|RAlt|Escape|BackSpace|F\d\d?|"
	. "Insert|Esc|Escape|BS|Delete|Home|End|PgDn|PgUp|Up|Down|Left|Right|ScrollLock|CapsLock|NumLock|AppsKey|"
	. "PrintScreen|CtrlDown|Pause|Break|Help|Sleep|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|"
	. "Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|MButton|RButton|LButton|"
	. "Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Joy"))
		Send % backspace
	If (WinExist("AHK_class #32768") && hotkey = "RButton")
		WinClose, AHK_class #32768
	If IsLabel=0
		Send % keystr
	if IsLabel(keystr)
		Gosub, %keystr%
	Return
}	
Morse(timeout := 400) { ;by Laszo -> http://www.autohotkey.com/forum/viewtopic.php?t=16951 (Modified to return: KeyWait %key%, T%tout%)
   tout := timeout/1000
   key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
   If InStr(key, A_Space)
		key:=SubStr(key1,InStr(key,A_Space,1,-1))
	If InStr(",Shift,Win,Ctrl,Alt,","," Key ",")
		key1:="{L" key "}{R" key "}"
   Loop {
      t := A_TickCount
      KeyWait %key%, T%tout%
		Pattern .= A_TickCount-t > timeout
		If(ErrorLevel)
			Return Pattern
    If InStr(",Capslock,LButton,RButton,MButton,","," key ",") || 1=InStr(key,"Joy")
      KeyWait,%key%,T%tout% D
    else
      Input,pressed,T%tout% L1 V,{%key%}%key1%
		If (ErrorLevel="Timeout" or ErrorLevel=1)
			Return Pattern
		else if (ErrorLevel="Max")
			Return
   }
}