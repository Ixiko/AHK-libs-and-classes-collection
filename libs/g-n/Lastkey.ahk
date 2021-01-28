; =================================================================================
; | LastKey.ahk by Holle. Special thanks to "just me" for creating the functions "IsDeadKey()" and "CombineKeys()" plus great support.
; |
; | What's the use of it?  --- The global variable LastKey contains the last pressed key or key-combination.
; |
; | Set Mode:   LastKeyMode := 1/2/3  ( default: "LastKeyMode := 2" )
; |
; | Mode 1 : The last pressed key (visible char, or keyname). Example1: "LControl + F10" --> "F10"
; | Mode 2 : Same like Mode 1, but combinations will stored too. Example: "LControl + F10" --> "^F10"
; | Mode 3 : Same like Mode 2, but combinations will differentiated by the side. Example: "LControl + F10" --> "<^F10"
; | https://www.autohotkey.com/boards/viewtopic.php?f=6&t=1740&sid=4a1eb1580fd458d392da552fe5cf439c
; | Tip: If the result of the key-combination a visible key (like "Alt + Control + q" --> "@"), in all modes the visible key ist stored.
; =================================================================================
#SingleInstance Force
#Persistent
#NoEnv

Process, Priority, , High
SetBatchLines, -1

hDriver:=DllCall("GetModuleHandle", "uint", 0) ; can be the good solution if dead key header and other...
hKbdHook := DllCall("SetWindowsHookEx", "int", 0x0D, "uint", RegisterCallback("LastKey"), "uint", hDriver, "uint", 0)
OnExit, UnhookKeyboardAndExit

Goto LastKeyIncludePoint

LastKey(nCode, wParam, lParam) {
	global LastKey , LastKeyMode , ShiftHook , ControlHook , AltHook , WinHook
	static DeadKey := "" , DeadKeyShift := ""
	VK:=NumGet(lParam+0), SC:=NumGet(lParam+4), flag:=NumGet(lParam+8), KeyName := GetKeyName("vk" dec2hex(vk,1))
	if (flag > 127) { ; "key up"
		if KeyName contains Shift
			ShiftHook := false
		else if KeyName contains Control
			ControlHook := false
		else if KeyName contains Alt
			AltHook := false
		else if KeyName contains Win
			WinHook := false
		return DllCall("CallNextHookEx", "uint", hKbdHook, "int", nCode, "uint", wParam, "uint", lParam)
	}
	ShiftState := GetKeyState("Shift","P")?"+":""
	ControlState := GetKeyState("Control","P")?"^":""
	AltState := GetKeyState("Alt","P")?"!":""
	LWinState := GetKeyState("LWin","P")?"<#":""
	RWinState := GetKeyState("RWin","P")?">#":""
	WinState := GetKeyState("Win","P")?"#":LWinState?"#":RWinState?"#":""
	LShiftState := GetKeyState("LShift","P")?"<+":""
	RShiftState := GetKeyState("RShift","P")?">+":""
	LControlState := GetKeyState("LControl","P")?"<^":""
	RControlState := GetKeyState("RControl","P")?">^":""
	LAltState := GetKeyState("LAlt","P")?"<!":""
	RAltState := GetKeyState("RAlt","P")?">!":""
	AltGrState := RAltState&&ControlState?"<^>!":""
	if ((KeyName = "RAlt") && ControlState)
		KeyName := "AltGr"
	if (StrLen(KeyName) = 1) { ; Single Key
		StringLower, KeyName, KeyName
		if DeadKey { ; the key before was a "Dead Key"
			sleep 1
			LastKey := CombineKeys(KeyName, ShiftState, DeadKey, DeadKeyShift) , DeadKey := DeadKeyShift := ""
		}
		else if DeadKey := IsDeadKey(VK, , ShiftState ControlState AltState) ; this key is a "Dead key"
			DeadKeyShift := ShiftState
		else {
			CombineKey := CombineKeys(KeyName, ShiftState ControlState AltState)
			if ((asc(CombineKey) > 32) && (asc(CombineKey) != asc(KeyName))) || (LastKeyMode = 1) ; visible char
				LastKey := CombineKey
			else if (LastKeyMode = 3)
				LastKey := LControlState RControlState LAltState RAltState LWinState RWinState KeyName
			else
				LastKey := ControlState AltState WinState KeyName
		}
	}
	else { ; named key
		if LastKey contains Button,Wheel,Joy
		{
			if ShiftHook && (SubStr(KeyName,-4) = "Shift")
				return DllCall("CallNextHookEx", "uint", hKbdHook, "int", nCode, "uint", wParam, "uint", lParam)
			if ControlHook && (SubStr(KeyName,-6) = "Control")
				return DllCall("CallNextHookEx", "uint", hKbdHook, "int", nCode, "uint", wParam, "uint", lParam)
			if AltHook && (SubStr(KeyName,-2) = "Alt")
				return DllCall("CallNextHookEx", "uint", hKbdHook, "int", nCode, "uint", wParam, "uint", lParam)
			if WinHook && (SubStr(KeyName,-2) = "Win")
				return DllCall("CallNextHookEx", "uint", hKbdHook, "int", nCode, "uint", wParam, "uint", lParam)
		}
		prefix := ""
		if (LastKeyMode = 1)
			LastKeyPrefix := KeyName
		else {
			States = LShiftState|RShiftState|LControlState|RControlState|LAltState|RAltState|LWinState|RWinState
			Loop, parse, States, |
				prefix .= KeyName=StrTrimRight(A_LoopField,5)?"":%A_LoopField%
			LastKeyPrefix := prefix . KeyName
		}
		if (KeyName = "AltGr") {
			Stringreplace, LastKeyPrefix, LastKeyPrefix, <^, , all
			Stringreplace, LastKeyPrefix, LastKeyPrefix, >!, , all
		}
		if (LastKeyMode = 2) {
			CutLastKey := StrTrimRight(LastKeyPrefix,1)
			StringReplace, CutLastKey, CutLastKey, <, , All
			StringReplace, CutLastKey, CutLastKey, >, , All
			LastKeyPrefix := CutLastKey . SubStr(LastKeyPrefix,0,1)
		}
		LastKey := LastKeyPrefix
	}
	return DllCall("CallNextHookEx", "uint", hKbdHook, "int", nCode, "uint", wParam, "uint", lParam)
}

