/*
	Function: hotstrings
		Dynamically adds regular expression hotstrings.

	Parameters:
		c - regular expression hotstring
		a - (optional) text to replace hotstring with or a label to goto, 
			leave blank to remove hotstring definition from triggering an action

	Examples:
> hotstrings("(B|b)tw\s", "%$1%y the way") ; type 'btw' followed by space, tab or return
> hotstrings("i)omg", "oh my god{!}") ; type 'OMG' in any case, upper, lower or mixed
> hotstrings("\bcolou?r", "rgb(128, 255, 0);") ; '\b' prevents matching with anything before the word, e.g. 'multicololoured'

	License:
		- Version 2.54 <http://www.autohotkey.net/~Titan/#hotstrings>
		- Simplified BSD License <http://www.autohotkey.net/~Titan/license.txt>
*/
hotstrings(k, a = "")
{
	static z, m = "*~$", s, t, w = 2000
	global $
	If z = ; init
	{
		Loop, 94
		{
			c := Chr(A_Index + 32)
			If A_Index not between 33 and 58
				Hotkey, %m%%c%, __hs
		}
		e = BS|Space|Enter|Return|Tab
		Loop, Parse, e, |
			Hotkey, %m%%A_LoopField%, __hs
		z = 1
	}
	If (a == "" and k == "") ; poll
	{
		StringTrimLeft, q, A_ThisHotkey, StrLen(m)
		If q = BS
		{
			If (SubStr(s, 0) != "}")
				StringTrimRight, s, s, 1
		}
		Else
		{
			If q = Space
				q := " "
			Else If q = Tab
				q := "`t"
			Else If q in Enter,Return
				q := "`n"
			Else If (StrLen(q) != 1)
				q = {%q%}
			Else If (GetKeyState("Shift") or GetKeyState("CapsLock", "T"))
				StringUpper, q, q
			s .= q
		}
		Loop, Parse, t, `n ; check
		{
			StringSplit, x, A_LoopField, `r
			If (RegExMatch(s, x1 . "$", $)) ; match
			{
				StringLen, l, $
				StringTrimRight, s, s, l
				SendInput, {BS %l%}
				If (IsLabel(x2))
					Gosub, %x2%
				Else
				{
					Transform, x0, Deref, %x2%
					SendInput, %x0%
				}
			}
		}
		If (StrLen(s) > w)
			StringTrimLeft, s, s, w // 2
	}
	Else ; assert
	{
		StringReplace, k, k, `n, \n, All ; normalize
		StringReplace, k, k, `r, \r, All
		Loop, Parse, t, `n
		{
			l = %A_LoopField%
			If (SubStr(l, 1, InStr(l, "`r") - 1) == k)
				StringReplace, t, t, `n%l%
		}
		If a !=
			t = %t%`n%k%`r%a%
	}
	Return
	__hs: ; event
	hotstrings("", "")
	Return
}
