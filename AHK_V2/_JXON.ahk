;;;; AHK v2
; Example ===================================================================================
; ===========================================================================================

; Msgbox "The idea here is to create several nested arrays, save to text with JxonEncode(), and then reload the array with JxonDecode().  The resulting array should be the same.`r`n`r`nThis is what this example shows."

; a := Map(), b := Map(), c := Map(), d := Map(), e := Map(), f := Map()
; d["g"] := 1, d["h"] := 2, d["i"] := ["purple","pink","pippy red"]
; e["g"] := 1, e["h"] := 2, e["i"] := Map("1","test1","2","test2","3","test3")
; f["g"] := 1, f["h"] := 2, f["i"] := [1,2,Map("a",1.0009,"b",2.0003,"c",3.0001)]

; a["test1"] := "test11", a["d"] := d
; b["test3"] := "test33", b["e"] := e
; c["test5"] := "test55", c["f"] := f

; myObj := MyClass()
; myObj.a := a, myObj.b := b, myObj.c := c, myObj.test7 := "test77", myObj.test8 := "test88"

; g := ["blue","green","red"], myObj.h := g ; add linear array for testing

; textData2 := JxonEncode(myObj,4) ; ===> convert array to JSON
; msgbox "JSON output text:`r`n===========================================`r`n(Should match second output.)`r`n`r`n" textData2

; newObj := JxonDecode(&textData2) ; ===> convert json back to MyClass object

; textData3 := JxonEncode(newObj,4) ; ===> break down array into JSON string again, should be identical
; msgbox "Second output text:`r`n===========================================`r`n(should be identical to first output)`r`n`r`n" textData3

; ExitApp

; ===========================================================================================
; End Example ; =============================================================================
; ===========================================================================================

; originally posted by user coco on AutoHotkey.com
; https://github.com/cocobelgica/AutoHotkey-JSON

