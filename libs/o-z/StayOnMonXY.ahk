; Title:
; Link:   	github.com/lintalist/lintalist/blob/master/include/StayOnMonitor.ahk
; Author:
; Date:
; for:     	AHK_L


/*  LintaList Include [could be used elsewhere]

	Purpose: Get X, Y, Coordinates while keeping Gui ON active monitor
	Version: 1.1
	History
	v1.1 Added MonitorTop check to avoid search window moving off screen (top), could happen when using Office and scrolling document (reports caret pos offscreen)
	v1.0 initial version
	; called as XY:=StayOnMonXY(Width, Height, 0, 1, 1)

*/

StayOnMonXY(GW, GH, Mouse = 0, MouseAlternative = 1, Center = 0) 	{
	 ; GW = gui width
	 ; GH = gui heigth
	 ; Mouse = 1 or 0. If 1 use the mouse cursor
	 ; MouseAlternative = 1 or 0. If caret fails use mouse as an alternative
	 ; Center = 1 always center, 0 don't center, 2 remember position set by user.
	 Global XY
	 CoordMode, Caret, Screen
	 SysGet, MonitorCount, MonitorCount ; get number of monitors
	 Loop, %MonitorCount%
		{
		 SysGet, Monitor, Monitor, %A_Index%
		 MonitorMaxRight%A_Index% := MonitorRight
		 MonitorTop%A_Index%:=MonitorTop
		}

	 If (XY = "") and (Center = 2) ; first time we'll show Gui with Center = 2 so center it
		{
		 X := (A_ScreenWidth - GW) / 2
		 Y := (A_ScreenHeight - GH) / 2
		 Return ReturnXY(X,Y)
		}

	 If (Center = 2) ; simply return position set by user
		{
		 Return XY
		}

	 If (Center = 1)
		{
		 X := (A_ScreenWidth - GW) / 2
		 Y := (A_ScreenHeight - GH) / 2
		 Return ReturnXY(X,Y)
		}

	 If ((Mouse = 0) OR (Mouse = ""))
		{
		 X := A_CaretX ; get x & y via caret pos
		 Y := A_CaretY
		 If (X = "")
		 	X:=0
		 If (Y = "")
		 	Y:=0
		 If (If_Between(X, -50, 50) AND If_Between(Y, -50, 50) AND (MouseAlternative = 1)) ; if caret fails + use Mouse
		 {
		  CoordMode, Mouse , Screen
			MouseGetPos, X, Y
		 X-=100
		 Y-=10
		 }
 		 If (If_Between(X, -15, 15) AND If_Between(X, -15, 15) AND (MouseAlternative = 0)) ; if caret fails + don't use mouse find center of first monitor
			{
			 X := (A_ScreenWidth - GW) / 2
			 Y := (A_ScreenHeight - GH) / 2
			}
		}
	 Else If (Mouse = 1)
	 {
	   CoordMode, Mouse , Screen
		 MouseGetPos, X, Y
		 X-=100
		 Y-=50
		 ToolTip % X ":" Y
	 }

	 If ( Y + GH + 60 > A_ScreenHeight ) ; fix Y pos later, not as important, will need monitor bottom vars.
		Y := A_ScreenHeight - GH - 80

	 If (MonitorCount = 1) ; single monitor
		{
		 If ( X + GW > A_ScreenWidth )
			X := A_ScreenWidth - GW
		 If (X	< 0) ; single monitor offscreen
		 	X:=0
		}
	 Else
		{
		 If ( X > MonitorMaxRight1 AND X + GW > MonitorMaxRight2  ) ; 2nd monitor at right pos.
				X := MonitorMaxRight2 - GW - 10

		 If ( X > 0 AND X < MonitorMaxRight1 ) ; caret is found on first monitor
			{
			 If ( X + GW > MonitorMaxRight1 ) ; gui would be out of view of 1st monitor
				X := MonitorMaxRight1 - GW - 10
			}

		 If ( X < 0 ) ; 2nd monitor at left pos.
			{
				If ( X + GW > 0 ) ; gui would overflow to 1st monitor
				X := 0 - GW
			}
		}

	 If If_Between(X, -15, 15)
		X := 20
	 If If_Between(Y, -15, 15)
		Y := 20
	 If (Y < MonitorTop1)
		Y:=20

 Return ReturnXY(X,Y)
}

; v1.5 ensure valid coordinates are returned (mostly to prevent empty variables for Gui, Show)
ReturnXY(X,Y)	{
	 If (X = "") or (X = 0)
		X:=30
	 If (Y = "") or (Y = 0)
		Y:=100
	 If If_Between(X, -15, 15)
		X:=20
	 If If_Between(Y, -15, 15)
		Y:=20
 Return X . "|" . Y
}

; infogulch @ http://www.autohotkey.com/board/topic/29750-if-betweenincontainsis-functions/
; reference: http://www.autohotkey.com/docs/commands/IfBetween.htm
; Reverse 1/0,
;     1: reverses high and low if necessary
;     0: works like normal "If Var Between"
If_Between(Var, Low, High, Reverse = 0)	{
	 If Reverse
		Return (Low < High) ? (Low <= Var && Var <= High) : (High <= Var && Var <= Low)
 Return (Low <= Var && Var <= High)
}