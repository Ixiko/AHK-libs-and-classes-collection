/*
~+::RapidHotkey("Plus")
~h::RapidHotkey("{Raw}Hello World!", 3) ;Press h 4 times rapidly to send Hello World!
~o::RapidHotkey("^o", 4, 0.2) ;be careful, if you use this hotkey, above will not work properly
~Esc::RapidHotkey("exit", 4, 0.2, 1) ;Press Esc 4 times rapidly to exit this script
~LControl::RapidHotkey("!{TAB}",2) ;Press LControl rapidly twice to AltTab
~RControl::RapidHotkey("+!{TAB}",2) ;Press RControl rapidly twice to ShiftAltTab
~LShift::RapidHotkey("^{TAB}", 2) ;Switch back in internal windows
~RShift::RapidHotkey("^+{TAB}", 2) ;Switch between internal windows
~e::RapidHotkey("#e""#r",3) ;Run Windows Explorer
~^!7::RapidHotkey("{{}{}}{Left}", 2)

;~ ~a::RapidHotkey("test", 2, 0.3, 1) ;You Can also specify a Label to be launched
test:
MsgBox, Test
Return

Exit:
ExitApp

~LButton & RButton::RapidHotkey("Menu1""Menu2""Menu3",1,0.3,1)
Menu1:
Menu2:
Menu3:
MsgBox % A_ThisLabel
Return

*/	
/*
RapidHotkey(keystroke, times="2", delay=0.2, IsLabel=0)
{
	Pattern := Morse(delay*1000)
	If (StrLen(Pattern) < 2 and Chr(Asc(times)) != "1")
		Return
	If (times = "" and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""	
			If (StrLen(Pattern) = A_Index+1)
				continue := A_Index, times := StrLen(Pattern)
	}
	Else if (RegExMatch(times, "^\d+$") and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""
			If (StrLen(Pattern) = A_Index+times-1)
				times := StrLen(Pattern), continue := A_Index
	}
	Else if InStr(times, """")
	{
		Loop, Parse, times,""
			If (StrLen(Pattern) = A_LoopField)
				continue := A_Index, times := A_LoopField
	}
	Else if (times = "")
		continue = 1, times = 2
	Else if (times = StrLen(Pattern))
		continue = 1
	If !continue
		Return
	Loop, Parse, keystroke,""
		If (continue = A_Index)
			keystr := A_LoopField
	Loop, Parse, IsLabel,""
		If (continue = A_Index)
			IsLabel := A_LoopField
	hotkey := RegExReplace(A_ThisHotkey, "[\*\~\$\#\+\!\^]")
	IfInString, hotkey, %A_Space%
		StringTrimLeft, hotkey,hotkey,% InStr(hotkey,A_Space,1,0)
	Loop % times
		backspace .= "{Backspace}"
	keywait = Ctrl|Alt|Shift|LWin|RWin
	Loop, Parse, keywait, |
		KeyWait, %A_LoopField%
	If ((!IsLabel or (IsLabel and IsLabel(keystr))) and InStr(A_ThisHotkey, "~") and !RegExMatch(A_ThisHotkey
	, "i)\^[^\!\d]|![^\d]|#|Control|Ctrl|LCtrl|RCtrl|Shift|RShift|LShift|RWin|LWin|Escape|BackSpace|F\d\d?|"
	. "Insert|Esc|Escape|BS|Delete|Home|End|PgDn|PgUp|Up|Down|Left|Right|ScrollLock|CapsLock|NumLock|AppsKey|"
	. "PrintScreen|CtrlDown|Pause|Break|Help|Sleep|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|"
	. "Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|MButton|RButton|LButton|"
	. "Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2"))
		SendInput % backspace
	If (WinExist("AHK_class #32768") and hotkey = "RButton")
		WinClose, AHK_class #32768
	If !IsLabel
		SendInput % keystr
	else if IsLabel(keystr)
		Gosub, %keystr%
	Return
}
Morse(timeout = 400) { ;by Laszo -> http://www.autohotkey.com/forum/viewtopic.php?t=16951   +   Modifications by HotKeyIt
	static running
	If running
		Return
	running=1
	k:="+AppsKey+Lwin+Rwin+LControl+RControl+LAlt+RAlt+LShift+RShift+Tab+Backspace+Enter+Left+Right"
	. "+Up+Down+Delete+Insert+Escape+Home+End+PgUp+PgDn+Numpad0+Numpad1+Numpad2+Numpad3"
	. "+Numpad4+Numpad5+Numpad6+Numpad7+Numpad8+Numpad9+NumpadDot+NumpadDiv+NumpadMult+NumpadAdd"
	. "+NumpadSub+NumpadEnter+NumpadIns+NumpadEnd+NumpadDown+NumpadPgDn+NumpadLeft+NumpadClear+NumpadRight"
	. "+NumpadHome+NumpadUp+NumpadPgUp+NumpadDel+NumpadDiv+NumpadMult+NumpadAdd+NumpadSub+NumpadEnter"
	. "+F1+F2+F3+F4+F5+F6+F7+F8+F9+F10+F11+F12+F13+F14+F15+F16+F17+F18+F19"
	. "+F20+F21+F22+F23+F24+Pause+Break+PrintScreen+a+b"
	. "+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t+u+v+w+x+y+z+0+1"
	. "+2+3+4+5+6+7+8+9+Space+´+,+-+."
	. "+>+^+RButton+LButton+MButton+Capslock+Scrolllock+Numlock+"
   key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
	If key=
		key:=SubStr(A_ThisHotkey,0)
   IfInString, key, %A_Space%
	{
		StringSplit,key,key,&,% A_Space
		If key1=Shift
			StringReplace,k,k,+LShift+RShift+, +
		else if key1=Alt
			StringReplace,k,k,+LAlt+RAlt+, +
		else if (key1="Ctrl" || key1="Control")
			StringReplace,k,k,+LControl+RControl+, +
		else
			StringReplace,k,k,% "+" key1 "+", +
		StringTrimLeft, key, key,% InStr(key,A_Space,1,0)
	}
	If key=BS
		key=BackSpace
	else if key=Esc
		key=Escape
	else if key=Return
		key=Enter
	else if key=Ins
		key=Insert
	else if key=Del
		key=Delete
	else if key=LCtrl
		key=LControl
	else if key=RCtrl
		key=RControl
	If (key="Alt" or InStr(A_ThisHotkey,"!"))
		StringReplace,k,k,+LAlt+RAlt+,+
	If (key="Ctrl" or key="Control" or InStr(A_ThisHotkey,"^"))
		StringReplace,k,k,+LControl+RControl+,+
	If (key="Shift" or (InStr(A_ThisHotkey,"+") and key!="+"))
		StringReplace,k,k,+LShift+RShift+,+
	StringReplace,k,k,+%key%+,+
	If (SubStr(k,1,1)="+")
		StringTrimLeft,k,k,1
	If (SubStr(k,0)="+")
		StringTrimRight,k,k,1
	StringReplace,k,k,+,% Chr(1),A
	If (key!="+")
		k .=Chr(1) "+"
   Loop {
      t := A_TickCount
      While % (GetKeyState(key,"P") and A_TickCount-t < timeout){
			Sleep, 10
         Loop,parse,k,% Chr(1)
            If (GetKeyState(A_LoopField,"P") && A_LoopField!=key && running:=0)
               Return
		}
		If (GetKeyState(key,"P") && !running:=0)
			Return Pattern . "1"
		else
			Pattern .=A_TickCount-t > timeout
      t := A_TickCount
      While % (!GetKeyState(key,"P") and A_TickCount-t < timeout){
			Sleep, 10
         Loop,parse,k,% Chr(1)
            If GetKeyState(A_LoopField,"P")
               If (A_LoopField!=key && !running:=0)
                  Return
					else
						Break
		}
      If (!GetKeyState(key,"P") && !running:=0)
         Return Pattern
   }
}















RapidHotkey(keystroke, times="2", delay=0.2, IsLabel=0)
{
	Pattern := Morse(delay*1000)
	If (StrLen(Pattern) < 2 and Chr(Asc(times)) != "1")
		Return
	If (times = "" and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""	
			If (StrLen(Pattern) = A_Index+1)
				continue := A_Index, times := StrLen(Pattern)
	}
	Else if (RegExMatch(times, "^\d+$") and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""
			If (StrLen(Pattern) = A_Index+times-1)
				times := StrLen(Pattern), continue := A_Index
	}
	Else if InStr(times, """")
	{
		Loop, Parse, times,""
			If (StrLen(Pattern) = A_LoopField)
				continue := A_Index, times := A_LoopField
	}
	Else if (times = "")
		continue = 1, times = 2
	Else if (times = StrLen(Pattern))
		continue = 1
	If !continue
		Return
	Loop, Parse, keystroke,""
		If (continue = A_Index)
			keystr := A_LoopField
	Loop, Parse, IsLabel,""
		If (continue = A_Index)
			IsLabel := A_LoopField
	hotkey := RegExReplace(A_ThisHotkey, "[\*\~\$\#\+\!\^]")
	IfInString, hotkey, %A_Space%
		StringTrimLeft, hotkey,hotkey,% InStr(hotkey,A_Space,1,0)
	Loop % times
		backspace .= "{Backspace}"
	keywait = Ctrl|Alt|Shift|LWin|RWin
	Loop, Parse, keywait, |
		KeyWait, %A_LoopField%
	If ((!IsLabel or (IsLabel and IsLabel(keystr))) and InStr(A_ThisHotkey, "~") and !RegExMatch(A_ThisHotkey
	, "i)\^[^\!\d]|![^\d]|#|Control|Ctrl|LCtrl|RCtrl|Shift|RShift|LShift|RWin|LWin|Escape|BackSpace|F\d\d?|"
	. "Insert|Esc|Escape|BS|Delete|Home|End|PgDn|PgUp|Up|Down|Left|Right|ScrollLock|CapsLock|NumLock|AppsKey|"
	. "PrintScreen|CtrlDown|Pause|Break|Help|Sleep|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|"
	. "Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|MButton|RButton|LButton|"
	. "Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2"))
		SendInput % backspace
	If (WinExist("AHK_class #32768") and hotkey = "RButton")
		WinClose, AHK_class #32768
	If !IsLabel
		SendInput % keystr
	else if IsLabel(keystr)
		Gosub, %keystr%
	Return
}

Morse(timeout = 400) { ;by Laszo -> http://www.autohotkey.com/forum/viewtopic.php?t=16951   +   Modifications by HotKeyIt
   allkeys:="+AppsKey+Lwin+Rwin+LControl+RControl+LAlt+RAlt+LShift+RShift+Tab+Backspace+Enter+Left+Right"
	. "+Up+Down+Delete+Insert+Escape+Home+End+PgUp+PgDn+Numpad0+Numpad1+Numpad2+Numpad3"
	. "+Numpad4+Numpad5+Numpad6+Numpad7+Numpad8+Numpad9+NumpadDot+NumpadDiv+NumpadMult+NumpadAdd"
	. "+NumpadSub+NumpadEnter+NumpadIns+NumpadEnd+NumpadDown+NumpadPgDn+NumpadLeft+NumpadClear+NumpadRight"
	. "+NumpadHome+NumpadUp+NumpadPgUp+NumpadDel+NumpadDiv+NumpadMult+NumpadAdd+NumpadSub+NumpadEnter"
	. "+F1+F2+F3+F4+F5+F6+F7+F8+F9+F10+F11+F12+F13+F14+F15+F16+F17+F18+F19"
	. "+F20+F21+F22+F23+F24+Pause+Break+PrintScreen+a+b"
	. "+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t+u+v+w+x+y+z+0+1"
	. "+2+3+4+5+6+7+8+9+Space+´+,+-+."
	. "+>+^+RButton+LButton+MButton+Capslock+Scrolllock+Numlock+"
	key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
	k:=allkeys
	If key=
		key:=SubStr(A_ThisHotkey,0)
   IfInString, key, %A_Space%
	{
		StringReplace,k,k,% "+" SubStr(key,1,InStr(key, " ")-1) "+", +
		StringTrimLeft, key, key,% InStr(key,A_Space,1,0)
	}
;~ 	ToolTip % key
	If key=BS
		key=BackSpace
	else if key=Esc
		key=Escape
	else if key=Return
		key=Enter
	else if key=Ins
		key=Insert
	else if key=Del
		key=Delete
	else if key=LCtrl
		key=LControl
	else if key=RCtrl
		key=RControl
	If (key="Alt" or InStr(A_ThisHotkey,"!"))
		StringReplace,k,k,+LAlt+RAlt+,+
	If (key="Ctrl" or key="Control" or InStr(A_ThisHotkey,"^"))
		StringReplace,k,k,+LControl+RControl+,+
	If (key="Shift" or (InStr(A_ThisHotkey,"+") and key!="+"))
		StringReplace,k,k,+LShift+RShift+,+
	StringReplace,k,k,+%key%+,+
	If (SubStr(k,1,1)="+")
		StringTrimLeft,k,k,1
	If (SubStr(k,0)="+")
		StringTrimRight,k,k,1
	StringSplit,k,k,+
	If (key!="+")
		k132=+
;~ 	MsgBox % k
	Loop {
      t := A_TickCount
		While % (GetKeyState(key,"P") and (A_TickCount-t < timeout)){
			other:=GetKeystate(k1,"P")+GetKeystate(k2,"P")+GetKeystate(k3,"P")+GetKeystate(k4,"P")+GetKeystate(k5,"P")
				+GetKeystate(k6,"P")+GetKeystate(k7,"P")+GetKeystate(k8,"P")+GetKeystate(k9,"P")+GetKeystate(k10,"P")
				+GetKeystate(k11,"P")+GetKeystate(k12,"P")+GetKeystate(k13,"P")+GetKeystate(k14,"P")+GetKeystate(k15,"P")
				+GetKeystate(k16,"P")+GetKeystate(k17,"P")+GetKeystate(k18,"P")+GetKeystate(k19,"P")+GetKeystate(k20,"P")
				+GetKeystate(k21,"P")+GetKeystate(k22,"P")+GetKeystate(k23,"P")+GetKeystate(k24,"P")+GetKeystate(k25,"P")
				+GetKeystate(k26,"P")+GetKeystate(k27,"P")+GetKeystate(k28,"P")+GetKeystate(k29,"P")+GetKeystate(k30,"P")
				+GetKeystate(k31,"P")+GetKeystate(k32,"P")+GetKeystate(k33,"P")+GetKeystate(k34,"P")+GetKeystate(k35,"P")
				+GetKeystate(k36,"P")+GetKeystate(k37,"P")+GetKeystate(k38,"P")+GetKeystate(k39,"P")+GetKeystate(k40,"P")
				+GetKeystate(k41,"P")+GetKeystate(k42,"P")+GetKeystate(k43,"P")+GetKeystate(k44,"P")+GetKeystate(k45,"P")
				+GetKeystate(k46,"P")+GetKeystate(k47,"P")+GetKeystate(k48,"P")+GetKeystate(k49,"P")+GetKeystate(k50,"P")
				+GetKeystate(k51,"P")+GetKeystate(k52,"P")+GetKeystate(k53,"P")+GetKeystate(k54,"P")+GetKeystate(k55,"P")
				+GetKeystate(k56,"P")+GetKeystate(k57,"P")+GetKeystate(k58,"P")+GetKeystate(k59,"P")+GetKeystate(k60,"P")
				+GetKeystate(k61,"P")+GetKeystate(k62,"P")+GetKeystate(k63,"P")+GetKeystate(k64,"P")+GetKeystate(k65,"P")
				+GetKeystate(k66,"P")+GetKeystate(k67,"P")+GetKeystate(k68,"P")+GetKeystate(k69,"P")+GetKeystate(k70,"P")
				+GetKeystate(k71,"P")+GetKeystate(k72,"P")+GetKeystate(k73,"P")
			ToolTip % "o " other
			Sleep, 200
			other+=GetKeystate(k74,"P")+GetKeystate(k75,"P")+GetKeystate(k76,"P")+GetKeystate(k77,"P")+GetKeystate(k78,"P")
				+GetKeystate(k79,"P")+GetKeystate(k80,"P")+GetKeystate(k81,"P")+GetKeystate(k82,"P")+GetKeystate(k83,"P")
				+GetKeystate(k84,"P")+GetKeystate(k85,"P")+GetKeystate(k86,"P")+GetKeystate(k87,"P")+GetKeystate(k88,"P")
				+GetKeystate(k89,"P")+GetKeystate(k90,"P")+GetKeystate(k91,"P")+GetKeystate(k92,"P")+GetKeystate(k93,"P")
				+GetKeystate(k94,"P")+GetKeystate(k95,"P")+GetKeystate(k96,"P")+GetKeystate(k97,"P")+GetKeystate(k98,"P")
				+GetKeystate(k99,"P")+GetKeystate(k100,"P")+GetKeystate(k101,"P")+GetKeystate(k102,"P")+GetKeystate(k103,"P")
				+GetKeystate(k104,"P")+GetKeystate(k105,"P")+GetKeystate(k106,"P")+GetKeystate(k107,"P")+GetKeystate(k108,"P")
				+GetKeystate(k109,"P")+GetKeystate(k110,"P")+GetKeystate(k111,"P")+GetKeystate(k112,"P")+GetKeystate(k113,"P")
				+GetKeystate(k114,"P")+GetKeystate(k115,"P")+GetKeystate(k116,"P")+GetKeystate(k117,"P")+GetKeystate(k118,"P")
				+GetKeystate(k119,"P")+GetKeystate(k120,"P")+GetKeystate(k121,"P")+GetKeystate(k122,"P")+GetKeystate(k123,"P")
				+GetKeystate(k124,"P")+GetKeystate(k125,"P")+GetKeystate(k126,"P")+GetKeystate(k127,"P")+GetKeystate(k128,"P")
				+GetKeystate(k129,"P")+GetKeystate(k130,"P")+GetKeystate(k131,"P")+(key!="+" ? GetKeystate(k132,"P") : 0)
			ToolTip % "other " other
			Sleep, 200
			If other>0
					Return
			KeyWait %key%, T0.03
			If (!ErrorLevel){
				Pattern .= "0"
				continued:=1
				break
			}
		}
		If !continued
			Return Pattern
		t := A_TickCount
		While % (!GetKeyState(key,"P") and (A_TickCount-t < timeout)){
			other:=GetKeystate(k1,"P")+GetKeystate(k2,"P")+GetKeystate(k3,"P")+GetKeystate(k4,"P")+GetKeystate(k5,"P")
				+GetKeystate(k6,"P")+GetKeystate(k7,"P")+GetKeystate(k8,"P")+GetKeystate(k9,"P")+GetKeystate(k10,"P")
				+GetKeystate(k11,"P")+GetKeystate(k12,"P")+GetKeystate(k13,"P")+GetKeystate(k14,"P")+GetKeystate(k15,"P")
				+GetKeystate(k16,"P")+GetKeystate(k17,"P")+GetKeystate(k18,"P")+GetKeystate(k19,"P")+GetKeystate(k20,"P")
				+GetKeystate(k21,"P")+GetKeystate(k22,"P")+GetKeystate(k23,"P")+GetKeystate(k24,"P")+GetKeystate(k25,"P")
				+GetKeystate(k26,"P")+GetKeystate(k27,"P")+GetKeystate(k28,"P")+GetKeystate(k29,"P")+GetKeystate(k30,"P")
				+GetKeystate(k31,"P")+GetKeystate(k32,"P")+GetKeystate(k33,"P")+GetKeystate(k34,"P")+GetKeystate(k35,"P")
				+GetKeystate(k36,"P")+GetKeystate(k37,"P")+GetKeystate(k38,"P")+GetKeystate(k39,"P")+GetKeystate(k40,"P")
				+GetKeystate(k41,"P")+GetKeystate(k42,"P")+GetKeystate(k43,"P")+GetKeystate(k44,"P")+GetKeystate(k45,"P")
				+GetKeystate(k46,"P")+GetKeystate(k47,"P")+GetKeystate(k48,"P")+GetKeystate(k49,"P")+GetKeystate(k50,"P")
				+GetKeystate(k51,"P")+GetKeystate(k52,"P")+GetKeystate(k53,"P")+GetKeystate(k54,"P")+GetKeystate(k55,"P")
				+GetKeystate(k56,"P")+GetKeystate(k57,"P")+GetKeystate(k58,"P")+GetKeystate(k59,"P")+GetKeystate(k60,"P")
				+GetKeystate(k61,"P")+GetKeystate(k62,"P")+GetKeystate(k63,"P")+GetKeystate(k64,"P")+GetKeystate(k65,"P")
				+GetKeystate(k66,"P")+GetKeystate(k67,"P")+GetKeystate(k68,"P")+GetKeystate(k69,"P")+GetKeystate(k70,"P")
				+GetKeystate(k71,"P")+GetKeystate(k72,"P")+GetKeystate(k73,"P")
;~ 			ToolTip % "other" other
			other+=GetKeystate(k74,"P")+GetKeystate(k75,"P")+GetKeystate(k76,"P")+GetKeystate(k77,"P")+GetKeystate(k78,"P")
				+GetKeystate(k79,"P")+GetKeystate(k80,"P")+GetKeystate(k81,"P")+GetKeystate(k82,"P")+GetKeystate(k83,"P")
				+GetKeystate(k84,"P")+GetKeystate(k85,"P")+GetKeystate(k86,"P")+GetKeystate(k87,"P")+GetKeystate(k88,"P")
				+GetKeystate(k89,"P")+GetKeystate(k90,"P")+GetKeystate(k91,"P")+GetKeystate(k92,"P")+GetKeystate(k93,"P")
				+GetKeystate(k94,"P")+GetKeystate(k95,"P")+GetKeystate(k96,"P")+GetKeystate(k97,"P")+GetKeystate(k98,"P")
				+GetKeystate(k99,"P")+GetKeystate(k100,"P")+GetKeystate(k101,"P")+GetKeystate(k102,"P")+GetKeystate(k103,"P")
				+GetKeystate(k104,"P")+GetKeystate(k105,"P")+GetKeystate(k106,"P")+GetKeystate(k107,"P")+GetKeystate(k108,"P")
				+GetKeystate(k109,"P")+GetKeystate(k110,"P")+GetKeystate(k111,"P")+GetKeystate(k112,"P")+GetKeystate(k113,"P")
				+GetKeystate(k114,"P")+GetKeystate(k115,"P")+GetKeystate(k116,"P")+GetKeystate(k117,"P")+GetKeystate(k118,"P")
				+GetKeystate(k119,"P")+GetKeystate(k120,"P")+GetKeystate(k121,"P")+GetKeystate(k122,"P")+GetKeystate(k123,"P")
				+GetKeystate(k124,"P")+GetKeystate(k125,"P")+GetKeystate(k126,"P")+GetKeystate(k127,"P")+GetKeystate(k128,"P")
				+GetKeystate(k129,"P")+GetKeystate(k130,"P")+GetKeystate(k131,"P")+(key!="+" ? GetKeystate(k132,"P") : 0)
			If other>0
					Return
			KeyWait %key%, DT0.03
			If (!ErrorLevel){
				continued:=1
				break
			}
		}
		If !continued
			Return Pattern
		continued=
   }
}



/*
RapidHotkey(keystroke, times="2", delay=0.2, IsLabel=0)
{
	Pattern := Morse(delay*1000)
	If (StrLen(Pattern) < 2 and Chr(Asc(times)) != "1")
		Return
	If (times = "" and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""	
			If (StrLen(Pattern) = A_Index+1)
				continue := A_Index, times := StrLen(Pattern)
	}
	Else if (RegExMatch(times, "^\d+$") and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""
			If (StrLen(Pattern) = A_Index+times-1)
				times := StrLen(Pattern), continue := A_Index
	}
	Else if InStr(times, """")
	{
		Loop, Parse, times,""
			If (StrLen(Pattern) = A_LoopField)
				continue := A_Index, times := A_LoopField
	}
	Else if (times = "")
		continue = 1, times = 2
	Else if (times = StrLen(Pattern))
		continue = 1
	If !continue
		Return
	Loop, Parse, keystroke,""
		If (continue = A_Index)
			keystr := A_LoopField
	Loop, Parse, IsLabel,""
		If (continue = A_Index)
			IsLabel := A_LoopField
	hotkey := RegExReplace(A_ThisHotkey, "[\*\~\$\#\+\!\^]")
	IfInString, hotkey, %A_Space%
		StringTrimLeft, hotkey,hotkey,% InStr(hotkey,A_Space,1,0)
	Loop % times
		backspace .= "{Backspace}"
	keywait = Ctrl|Alt|Shift|LWin|RWin
	Loop, Parse, keywait, |
		KeyWait, %A_LoopField%
	If ((!IsLabel or (IsLabel and IsLabel(keystr))) and InStr(A_ThisHotkey, "~") and !RegExMatch(A_ThisHotkey
	, "i)\^[^\!\d]|![^\d]|#|Control|Ctrl|LCtrl|RCtrl|Shift|RShift|LShift|RWin|LWin|Escape|BackSpace|F\d\d?|"
	. "Insert|Esc|Escape|BS|Delete|Home|End|PgDn|PgUp|Up|Down|Left|Right|ScrollLock|CapsLock|NumLock|AppsKey|"
	. "PrintScreen|CtrlDown|Pause|Break|Help|Sleep|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|"
	. "Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|MButton|RButton|LButton|"
	. "Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2"))
		SendInput % backspace
	If (WinExist("AHK_class #32768") and hotkey = "RButton")
		WinClose, AHK_class #32768
	If !IsLabel
		SendInput % keystr
	else if IsLabel(keystr)
		Gosub, %keystr%
	Return
}

Morse(timeout = 400) { ;by Laszo -> http://www.autohotkey.com/forum/viewtopic.php?t=16951   +   Modifications by HotKeyIt
   allkeys:="+AppsKey+Lwin+Rwin+NumLock+LControl+RControl+LAlt+RAlt+LShift+RShift+Tab+Backspace+Enter+Left+Right"
	. "+Up+Down+Delete+Insert+Escape+Home+End+PgUp+PgDn+Numpad0+Numpad1+Numpad2+Numpad3"
	. "+Numpad4+Numpad5+Numpad6+Numpad7+Numpad8+Numpad9+NumpadDot+NumpadDiv+NumpadMult+NumpadAdd"
	. "+NumpadSub+NumpadEnter+NumpadIns+NumpadEnd+NumpadDown+NumpadPgDn+NumpadLeft+NumpadClear+NumpadRight"
	. "+NumpadHome+NumpadUp+NumpadPgUp+NumpadDel+NumpadDiv+NumpadMult+NumpadAdd+NumpadSub+NumpadEnter"
	. "+F1+F2+F3+F4+F5+F6+F7+F8+F9+F10+F11+F12+F13+F14+F15+F16+F17+F18+F19"
	. "+F20+F21+F22+F23+F24+Pause+Break+PrintScreen+a+b"
	. "+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t+u+v+w+x+y+z+0+1"
	. "+2+3+4+5+6+7+8+9+Space+!+""+`%+``+´+'+(+)+,+-+.+\+/"
	. "+:+;+<+>+=+?+@+[+]+^+_+{+}+|+RButton+LButton+MButton+"
	key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
	If key=
		key:=SubStr(A_ThisHotkey,0)
   IfInString, key, %A_Space%
		StringTrimLeft, key, key,% InStr(key,A_Space,1,0)
	If key=BS
		key=BackSpace
	else if key=Esc
		key=Escape
	else if key=Return
		key=Enter
	else if key=Ins
		key=Insert
	else if key=Del
		key=Delete
	else if key=LCtrl
		key=LControl
	else if key=RCtrl
		key=RControl
	If key=Alt
		StringReplace,k,allkeys,+LAlt+RAlt+,+
	else if (key="Ctrl" or key="Control")
		StringReplace,k,allkeys,+LControl+RControl+,+
	else if key=Shift
		StringReplace,k,allkeys,+LShift+RShift+,+
	else
		StringReplace,k,allkeys,+%key%+,+
	If (SubStr(k,1,1)="+")
		StringTrimLeft,k,k,1
	If (SubStr(k,0)="+")
		StringTrimRight,k,k,1
	StringSplit,k,k,+
	If (key!="+")
		k140=+
   Loop {
      t := A_TickCount
		While % (GetKeyState(key,"P") and (A_TickCount-t < timeout)){
			other:=GetKeystate(k1,"P")+GetKeystate(k2,"P")+GetKeystate(k3,"P")+GetKeystate(k4,"P")+GetKeystate(k5,"P")
			+GetKeystate(k6,"P")+GetKeystate(k7,"P")+GetKeystate(k8,"P")+GetKeystate(k9,"P")+GetKeystate(k10,"P")
			+GetKeystate(k11,"P")+GetKeystate(k12,"P")+GetKeystate(k13,"P")+GetKeystate(k14,"P")+GetKeystate(k15,"P")
			+GetKeystate(k16,"P")+GetKeystate(k17,"P")+GetKeystate(k18,"P")+GetKeystate(k19,"P")+GetKeystate(k20,"P")
			+GetKeystate(k21,"P")+GetKeystate(k22,"P")+GetKeystate(k23,"P")+GetKeystate(k24,"P")+GetKeystate(k25,"P")
			+GetKeystate(k26,"P")+GetKeystate(k27,"P")+GetKeystate(k28,"P")+GetKeystate(k29,"P")+GetKeystate(k30,"P")
			+GetKeystate(k31,"P")+GetKeystate(k32,"P")+GetKeystate(k33,"P")+GetKeystate(k34,"P")+GetKeystate(k35,"P")
			+GetKeystate(k36,"P")+GetKeystate(k37,"P")+GetKeystate(k38,"P")+GetKeystate(k39,"P")+GetKeystate(k40,"P")
			+GetKeystate(k41,"P")+GetKeystate(k42,"P")+GetKeystate(k43,"P")+GetKeystate(k44,"P")+GetKeystate(k45,"P")
			+GetKeystate(k46,"P")+GetKeystate(k47,"P")+GetKeystate(k48,"P")+GetKeystate(k49,"P")+GetKeystate(k50,"P")
			+GetKeystate(k51,"P")+GetKeystate(k52,"P")+GetKeystate(k53,"P")+GetKeystate(k54,"P")+GetKeystate(k55,"P")
			+GetKeystate(k56,"P")+GetKeystate(k57,"P")+GetKeystate(k58,"P")+GetKeystate(k59,"P")+GetKeystate(k60,"P")
			+GetKeystate(k61,"P")+GetKeystate(k62,"P")+GetKeystate(k63,"P")+GetKeystate(k64,"P")+GetKeystate(k65,"P")
			+GetKeystate(k66,"P")+GetKeystate(k67,"P")
			other+=GetKeystate(k68,"P")+GetKeystate(k69,"P")+GetKeystate(k70,"P")+GetKeystate(k71,"P")+GetKeystate(k72,"P")
			+GetKeystate(k73,"P")+GetKeystate(k74,"P")+GetKeystate(k75,"P")+GetKeystate(k76,"P")+GetKeystate(k77,"P")
			+GetKeystate(k78,"P")+GetKeystate(k79,"P")+GetKeystate(k80,"P")+GetKeystate(k81,"P")+GetKeystate(k82,"P")
			+GetKeystate(k83,"P")+GetKeystate(k84,"P")+GetKeystate(k85,"P")+GetKeystate(k86,"P")+GetKeystate(k87,"P")
			+GetKeystate(k88,"P")+GetKeystate(k89,"P")+GetKeystate(k90,"P")+GetKeystate(k91,"P")+GetKeystate(k92,"P")
			+GetKeystate(k93,"P")+GetKeystate(k94,"P")+GetKeystate(k95,"P")+GetKeystate(k96,"P")+GetKeystate(k97,"P")
			+GetKeystate(k98,"P")+GetKeystate(k99,"P")+GetKeystate(k100,"P")+GetKeystate(k101,"P")+GetKeystate(k102,"P")
			+GetKeystate(k103,"P")+GetKeystate(k104,"P")+GetKeystate(k105,"P")+GetKeystate(k106,"P")+GetKeystate(k107,"P")
			+GetKeystate(k108,"P")+GetKeystate(k109,"P")+GetKeystate(k110,"P")+GetKeystate(k111,"P")+GetKeystate(k112,"P")
			+GetKeystate(k113,"P")+GetKeystate(k114,"P")+GetKeystate(k115,"P")+GetKeystate(k116,"P")+GetKeystate(k117,"P")
			+GetKeystate(k118,"P")+GetKeystate(k119,"P")+GetKeystate(k120,"P")+GetKeystate(k121,"P")+GetKeystate(k122,"P")
			+GetKeystate(k123,"P")+GetKeystate(k124,"P")+GetKeystate(k125,"P")+GetKeystate(k126,"P")+GetKeystate(k127,"P")
			+GetKeystate(k128,"P")+GetKeystate(k129,"P")+GetKeystate(k130,"P")+GetKeystate(k131,"P")+GetKeystate(k132,"P")
			+GetKeystate(k133,"P")+GetKeystate(k134,"P")+GetKeystate(k135,"P")+GetKeystate(k136,"P")+GetKeystate(k137,"P")
			+GetKeystate(k138,"P")+GetKeystate(k139,"P")+GetKeystate(k140,"P")
			If other>0
					Return
			KeyWait %key%, T0.03
			If (!ErrorLevel){
				Pattern .= A_TickCount-t > timeout
				continued:=1
				break
			}
		}
		If !continued
			Return Pattern
		t := A_TickCount
		While % (!GetKeyState(key,"P") and (A_TickCount-t < timeout)){
			other:=GetKeystate(k1,"P")+GetKeystate(k2,"P")+GetKeystate(k3,"P")+GetKeystate(k4,"P")+GetKeystate(k5,"P")
			+GetKeystate(k6,"P")+GetKeystate(k7,"P")+GetKeystate(k8,"P")+GetKeystate(k9,"P")+GetKeystate(k10,"P")
			+GetKeystate(k11,"P")+GetKeystate(k12,"P")+GetKeystate(k13,"P")+GetKeystate(k14,"P")+GetKeystate(k15,"P")
			+GetKeystate(k16,"P")+GetKeystate(k17,"P")+GetKeystate(k18,"P")+GetKeystate(k19,"P")+GetKeystate(k20,"P")
			+GetKeystate(k21,"P")+GetKeystate(k22,"P")+GetKeystate(k23,"P")+GetKeystate(k24,"P")+GetKeystate(k25,"P")
			+GetKeystate(k26,"P")+GetKeystate(k27,"P")+GetKeystate(k28,"P")+GetKeystate(k29,"P")+GetKeystate(k30,"P")
			+GetKeystate(k31,"P")+GetKeystate(k32,"P")+GetKeystate(k33,"P")+GetKeystate(k34,"P")+GetKeystate(k35,"P")
			+GetKeystate(k36,"P")+GetKeystate(k37,"P")+GetKeystate(k38,"P")+GetKeystate(k39,"P")+GetKeystate(k40,"P")
			+GetKeystate(k41,"P")+GetKeystate(k42,"P")+GetKeystate(k43,"P")+GetKeystate(k44,"P")+GetKeystate(k45,"P")
			+GetKeystate(k46,"P")+GetKeystate(k47,"P")+GetKeystate(k48,"P")+GetKeystate(k49,"P")+GetKeystate(k50,"P")
			+GetKeystate(k51,"P")+GetKeystate(k52,"P")+GetKeystate(k53,"P")+GetKeystate(k54,"P")+GetKeystate(k55,"P")
			+GetKeystate(k56,"P")+GetKeystate(k57,"P")+GetKeystate(k58,"P")+GetKeystate(k59,"P")+GetKeystate(k60,"P")
			+GetKeystate(k61,"P")+GetKeystate(k62,"P")+GetKeystate(k63,"P")+GetKeystate(k64,"P")+GetKeystate(k65,"P")
			+GetKeystate(k66,"P")+GetKeystate(k67,"P")
			other+=GetKeystate(k68,"P")+GetKeystate(k69,"P")+GetKeystate(k70,"P")+GetKeystate(k71,"P")+GetKeystate(k72,"P")
			+GetKeystate(k73,"P")+GetKeystate(k74,"P")+GetKeystate(k75,"P")+GetKeystate(k76,"P")+GetKeystate(k77,"P")
			+GetKeystate(k78,"P")+GetKeystate(k79,"P")+GetKeystate(k80,"P")+GetKeystate(k81,"P")+GetKeystate(k82,"P")
			+GetKeystate(k83,"P")+GetKeystate(k84,"P")+GetKeystate(k85,"P")+GetKeystate(k86,"P")+GetKeystate(k87,"P")
			+GetKeystate(k88,"P")+GetKeystate(k89,"P")+GetKeystate(k90,"P")+GetKeystate(k91,"P")+GetKeystate(k92,"P")
			+GetKeystate(k93,"P")+GetKeystate(k94,"P")+GetKeystate(k95,"P")+GetKeystate(k96,"P")+GetKeystate(k97,"P")
			+GetKeystate(k98,"P")+GetKeystate(k99,"P")+GetKeystate(k100,"P")+GetKeystate(k101,"P")+GetKeystate(k102,"P")
			+GetKeystate(k103,"P")+GetKeystate(k104,"P")+GetKeystate(k105,"P")+GetKeystate(k106,"P")+GetKeystate(k107,"P")
			+GetKeystate(k108,"P")+GetKeystate(k109,"P")+GetKeystate(k110,"P")+GetKeystate(k111,"P")+GetKeystate(k112,"P")
			+GetKeystate(k113,"P")+GetKeystate(k114,"P")+GetKeystate(k115,"P")+GetKeystate(k116,"P")+GetKeystate(k117,"P")
			+GetKeystate(k118,"P")+GetKeystate(k119,"P")+GetKeystate(k120,"P")+GetKeystate(k121,"P")+GetKeystate(k122,"P")
			+GetKeystate(k123,"P")+GetKeystate(k124,"P")+GetKeystate(k125,"P")+GetKeystate(k126,"P")+GetKeystate(k127,"P")
			+GetKeystate(k128,"P")+GetKeystate(k129,"P")+GetKeystate(k130,"P")+GetKeystate(k131,"P")+GetKeystate(k132,"P")
			+GetKeystate(k133,"P")+GetKeystate(k134,"P")+GetKeystate(k135,"P")+GetKeystate(k136,"P")+GetKeystate(k137,"P")
			+GetKeystate(k138,"P")+GetKeystate(k139,"P")+GetKeystate(k140,"P")
			If other>0
					Return
			KeyWait %key%, DT0.03
			If (!ErrorLevel){
				continued:=1
				break
			}
		}
		If !continued
			Return Pattern
		continued=
   }
}


/*
~h::RapidHotkey("{Raw}Hello World!", 3) ;Press h 4 times rapidly to send Hello World!
~o::RapidHotkey("^o", 4, 0.2) ;be careful, if you use this hotkey, above will not work properly
~Esc::RapidHotkey("exit", 4, 0.2, 1) ;Press Esc 4 times rapidly to exit this script
~LControl::RapidHotkey("!{TAB}",2) ;Press LControl rapidly twice to AltTab
~RControl::RapidHotkey("+!{TAB}",2) ;Press RControl rapidly twice to ShiftAltTab
~LShift::RapidHotkey("^{TAB}", 2) ;Switch back in internal windows
~RShift::RapidHotkey("^+{TAB}", 2) ;Switch between internal windows
~e::RapidHotkey("#e""#r",3) ;Run Windows Explorer
~^!7::RapidHotkey("{{}{}}{Left}", 2)

~a::RapidHotkey("test", 2, 0.3, 1) ;You Can also specify a Label to be launched
test:
MsgBox, Test
Return

Exit:
ExitApp

~LButton & RButton::RapidHotkey("Menu1""Menu2""Menu3",1,0.3,1)
Menu1:
Menu2:
Menu3:
MsgBox % A_ThisLabel
Return

RapidHotkey(keystroke, times="2", delay=0.2, IsLabel=0)
{
	Pattern := Morse(delay*1000)
;~ 	allkeys:="AppsKey+ALT+LWIN+RWIN+SHIFT+NumLock+LControl+LAlt+LShift+Tab+Backspace+Enter+Left+Right"
;~ 	. "+Up+Down+Delete+Insert+Escape+Home+End+PgUp+PgDn+Numpad0+Numpad1+Numpad2+Numpad3"
;~ 	. "+Numpad4+Numpad5+Numpad6+Numpad7+Numpad8+Numpad9+NumpadDot+NumpadDiv+NumpadMult+NumpadAdd"
;~ 	. "+NumpadSub+NumpadEnter+NumpadIns+NumpadEnd+NumpadDown+NumpadPgDn+NumpadLeft+NumpadClear+NumpadRight"
;~ 	. "+NumpadHome+NumpadUp+NumpadPgUp+NumpadDel+NumpadDiv+NumpadMult+NumpadAdd+NumpadSub+NumpadEnter"
;~ 	. "+F1+F2+F3+F4+F5+F6+F7+F8+F9+F10+F11+F12+F13+F14+F15+F16+F17+F18+F19"
;~ 	. "+F20+F21+F22+F23+F24+Pause+Break+PrintScreen+LWin+RWin+RControl+RAlt+RShift+a+b"
;~ 	. "+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t+u+v+w+x+y+z+0+1"
;~ 	. "+2+3+4+5+6+7+8+9+Space+!+""+`%+``+´+'+(+)+,+-+.+\+/"
;~ 	. "+:+;+<+>+=+?+@+[+]+^+_+{+}+|"
;~    key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
;~ 	If key=BS
;~ 		key=BackSpace
;~ 	else if key=Esc
;~ 		key=Escape
;~    IfInString, key, %A_Space%
;~ 	StringTrimLeft, key, key,% InStr(key,A_Space,1,0)
;~    Loop {
;~       t := A_TickCount
;~ 		While % (A_TickCount-t < delay*1000){
;~ 			Loop,parse,allkeys,+
;~ 			{
;~ 				If (GetKeyState(A_LoopField,"P") and A_LoopField!=key)
;~ 					Return
;~ 				else if (A_LoopField=key and !GetKeyState(A_LoopField,"P") and breaked:=1 and ((Pattern := Pattern . (A_TickCount-t > delay*1000)) or 1))
;~ 					break
;~ 			}
;~ 			If breaked
;~ 				break
;~       }
;~ 		breaked=
;~ 		t := A_TickCount
;~ 		While % (A_TickCount-t < delay*1000){
;~ 			Loop,parse,allkeys,+
;~ 			{
;~ 				If GetKeyState(A_LoopField,"P"){
;~ 					If (A_LoopField!=key)
;~ 						Return
;~ 					else if (breaked:=1 and continued:=1)
;~ 						break
;~ 				}
;~ 			}
;~ 			If breaked
;~ 				break
;~ 		}
;~ 		If !continued
;~ 			break
;~ 		continued=
;~ 		breaked=
;~ 	}
	If (StrLen(Pattern) < 2 and Chr(Asc(times)) != "1")
		Return
	If (times = "" and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""	
			If (StrLen(Pattern) = A_Index+1)
				continue := A_Index, times := StrLen(Pattern)
	}
	Else if (RegExMatch(times, "^\d+$") and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""
			If (StrLen(Pattern) = A_Index+times-1)
				times := StrLen(Pattern), continue := A_Index
	}
	Else if InStr(times, """")
	{
		Loop, Parse, times,""
			If (StrLen(Pattern) = A_LoopField)
				continue := A_Index, times := A_LoopField
	}
	Else if (times = "")
		continue = 1, times = 2
	Else if (times = StrLen(Pattern))
		continue = 1
	If !continue
		Return
	Loop, Parse, keystroke,""
		If (continue = A_Index)
			keystr := A_LoopField
	Loop, Parse, IsLabel,""
		If (continue = A_Index)
			IsLabel := A_LoopField
	hotkey := RegExReplace(A_ThisHotkey, "[\*\~\$\#\+\!\^]")
	IfInString, hotkey, %A_Space%
		StringTrimLeft, hotkey,hotkey,% InStr(hotkey,A_Space,1,0)
	Loop % times
		backspace .= "{Backspace}"
	keywait = Ctrl|Alt|Shift|LWin|RWin
	Loop, Parse, keywait, |
		KeyWait, %A_LoopField%
	If ((!IsLabel or (IsLabel and IsLabel(keystr))) and InStr(A_ThisHotkey, "~") and !RegExMatch(A_ThisHotkey
	, "i)\^[^\!\d]|![^\d]|#|Control|Ctrl|LCtrl|RCtrl|Shift|RShift|LShift|RWin|LWin|Escape|BackSpace|F\d\d?|"
	. "Insert|Esc|Escape|BS|Delete|Home|End|PgDn|PgUp|Up|Down|Left|Right|ScrollLock|CapsLock|NumLock|AppsKey|"
	. "PrintScreen|CtrlDown|Pause|Break|Help|Sleep|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|"
	. "Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|MButton|RButton|LButton|"
	. "Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2"))
		SendInput % backspace
	If (WinExist("AHK_class #32768") and hotkey = "RButton")
		WinClose, AHK_class #32768
	If !IsLabel
		SendInput % keystr
	else if IsLabel(keystr)
		Gosub, %keystr%
	Return
}

Morse(timeout = 400) { ;by Laszo -> http://www.autohotkey.com/forum/viewtopic.php?t=16951   +   Modifications by HotKeyIt
   allkeys:="+AppsKey+Lwin+Rwin+NumLock+LControl+RControl+LAlt+RAlt+LShift+RShift+Tab+Backspace+Enter+Left+Right"
	. "+Up+Down+Delete+Insert+Escape+Home+End+PgUp+PgDn+Numpad0+Numpad1+Numpad2+Numpad3"
	. "+Numpad4+Numpad5+Numpad6+Numpad7+Numpad8+Numpad9+NumpadDot+NumpadDiv+NumpadMult+NumpadAdd"
	. "+NumpadSub+NumpadEnter+NumpadIns+NumpadEnd+NumpadDown+NumpadPgDn+NumpadLeft+NumpadClear+NumpadRight"
	. "+NumpadHome+NumpadUp+NumpadPgUp+NumpadDel+NumpadDiv+NumpadMult+NumpadAdd+NumpadSub+NumpadEnter"
	. "+F1+F2+F3+F4+F5+F6+F7+F8+F9+F10+F11+F12+F13+F14+F15+F16+F17+F18+F19"
	. "+F20+F21+F22+F23+F24+Pause+Break+PrintScreen+a+b"
	. "+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t+u+v+w+x+y+z+0+1"
	. "+2+3+4+5+6+7+8+9+Space+!+""+`%+``+´+'+(+)+,+-+.+\+/"
	. "+:+;+<+>+=+?+@+[+]+^+_+{+}+|+"
	key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
   IfInString, key, %A_Space%
		StringTrimLeft, key, key,% InStr(key,A_Space,1,0)
	If key=BS
		key=BackSpace
	else if key=Esc
		key=Escape
	If key=Alt
		StringReplace,k,allkeys,+LAlt+RAlt+,+Alt+
	else if key=Ctrl
		StringReplace,k,allkeys,+LControl+RControl+,+Ctrl+
	else if key=Shift
		StringReplace,k,allkeys,+LShift+RShift+,+Shift+
	else
		StringReplace,k,allkeys,+%key%+,+
	If (SubStr(k,1,1)="+")
		StringTrimLeft,k,k,1
	If (SubStr(k,0)="+")
		StringTrimRight,k,k,1
;~ 	MsgBox % kh
	StringSplit,k,k,+
   Loop {
      t := A_TickCount
		While % (GetKeyState(key,"P") and (A_TickCount-t < timeout)){
			other:=GetKeystate(k1,"P")+GetKeystate(k2,"P")+GetKeystate(k3,"P")+GetKeystate(k4,"P")+GetKeystate(k5,"P")+GetKeystate(k6,"P")+GetKeystate(k7,"P")+GetKeystate(k8,"P")+GetKeystate(k9,"P")+GetKeystate(k10,"P")+GetKeystate(k11,"P")+GetKeystate(k12,"P")+GetKeystate(k13,"P")+GetKeystate(k14,"P")+GetKeystate(k15,"P")+GetKeystate(k16,"P")+GetKeystate(k17,"P")+GetKeystate(k18,"P")+GetKeystate(k19,"P")+GetKeystate(k20,"P")+GetKeystate(k21,"P")+GetKeystate(k22,"P")+GetKeystate(k23,"P")+GetKeystate(k24,"P")+GetKeystate(k25,"P")+GetKeystate(k26,"P")+GetKeystate(k27,"P")+GetKeystate(k28,"P")+GetKeystate(k29,"P")+GetKeystate(k30,"P")+GetKeystate(k31,"P")+GetKeystate(k32,"P")+GetKeystate(k33,"P")+GetKeystate(k34,"P")+GetKeystate(k35,"P")+GetKeystate(k36,"P")+GetKeystate(k37,"P")+GetKeystate(k38,"P")+GetKeystate(k39,"P")+GetKeystate(k40,"P")+GetKeystate(k41,"P")+GetKeystate(k42,"P")+GetKeystate(k43,"P")+GetKeystate(k44,"P")+GetKeystate(k45,"P")+GetKeystate(k46,"P")+GetKeystate(k47,"P")+GetKeystate(k48,"P")+GetKeystate(k49,"P")+GetKeystate(k50,"P")+GetKeystate(k51,"P")+GetKeystate(k52,"P")+GetKeystate(k53,"P")+GetKeystate(k54,"P")+GetKeystate(k55,"P")+GetKeystate(k56,"P")+GetKeystate(k57,"P")+GetKeystate(k58,"P")+GetKeystate(k59,"P")+GetKeystate(k60,"P")+GetKeystate(k61,"P")+GetKeystate(k62,"P")+GetKeystate(k63,"P")+GetKeystate(k64,"P")+GetKeystate(k65,"P")+GetKeystate(k66,"P")+GetKeystate(k67,"P")
			other+=GetKeystate(k68,"P")+GetKeystate(k69,"P")+GetKeystate(k70,"P")+GetKeystate(k71,"P")+GetKeystate(k72,"P")+GetKeystate(k73,"P")+GetKeystate(k74,"P")+GetKeystate(k75,"P")+GetKeystate(k76,"P")+GetKeystate(k77,"P")+GetKeystate(k78,"P")+GetKeystate(k79,"P")+GetKeystate(k80,"P")+GetKeystate(k81,"P")+GetKeystate(k82,"P")+GetKeystate(k83,"P")+GetKeystate(k84,"P")+GetKeystate(k85,"P")+GetKeystate(k86,"P")+GetKeystate(k87,"P")+GetKeystate(k88,"P")+GetKeystate(k89,"P")+GetKeystate(k90,"P")+GetKeystate(k91,"P")+GetKeystate(k92,"P")+GetKeystate(k93,"P")+GetKeystate(k94,"P")+GetKeystate(k95,"P")+GetKeystate(k96,"P")+GetKeystate(k97,"P")+GetKeystate(k98,"P")+GetKeystate(k99,"P")+GetKeystate(k100,"P")+GetKeystate(k101,"P")+GetKeystate(k102,"P")+GetKeystate(k103,"P")+GetKeystate(k104,"P")+GetKeystate(k105,"P")+GetKeystate(k106,"P")+GetKeystate(k107,"P")+GetKeystate(k108,"P")+GetKeystate(k109,"P")+GetKeystate(k110,"P")+GetKeystate(k111,"P")+GetKeystate(k112,"P")+GetKeystate(k113,"P")+GetKeystate(k114,"P")+GetKeystate(k115,"P")+GetKeystate(k116,"P")+GetKeystate(k117,"P")+GetKeystate(k118,"P")+GetKeystate(k119,"P")+GetKeystate(k120,"P")+GetKeystate(k121,"P")+GetKeystate(k122,"P")+GetKeystate(k123,"P")+GetKeystate(k124,"P")+GetKeystate(k125,"P")+GetKeystate(k126,"P")+GetKeystate(k127,"P")+GetKeystate(k128,"P")+GetKeystate(k129,"P")+GetKeystate(k130,"P")+GetKeystate(k131,"P")+GetKeystate(k132,"P")+GetKeystate(k133,"P")+GetKeystate(k134,"P")+GetKeystate(k135,"P")+GetKeystate(k136,"P")
			If other>0
					Return
			KeyWait %key%, T0.03
			If (!ErrorLevel){
				Pattern .= A_TickCount-t > timeout
				continued:=1
				break
			}
		}
		If !continued
			Return Pattern
;~ 		ToolTip % key "." Pattern
		t := A_TickCount
		While % (!GetKeyState(key,"P") and (A_TickCount-t < timeout)){
			other:=GetKeystate(k1,"P")+GetKeystate(k2,"P")+GetKeystate(k3,"P")+GetKeystate(k4,"P")+GetKeystate(k5,"P")+GetKeystate(k6,"P")+GetKeystate(k7,"P")+GetKeystate(k8,"P")+GetKeystate(k9,"P")+GetKeystate(k10,"P")+GetKeystate(k11,"P")+GetKeystate(k12,"P")+GetKeystate(k13,"P")+GetKeystate(k14,"P")+GetKeystate(k15,"P")+GetKeystate(k16,"P")+GetKeystate(k17,"P")+GetKeystate(k18,"P")+GetKeystate(k19,"P")+GetKeystate(k20,"P")+GetKeystate(k21,"P")+GetKeystate(k22,"P")+GetKeystate(k23,"P")+GetKeystate(k24,"P")+GetKeystate(k25,"P")+GetKeystate(k26,"P")+GetKeystate(k27,"P")+GetKeystate(k28,"P")+GetKeystate(k29,"P")+GetKeystate(k30,"P")+GetKeystate(k31,"P")+GetKeystate(k32,"P")+GetKeystate(k33,"P")+GetKeystate(k34,"P")+GetKeystate(k35,"P")+GetKeystate(k36,"P")+GetKeystate(k37,"P")+GetKeystate(k38,"P")+GetKeystate(k39,"P")+GetKeystate(k40,"P")+GetKeystate(k41,"P")+GetKeystate(k42,"P")+GetKeystate(k43,"P")+GetKeystate(k44,"P")+GetKeystate(k45,"P")+GetKeystate(k46,"P")+GetKeystate(k47,"P")+GetKeystate(k48,"P")+GetKeystate(k49,"P")+GetKeystate(k50,"P")+GetKeystate(k51,"P")+GetKeystate(k52,"P")+GetKeystate(k53,"P")+GetKeystate(k54,"P")+GetKeystate(k55,"P")+GetKeystate(k56,"P")+GetKeystate(k57,"P")+GetKeystate(k58,"P")+GetKeystate(k59,"P")+GetKeystate(k60,"P")+GetKeystate(k61,"P")+GetKeystate(k62,"P")+GetKeystate(k63,"P")+GetKeystate(k64,"P")+GetKeystate(k65,"P")+GetKeystate(k66,"P")+GetKeystate(k67,"P")
			other+=GetKeystate(k68,"P")+GetKeystate(k69,"P")+GetKeystate(k70,"P")+GetKeystate(k71,"P")+GetKeystate(k72,"P")+GetKeystate(k73,"P")+GetKeystate(k74,"P")+GetKeystate(k75,"P")+GetKeystate(k76,"P")+GetKeystate(k77,"P")+GetKeystate(k78,"P")+GetKeystate(k79,"P")+GetKeystate(k80,"P")+GetKeystate(k81,"P")+GetKeystate(k82,"P")+GetKeystate(k83,"P")+GetKeystate(k84,"P")+GetKeystate(k85,"P")+GetKeystate(k86,"P")+GetKeystate(k87,"P")+GetKeystate(k88,"P")+GetKeystate(k89,"P")+GetKeystate(k90,"P")+GetKeystate(k91,"P")+GetKeystate(k92,"P")+GetKeystate(k93,"P")+GetKeystate(k94,"P")+GetKeystate(k95,"P")+GetKeystate(k96,"P")+GetKeystate(k97,"P")+GetKeystate(k98,"P")+GetKeystate(k99,"P")+GetKeystate(k100,"P")+GetKeystate(k101,"P")+GetKeystate(k102,"P")+GetKeystate(k103,"P")+GetKeystate(k104,"P")+GetKeystate(k105,"P")+GetKeystate(k106,"P")+GetKeystate(k107,"P")+GetKeystate(k108,"P")+GetKeystate(k109,"P")+GetKeystate(k110,"P")+GetKeystate(k111,"P")+GetKeystate(k112,"P")+GetKeystate(k113,"P")+GetKeystate(k114,"P")+GetKeystate(k115,"P")+GetKeystate(k116,"P")+GetKeystate(k117,"P")+GetKeystate(k118,"P")+GetKeystate(k119,"P")+GetKeystate(k120,"P")+GetKeystate(k121,"P")+GetKeystate(k122,"P")+GetKeystate(k123,"P")+GetKeystate(k124,"P")+GetKeystate(k125,"P")+GetKeystate(k126,"P")+GetKeystate(k127,"P")+GetKeystate(k128,"P")+GetKeystate(k129,"P")+GetKeystate(k130,"P")+GetKeystate(k131,"P")+GetKeystate(k132,"P")+GetKeystate(k133,"P")+GetKeystate(k134,"P")+GetKeystate(k135,"P")+GetKeystate(k136,"P")
			If other>0
					Return
			KeyWait %key%, DT0.03
			If (!ErrorLevel){
				continued:=1
				break
			}
		}
		If !continued
			Return Pattern
		continued=
   }
}


/*
~h::RapidHotkey("{Raw}Hello World!", 3) ;Press h 4 times rapidly to send Hello World!
~o::RapidHotkey("^o", 4, 0.2) ;be careful, if you use this hotkey, above will not work properly
~Esc::RapidHotkey("exit", 4, 0.2, 1) ;Press Esc 4 times rapidly to exit this script
~LControl::RapidHotkey("!{TAB}",2) ;Press LControl rapidly twice to AltTab
~RControl::RapidHotkey("+!{TAB}",2) ;Press RControl rapidly twice to ShiftAltTab
~LShift::RapidHotkey("^{TAB}", 2) ;Switch back in internal windows
~RShift::RapidHotkey("^+{TAB}", 2) ;Switch between internal windows
~e::RapidHotkey("#e""#r",3) ;Run Windows Explorer
~^!7::RapidHotkey("{{}{}}{Left}", 2)

~a::RapidHotkey("test", 2, 0.3, 1) ;You Can also specify a Label to be launched
test:
MsgBox, Test
Return

Exit:
ExitApp

~LButton & RButton::RapidHotkey("Menu1""Menu2""Menu3",1,0.3,1)
Menu1:
Menu2:
Menu3:
MsgBox % A_ThisLabel
Return

RapidHotkey(keystroke, times="2", delay=0.2, IsLabel=0)
{
;~ 	Pattern := Morse(delay*1000)
	allkeys:="AppsKey+ALT+LWIN+RWIN+SHIFT+NumLock+LControl+LAlt+LShift+Tab+Backspace+Enter+Left+Right"
	. "+Up+Down+Delete+Insert+Escape+Home+End+PgUp+PgDn+Numpad0+Numpad1+Numpad2+Numpad3"
	. "+Numpad4+Numpad5+Numpad6+Numpad7+Numpad8+Numpad9+NumpadDot+NumpadDiv+NumpadMult+NumpadAdd"
	. "+NumpadSub+NumpadEnter+NumpadIns+NumpadEnd+NumpadDown+NumpadPgDn+NumpadLeft+NumpadClear+NumpadRight"
	. "+NumpadHome+NumpadUp+NumpadPgUp+NumpadDel+NumpadDiv+NumpadMult+NumpadAdd+NumpadSub+NumpadEnter"
	. "+F1+F2+F3+F4+F5+F6+F7+F8+F9+F10+F11+F12+F13+F14+F15+F16+F17+F18+F19"
	. "+F20+F21+F22+F23+F24+Pause+Break+PrintScreen+LWin+RWin+RControl+RAlt+RShift+a+b"
	. "+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t+u+v+w+x+y+z+0+1"
	. "+2+3+4+5+6+7+8+9+Space+!+""+`%+``+´+'+(+)+,+-+.+\+/"
	. "+:+;+<+>+=+?+@+[+]+^+_+{+}+|"
   key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
	If key=BS
		key=BackSpace
	else if key=Esc
		key=Escape
   IfInString, key, %A_Space%
	StringTrimLeft, key, key,% InStr(key,A_Space,1,0)
   Loop {
      t := A_TickCount
		While % (A_TickCount-t < delay*1000){
			Loop,parse,allkeys,+
			{
				If (GetKeyState(A_LoopField,"P") and A_LoopField!=key)
					Return
				else if (A_LoopField=key and !GetKeyState(A_LoopField,"P") and breaked:=1 and ((Pattern := Pattern . (A_TickCount-t > delay*1000)) or 1))
					break
			}
			If breaked
				break
      }
		breaked=
		t := A_TickCount
		While % (A_TickCount-t < delay*1000){
			Loop,parse,allkeys,+
			{
				If GetKeyState(A_LoopField,"P"){
					If (A_LoopField!=key)
						Return
					else if (breaked:=1 and continued:=1)
						break
				}
			}
			If breaked
				break
		}
		If !continued
			break
		continued=
		breaked=
	}
	If (StrLen(Pattern) < 2 and Chr(Asc(times)) != "1")
		Return
	If (times = "" and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""	
			If (StrLen(Pattern) = A_Index+1)
				continue := A_Index, times := StrLen(Pattern)
	}
	Else if (RegExMatch(times, "^\d+$") and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""
			If (StrLen(Pattern) = A_Index+times-1)
				times := StrLen(Pattern), continue := A_Index
	}
	Else if InStr(times, """")
	{
		Loop, Parse, times,""
			If (StrLen(Pattern) = A_LoopField)
				continue := A_Index, times := A_LoopField
	}
	Else if (times = "")
		continue = 1, times = 2
	Else if (times = StrLen(Pattern))
		continue = 1
	If !continue
		Return
	Loop, Parse, keystroke,""
		If (continue = A_Index)
			keystr := A_LoopField
	Loop, Parse, IsLabel,""
		If (continue = A_Index)
			IsLabel := A_LoopField
	hotkey := RegExReplace(A_ThisHotkey, "[\*\~\$\#\+\!\^]")
	IfInString, hotkey, %A_Space%
		StringTrimLeft, hotkey,hotkey,% InStr(hotkey,A_Space,1,0)
	Loop % times
		backspace .= "{Backspace}"
	keywait = Ctrl|Alt|Shift|LWin|RWin
	Loop, Parse, keywait, |
		KeyWait, %A_LoopField%
	If ((!IsLabel or (IsLabel and IsLabel(keystr))) and InStr(A_ThisHotkey, "~") and !RegExMatch(A_ThisHotkey
	, "i)\^[^\!\d]|![^\d]|#|Control|Ctrl|LCtrl|RCtrl|Shift|RShift|LShift|RWin|LWin|Escape|BackSpace|F\d\d?|"
	. "Insert|Esc|Escape|BS|Delete|Home|End|PgDn|PgUp|Up|Down|Left|Right|ScrollLock|CapsLock|NumLock|AppsKey|"
	. "PrintScreen|CtrlDown|Pause|Break|Help|Sleep|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|"
	. "Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|MButton|RButton|LButton|"
	. "Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2"))
		SendInput % backspace
	If (WinExist("AHK_class #32768") and hotkey = "RButton")
		WinClose, AHK_class #32768
	If !IsLabel
		SendInput % keystr
	else if IsLabel(keystr)
		Gosub, %keystr%
	Return
}

Morse(timeout = 400) { ;by Laszo -> http://www.autohotkey.com/forum/viewtopic.php?t=16951   +   Modifications by HotKeyIt
   allkeys:="AppsKey+ALT+LWIN+RWIN+SHIFT+NumLock+LControl+LAlt+LShift+Tab+Backspace+Enter+Left+Right"
	. "+Up+Down+Delete+Insert+Escape+Home+End+PgUp+PgDn+Numpad0+Numpad1+Numpad2+Numpad3"
	. "+Numpad4+Numpad5+Numpad6+Numpad7+Numpad8+Numpad9+NumpadDot+NumpadDiv+NumpadMult+NumpadAdd"
	. "+NumpadSub+NumpadEnter+NumpadIns+NumpadEnd+NumpadDown+NumpadPgDn+NumpadLeft+NumpadClear+NumpadRight"
	. "+NumpadHome+NumpadUp+NumpadPgUp+NumpadDel+NumpadDiv+NumpadMult+NumpadAdd+NumpadSub+NumpadEnter"
	. "+F1+F2+F3+F4+F5+F6+F7+F8+F9+F10+F11+F12+F13+F14+F15+F16+F17+F18+F19"
	. "+F20+F21+F22+F23+F24+Pause+Break+PrintScreen+LWin+RWin+RControl+RAlt+RShift+a+b"
	. "+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t+u+v+w+x+y+z+0+1"
	. "+2+3+4+5+6+7+8+9+Space+!+""+`%+``+´+'+(+)+,+-+.+\+/"
	. "+:+;+<+>+=+?+@+[+]+^+_+{+}+|"
   key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
	If key=BS
		key=BackSpace
	else if key=Esc
		key=Escape
   IfInString, key, %A_Space%
	StringTrimLeft, key, key,% InStr(key,A_Space,1,0)
   Loop {
      t := A_TickCount
		While % (A_TickCount-t < timeout){
			Loop,parse,allkeys,+
			{
				If (GetKeyState(A_LoopField,"P") and A_LoopField!=key)
					Return
				else if (A_LoopField=key and !GetKeyState(A_LoopField,"P") and breaked:=1 and ((Pattern := Pattern . (A_TickCount-t > timeout)) or 1))
					break
			}
			If breaked
				break
      }
		breaked=
		t := A_TickCount
		While % (A_TickCount-t < timeout){
			Loop,parse,allkeys,+
			{
				If GetKeyState(A_LoopField,"P"){
					If (A_LoopField!=key)
						Return
					else if (breaked:=1 and continued:=1)
						break
				}
			}
			If breaked
				break
		}
		If !continued
			Return Pattern
		continued=
		breaked=
	}
}
*/
RapidHotkey(keystroke, times="2", delay=0.2, IsLabel=0)
{
	thishotkey:=A_ThisHotkey
  ,hotkey := RegExReplace(A_ThisHotkey, "[\*\~\$\#\+\!\^]")
	,Pattern := Morse(delay*1000)
	If (StrLen(Pattern) < 2 and Chr(Asc(times)) != "1")
		Return
	If (times = "" and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""	
			If (StrLen(Pattern) = A_Index+1)
				continue := A_Index, times := StrLen(Pattern)
	}
	Else if (RegExMatch(times, "^\d+$") and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""
			If (StrLen(Pattern) = A_Index+times-1)
				times := StrLen(Pattern), continue := A_Index
	}
	Else if InStr(times, """")
	{
		Loop, Parse, times,""
			If (StrLen(Pattern) = A_LoopField)
				continue := A_Index, times := A_LoopField
	}
	Else if (times = "")
		continue := 1, times := 2
	Else if (times = StrLen(Pattern))
		continue = 1
	If !continue
		Return
	Loop, Parse, keystroke,""
		If (continue = A_Index)
			keystr := A_LoopField
	Loop, Parse, IsLabel,""
		If (continue = A_Index)
			IsLabel := A_LoopField
	IfInString, hotkey, %A_Space%
		StringTrimLeft, hotkey,hotkey,% InStr(hotkey,A_Space,1,0)
  Loop % times
		backspace .= "{Backspace}"
	keywait = Ctrl|Alt|Shift|LWin|RWin
	Loop, Parse, keywait, |
		KeyWait, %A_LoopField%
  KeyWait % hotkey
  If thishotkey!=A_ThisHotkey
		Return
	If ((!IsLabel or (IsLabel and IsLabel(keystr))) and InStr(A_ThisHotkey, "~") and !RegExMatch(A_ThisHotkey
	, "i)\^[^\!\d]|![^\d]|#|Control|Ctrl|LCtrl|RCtrl|Shift|RShift|LShift|RWin|LWin|Alt|LAlt|RAlt|Escape|BackSpace|F\d\d?|"
	. "Insert|Esc|Escape|BS|Delete|Home|End|PgDn|PgUp|Up|Down|Left|Right|ScrollLock|CapsLock|NumLock|AppsKey|"
	. "PrintScreen|CtrlDown|Pause|Break|Help|Sleep|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|"
	. "Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|MButton|RButton|LButton|"
	. "Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Joy"))
		Send % backspace
	If (WinExist("AHK_class #32768") and hotkey = "RButton")
		WinClose, AHK_class #32768
	If !IsLabel
		Send % keystr
	else if IsLabel(keystr)
		Gosub, %keystr%
	Return
}	
Morse(timeout = 400) { ;by Laszo -> http://www.autohotkey.com/forum/viewtopic.php?t=16951 (Modified to return: KeyWait %key%, T%tout%)
   tout := timeout/1000
   key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
   IfInString, key, %A_Space%
		StringTrimLeft, key, key,% InStr(key,A_Space,1,0)
	If Key in Shift,Win,Ctrl,Alt
		key1:="{L" key "}{R" key "}"
   Loop {
      t := A_TickCount
      KeyWait %key%, T%tout%
		Pattern .= A_TickCount-t > timeout
		If(ErrorLevel)
			Return Pattern
    If key in Capslock,LButton,RButton,MButton
      KeyWait,%key%,T%tout% D
    else if (1=InStr(key,"Joy"))
      KeyWait,%key%,T%tout% D
    else
      Input,pressed,T%tout% L1 V,{%key%}%key1%
		If (ErrorLevel="Timeout" or ErrorLevel=1)
			Return Pattern
		else if (ErrorLevel="Max")
			Return
   }
}