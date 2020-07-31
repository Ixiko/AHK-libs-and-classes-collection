;Cross use functions

Compare(StringA, StringB){ ;Gives a similarity score for string A and B
	Score := 0, SearchLength := 0, LengthA := StrLen(StringA), LengthB := StrLen(StringB)
	Loop % (LengthA < LengthB ? LengthA : LengthB) * 2 {
		If Mod(A_Index, 2)
			SearchLength += 1, Needle := "A", Haystack := "B"
		Else Needle := "B", Haystack := "A"
		StartAtHaystack := 1, StartAtNeedle := 1
		While (StartAtNeedle + SearchLength <= Length%Needle% + 1) {
			SearchText := SubStr(String%Needle%, StartAtNeedle, SearchLength)
			If (Pos := InStr(String%Haystack%, SearchText, 0, StartAtHaystack)) {
				StartAtHaystack := Pos + SearchLength, StartAtNeedle += SearchLength, Score += SearchLength**2
				If (StartAtHaystack + SearchLength > Length%Haystack% + 1)
					Break
			} Else StartAtNeedle += 1
	}} Return Score / (LengthA > LengthB ? LengthA : LengthB)
}

StrRev(in){ ;Returns reversed string
	DllCall("msvcrt\_" (A_IsUnicode ? "wcs":"str") "rev", "UInt",&in, "CDecl")
	return in
}

SubStrEnd(str,len=1){ 	;Returns string with a number of chars removed from the end
	return SubStr(str,1,StrLen(var)-len)
}

Rotate(x=0, y=0, angle=0, cx=0, cy=0, GetLastY=0){	;Rotate coordinates. Clockwise and y down, x right. To ease usage, GetLastY must be used to get y variable from last call of Rotate()
	static ny
	If (GetLastY){
		return ny
	}
	radians := (3.14159265359 / 180) * (angle * -1),
	cos := cos(radians),
	sin := sin(radians),
	ny := (cos * (y - cy)) - (sin * (x - cx)) + cy
	nx := (cos * (x - cx)) + (sin * (y - cy)) + cx,
	return nx
}
RotateX(x, y,angle, cx=0, cy=0){ 	;Rotate coordinates. Clockwise and y down, x right. To ease usage, GetLastY must be used to get y variable from last call of Rotate()
	radians := (3.14159265359 / 180) * (angle * -1),
	nx := := (cos * (x - cx)) + (sin * (y - cy)) + cx,
	return nx
}
RotateY(x, y,angle, cx=0, cy=0){	;Rotate coordinates. Clockwise and y down, x right. To ease usage, GetLastY must be used to get y variable from last call of Rotate()
	radians := (3.14159265359 / 180) * (angle * -1),
	ny := (cos * (y - cy)) - (sin * (x - cx)) + cy
	return ny
}

Angle(x1,y1,x2,y2){ 	;Get angle between 2 points. y down, x right.
	Return atan2(y1 - y2, x2 - x1) * 180 / 3.14159265359 -90
}

Distance(x1,y1,x2,y2) { ;Get distance between 2 points.
	Return Sqrt((y2-y1)**2 + (x2-x1)**2)
}

Atan2(x,y) {  ;Atan2 math function ;4-quadrant atan
	Return dllcall("msvcrt\atan2","Double",y, "Double",x, "CDECL Double")
}

RandomNormal(min=0, max=100, skew=1) {	;Returns a random number generated with normal distribution in mind.
	Return ((sqrt( -2.0 * log( random(0.0,1.0) ) ) * cos( 2.0 * 3.14159265359 * random(0.0,1.0) ))/10.0 + 0.5)**skew*(max-min)+min
}

RemoveModifiers(Hotkey){ ; Returns Hotkey without typical modifers (!^+)
	Return RegExReplace(Hotkey, "^\+?\^?\!?")
}

TrimTrailingZeros(number) { ;Returns number with trailing zeroes removed. 10.00->10  4.380->4.38  120->120
	If number is float
		return regexReplace(number, "\.?0*$")
	else return number
}

TrimWhitespace(str) {	;Returns str without leading or trailing whitespace "	sd  `n"->"sd"
	Return regexreplace(regexreplace(str, "^\s+"), "\s+$") ;trim beginning and ending whitespace
}

MoveGuiToBounds(Gui,Aggressive=0){	;Move gui inside screen bounds partially or completely. Takes traywnd in to account but doesnt care how its positioned!
	SysGet, VW, 78
	SysGet, VH, 79
	Gui, %Gui%: +LastFound
	WinGetPos, GX, GY, GW, GH,
	WinGetPos,,,, TBH, ahk_class Shell_TrayWnd
	If (Aggressive=1)
		Gui, %Gui%:Show,% ((GX<0)?(" x-2 "):(((GX+GW>VW)?(" x" VW-GW+2):("")))) ((GY<0)?(" y0 "):(((GY+GH>VH-TBH-2)?(" y" VH-GH-TBH+2):(""))))
	else Gui, %Gui%:Show,% ((GX+GW<0)?(" x-2 "):(((GX>VW)?(" x" VW-GW+2):("")))) ((GY+GH<0)?(" y0 "):(((GY>VH-TBH-2)?(" y" VH-GH-TBH+2):(""))))
}

GetLayout() {	;Returns keyboard layout id
	Return DllCall("GetKeyboardLayout", Int,DllCall("GetWindowThreadProcessId", int,WinActive("A"), Int,0))
}
