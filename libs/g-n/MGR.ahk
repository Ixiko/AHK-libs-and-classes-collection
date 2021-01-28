/*
Name	: Mouse Gesture Recognizer v0.9.5 (09/May/2013)
Author	: R3gX
Link	: http://www.autohotkey.com/board/topic/66655-mgr-v094/?p=421676
GitHub	: https://github.com/R3gX/MGR

Description :
	This script allows you to use mouse gestures to
	- launch files, folders or urls
	- use functions (+parameters)
	- send macros or texts

Works with :
	AutoHotkey_L 1.1.9.04

Thanks to :
	@Carrozza, @sumon, @tsenlaw and others for their interest
Special thanks to :
	@mright for his work. v0.9.3+ use some of his ideas & code
	http://www.autohotkey.com/board/topic/66655-mgr-v094/?p=460086

Licence	:
	Use in source, library and binary form is permitted.
	Redistribution and modification must meet the following conditions:
	- My nickname (R3gX) and the origin (link) must be reproduced by binaries,
	  or attached in the documentation.
	- If changes are made to my work, you are encouraged (yet not obliged)
	  to post the changes for others to view, on the Autohotkey forum.
	ALL MY SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY EXPRESSED
	OR IMPLIED WARRANTIES.
*/

; Autoload the hotkey activation
mgr_Load()

; Set script's settings & hotkeys
mgr_Load(){
	CoordMode, Mouse, Screen
	SetFormat, Float, 0.3
	Hotkey,	*RButton,  mgr_MonitorRButton, On
	Hotkey,	#RButton,  mgr_MonitorRButton, On
	Hotkey, WheelUp,   mgr_Wheel, On
	Hotkey, WheelDown, mgr_Wheel, On
	Return
}

; Simulate the WheelUp & WheelDown button
mgr_Wheel(){
	mgr_Wheel:
	If (GetKeyState("RButton", "P") && A_ThisHotkey~="i)Wheel(Up|Down)")
		Return, mgr_WheelState(A_ThisHotkey, 1)
	Else
		SendInput, % mgr_GetModifiers() "{" A_ThisHotkey "}"
	Return, mgr_WheelState()
}

; Stor wheel buttons states
mgr_WheelState(Button="", State=""){
	static wheel := {"WheelUp":0, "WheelDown":0}
	If (Button~="i)Wheel(Up|Down)" && State~="[01]")
		Return, (wheel[Button] := State)
	Else If (Button~="i)Wheel(Up|Down)" && State=="")
		Return, wheel.HasKey(Button) ? wheel[Button] : 0
	Else
		wheel["WheelUp"] := 0, wheel["WheelDown"] := 0
}

; Monitor the RButton to recognize Rocker, Wheel and Mouse Gesture
mgr_MonitorRButton(){
	mgr_MonitorRButton:
	; Rocker gesture "LButton & RButton"
	If GetKeyState("LButton", "P")
		Return, mgr_Execute(mgr_GetCommand("LB-RB"))

	; Initialize variables
	Gesture := Direction := LDirection := Directions := ""
	mgr_WheelState() , Rocker_Wheel := 0
	MouseGetPos OriginalX, OriginalY

	While GetKeyState("RButton", "P"){
		Sleep 10

		; Rocker & Wheel Gestures
		If GetKeyState("LButton", "P")		; RButton & LButton
			mgr_Execute(mgr_GetCommand("RB-LB")) , Rocker_Wheel := 1
		Else If mgr_WheelState("WheelUp")	; RButton & WheelUp
			mgr_Execute(mgr_GetCommand("RB-WU")) , Rocker_Wheel := 1
		Else If mgr_WheelState("WheelDown")	; RButton & WheelDown
			mgr_Execute(mgr_GetCommand("RB-WD")) , Rocker_Wheel := 1
		Rocker_Wheel ? mgr_WheelState()

		; Mouse Gestures
		MouseGetPos CurrentX, CurrentY
		OffsetX := CurrentX-OriginalX, OffsetY := CurrentY-OriginalY
		If ((Distance := Sqrt(OffsetX**2+OffsetY**2))>=10){
			Direction := mgr_GetDirection(OffsetX, OffsetY, Distance)
			If (!LDirection || mgr_Offset(LDirection, Direction)>=90)
				Gesture .= (Gesture ? "-" : "") (LDirection := Direction)
				, mgr_GetCommand(Gesture, 1)
			OriginalX := CurrentX, OriginalY := CurrentY
		}
	}
	ToolTip
	If Rocker_Wheel
		Return
	Else If Gesture
		mgr_Execute(mgr_GetCommand(Gesture))
	Else
		SendInput, % mgr_GetModifiers() . "{RButton}"
	Return
}

; Calculate the mouse direction
mgr_GetDirection(OffsetX, OffsetY, Distance){
	static Directions := ["R", "UR", "U", "UL", "L", "DL", "D", "DR", "R"]
	n := ACos(OffsetX/Distance)/ATan(1)
	Return, Directions[Round(OffsetY<0 ? n : 8-n)+1]
}

; Calculate the minimal offset between two directions
mgr_Offset(Direction1, Direction2){
	static Angles := {R:0, UR:45, U:90, UL:135, L:180, DL:225, D:270, DR:315}
	Offset := Abs(Angles[Direction2]-Angles[Direction1])
	Return, (Offset>180 ? 360-Offset : Offset)
}

; Simple way to get hotkey modifiers
mgr_GetModifiers(){
	For Modifier,Symbol in {Ctrl:"^", Alt:"!", Shift:"+", LWin:"#"}
		Modifiers .= GetKeyState(Modifier,	"P") ? Symbol : ""
	Return, Modifiers
}