IsDeadKey(VK, SC := 0, Modifiers := "") { ; by just me
    Static VK_Mod := {"+": 0x10, "^": 0x11, "!": 0x12}
    VarSetCapacity(Chars, 32, 0)
    VarSetCapacity(ModStates, 256, 0)
    For Each, Modifier In StrSplit(Modifiers)
        If VK_Mod.HasKey(Modifier)
            NumPut(0x80, ModStates, VK_Mod[Modifier], "UChar")
    CharCount :=  DllCall("User32.dll\ToUnicode", "UInt", VK, "UInt", SC, "Ptr", &ModStates, "Str", Chars
                       , "Int", 16, "UInt", 0, "Int")
    If (CharCount < 0) { ; the specified key is a dead-key, remove it from the keyboard buffer
        VarSetCapacity(Dummy, 32, 0)
        VarSetCapacity(ModStates, 256, 0)
        DllCall("User32.dll\ToUnicode", "UInt", 0x20, "UInt", 0, "Ptr", &ModStates, "Str", Dummy
            , "Int", 16, "UInt", 0, "Int")
    }
    Return (CharCount = -1 ? Chars : "")
}

CombineKeys(Key, KeyModifiers := "", DeadKey := "", DeadKeyModifiers := "", Locale := 0) { ; by just me
    ; for more information about CombineKeys() visit http://ahkscript.org/boards/viewtopic.php?t=1336#p8806
    Static VK_Mod := {"+": 0x10, "^": 0x11, "!": 0x12}
    HKL := 0 ; initialize HKL
    If (Locale) {
        Locale := SubStr("0000000" . Locale, -7)
        If !(HKL := DllCall("User32.dll\LoadKeyboardLayout", "Str", Locale, "UInt", 0x81, "UInt"))
            Return ""
    }
    If (DeadKey) {
        VarSetCapacity(Chars, 32, 0)
        VarSetCapacity(ModStates, 256, 0)
        DeadKey := SubStr(DeadKey, 1, 1)
        VK := GetKeyVK(DeadKey)
        SC := GetKeySC(DeadKey)
        For Each, Modifier In StrSplit(DeadKeyModifiers)
            If VK_Mod.HasKey(Modifier)
                NumPut(0x80, ModStates, VK_Mod[Modifier], "UChar")
        CharCount :=  DllCall("User32.dll\ToUnicodeEx", "UInt", VK, "UInt", SC, "Ptr", &ModStates, "Str", Chars
                          , "Int", 16, "UInt", 0 , "UInt", HKL, "Int")
        If (CharCount <> -1) { ; the specified dead-key is invalid
            If (HKL)
                DllCall("User32.dll\UnloadKeyboardLayout", "UInt", HKL)
            Return ""
        }
    }
    VarSetCapacity(Chars, 32, 0)
    VarSetCapacity(ModStates, 256, 0)
    Key := SubStr(Key, 1, 1)
    VK := GetKeyVK(Key)
    SC := GetKeySC(Key)
    For Each, Modifier In StrSplit(KeyModifiers)
        If VK_Mod.HasKey(Modifier)
            NumPut(0x80, ModStates, VK_Mod[Modifier], "UChar")
    CharCount := DllCall("User32.dll\ToUnicodeEx", "UInt", VK, "UInt", SC, "Ptr", &ModStates, "Str", Chars
                      , "Int", 16, "UInt", 0, "UInt", HKL, "Int")
    If (CharCount < 0) { ; the specified key is a dead-key, remove it from the keyboard buffer and return ""
        VarSetCapacity(ModStates, 256, 0)
        DllCall("User32.dll\ToUnicodeEx", "UInt", 0x20, "UInt", 0, "Ptr", &ModStates, "Str", Chars
            , "Int", 16, "UInt", 0, "UInt", HKL, "Int")
        If (HKL)
            DllCall("User32.dll\UnloadKeyboardLayout", "UInt", HKL)
        Return ""
    }
    If (HKL)
        DllCall("User32.dll\UnloadKeyboardLayout", "UInt", HKL)
    If (CharCount < 1) ; the specified combination has no translation for the current state of the keyboard
        Return ""
    Return StrGet(&Chars, CharCount, "UTF-16")
}

