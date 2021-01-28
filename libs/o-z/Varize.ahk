varize(var, autofix = true) 
{
	;var = "€:\Dév\« ÂùtöH°tkéÿ™ »\¡Dœ©s & Inf¤ß!"
	;MsgBox, % "var:`t" . var . "`nautofix:`t" . varize(var) . "`nerrors:`t" varize(var, false)
	Loop, Parse, var
	{ c = %A_LoopField%
		x := Asc(c)
		If (x > 47 and x < 58) or (x > 64 and x < 91) or (x > 96 and x < 123)
			or c = "#" or c = "_" or c = "@" or c = "$" or c = "?" or c = "[" or c = "]"
			IfEqual, autofix, 1, SetEnv, nv, %nv%%c%
			Else er++
	} If StrLen(var) > 254
		IfEqual, autofix, 1, StringLeft, var, var, 254
		Else er++
	IfEqual, autofix, 1, Return, nv
	Else Return, er
}