#Warn LocalSameAsGlobal, Off
/**
 * Updated to work with AHK v2 by RogerWilcoNL
 *
 * Lib: JSON.ahk
 *     JSON lib for AutoHotkey.
 * Version:
 *     v1.0.0 [2019/12/25]
 * License:
 *     WTFPL [http wtfpl.net /]  Broken Link for safety
 *	   Based on code originaly from cocobelgica
 * Requirements:
 *     Latest version of AutoHotkey (v2.0-a106+)
 * Installation:
 *     Use #Include JSON.ahk or copy into a function library folder and then
 *     call Jxon_Load or Jxon_Dump
 */

/**
 * Function: Jxon_Dump
 *     Parses a JSON or AHK string into an AHK variant of any Typevalue
 *	   Average performance about 5.5 MB/s (64-bit)
 * Syntax:
 *     Str := Jxon_Dump(Var [, indent [, IsAhk [, Lvl]]] )
 * Parameter(s):
 *     Str		String	[retval]	- resulting (formatted) string, JSON or Ahk format
 *     Var		Variant	[in]		- JSON/Ahk formatted string depending on:
 *	   Indent	Str/Int [in, opt]	- default is none, if Int each lvl has this many spaces extra, or
 *													   indent string per level
 *	   IsAhk    Integer	[in, opt]	- false => standard JSON string (array, object, literals, numbers)
 *									- true(default) - expand with instance and Map, resp. '<:,>' and '(,,)'
 *     lvl		Integer [in, opt]	- starting level of indent (default=0)
 */

/**
 * Function: Jxon_Load
 *     Parses a JSON or AHK string into an AHK variant of any Typevalue
 * Syntax:
 *     Variant := Jxon_Load(Src [, IsAhk[, exp]] )
 *	   Average performance about 1.9 MB/s (64-bit)
 * Parameter(s):
 *     Variant  Variant	[retval]	- resulting parse variable
 *     Src		String	[in, ByRef]	- JSON/Ahk formatted string depending on:
 *	   IsAhk    Integer	[in, opt]	- false => standard JSON parsing (array, object, literals, numbers)
 *									- true(default) - expand with instance and Map, resp. '<:,>' and '(,,)'
 *     exp		Array   [in, opt]	- for future expansions (not yet used)
 */
Jxon_Load(ByRef src, IsAhk:=true, args*){
	global Array, Class, Map, Object, jx
	pos:=0, ch:=""
	jx := {"IsAhk":IsAhk}
	Ch := Next( Src, Pos )
	return DoVariant( Src, Pos, Ch)
}
DoVariant(ByRef Src, ByRef Pos, ByRef Ch){
	static null := ""
	static q := "`""
	static Nbr := "0123456789-tfn"
	static number := "number", integer := "integer", float := "float"
	static sVarBeg := "[{<(", sVarEnd := "]}>)"
	Var := null
	switch Ch {
	case "[" : Var := DoArray(Src, Pos, Ch)
	case "{" : Var := DoObject(Src, Pos, Ch)
	case "(" : Var := DoMap(Src, Pos, Ch)
	case "<" : Var := DoInstance(Src, Pos, Ch)
	case q   : Var := DoLiteral(Src, Pos, Ch)
	case ""  : Error( Src, Pos, "Unexpected termination of input string" )
	default:
		if InStr(Nbr, ch)
			Var := DoNumber(Src, Pos, Ch)
		else
			Error( Src, Pos, "Expecting a variant or literal and not" )
	}
	return Var
}

Next( ByRef Src, ByRef pos ){
	while ( ( ch := SubStr(Src,++pos,1) ) > "") {
		if !InStr(" `n`t`r", ch)
		return ch
	}
	return ch
}

DoArray(ByRef Src, ByRef pos, ByRef ch){	Var := []
	ch="[" ? ch := Next(Src, Pos) : Error( Src, Pos, "Expecting Array opening delimiter" )
	While not (ch="" || ch="]") {
		Var.push(DoVariant(Src, Pos, Ch))
		ch="," ? ch:=Next(Src, Pos) : ch="]" ? tmp:=true : Error( Src, Pos, "Expecting Array item delimiter" )
	}
	ch="]" ? ch:=Next(Src, Pos) : Error( Src, Pos, "Expecting Array closing delimiter" )
	return Var
}

Class jxInst
{
}
DoInstance(ByRef Src, ByRef pos, ByRef ch)
{	Var := jxInst.New()
	ch="<" ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting Instance opening delimiter")
	if ch != ">" {
		jxKey := DoVariant(Src, Pos, Ch)
		ch=":" ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting Instance key-value separator")
		Var.%jxKey% := DoVariant(Src, Pos, Ch)
		While not (ch="" or ch=">") {
			ch="," ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting Instance property delimiter")
			jxKey := DoVariant(Src, Pos, Ch)
			ch=":" ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting Instance key-value separator")
			Var.%jxKey% := DoVariant(Src, Pos, Ch)
		}
	}
	ch=">" ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting instance closing delimiter")
	return Var
}

