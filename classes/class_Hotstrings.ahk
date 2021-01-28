; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=7864
; Author:	GeekDude
; Date:
; for:     	AHK_L


/*
#NoEnv
SetBatchLines, -1

Hotstrings.Register("Oi)MsgBox,?\s*(.*)\n", Func("Test"))
return

Test(Match)
{
	MsgBox, % Match[1]
}

*/

class Hotstrings
{
	static Prefix := "*~$", Buf := "", MaxBuf := 2000, RegExps := ""
	, Reset := "Left,Right,Up,Down,Home,End,RButton,LButton"
	, _ := Hotstrings := new Hotstrings() ; Autoinitialization trick

	__New()
	{
		RegRead, sd, HKCU, Control Panel\International, sDecimal
		this.sd := sd, Target := this.Handle.Bind(this), m := this.Prefix
		Loop, 94
			if (A_Index < 33 || A_Index > 58)
				Hotkey, % m . Chr(A_Index+32), %target%
		for k,v in StrSplit("0,1,2,3,4,5,6,7,8,9,Dot,Div,Mult,Add,Sub,Enter", ",")
			Hotkey, %m%Numpad%v%, %target%
		for k,v in StrSplit("BS,Space,Enter,Return,Tab," this.Reset, ",")
			Hotkey, %m%%v%, %target%
	}

	Handle()
	{
		Critical

		Key := SubStr(A_ThisHotkey, StrLen(this.Prefix)+1), Buffer := this.Buf
		if (Key = "BS") ; I should probably try to remove the entire {} instead of ignoring it
			Buffer := SubStr(Buffer, 0) = "}" ? Buffer : SubStr(Buffer, 1, -1)
		else if Key in % this.Reset
			Buffer := ""
		else
		{
			Map := {Space: " ", Tab: "`t", Enter: "`n", Return: "`n"
			, Div: "/", Mult: "*", Add: "+", Sub: "-", Dot: this.sd}
			if Map.HasKey(Key := StrReplace(Key, "Numpad")) ; This probably won't have bad effects
				Key := Map[Key]
			else if (StrLen(Key) > 1) ; I'm not sure the circumstances in which this would trigger
				Key := "{" Key "}"
			else if (GetKeyState("Shift") ^ GetKeyState("CapsLock", "T"))
				Key := Format("{:U}", Key) ; StringUpper here wouldn't be a terrible idea
			Buffer .= Key
		}

		for RegEx, Info in this.RegExps
		{
			if (RegExMatch(Buffer, RegEx "$", Match))
			{
				MatchText := IsObject(Match) ? Match[0] : Match, Action := Info.Action
				Buffer := SubStr(Buffer, 1, -StrLen(MatchText))
				AutoBS := Info.AutoBS ? "{BS " StrLen(MatchText) "}" : ""

				if (IsLabel(Action) || IsFunc(Action) || IsObject(Action))
				{
					SendInput, %AutoBS%
					if IsFunc(Action)
					{
						; Hackaround to pass BoundFunc to itself
						Context := {Match: Match, Action: Action}
						Action := this.Proxy.Bind(this, Context)
						Context.BoundFunc := Action
					}
					SetTimer, %Action%, -0
				}
				else
				{
					Transform, Action, Deref, %Action%
					SendInput, %AutoBS%%Action%
				}
			}
		}
		this.Buf := SubStr(Buffer, -this.MaxBuf)
	}

	; Handles garbage collection for the timer
	Proxy(Context)
	{
		; Make sure to break the circular reference
		BoundFunc := Context.BoundFunc, Context.Delete("BoundFunc")
		SetTimer, %BoundFunc%, Delete
		Action := Context.Action, %Action%(Context.Match)
	}

	Register(RegEx, Action, AutoBS=1)
	{
		this.RegExps[RegEx] := {Action: Action, AutoBS: AutoBS}
	}
}