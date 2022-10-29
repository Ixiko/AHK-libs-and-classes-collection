/*
    Library: json
    Author: neovis
    https://github.com/neovis22/json
*/

json_load(path, encoding="utf-8") {
    try
        return json_parse(FileOpen(path, "r", encoding).read())
    catch err
        throw err
}

json_dump(path, obj, encoding="utf-8") {
    try
        return FileOpen(path, "w", encoding).write(json_stringify(obj))
    catch err
        throw err
}

json_parse(byref json) {
    return IsObject(json) ? json : __JSON__.parse(json)
}

json_stringify(obj) {
    return __JSON__.stringify(obj, [])
}

json_pretty(obj, space=4) {
    if space is integer
        space := Format("{: " space "}", "")
    return __JSON__.stringify(obj, [], space, "`n")
}

json_true() {
    static x := []
    return x
}

json_false() {
    static x := []
    return x
}

json_null() {
    static x := []
    return x
}

json_escape(str) {
    str :=
    (join ltrim
        StrReplace(StrReplace(StrReplace(StrReplace(
        StrReplace(StrReplace(StrReplace(StrReplace(str
        , "\", "\\"), "/", "\/"), """", "\"""), "`b", "\b")
        , "`f", "\f"), "`n", "\n"), "`r", "\r"), "`t", "\t")
    )
    p := 0
    while (p := RegExMatch(str, __JSON__.regexpEscapeChar, m, p+1))
        str := StrReplace(str, m, Format("\u{1:04x}", Ord(m)))
    return str
}

json_unescape(str) {
    static map := {b:"`b", f:"`f", n:"`n", r:"`r", t:"`t"}
    p := 0
    while (p := InStr(str, "\",, ++ p))
        str := (c := SubStr(str, p+1, 1)) = "u"
            ? StrReplace(str, SubStr(str, p, 6), Chr("0x" SubStr(str, p+2, 4)),, 1)
            : StrReplace(str, SubStr(str, p, 2), map.hasKey(c) ? map[c] : c,, 1)
    return str
}

json_setMaxReferenceCount(limit=300) {
    return __JSON__.maxReferenceCount := limit
}

json_setEscapePattern(regex="[^\x{20}-\x{10ffff}]") {
    return __JSON__.regexpEscapeChar := regex
}

/*
    내부 클래스
*/
class __JSON__ {
    
    static maxReferenceCount := 300
    
    static regexpEscapeChar := "[^\x{20}-\x{10ffff}]"
    
    parse(byref src) {
        static const := {"true":1, "false":0, "null":""}
        
        stack := []
        depth := 0
        array := []
        pos := 0
        
        while ((ch := SubStr(src, ++ pos, 1)) != "") {
            switch (ch) {
                case ",":
                    is_key := !array[obj]
                case ":":
                    is_key := false
                case """", "'":
                    p := ++ pos
                    while ((c := SubStr(src, pos, 1)) != "" && c != ch)
                        pos += c == "\" ? 2 : 1
                    value := json_unescape(SubStr(src, p, pos-p))
                    , is_key ? key := value : array[obj] ? obj.push(value) : obj[key] := value
                case "[", "{":
                    stack[++ depth] := value := (is_key := ch == "{") ? {} : []
                    , array[obj] ? obj.push(value) : obj[key] := value
                    , array[obj := value] := !is_key
                case "]", "}":
                    obj := stack[-- depth]
                case " ", "`t", "`n", "`r":
                case "/":
                    switch (SubStr(src, ++ pos, 1)) {
                        case "*": ; multi-line comments
                            if (pos := InStr(src, "*/",, pos))
                                pos += 2
                            else
                                throw Exception("Json SyntaxError: multi-line comments unclosed")
                        case "/": ; single-line comments
                            while ((c := SubStr(src, ++ pos, 1)) != "" && c != "`n" && c != "`r")
                                continue
                        default:
                            throw Exception("Json SyntaxError: '/' at position " pos-1)
                    }
                default:
                    if (!p := RegExMatch(src, "[:,\[\]{}]",, pos))
                        p := StrLen(src)
                    value := Trim(SubStr(src, pos, p-pos), " `t`r`n"), pos := p-1
                    
                    if value is number
                        value += 0
                    else if (const.hasKey(value))
                        value := const[value]
                    else
                        throw Exception("Json SyntaxError: '" value "' at position " p)
                    
                    is_key ? key := value : array[obj] ? obj.push(value) : obj[key] := value
            }
        }
        return stack[1]
    }
    
    stringify(obj, ref, space="", newline="") {
        if (IsObject(obj)) {
            ; ComObject는 열거시 DISP_E_MEMBERNOTFOUND 오류가 발생할 수 있으므로 식별 가능한 클래스 문자열로 대체
            if (ComObjValue(obj) != "")
                return """{ComObject:" ComObjType(obj, "Class") "}"""
            
            switch (obj) {
                case json_null():
                    return "null"
                case json_true():
                    return "true"
                case json_false():
                    return "false"
            }
            
            if (ref[&obj]) {
                if (++ ref[&obj] > this.maxReferenceCount)
                    throw Exception("Json Error: too much recursion")
            } else {
                ref[&obj] := 1
            }
            
            ; 아이템이 1~N개인지 확인하여 객체와 배열을 구분
            if (ObjMinIndex(obj) == 1 && ObjCount(obj) == ObjMaxIndex(obj)) {
                for i, v in obj
                    res .= (a_index-1 ? "," : "") newline space
                    . this.stringify(v, ref, space, newline space)
                if (res != "")
                    res .= newline
                return "[" res "]"
            } else {
                for i, v in obj
                    res .= (a_index-1 ? "," : "") newline space
                    . """" json_escape(i) """:" (space ? " " : "")
                    . this.stringify(v, ref, space, newline space)
                if (res != "")
                    res .= newline
                return "{" res "}"
            }
        }
        return ObjGetCapacity([obj], 1) == "" ? obj : """" json_escape(obj) """"
    }
}