/*==Description=========================================================================

MOUSE GESTURES module
Author:		Learning one (Boris Mudrinic)
Contact:	boris-mudrinic@net.hr
AHK forum:	http://www.autohotkey.com/forum/topic56472.html

License:	
Mouse gestures module is free for non-commercial, personal use.
You are not allowed to use it commercialy or have any profit from it in general, without my written permission.
I'm not responsible for any damages arising from the use of Mouse gestures module. You are not allowed to remove
comments from this file.
In majotiry of cases, mentioning my name and contact will probably be all what I'll demand for giving you permission
to use this module commercialy. First ask and than act!


Documentation.
Mouse gestures are specific mouse movements which can be recognized by this module. 
Gestures recognition system recognizes 4 basic mouse movements; up, down, right, left.
Abbreviations for those movements are U (up), D (down) , R (right), and L (left).
Minimal mouse movement distance which this module recognizes as movement is 9 pixels.

To recognize mouse gesture, you have to call MG_Recognize() function. You can:
1) 	store performed gesture in variable. Example: Gesture := MG_Recognize()
2) 	or execute existing MG_ function. Syntaxs: "MG_" means mouse gesture. "U" means up, "D" down, "R" right, "L" left.
	So, for example, if function MG_R() exists in your script, it will be executed when you perform "drag right gesture"
	MG_RU() will be executed when you perform "drag right up gesture", MG_UDU() - "drag up down up gesture", etc.

MG_Recognize(MGHotkey="", ToolTip=0, MaxMoves=3, ExecuteMGFunction=1, SendIfNoDrag=1)
All parameters are optional.
-	MGHotkey 	mouse gesture hotkey. Can be: 1) any mouse button that can be pressed down and 2) any keyboard key
				except alt, control, shift (modifiers).
-	ToolTip 	1 means show gesture in tooltip while performing it, 0 means don't show it.
-	MaxMoves	maximum number of moves (directions) in one gesture. If you perform more moves than specified,
				gesture will be canceled. In that case, MG_Recognize() will not execute existing MG_<gesture> 
				function and will return blank value.
-	ExecuteMGFunction	1 means execute existing MG_<gesture> function. 0 means don't execute it.
-	SendIfNoDrag		1 means send MGHotkey click (press) if drag was under 9 pixels. 0 Means don't send it.

MG_Recognize() return values:
- blank	if gesture is canceled
- 0 if you dragged MGHotkey for less than 9 pixels
- <performed gesture> for example; R, D, LD, LUL, URL, etc.

If SendIfNoDrag = 1 (default), normal MGHotkey's click function is preserved; just click and don't drag and module will
send normal click. There are no built-in actions on gestures. It's up to you to write your commands that fit your needs.
You can find more informations about this type of mouse gestures in Radial menu help file. You will find Radial menu here:
http://www.autohotkey.com/forum/viewtopic.php?p=308352#308352
*/


;===Functions===========================================================================
MG_GetMove(Angle)
{
	Loop, 4
    {
		if (Angle <= 90*A_Index-45)
		{
			Sector := A_Index
			Break
		}
		Else if (A_Index = 4)
		Sector = 1
    }
	
	if Sector = 1
	Return "U"
	else if Sector = 2
	Return "R"
	else if Sector = 3
	Return "D"
	else if Sector = 4
	Return "L"
}

MG_GetAngle(StartX, StartY, EndX, EndY)
{
    x := EndX-StartX, y := EndY-StartY
    if x = 0
    {
        if y > 0
        return 180
        Else if y < 0
        return 360
        Else
        return
    }
    deg := ATan(y/x)*57.295779513
    if x > 0
    return deg + 90
    Else
    return deg + 270	
}

MG_GetRadius(StartX, StartY, EndX, EndY)
{
    a := Abs(endX-startX), b := Abs(endY-startY), Radius := Sqrt(a*a+b*b)
    Return Radius    
}

MG_Recognize(MGHotkey="", ToolTip=0, MaxMoves=3, ExecuteMGFunction=1, SendIfNoDrag=1)
{
   CoordMode, mouse, Screen
   MouseGetPos, mx1, my1
   if MGHotkey =
   MGHotkey := RegExReplace(A_ThisHotkey,"^(\w* & |\W)")
   Loop
   {
		if !(GetKeyState(MGHotkey, "p"))
		{
			if Gesture =
			{
				if ToolTip = 1
				ToolTip
				if SendIfNoDrag = 1
				{
					Suspend, on
					SendInput, {%MGHotkey%}
					Suspend, off
				}
				Return 0
			}
			if ToolTip = 1
			ToolTip
			if (IsFunc("MG_" Gesture) <> 0 and ExecuteMGFunction = 1)
			MG_%Gesture%()
			Return Gesture
		}
		Sleep, 20
		MouseGetPos, EndX, EndY
		Radius := MG_GetRadius(mx1, my1, EndX, EndY)
		if (Radius < 9)
		Continue
		
		Angle := MG_GetAngle(mx1, my1, EndX, EndY)
		MouseGetPos, mx1, my1
		CurMove := MG_GetMove(Angle)
		
		if !(CurMove = LastMove)
		{
			Gesture .= CurMove
			LastMove := CurMove
			{
				if (StrLen(Gesture) > MaxMoves)  
				{
					if ToolTip = 1
					ToolTip
					Progress, m2 b fs10 zh0 w80 WMn700, Gesture canceled
					Sleep, 200
					KeyWait, %MGHotkey%
					Progress, off
					Return
				}
			}
		}
		if ToolTip = 1
		ToolTip, %Gesture%
	}
}