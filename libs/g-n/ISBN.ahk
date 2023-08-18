If validate_Isbn("156881111X") {
	MsgBox % "156881111X is a Valid ISBN Number!"
}

If validate_Isbn("0-7475-3269-9") {
	MsgBox % "0-7475-3269-9 is a Valid ISBN Number!"
}

x := generate_isbn()

While !validate_Isbn(ByRef x) {
	x := generate_isbn()
}

MsgBox % x . "`nEnjoy your newly genereated valid ISBN Number.`nBe sure to check if it is in use"

generate_isbn() {
	Loop, 10 {
		Random, y, 0, 9
		g .= y
	}
	Return g 
}

validate_Isbn(v) {
	i := "10"
	StringReplace, v, v, -,, All ;remove -
		For each, Int in StrSplit(v,,"`r") {
			If InStr("Xx", SubStr(Int, 1,1)) {
				Int := "10"
			}
			r += i * Int			 
			i--	 
		}
		If !Mod(r, 11)
		{
			Return True  
		}
	Return False
}