; Get the appropriate command for the current gesture
mgr_GetCommand(Gesture, Tooltip=0){
	If !Gesture
		Return

	MouseGetPos,,, WinID
	WinGetTitle, Title, % "ahk_id " WinID
	WinGetClass, Class, % "ahk_id " WinID
	WinGet, Process, ProcessName, % "ahk_id " WinID

	Gesture := (Shake := mgr_ShakeGesture(Gesture)) ? Shake : Gesture
	Gesture := mgr_GetModifiers() . Gesture
	Area    := mgr_GetMonitorArea(3, 3)
	mgr_G   := mgr_ReadGestures()
	S       := mgr_GetMatchingSection(mgr_G, Title, Class, Process)

	; Decreasing priority : Gesture@Area > Gesture
	For index,_G in [Gesture "@" Area, Gesture]
	{
		; Decreasing priority : Master > S.wT > S.wC > S.wP > Default
		Command := mgr_G["Master"].HasKey(_G)  ? mgr_G["Master", _G]
				:  mgr_G[S.wT].HasKey(_G)      ? mgr_G[S.wT, _G]
				:  mgr_G[S.wC].HasKey(_G)      ? mgr_G[S.wC, _G]
				:  mgr_G[S.wP].HasKey(_G)      ? mgr_G[S.wP, _G]
				:  mgr_G["Default"].HasKey(_G) ? mgr_G["Default", _G]
				:  ""
		If Command	; Leave the priority
			Break	; to first matching command
	}
	RegExMatch(Command, "(?P<CMD>.+?)(;(?P<DSC>.+?))?$", m)
	ToolTip, % (Tooltip==1) ? (mDSC ? mDSC : _G) : ""

	;; Debugging
	;ToolTip, % "Gesture`t: " Gesture "`nTitle`t: " Title "`nClass`t: " Class
	;		 . "`nProcess`t: " Process "`nCMD`t: " Command
	Return, Trim(mCMD)
}

; Load all the gestures from the config file
mgr_ReadGestures(){
	global mgr_Config
	mgr_G := {}
	IniRead, Sections, % mgr_Config
	Loop Parse, Sections, `n, `r
	{
		IniRead, Content, % mgr_Config, % (Section := A_LoopField)
		Loop, Parse, Section, |, % A_Space . A_Tab
		{
			If !IsObject(mgr_G[(SectionPart:= A_LoopField)])
				mgr_G[SectionPart] := {}
			Loop, Parse, Content, `n, `r
			{
				StringSplit, KeyVal, A_LoopField, =, % A_Space . A_Tab
				Loop, Parse, KeyVal1, |, % A_Space . A_Tab
					mgr_G[SectionPart, A_LoopField] := KeyVal2
			}
		}
	}
	Return, mgr_G
}

; Get the sections that match the current window process, class or title
mgr_GetMatchingSection(mgr_G, Title, Class, Process){
	For Section,oGestures in mgr_G
	{
		If not (Section~="i)" Process)
			Continue
		RegExMatch(Section, "i)" Process "\s*:(.+)", m)
		If (m1 && InStr(Title, m1))
			SwTitle := Section
		Else If (m1 && InStr(Class, m1))
			SwClass := Section
		Else If !m1
			SwProcess := Section
	}
	Return, {"wT":SwTitle, "wC":SwClass, "wP":SwProcess}
}

; Execute the command (shortcut, url, function, label, macro or text)
mgr_Execute(Command){
	Transform, Command, Deref, % Command
	If !(Command := Trim(Command))
		Return
	Func_rx := "^(?P<Func>\w+)\(\s*(?P<Params>.*?)\s*\)"
	If (RegExMatch(Command, Func_rx, m) && IsFunc(mFunc)){
		params := []
		Loop, Parse, mParams, CSV, %A_Space%%A_Tab%
			params.Insert(A_LoopField)
		%mFunc%(params*)
	}
	Else If IsLabel(Command)
		GoSub, % Command
	Else
		SendInput, % Command
}

; Recognize if the gesture is a shake gesture (HShake, VShake & DShake)
mgr_ShakeGesture(Gesture){
	shakes := ["(R)-L", "(L)-R", "(U)-D", "(D)-U"
			  , "(UR)-DL", "(DL)-UR", "(UL)-DR", "(DR)-UL"]
	For i,shake in shakes
		If RegExMatch(gesture, "i)^(" shake ")(-\1|-\2)+$", m)
			Return, (m2~="i)^[RL]$") ? "HShake" ; L-R-L , R-L-R , L-R-L-R...
				  : (m2~="i)^[UD]$") ? "VShake" ; D-U-D , U-D-U-D, D-U-D-U...
				  : "DShake"                    ; UL-DR-UL, DL-UR-DL-UR...
}

; Get the monitor area where the mouse is (tested with 2 monitors)
mgr_GetMonitorArea(partX, partY){
	CoordMode, Mouse, Screen
	MouseGetPos m_x, m_y, WinID
	SysGet, Monitor_, Monitor, % mgr_GetMonitorNbr()
	m_x := m_x-Monitor_Left , m_y := m_y-Monitor_Top
	onePartX := (Monitor_Right-Monitor_Left)//partX
	onePartY := (Monitor_Bottom-Monitor_Top)//partY
	Return, (m_x//onePartX) + ((m_y//onePartY)*partX) + 1
}

mgr_GetMonitorNbr(){ ; Get the monitor number where the mouse is
    SysGet, MonitorCount, 80
    MouseGetPos, X, Y
    Loop %MonitorCount%
    {
        SysGet, Mon, Monitor, %A_Index%
        If (X>=(MonLeft-10) && X<=(MonRight+10)
        	&& Y>=(MonTop-10) && Y<=(MonBottom+10))
            Return A_Index
    }
}