; type(v) by lexikos - http://ahkscript.org/boards/viewtopic.php?f=6&t=2306&sid=8e1b4d1358e28ecf577a7aca4d22f9b9

; Object version - depends on current float format including a decimal point.
type(v) {
    if IsObject(v)
        return "Object"
    return v="" || [v].GetCapacity(1) ? "String" : InStr(v,".") ? "Float" : "Integer"
}

; COM version - reports the wrong type for integers outside 32-bit range.
com_type(ByRef v) {
    if IsObject(v)
        return "Object"
    a := ComObjArray(0xC, 1)
    a[0] := v
    DllCall("oleaut32\SafeArrayAccessData", "ptr", ComObjValue(a), "ptr*", ap)
    type := NumGet(ap+0, "ushort")
    DllCall("oleaut32\SafeArrayUnaccessData", "ptr", ComObjValue(a))
    return type=3?"Integer" : type=8?"String" : type=5?"Float" : type
}