; MouseExtras
; Author: Pulover [Rodolfo U. Batista]
; rodolfoub@gmail.com

/*
- Allows to use subroutines for Holding and Double Clicking a Mouse Button.
- Keeps One-Click and Drag functions.
- Works with combinations, i.e. LButton & RButton.

Usage:
Assign the function to the Mouse Hotkey and input the Labels to
trigger with GoSub and wait times in the parameters:

MouseExtras("HoldSub", "DoubleSub", "HoldTime", "DClickTime", "Button")
  HoldSub: Button Hold Label.
  HoldTime: Wait Time to Hold Button (miliseconds - optional).
  DoubleSub: Double Click Label.
  DClickTime: Wait Time for Double Click (seconds - optional).
  Button: Choose a different Button (optional - may be useful for combinations).

- If you don't want to use a certain function put "" in the label.
- I recommend using the "*" prefix to allow them to work with modifiers.
- Note: Althought it's designed for MouseButtons it will work with Keyboard as well.
*/

MouseExtras(HoldSub, HoldTime="200", DoubleSub="", DClickTime="0.2", Button="")
{
    If Button =
		Button := A_ThisHotkey
	Button := LTrim(Button, "~*$")
	If InStr(Button, "&")
		Button := RegExReplace(Button, "^.*&( +)?")
	MouseGetPos, xpos
	Loop
	{
		MouseGetPos, xposn
		If (A_TimeSinceThisHotkey > HoldTime)
		{
			If IsLabel(HoldSub)
				GoSub, %HoldSub%
			Else
			{
				Send {%Button% Down}
				KeyWait, %Button%
				Send {%Button% Up}
			}
			return
		}
		Else
		If (xpos <> xposn)
		{
			Send {%Button% Down}
			KeyWait, %Button%
			Send {%Button% Up}
			return
		}
		Else
		If !GetKeyState(Button, "P")
		{
			If !IsLabel(DoubleSub)
			{
				Send {%Button%}
				return
			}
			KeyWait, %Button%, D T%DClickTime%
			If ErrorLevel
				Send {%Button%}
			Else
			{
				If IsLabel(DoubleSub)
					GoSub, %DoubleSub%
				Else
					Send {%Button%}
			}
			return
		}
	}
}