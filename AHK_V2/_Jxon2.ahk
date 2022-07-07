Jxon_Load2(ByRef src, args*) {
	static q := Chr(34)
	
	key := "", is_key := false
	stack := [ tree := [] ]
	
	is_arr := Map(tree, 1) ; ahk v2
	
	next := q "{[(01234567890-tfn"
	pos := 0
	
	while ( (ch := SubStr(src, ++pos, 1)) != "" ) {
		if InStr(" `t`n`r", ch)
			continue
		
		if !InStr(next, ch, true) {
			testArr := StrSplit(SubStr(src, 1, pos), "`n")
			ln := testArr.Length
			col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

			msg := Format("{}: line {} col {} (char {})"
			,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
			  : (next == "'")     ? "Unterminated string starting at"
			  : (next == "\")     ? "Invalid \escape"
			  : (next == ":")     ? "Expecting ':' delimiter"
			  : (next == q)       ? "Expecting object key enclosed in double quotes"
			  : (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
			  : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
			  : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
			  : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
			    , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
			, ln, col, pos)

			throw Exception(msg, -1, ch)
		}
		
		obj := stack[1]
		memType := Type(obj)
		is_array := (memType = "Array") ? 1 : 0
		
		if i := InStr("{[(", ch) { ; start new object / map?
			val := (i = 1) ? Map() : (i = 2) ? Array() : {}
			
			If (memType = "Array") {
				obj.Push(val)
			} Else If (memType = "Map") {
				obj[key] := val
			} Else If (memType = "Object") {
				obj.%key% := val
			}
			
			stack.InsertAt(1,val)
			
			is_arr[val] := !(is_key := (ch == "{" Or ch == "("))
			next := q (is_key ? "})" : "{([]0123456789-tfn")
		} else if InStr("}])", ch) {
			stack.RemoveAt(1)
			
			; memType2 := Type(stack[1])
			
			; If (stack[1] == tree)
				; next := ""
			; Else If (memType2 = "Array")
				; next := ",]"
			; Else If (memType2 = "Map")
				; next := ",}"
			; Else If (memType2 = "Object")
				; next := ",)"
			
			next := stack[1]==tree ? "" : (is_arr[stack[1]] ? ",]" : ",})")
		} else if InStr(",:", ch) {
			is_key := (!is_array && ch == ",")
			next := is_key ? q : q "{[(0123456789-tfn"
		} else { ; string | number | true | false | null
			if (ch == q) { ; string
				i := pos
				while i := InStr(src, q,, i+1) {
					val := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
					static end := A_AhkVersion<"2" ? 0 : -1
					if (SubStr(val, end) != "\")
						break
				}
				if !i ? (pos--, next := "'") : 0
					continue

				pos := i ; update pos

				  ; val := StrReplace(val,    "\/",  "/")
				val := StrReplace(val, "\" . q,    q)
				, val := StrReplace(val,    "\b", "`b")
				, val := StrReplace(val,    "\f", "`f")
				, val := StrReplace(val,    "\n", "`n")
				, val := StrReplace(val,    "\r", "`r")
				, val := StrReplace(val,    "\t", "`t")

				i := 0
				while i := InStr(val, "\",, i+1) {
					if (SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
						continue 2

					xxxx := Abs("0x" . SubStr(val, i+2, 4)) ; \uXXXX - JSON unicode escape sequence
					if (A_IsUnicode || xxxx < 0x100)
						val := SubStr(val, 1, i-1) . Chr(xxxx) . SubStr(val, i+6)
				}
				
				if is_key {
					key := val, next := ":"
					continue
				}
			} else { ; number | true | false | null
				val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)
				
				static number := "number", integer := "integer", float := "float"
				
				if val is number
				{
					if val is integer
						val += 0
					else if val is float
						val += 0
					else if (val == "true" || val == "false")
						val := %value% + 0
					else if (val == "null")
						val := ""
					else if is_key {			; Else if (pos--, next := "#")
						pos--, next := "#"			; continue
						continue
					}
				}
				
				pos += i-1
			}
			
			If (memType = "Array")
				obj.Push(val), next := ",]"
			Else If (memType = "Map")
				obj[key] := val, next := ",}"
			Else If (memType = "Object")
				obj.%key% := val, next := ",)"
			
			; is_array ? obj.Push(val) : obj[key] := val
			
			next := obj == tree ? "" : is_array ? ",]" : ",})"
		}
	}
	
	return tree[1]
}

arrType() {

}
















Jxon_Dump2(obj, indent:="", lvl:=1) {
	static q := Chr(34)
	
	if IsObject(obj) {
		memType := Type(obj) ; Type.Call(obj)
		is_array := (memType = "Array") ? 1 : 0
		
		if (memType ? (memType != "Object" And memType != "Map" And memType != "Array" And memType != "Class") : (ObjGetCapacity(obj) == "")) {
			throw Exception("Object type not supported.", -1, Format("<Object at 0x{:p}>", &obj))
		}
		
		static integer := "integer"
		if indent is integer ; %integer%
		{
			if (indent < 0)
				throw Exception("Indent parameter must be a postive integer.", -1, indent)
			spaces := indent, indent := ""
			
			Loop spaces ; ===> changed
				indent .= " "
		}
		indt := ""
		Loop indent ? lvl : 0
			indt .= indent

		lvl += 1, out := "" ; Make #Warn happy
		
		If (memType = "Array" Or memType = "Map") {
			for k, v in obj {
				If (Type(v) = "Prototype")
					continue
				
				if IsObject(k) || (k == "")
					throw Exception("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", &obj) : "<blank>")
				
				if (memType != "Array") ;// key ; ObjGetCapacity([k], 1)
					out .= (ObjGetCapacity([k]) ? Jxon_Dump2(k) : q k q) (indent ? ": " : ":") ; token + padding
				
				out .= Jxon_Dump2(v, indent, lvl) (indent ? ",`n" indt : ",") ; value -> token + indent
			}
		} Else {
			for k, v in obj.OwnProps() {
				If (Type(v) = "Prototype")
					continue
				
				if IsObject(k) || (k == "")
					throw Exception("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>`r`n`r`n", &obj) : "<blank>")
				
				if (memType != "Array") ;// key ; ObjGetCapacity([k], 1)
					out .= (ObjGetCapacity([k]) ? Jxon_Dump2(k) : q k q) (indent ? ": " : ":") ; token + padding
				
				out .= Jxon_Dump2(v, indent, lvl) (indent ? ",`n" indt : ",") ; value -> token + indent
			}
		}

		if (out != "") {
			out := Trim(out, ",`n" . indent)
			if (indent != "")
				out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent)+1)
		}
		
		If (memType = "Array")
			retVal := "[" out "]"
		Else If (memType = "Map")
			retVal := "{" out "}"
		Else If (memType = "Object" Or memType = "Class")
			retVal := "(" out ")"
		
		return retVal
	} else { ; Number or String
		If (Type(obj) != "String")
			return obj
		Else {
			obj := StrReplace(obj,"`t","\t")
			obj := StrReplace(obj,"`r","\r")
			obj := StrReplace(obj,"`n","\n")
			obj := StrReplace(obj,"`b","\b")
			obj := StrReplace(obj,"`f","\f")
			obj := StrReplace(obj,"\","\\")
			obj := StrReplace(obj,q,"\" q)
			return q obj q
		}
	}
}