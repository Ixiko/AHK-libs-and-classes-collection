;
; File encoding:  UTF-8
; Author: fincs
;
; ComDispTable: Creates a dispatch table for use with ComDispatch()
;

ComDispTable(methods)
{
	id2method := {}, method2id := {}
	_methods := A_AhkVersion < "2" ? "methods" : methods
	Loop Parse, %_methods%, `,
	{
		dispid := A_Index - 1
		; StringLower, method, A_LoopField
		method := RegExReplace(A_LoopField, "([A-Z])", "$L1")
		if q := InStr(method := Trim(method), "=")
		{
			aliaslist := Trim(SubStr(method, 1, q-1))
			_aliaslist := A_AhkVersion < "2" ? "aliaslist" : aliaslist
			, ahkmethod := Trim(SubStr(method, q+1))
			Loop Parse, %_aliaslist%, &
				method2id[Trim(A_LoopField)] := dispid
		} else {
			method2id[method] := dispid
			, ahkmethod := method
		}
		if !(q := Func(ahkmethod)) || (!q.IsVariadic && q.MinParams < 1)
			return
		id2method[dispid] := q
	}
	return [id2method, method2id]
}