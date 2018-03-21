vtype(v, assert:="")
{
	static is_v2      := A_AhkVersion >= "2"
	static Type       := is_v2 ? Func("Type") : ""
	static nMatchObj  := is_v2 ? "" : NumGet(&(m, RegExMatch("", "O)", m)))
	static nBoundFunc := NumGet(&(f := Func("Func").Bind()))
	static nFileObj   := NumGet(&(f := FileOpen("*", "w")))

	if is_v2
		t := %Type%(v) ;// use v2.0-a built-in Type()

	else if IsObject(v)
		t := ObjGetCapacity(v) != ""  ? "Object"
		  :  IsFunc(v)                ? "Func"
		  :  ComObjType(v) != ""      ? "ComObject"
		  :  NumGet(&v) == nBoundFunc ? "BoundFunc"
		  :  NumGet(&v) == nMatchObj  ? "RegExMatchObject"
		  :  NumGet(&v) == nFileObj   ? "FileObject"
		  :                             "Property"

	else
		t := ObjGetCapacity([v], 1) != "" ? "String" : (InStr(v, ".") ? "Float" : "Integer")
	
	return assert ? InStr(t, assert) : t
}