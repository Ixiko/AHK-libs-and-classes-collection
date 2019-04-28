; self references (tree) syntax: 
;   / is root object
;   sub objects referenced by index
;   if reference ends with "k" it is the key-object at that index
;   each nest level adds another "/"
;
; e.g.
; /       refers to root itself
; /2      refers to the root's second index value
; /4k     refers to the root's fourth index *key* (object-key)
; /1/5k/3 refers to: root first index value -> fifth index key -> third index value

;TODO: drop support for ahk-objects, and change all escape sequences to \

LSON( obj_text ) {
    return IsObject(obj_text) ? LSON_Serialize(obj_text) : LSON_Deserialize(obj_text)
}


LSON_GetObj( obj, lobj, tpos ) 
{
    if (lobj.HasKey(&obj))
        return lobj[&obj]
    lobj[&obj] := tpos
    return IsFunc(obj) ? obj.Name "()" : LSON_Serialize(obj, lobj, tpos)
}
LSON_Serialize( obj, lobj = "", tpos = "" ) 
{
    array := True,  tpos .= "/", sep := ", "
    if !IsObject(lobj)
        lobj := Object(&obj, tpos) ; this root object is static through all recursion
    for k,v in obj
    {
        retObj .= ", " (IsObject(k) ? LSON_GetObj(k, lobj, tpos A_Index "k") : LSON_Normalize(k)) ": "
               . v :=  (IsObject(v) ? LSON_GetObj(v, lobj, tpos A_Index)     : (v+0 != "" ? v : LSON_Normalize(v)))
        if (array := array && k == A_Index)
            retArr .= ", " v
    }
    return array ? "[" SubStr(retArr,3) "]" : "{" SubStr(retObj,3) "}"
}

LSON_Deserialize( _text, lobj = "", tpos = "" ) 
{
    _text := RegExReplace(_text, "^\s++") ; remove leading whitespace
    c := SubStr(_text, 1, 1)
    if !InStr("[{",c)
        throw "object not recognized"
    type := c = "[" ? "arr" : "obj", mode := c = "[" ? "value" : "key"
    ret  := Object(), pos := 1, idx := 1, keytoken := "", complete := false
    
    if !IsObject(lobj)
        tpos := "/", lobj := Object()
    lobj[tpos] := &ret
    
    while pos+1 < StrLen(_text) && InStr(" `t`r`n", SubStr(_text, pos+1, 1)) ;trim whitespace
        ++pos
    if SubStr(_text, pos+1, 1) = (type = "arr" ? "]" : "}") ;end of object with no tokens
        complete := true, _text := "" ;skip the loop
    
    while ++pos <= StrLen(_text) {
        c := SubStr(_text, pos, 1)
        if (c == "")
            break
        if InStr(" `t`r`n", c) ;whitespace
            continue
        text := SubStr(_text, pos)
        if RegExMatch(text, "^""(?:\\.|[^""\\])*+""", token) ;string
            pos += StrLen(token), token := LSON_UnNormalize(token), tokentype := "string"
        else if RegExMatch(text, "^(?<neg>-?)\s*(?<num>0x[\da-fA-F]++|\d++(?:\.\d++(?:e[\+\-]?\d++)?)?)", token) ; number
            pos += StrLen(token), token := (tokenNeg tokenNum) + 0, tokentype := "number"
        else if (mode = "key") && RegExmatch(text, "^[\w#@$]++", token) ;identifier
            pos += StrLen(token), token := token, tokentype := "identifier"
        else if RegExMatch(text, "^(?!\.)[\w#@$\.]+(?<!\.)(?=\(\))", token) { ;function
            pos += StrLen(token)+2, tokentype := "function"
            if !IsFunc(token)
                throw "Function not found: " token "() at position " (pos-StrLen(token)-2)
            token := Func(token)
        }
        else if RegExMatch(text, "^(?:\/(?:\d+k?)?)++", token) { ; self-reference
            pos += StrLen(token), tokentype := "reference"
            if !lobj.HasKey(token)
                throw "Self-reference not found: " token " at position " (pos-StrLen(token))
            token := Object(lobj[token])
        }
        else if InStr("[{", c)
            token := LSON_Deserialize(text, lobj, tpos (tpos!="/"?"/":"") idx (mode="key"?"k":""))
            , pos += ErrorLevel, tokentype := object
        else if RegExMatch(text, "^(?:null|true|false)", token)
            pos += StrLen(token), tokentype := "name"
            , token := token = "false" ? false : token = "true" ? true : ""
        else
            throw "Expected token, got: '" c "' at position " pos
        
        if (type = "arr")
            ret[idx] := token
        else if (mode = "key")
            keytoken := token
        else
            ret[keytoken] := token, keytoken := ""
        
        while pos < StrLen(_text) && InStr(" `t`r`n", SubStr(_text, pos, 1)) ;trim whitespace after token
            ++pos
        
        c := SubStr(_text, pos, 1)
        if (c == "")
            break
        if (type = "arr")
            if (c = "]")
                mode := "end"
            else if (c = ",")
                idx++
            else
                throw "Expected array separator/termination, got: '" c  "' at position " pos
        else if (type = "obj")
            if (mode = "value" ? c = "," : c = ":")
                if (mode = "value")
                    mode := "key", idx++
                else
                    mode := "value"
            else if (mode = "value" && c = "}")
                mode := "end"
            else
                throw "Expected object " (mode = "key" ? "key/termination" : "value") ", got: '" c  "' at position " pos
        
        if (mode = "end") {
            complete := True
            break
        }
    }
    if !complete
        throw "Unexpected end of string"
    return ret, ErrorLevel := pos
}

