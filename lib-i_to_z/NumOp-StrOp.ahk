
/*
q:: ;NumOp and StrOp
MsgBox, % (1 + 1) ;2
MsgBox, % JEE_NumOp(1, "+", 1) ;2

MsgBox, % JEE_NumOp("2", "<", "10") ;1
MsgBox, % JEE_StrOp(2, "<", 10) ;0

MsgBox, % JEE_StrOp("a", "<=", "b", "<=", "c") ;1
MsgBox, % JEE_StrOp("a", "<=", "d", "<=", "c") ;0
return
*/
;==================================================

;doesn't handle: => (fat arrow functions)
;doesn't handle: , (multi-statement)
;vArg1 is ByRef in case we need ++ -- += -= etc
;vArg2 is ByRef in case we need ++ -- &vArg2
;accepts 2, 3 or 5 parameters

JEE_StrOp(ByRef vArg1, ByRef vArg2, oParams*) {
	if !(oParams.Length() ~= "^(0|1|3)$")
		return

	if !oParams.Length() ;unary operators: new ++ -- - ! ~ & *
	{
		if else if (vArg1 = "new")
			return new %vArg2%
		else if (vArg1 = "!") || (vArg1 = "NOT")
			return !vArg2
		else if (vArg1 = "&")
			return &vArg2

		;ordinarily don't work with strings: ++ -- - ~ *
		else if (vArg1 = "++")
			++vArg2
		else if (vArg2 = "++")
			vArg1++
		else if (vArg1 = "--")
			--vArg2
		else if (vArg2 = "--")
			vArg1--
		else if (vArg1 = "-")
			return -vArg2
		else if (vArg1 = "~") ;AHK v2 style
			return vArg2 ^ -1
		else if (vArg1 = "*") ;not in AHK v2
			return NumGet(vArg2+0, 0, "UChar")
		return
	}

	vArg3 := oParams.1, vArg4 := oParams.2, vArg5 := oParams.3
	if (oParams.Length() = 3) ;ternary operators: ? :, < <, < <=, <= <, <= <=
	{
		if (vArg2 = "?") && (vArg4 = ":")
			return vArg1 ? vArg3 : vArg5
		else if (vArg2 = "<") && (vArg4 = "<")
			return ("" vArg1 < "" vArg3) && ("" vArg3 < "" vArg5)
		else if (vArg2 = "<") && (vArg4 = "<=")
			return ("" vArg1 < "" vArg3) && ("" vArg3 <= "" vArg5)
		else if (vArg2 = "<=") && (vArg4 = "<")
			return ("" vArg1 <= "" vArg3) && ("" vArg3 < "" vArg5)
		else if (vArg2 = "<=") && (vArg4 = "<=")
			return ("" vArg1 <= "" vArg3) && ("" vArg3 <= "" vArg5)
		return
	}

	;binary operators
	if (vArg2 = ".")
		return vArg1 . vArg3
	else if (vArg2 = "~=")
		return vArg1 ~= vArg3
	else if (vArg2 = ">")
		return "" vArg1 > "" vArg3
	else if (vArg2 = "<")
		return "" vArg1 < "" vArg3
	else if (vArg2 = ">=")
		return "" vArg1 >= "" vArg3
	else if (vArg2 = "<=")
		return "" vArg1 <= "" vArg3
	else if (vArg2 = "=") ;AHK v2 style
		return "" vArg1 = "" vArg3
	else if (vArg2 = "==") ;AHK v2 style
		return "" vArg1 == "" vArg3
	else if (vArg2 = "<>") ;may be removed in AHK v2
		return "" vArg1 <> "" vArg3
	else if (vArg2 = "!=") ;AHK v2 style
		return !("" vArg1 = "" vArg3)
	else if (vArg2 = "!==") ;AHK v2 style
		return !("" vArg1 == "" vArg3)
	else if (vArg2 = "&&") || (vArg2 = "AND") ;AHK v2 style
		return (vArg1 && vArg2) ? vArg2 : vArg1 ? vArg2 : vArg1
	else if (vArg2 = "||") || (vArg2 = "OR") ;AHK v2 style
		return vArg1 ? vArg1 : vArg3
	else if (vArg2 = ":=")
		vArg1 := vArg3
	else if (vArg2 = ".=")
		vArg1 .= vArg3

	;ordinarily don't work with strings:
	else if (vArg2 = "**")
		return vArg1 ** vArg3
	else if (vArg2 = "*")
		return vArg1 * vArg3
	else if (vArg2 = "/")
		return vArg1 / vArg3
	else if (vArg2 = "//")
		return vArg1 // vArg3
	else if (vArg2 = "+")
		return vArg1 + vArg3
	else if (vArg2 = "-")
		return vArg1 - vArg3
	else if (vArg2 = "<<")
		return vArg1 << vArg3
	else if (vArg2 = ">>")
		return vArg1 >> vArg3
	else if (vArg2 = "&")
		return !(vArg1 & vArg3)
	else if (vArg2 = "^")
		return vArg1 ^ vArg3
	else if (vArg2 = "|")
		return !(vArg1 | vArg3)
	else if (vArg2 = "+=")
		vArg1 += vArg3
	else if (vArg2 = "-=")
		vArg1 -= vArg3
	else if (vArg2 = "*=")
		vArg1 *= vArg3
	else if (vArg2 = "/=") ;AHK v2 style
		vArg1 := vArg1 / vArg3
	else if (vArg2 = "//=")
		vArg1 //= vArg3
	else if (vArg2 = "|=")
		vArg1 |= vArg3
	else if (vArg2 = "&=")
		vArg1 &= vArg3
	else if (vArg2 = "^=")
		vArg1 ^= vArg3
	else if (vArg2 = ">>=")
		vArg1 >>= vArg3
	else if (vArg2 = "<<=")
		vArg1 <<= vArg3

	if (vArg2 = "IS")
	{
		vType := vArg3
		%vType% := vType ;for AHK v2
		if vArg1 is %vType% ;[DO NOT CONVERT]
			return 1
		else
			return 0
	}

	;if object or a string without commas
	if (vArg2 = "CONTAINS" || vArg2 = "IN")
	&& !IsObject(vArg3) && !InStr(vArg3, ",")
		vArg3 := [vArg3]

	if (vArg2 = "CONTAINS") && IsObject(vArg3)
	{
		vText := vArg1, vNeedles := vArg3
		if !IsObject(vNeedles) && (vNeedles = "")
			return 1
		vCaseSen := (A_StringCaseSense = 1) || (A_StringCaseSense = "On")
		for vKey, vValue in (IsObject(vNeedles) ? vNeedles : StrSplit(vNeedles, ","))
			if InStr(vText, vValue, vCaseSen)
				return vKey
		return 0
	}

	if (vArg2 = "IN") && IsObject(vArg3)
	{
		vText := vArg1, vNeedles := vArg3
		if !IsObject(vNeedles) && (vNeedles = "") && (vText = "")
			return 1
		else if !(A_StringCaseSense = 1) && !(A_StringCaseSense = "On")
		{
			for vKey, vValue in (IsObject(vNeedles) ? vNeedles : StrSplit(vNeedles, ","))
				if ("" vText = "" vValue)
					return vKey
		}
		else
		{
			for vKey, vValue in (IsObject(vNeedles) ? vNeedles : StrSplit(vNeedles, ","))
				if ("" vText == "" vValue)
					return vKey
		}
		return 0
	}
}