JxonDecode(&src, args*) {
	key := "", isKey := false
	stack := [ tree := [] ]
	isArr := Map(tree, 1) ; ahk v2
	next := '"{[01234567890-tfn'
	pos := 0

	while ( (ch := SubStr(src, ++pos, 1)) != "" ) {
		if InStr(" `t`n`r", ch)
			continue
		if !InStr(next, ch, true) {
			testArr := StrSplit(SubStr(src, 1, pos), "`n")

			testArrLength := testArr.Length
			col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

			msg := Format("{}: line {} col {} (char {})"
			,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
			  : (next == "'")     ? "Unterminated string starting at"
			  : (next == "\")     ? "Invalid \escape"
			  : (next == ":")     ? "Expecting ':' delimiter"
			  : (next == '"')     ? "Expecting object key enclosed in double quotes"
			  : (next == '"}')    ? "Expecting object key enclosed in double quotes or object closing '}'"
			  : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
			  : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
			  : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
			    , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
			, testArrLength, col, pos)

			throw Error(msg, -1, ch)
		}

		obj := stack[1]
		memType := Type(obj)
		isArrayType := (memType = "Array") ? 1 : 0

		if indx := InStr("{[", ch) { ; start new object/map or array
			if (indx == 1) {
				val := Map()
			} else {
				val := Array()
			}

			if (isArrayType) {
				obj.Push(val)
			} else {
				obj[key] := val
			}

			stack.InsertAt(1,val)

			isKey := (ch == "{")
			isArr[val] := !isKey
			next := '"' (isKey ? "}" : "{[]0123456789-tfn")

		} else if InStr("}]", ch) {	; end object/map or array
			stack.RemoveAt(1)
			next := stack[1]==tree ? "" : isArr[stack[1]] ? ",]" : ",}"

		} else if InStr(",:", ch) {
			isKey := (!isArrayType && ch == ",")
			next := isKey ? '"' : '"{[0123456789-tfn'

		} else { ; string | number | true | false | null
			if (ch == '"') { ; string
				indx := pos
				while indx := InStr(src, '"',, indx+1) {
					val := StrReplace(SubStr(src, pos+1, indx-pos-1), "\\", "\u005C")
					if (SubStr(val, -1) != "\")
						break
				}
				if !indx ? (pos--, next := "'") : 0
					continue

				pos := indx ; update pos

				val := StrReplace(val, "\/", "/")
				val := StrReplace(val, '\"', '"')
				val := StrReplace(val, "\b", "`b")
				val := StrReplace(val, "\f", "`f")
				val := StrReplace(val, "\n", "`n")
				val := StrReplace(val, "\r", "`r")
				val := StrReplace(val, "\t", "`t")

				indx := 0
				while indx := InStr(val, "\",, indx+1) {
					if (SubStr(val, indx+1, 1) != "u") ? (pos -= StrLen(SubStr(val, indx)), next := "\") : 0
						continue 2

					xxxx := Abs("0x" . SubStr(val, indx+2, 4)) ; \uXXXX - JSON unicode escape sequence
					if (xxxx < 0x100)
						val := SubStr(val, 1, indx-1) . Chr(xxxx) . SubStr(val, indx+6)
				}

				if isKey {
					key := val, next := ":"
					continue
				}

			} else { ; number | true | false | null
				val := SubStr(src, pos, indx := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)

                if IsInteger(val)
                    val += 0
                else if IsFloat(val)
                    val += 0
                else if (val == "true" || val == "false")
                    val := (val == "true")
                else if (val == "null")
                    val := ""
                else if isKey {
                    pos--, next := "#"
                    continue
                }

				pos += indx-1
			}

			isArrayType ? obj.Push(val) : obj[key] := val
			next := obj == tree ? "" : isArrayType ? ",]" : ",}"
		}
	}

	return _ConvertObjectMapsToObjects(tree[1])
}

JxonEncode(obj, indent:="", lvl:=1) {
	if IsObject(obj) {
		isArrayType := (obj is Array)
		isMapType := (obj is Map)
		isClassType := (obj is Object) && !isArrayType && !isMapType

		if (!isArrayType && !isMapType && !isClassType) {
			throw Error("Object type not supported.`r`n`r`nObj Type: " Type(obj), -1, Format("<Object at 0x{:p}>", ObjPtr(obj)))
		}

		if IsInteger(indent) {
			if (indent < 0) {
				throw Error("Indent parameter must be a postive integer.", -1, indent)
			}
			spaces := indent, indent := ""

			loop spaces { ; ===> changed
				indent .= " "
			}
		}
		indt := ""

		loop (indent ? lvl : 0) {
			indt .= indent
		}

		lvl += 1, out := "" ; Make #Warn happy
		itObj := isClassType ? obj.OwnProps() : obj

		if (isClassType) {
			out .= '"$type"' (indent ? ": " : ":") '"' ObjGetBase(obj).__Class '"' ( indent ? ",`n" . indt : "," )
		}

		for (k, v in itObj) {
			if (IsObject(k) || k == "") {
				throw Error("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", ObjPtr(obj)) : "<blank>")
			}

			if !isArrayType { ;// key ; ObjGetCapacity([k], 1)
				out .= (ObjGetCapacity([k]) ? JxonEncode(k) : EscapeStr(k)) (indent ? ": " : ":") ; token + padding
			}

			out .= JxonEncode(v, indent, lvl) ; value
				.  ( indent ? ",`n" . indt : "," ) ; token + indent
		}

		if (out != "") {
			out := Trim(out, ",`n" . indent)
			if (indent != "") {
				out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent)+1)
			}
		}

		return isArrayType ? "[" . out . "]" : "{" . out . "}"

	} else {
		if (Type(obj) != "String") {
			return obj	 ; Number
		} else {
		    return EscapeStr(obj)
		}

		EscapeStr(obj) {
            obj := StrReplace(obj,"\","\\")
			obj := StrReplace(obj,"`t","\t")
			obj := StrReplace(obj,"`r","\r")
			obj := StrReplace(obj,"`n","\n")
			obj := StrReplace(obj,"`b","\b")
			obj := StrReplace(obj,"`f","\f")
			obj := StrReplace(obj,"/","\/")
			obj := StrReplace(obj,'"','\"')

			return '"' obj '"'
		}
	}
}

_ConvertObjectMapsToObjects(it) {
	if !(it is Object) {
		return it
	}

	if (it is Map && it.Has("$type")) {
		obj := %it["$type"]%()
		for k,v in it {
			if (k == "$type") {
				continue
			}
			obj.%k% := _ConvertObjectMapsToObjects(v)
		}
		return obj
	}

	for k,v in it {
		it[k] := _ConvertObjectMapsToObjects(v)
	}
	return it
}