LSON_Normalize(text) 
{
    text := RegExReplace(text,"\\","\\")
    text := RegExReplace(text,"/","\/")
    text := RegExReplace(text,"`b","\b")
    text := RegExReplace(text,"`f","\f")
    text := RegExReplace(text,"`n","\n")
    text := RegExReplace(text,"`r","\r")
    text := RegExReplace(text,"`t","\t")
    text := RegExReplace(text,"""","\""")
    while RegExMatch(text, "[\x0-\x19]", char)
        text := RegExReplace(text, char, "\u" Format("{1:04X}", asc(char)))
    return """" text """"
}

LSON_UnNormalize(text)
{
    text := SubStr(text, 2, -1) ;strip outside quotes
    while RegExMatch(text, "(?<!\\)((?:\\\\)*+)\\u(....)", char)
        text := RegExReplace(text, "(?<!\\)((?:\\\\)*+)\\u" char2, "$1" Chr("0x" char2))
    text := RegExReplace(text,"\\""", """") ;un-escape quotes
    text := RegExReplace(text,"\\t","`t")
    text := RegExReplace(text,"\\r","`r")
    text := RegExReplace(text,"\\n","`n")
    text := RegExReplace(text,"\\f","`f")
    text := RegExReplace(text,"\\b","`b")
    text := RegExReplace(text,"\\/","/")
    text := RegExReplace(text,"\\\\","\")
    return text
}

; These will not be used until a reliable method of determining whether an object's value contains binary data is found
LSON_BinToString(obj, k, len = "")
{
    vsz := len ? len*(1+A_IsUnicode) : obj.GetCapacity(k)
    vp  := obj.GetAddress(k)
    VarSetCapacity(outsz, 4, 0)
    DllCall("Crypt32.dll\CryptBinaryToString", "ptr", vp, "uint", vsz, "uint", 0xC, "ptr", 0   , "ptr", &outsz, "CDECL uint")
    NumGet(outsz)
    VarSetCapacity(out, NumGet(outsz)*(1+A_IsUnicode), 0)
    DllCall("Crypt32.dll\CryptBinaryToString", "ptr", vp, "uint", vsz, "uint", 0xC, "ptr", &out, "ptr", &outsz, "CDECL uint")
    return out
}

LSON_StringToBin(str, obj, k, encoding = "hex")
{
    VarSetCapacity(sz, 4, 0)
    type := encoding = "hex" ? 0xC : encoding = "base64" ? 0x6 : 0
    DllCall("Crypt32.dll\CryptStringToBinary", "ptr", &str, "UInt", 0, "UInt", type, "ptr",  0, "ptr", &sz, "ptr", 0, "ptr", 0, "CDecl")
    obj.SetCapacity(k, NumGet(sz))
    DllCall("Crypt32.dll\CryptStringToBinary", "ptr", &str, "UInt", 0, "UInt", type, "ptr", obj.GetAddress(k), "ptr", &sz, "ptr", 0, "ptr", 0, "CDecl")
}

;Format functions from v2 required by LSON
; AutoHotkey v2 alpha

; format(format_string, ...)
;   Equivalent to format_v(format_string, Array(...))
format(f, v*) {
    return format_v(f, v)
}

; format_v(format_string, values)
;   - format_string:
;       String of literal text and placeholders, as described below.
;   - values:
;       Array or map of values to insert into the format string.
;
; Placeholder format: "{" id ":" format "}"
;   - id:
;       Numeric or string literal identifying the value in the parameter
;       list.  For example, {1} is values[1] and {foo} is values["foo"].
;   - format:
;       A format specifier as accepted by printf but excluding the
;       leading "%".  See "Format Specification Fields" at MSDN:
;           http://msdn.microsoft.com/en-us/library/56e442dc.aspx
;       The "*" width specifier is not supported, and there may be other
;       limitations.
;
; Examples:
;   MsgBox % format("0x{1:X}", 4919)
;   MsgBox % format("Computation took {2:.9f} {1}", "seconds", 3.2001e-5)
;   MsgBox % format_v("chmod {mode:o} {file}", {mode: 511, file: "myfile"})
;
format_v(f, v)
{
    local out, arg, i, j, s, m, key, buf, c, type, p
    out := "" ; To make #Warn happy.
    VarSetCapacity(arg, 8), j := 1, VarSetCapacity(s, StrLen(f)*2.4)  ; Arbitrary estimate (120% * size of Unicode char).
    O_ := A_AhkVersion >= "2" ? "" : "O)"  ; Seems useful enough to support v1.
    while i := RegExMatch(f, O_ "\{((\w+)(?::([^*`%{}]*([scCdiouxXeEfgGaAp])))?|[{}])\}", m, j)  ; For each {placeholder}.
    {
        out .= SubStr(f, j, i-j)  ; Append the delimiting literal text.
        j := i + m.Len[0]  ; Calculate next search pos.
        if (m.1 = "{" || m.1 = "}") {  ; {{} or {}}.
            out .= m.2
            continue
        }
        key := m.2+0="" ? m.2 : m.2+0  ; +0 to convert to pure number.
        if !v.HasKey(key) {
            out .= m.0  ; Append original {} string to show the error.
            continue
        }
        if m.3 = "" {
            out .= v[key]  ; No format specifier, so just output the value.
            continue
        }
        if (type := m.4) = "s"
            NumPut((p := v.GetAddress(key)) ? p : &(s := v[key] ""), arg)
        else if InStr("cdioux", type)  ; Integer types.
            NumPut(v[key], arg, "int64") ; 64-bit in case of something like {1:I64i}.
        else if InStr("efga", type)  ; Floating-point types.
            NumPut(v[key], arg, "double")
        else if (type = "p")  ; Pointer type.
            NumPut(v[key], arg)
        else {  ; Note that this doesn't catch errors like "{1:si}".
            out .= m.0  ; Output m unaltered to show the error.
            continue
        }
        ; MsgBox % "key=" key ",fmt=" m.3 ",typ=" m.4 . (m.4="s" ? ",str=" NumGet(arg) ";" (&s) : "")
        if (c := DllCall("msvcrt\_vscwprintf", "wstr", "`%" m.3, "ptr", &arg, "cdecl")) >= 0  ; Determine required buffer size.
          && DllCall("msvcrt\_vsnwprintf", "wstr", buf, "ptr", VarSetCapacity(buf, ++c*2)//2, "wstr", "`%" m.3, "ptr", &arg, "cdecl") >= 0 {  ; Format string into buf.
            out .= buf  ; Append formatted string.
            continue
        }
    }
    out .= SubStr(f, j)  ; Append remainder of format string.
    return out
}