;==================================================

;doesn't handle: => (fat arrow functions)
;doesn't handle: , (multi-statement)
;vArg1 is ByRef in case we need ++ -- += -= etc
;vArg2 is ByRef in case we need ++ -- &vArg2
;accepts 2, 3 or 5 parameters

JEE_NumOp(ByRef vArg1, ByRef vArg2, oParams*) {
	if !(oParams.Length() ~= "^(0|1|3)$")
		return

	if !oParams.Length() ;unary operators: new ++ -- - ! ~ & *
	{
		if else if (vArg1 = "new")
			return new %vArg2%
		else if (vArg1 = "!") || (vArg1 = "NOT")
			return !vArg2
		else if (vArg1 = "&")
			return &vArg2

		;ordinarily don't work with strings: ++ -- - ~ *
		else if (vArg1 = "++")
			++vArg2
		else if (vArg2 = "++")
			vArg1++
		else if (vArg1 = "--")
			--vArg2
		else if (vArg2 = "--")
			vArg1--
		else if (vArg1 = "-")
			return -vArg2
		else if (vArg1 = "~") ;AHK v2 style
			return vArg2 ^ -1
		else if (vArg1 = "*") ;not in AHK v2
			return NumGet(vArg2+0, 0, "UChar")
		return
	}

	vArg3 := oParams.1, vArg4 := oParams.2, vArg5 := oParams.3
	if (oParams.Length() = 3) ;ternary operators: ? :, < <, < <=, <= <, <= <=
	{
		if (vArg2 = "?") && (vArg4 = ":")
			return vArg1 ? vArg3 : vArg5
		else if (vArg2 = "<") && (vArg4 = "<")
			return (vArg1 < vArg3) && (vArg3 < vArg5)
		else if (vArg2 = "<") && (vArg4 = "<=")
			return (vArg1 < vArg3) && (vArg3 <= vArg5)
		else if (vArg2 = "<=") && (vArg4 = "<")
			return (vArg1 <= vArg3) && (vArg3 < vArg5)
		else if (vArg2 = "<=") && (vArg4 = "<=")
			return (vArg1 <= vArg3) && (vArg3 <= vArg5)
		return
	}

	;binary operators
	if (vArg2 = ".")
		return vArg1 . vArg3
	else if (vArg2 = "~=")
		return vArg1 ~= vArg3
	else if (vArg2 = ">")
		return vArg1 > vArg3
	else if (vArg2 = "<")
		return vArg1 < vArg3
	else if (vArg2 = ">=")
		return vArg1 >= vArg3
	else if (vArg2 = "<=")
		return vArg1 <= vArg3
	else if (vArg2 = "=") ;AHK v2 style
		return vArg1 = vArg3
	else if (vArg2 = "==") ;AHK v2 style
		return vArg1 == vArg3
	else if (vArg2 = "<>") ;may be removed in AHK v2
		return vArg1 <> vArg3
	else if (vArg2 = "!=") ;AHK v2 style
		return !(vArg1 = vArg3)
	else if (vArg2 = "!==") ;AHK v2 style
		return !(vArg1 == vArg3)
	else if (vArg2 = "&&") || (vArg2 = "AND") ;AHK v2 style
		return (vArg1 && vArg2) ? vArg2 : vArg1 ? vArg2 : vArg1
	else if (vArg2 = "||") || (vArg2 = "OR") ;AHK v2 style
		return vArg1 ? vArg1 : vArg3
	else if (vArg2 = ":=")
		vArg1 := vArg3
	else if (vArg2 = ".=")
		vArg1 .= vArg3

	;ordinarily don't work with strings:
	else if (vArg2 = "**")
		return vArg1 ** vArg3
	else if (vArg2 = "*")
		return vArg1 * vArg3
	else if (vArg2 = "/")
		return vArg1 / vArg3
	else if (vArg2 = "//")
		return vArg1 // vArg3
	else if (vArg2 = "+")
		return vArg1 + vArg3
	else if (vArg2 = "-")
		return vArg1 - vArg3
	else if (vArg2 = "<<")
		return vArg1 << vArg3
	else if (vArg2 = ">>")
		return vArg1 >> vArg3
	else if (vArg2 = "&")
		return !(vArg1 & vArg3)
	else if (vArg2 = "^")
		return vArg1 ^ vArg3
	else if (vArg2 = "|")
		return !(vArg1 | vArg3)
	else if (vArg2 = "+=")
		vArg1 += vArg3
	else if (vArg2 = "-=")
		vArg1 -= vArg3
	else if (vArg2 = "*=")
		vArg1 *= vArg3
	else if (vArg2 = "/=") ;AHK v2 style
		vArg1 := vArg1 / vArg3
	else if (vArg2 = "//=")
		vArg1 //= vArg3
	else if (vArg2 = "|=")
		vArg1 |= vArg3
	else if (vArg2 = "&=")
		vArg1 &= vArg3
	else if (vArg2 = "^=")
		vArg1 ^= vArg3
	else if (vArg2 = ">>=")
		vArg1 >>= vArg3
	else if (vArg2 = "<<=")
		vArg1 <<= vArg3

	if (vArg2 = "IS")
	{
		vType := vArg3
		%vType% := vType ;for AHK v2
		if vArg1 is %vType% ;[DO NOT CONVERT]
			return 1
		else
			return 0
	}

	;if object or a string without commas
	if (vArg2 = "CONTAINS" || vArg2 = "IN")
	&& !IsObject(vArg3) && !InStr(vArg3, ",")
		vArg3 := [vArg3]

	if (vArg2 = "CONTAINS") && IsObject(vArg3)
	{
		vText := vArg1, vNeedles := vArg3
		if (vNeedles = "")
			return 1
		vCaseSen := (A_StringCaseSense = 1) || (A_StringCaseSense = "On")
		for vKey, vValue in (IsObject(vNeedles) ? vNeedles : StrSplit(vNeedles, ","))
			if InStr(vText, vValue, vCaseSen)
				return vKey
		return 0
	}

	if (vArg2 = "IN") && IsObject(vArg3)
	{
		vText := vArg1, vNeedles := vArg3
		if (vNeedles = "") && (vText = "")
			return 1
		else if !(A_StringCaseSense = 1) && !(A_StringCaseSense = "On")
		{
			for vKey, vValue in (IsObject(vNeedles) ? vNeedles : StrSplit(vNeedles, ","))
				if (vText = vValue)
					return vKey
		}
		else
		{
			for vKey, vValue in (IsObject(vNeedles) ? vNeedles : StrSplit(vNeedles, ","))
				if (vText == vValue)
					return vKey
		}
		return 0
	}
}

;==================================================