dec2hex(value,CutPrefix = 0) { ; by Holle
    ; Decimal to Hexadecimal
    ; Example 1 --> dec2hex(26) = 0x1A
    ; Example 2 --> dec2hex(26,1) = 1A  (Prefix is cut)
    Format := A_FormatInteger
    SetFormat, IntegerFast, H
    value += 0
    value .= ""
    SetFormat, IntegerFast, %Format%
    if CutPrefix
        StringTrimLeft, value, value, 2
    return value
}

StrTrimRight(string, count) { ; Example --> StrTrimRight("This is a test", 3)  --> "This is a t"
    StringTrimRight, result, string, %count%
Return result
}

UnhookKeyboardAndExit:
    DllCall("UnhookWindowsHookEx", "uint", hKbdHook)
ExitApp

*~LButton::
*~MButton::
*~RButton::
*~XButton1::
*~XButton2::
*~WheelUp::
*~WheelDown::
*~WheelLeft::
*~WheelRight::
*~Joy1::
*~Joy2::
*~Joy3::
*~Joy4::
*~Joy5::
*~Joy6::
*~Joy7::
*~Joy8::
*~Joy9::
*~Joy10::
*~Joy11::
*~Joy12::
*~Joy13::
*~Joy14::
*~Joy15::
*~Joy16::
*~Joy17::
*~Joy18::
*~Joy19::
*~Joy20::
*~Joy21::
*~Joy22::
*~Joy23::
*~Joy24::
*~Joy25::
*~Joy26::
*~Joy27::
*~Joy28::
*~Joy29::
*~Joy30::
*~Joy31::
*~Joy32::
	StringTrimLeft, KeyName, A_ThisHotkey, 2  ; Remove *~
	ShiftState := GetKeyState("Shift","P")?"+":""
	ControlState := GetKeyState("Control","P")?"^":""
	AltState := GetKeyState("Alt","P")?"!":""
	LWinState := GetKeyState("LWin","P")?"<#":""
	RWinState := GetKeyState("RWin","P")?">#":""
	WinState := GetKeyState("Win","P")?"#":LWinState?"#":RWinState?"#":""
	LShiftState := GetKeyState("LShift","P")?"<+":""
	RShiftState := GetKeyState("RShift","P")?">+":""
	LControlState := GetKeyState("LControl","P")?"<^":""
	RControlState := GetKeyState("RControl","P")?">^":""
	LAltState := GetKeyState("LAlt","P")?"<!":""
	RAltState := GetKeyState("RAlt","P")?">!":""
	AltGrState := RAltState&&ControlState?"<^>!":""
	hooks = Shift|Control|Alt|Win
	Loop, parse, hooks, |
	   KeyHook := A_LoopField . "State" , %A_LoopField%Hook := (%KeyHook%)?true:false
	if (LastKeyMode = 1)
		LastKeyPrefix := KeyName
	else
		LastKeyPrefix := LShiftState RShiftState LControlState RControlState LAltState RAltState LWinState RWinState KeyName
	if (LastKeyMode = 2) {
		CutLastKey := StrTrimRight(LastKeyPrefix,1)
		StringReplace, CutLastKey, CutLastKey, <, , All
		StringReplace, CutLastKey, CutLastKey, >, , All
		LastKeyPrefix := CutLastKey . SubStr(LastKeyPrefix,0,1)
	}
	LastKey := LastKeyPrefix
return

LastKeyIncludePoint: ; make it possible to include at the beginning
{
}