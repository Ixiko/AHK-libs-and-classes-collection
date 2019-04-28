;
; File encoding:  UTF-8
; Author: Lexikos
;
; ComVar: Creates an object which can be used to pass a value ByRef.
;   ComVar[] retrieves the value.
;   ComVar[] := Val sets the value.
;   ComVar.ref retrieves a ByRef object for passing to a COM function.
;

ComVar()
{
	static base := {__Get: "ComVarGet", __Set: "ComVarSet", __Delete: "ComVarDel"}
	static ComObjParam := A_AhkVersion < "2" ? "ComObjParameter" : "ComObject"
	; Create an array of 1 VARIANT.  This method allows built-in code to take
	; care of all conversions between VARIANT and AutoHotkey internal types.
	arr := ComObjArray(0xC, 1)
	; Lock the array and retrieve a pointer to the VARIANT.
	DllCall("oleaut32\SafeArrayAccessData", "ptr", ComObjValue(arr), "ptr*", arr_data)
	; Store the array and an object which can be used to pass the VARIANT ByRef.
	return {ref: %ComObjParam%(0x400C, arr_data), _: arr, base: base}
}

ComVarGet(cv, p*) ; Called when script accesses an unknown field.
{
	if p.MaxIndex() = "" ; No name/parameters, i.e. cv[]
		return cv._[0]
}

ComVarSet(cv, v, p*) ; Called when script sets an unknown field.
{
	if p.MaxIndex() = "" ; No name/parameters, i.e. cv[]:=v
		return cv._[0] := v
}

ComVarDel(cv) ; Called when the object is being freed.
{
	; This must be done to allow the internal array to be freed.
	DllCall("oleaut32\SafeArrayUnaccessData", "ptr", ComObjValue(cv._))
}