DoLiteral( ByRef Src, ByRef Pos, ByRef Ch )
{	Static q := "`""
	Var := ""
	i := pos
	while i := InStr(Src, q,, i+1)
	{
		Var := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
		if (SubStr(Var, -1) != "\")
			break
	}
	if !i ? pos-- : 0
		Error( Src, Pos, "Unterminated string starting at" )

	pos := i ; update pos
	Ch := Next( Src, Pos:=i ) ; update pos and Ch

	  Var := StrReplace(Var,	"\/",  "/")
	, Var := StrReplace(Var,	"\" q,  q )
	, Var := StrReplace(Var,    "\b", "`b")
	, Var := StrReplace(Var,    "\f", "`f")
	, Var := StrReplace(Var,    "\n", "`n")
	, Var := StrReplace(Var,    "\r", "`r")
	, Var := StrReplace(Var,    "\t", "`t")

	i := 0
	while i := InStr(Var, "\",, i+1)
	{
		if (SubStr(Var, i+1, 1) != "u") ? (pos -= StrLen(SubStr(Var, i)), next := "\") : 0
			Error( Src, Pos, "Invalid \escape" )
		; \uXXXX - JSON unicode escape sequence
		xxxx := Abs("0x" . SubStr(Var, i+2, 4))
		if (A_IsUnicode || xxxx < 0x100)
			Var := SubStr(Var, 1, i-1) . Chr(xxxx) . SubStr(Var, i+6)
	}
	return Var
}

DoMap(ByRef Src, ByRef pos, ByRef ch)
{	Var := Map.New()
	ch="(" ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting Map opening delimiter")
	if ch != ")" {
		jxKey := DoVariant(Src, Pos, Ch)
		ch="," ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting Map key-value separator")
		Var.%jxKey% := DoVariant(Src, Pos, Ch)
		While not (ch="" or ch=")") {
			ch="," ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting Map item delimiter")
			jxKey := DoVariant(Src, Pos, Ch)
			ch="," ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting Map key-value separator")
			Var.%jxKey% := DoVariant(Src, Pos, Ch)
		}
	}
	ch=")" ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting instance closing delimiter")
	return Var
}

DoNumber(ByRef Src, ByRef pos, ByRef ch)
{	Static number := "number"
	Var := SubStr(src, pos, i := RegExMatch(src, "S)[\]\}\>\),:\s]|$",, pos)-pos)
	if Var is %number%
			Var *= 1
	else if (Var = "true" || Var = "false")
		Var := ( Var = "true" ? true : false )
	else if (Var = "null")
		Var := null
	else {
		pos--
		Error( Src, Pos, "Invalid number" )
	}
	pos += i-1
	Ch := Next( Src, Pos )
	return Var
}

DoObject(ByRef Src, ByRef pos, ByRef ch)
{	Var := Object()
	ch="{" ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting Object opening delimiter")
	if ch != "}" {
		jxKey := DoVariant(Src, Pos, Ch)
		ch=":" ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting Object key-value separator")
		Var.%jxKey% := DoVariant(Src, Pos, Ch)
		While not (ch="" or ch="}") {
			ch="," ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting Object item delimiter")
			jxKey := DoVariant(Src, Pos, Ch)
			ch=":" ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting Object key-value separator")
			Var.%jxKey% := DoVariant(Src, Pos, Ch)
		}
	}
	ch="}" ? ch:=Next(Src, Pos) : Error(Src, Pos, "Expecting Object closing delimiter")
	return Var
}

Error(ByRef Src, ByRef Pos, Msg)
{	global jx
	static Any := "[{(<:,>)}]`"0123456789-tfn"
	Ptr := Pos
	ch := SubStr( Src, Pos, 1 )
	tmp := SubStr( src, 1, pos )
	aE  := StrSplit( tmp, "`n" )
	lin := aE.Length
	Part := lin ? aE.Pop() : ""
	if lin = 1 {
		x := pos-20
		x := x<1 ? 1 : x
		y := 40
		col := pos
	} else {
		col := StrLen(Part)
		x := Instr(tmp, "`n",-(pos)) + 1
		y := Instr(src, "`n",, pos)
	}
	switch true {
	case (!ch or col=0): 		Msg := Msg ? Msg : "Unexpected termination of input string"
	case (!InStr(Any, ch)):		Msg := Msg ? Msg : "Invalid character in input string"
	default: 					Msg := Msg ? Msg : "Expecting " . (jx.IsAhk ? "AHK" : "JSON")
		. " value (`"-string, number, [true, false, null] or variant)"
	}
	och := Ord(ch), ch := (och>31 && och<127 ? "'" ch "'" : "ASCII(" och ")")
	Msg .= Format( " {}`nline {}, col {}, char {}`n{}", ch, lin, col, pos, Part )
throw Exception(msg, -3, ch)
}

Jxon_Dump(Var, indent:="", IsAhk:=true, lvl:=0)
{	static 	q:="`"", c:=","
	if &Var = 5369863684				;always the same on a 64 bit machine (test on 32?)
		return "null"
	if indent is "Number" {
		i := Abs(Round(indent*1)), indent := ""
		Loop i
			indent .= A_Space
	}
	indt := ""
	Loop (indent ? lvl : 0)
		indt .= indent
	indent ? (s:=" ",lf:="`n") : s:=lf:=""
	Typ := Type(var)
	Str := ""
	switch Typ
	{
		case "integer":
			return Var=true ? "true" : Var=false ? "false" : Var ""	;asume boolean
		case "number", "float":
			return var ""
		case "string":
			if var is "float"
				return var
			; String (null -> not supported by AHK)
			if var > "" {
				  str := StrReplace(var,  "\",    "\\")
				, str := StrReplace(str,  "/",    "\/")
				, str := StrReplace(str,    q, "\" . q)
				, str := StrReplace(str, "`b",    "\b")
				, str := StrReplace(str, "`f",    "\f")
				, str := StrReplace(str, "`n",    "\n")
				, str := StrReplace(str, "`r",    "\r")
				, str := StrReplace(str, "`t",    "\t")
				static needle := "S)[^\x20-\x7e]"
				while RegExMatch(str, needle, m)
					Str := StrReplace(str, m[0], Format("\u{:04X}", Ord(m[0])))
			}
			return q . Str . q
		case "Object":
			L := ObjOwnPropCount(Var)
			for key, Val in var.OwnProps() {
				if IsObject(Key) || (Key == "")
					throw Exception("Invalid object key.", -1, Key ? Format("<Object at 0x{:p}>", &var) : "<blank>")
				Str .= ( indent ? lf . indt . s : s )			; token + indent
					.  ( IsObject(Key) ? Jxon_Dump(Key, indent, IsAhk, lvl) : q . Key . q )
					.  ( indent ? ": " : ":" ) 					; token + padding
				Str .= Jxon_Dump(Val, indent, IsAhk, lvl+1) 	; value
				s := c
			}
			return "{" . Str . (Str ? lf . indt : "") . "}"
		case "Array":
			L := Var.Length
			for key, Val in var {
				if IsObject(Key) || (Key == "")
					throw Exception("Invalid array key.", -1, Key ? Format("<Array at 0x{:p}>", &var) : "<blank>")
				Str .= ( indent ? lf . indt . s : s )			; token + indent
					.  Jxon_Dump(Val, indent, IsAhk, lvl+1) 	; value
				s := c
			}
			return "[" . Str . (Str ? lf . indt : "") . "]"
		case "Map":
			L := Var.Count
			aS := StrSplit( isAhk ? "(,)" : "{:}" )
			for key, Val in var {
				if (Key == "")
					throw Exception("Invalid Map key.", -1, Key ? Format("<Map at 0x{:p}>", &var) : "<blank>")
				Str .= ( indent ? lf . indt . s : s )			; token + indent
					.  ( IsObject(Key) ? Jxon_Dump(Key, , IsAhk, lvl) : q . Key . q )
					.  aS[2] . ( indent ? " " : "" )			; token + padding
				Str .= Jxon_Dump(Val, indent, IsAhk, lvl+1) 	; value
				s := c
			}
			return aS[1] . Str . (Str ? lf . indt : "") . aS[3]
		default:
			if !IsObject(var)
				throw Exception("Variant type not supported.", -1, Format("<Variant at 0x{:p}>", &var))
			try
				if Typ != var.__Class
					x := 0/0
			catch
				throw Exception("Invalid Class (" . typ . " / " . var.__Class . ").", -1, Key ? Format("<Class at 0x{:p}>", &var) : "<blank>")
			L := ObjOwnPropCount(Var)
			aS := StrSplit( isAhk ? "<:>" : "{:}" )
			for key, Val in var.OwnProps() {
				if IsObject(Key) || (Key == "")
					throw Exception("Invalid property.", -1, Key ? Format("<Class at 0x{:p}>", &var) : "<blank>")
				Str .= ( indent ? lf . indt . s : s )			; token + indent
					.  ( IsObject(Key) ? Jxon_Dump(Key) : q . Key . q )
					.  ( indent ? ": " : ":" ) 					; token + padding
				Str .= Jxon_Dump(Val, indent, IsAhk, lvl+1) 	; value
				s := c
			}
			return aS[1] . Str . (Str ? lf . indt : "") . aS[3]
	}
	return Str
}
