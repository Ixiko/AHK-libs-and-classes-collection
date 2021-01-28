; Array Lib - temp01 - http://www.autohotkey.com/forum/viewtopic.php?t=49736
Array(p1="……", p2="……", p3="……", p4="……", p5="……", p6="……"){
	static ArrBase
	If !ArrBase
		ArrBase := Object("len", "Array_Length", "indexOf", "Array_indexOf", "join", "Array_Join"
		, "append", "Array_Append", "insert", "Array_Insert", "delete", "Array_Delete"
		, "sort", "Array_sort", "reverse", "Array_Reverse", "unique", "Array_Unique"
		, "extend", "Array_Extend", "copy", "Array_Copy", "pop", "Array_Pop")

	arr := Object("base", ArrBase)
	While (_:=p%A_Index%)!="……" && A_Index<=6
		arr[A_Index] := _
	Return arr
}

Array_indexOf(arr, val, opts="", startpos=1){
	P := !!InStr(opts, "P"), C := !!InStr(opts, "C")
	If A := !!InStr(opts, "A")
		matches := Array()
	Loop % arr.len()
		If(A_Index>=startpos)
			If(match := InStr(arr[A_Index], val, C)) and (P or StrLen(arr[A_Index])=StrLen(val))
				If A
					matches.append(A_Index)
				Else
					Return A_Index
	If A
		Return matches
	Else
		Return 0
}
Array_Join(arr, sep="`n"){
	Loop, % arr.len()
		str .= arr[A_Index] sep
	StringTrimRight, str, str, % StrLen(sep)
	return str
}
Array_Copy(arr){
	Return Array().extend(arr)
}

Array_Append(arr, p1="……", p2="……", p3="……", p4="……", p5="……", p6="……"){
	Return arr.insert(arr.len()+1, p1, p2, p3, p4, p5, p6)
}
Array_Insert(arr, index, p1="……", p2="……", p3="……", p4="……", p5="……", p6="……"){
	While (_:=p%A_Index%)!="……" && A_Index<=6
		arr._Insert(index + (A_Index-1), _)
	Return arr
}
Array_Reverse(arr){
	arr2 := Array()
	Loop, % len:=arr.len()
		arr2[len-(A_Index-1)] := arr[A_Index]
	Return arr2
}
Array_Sort(arr, func="Array_CompareFunc"){
	n := arr.len(), swapped := true
	while swapped {
		swapped := false
		Loop, % n-1 {
			i := A_Index
			if %func%(arr[i], arr[i+1], 1) > 0 ; standard ahk syntax for sort callout functions
				arr.insert(i, arr[i+1]).delete(i+2), swapped := true
		}
		n--
	}
	Return arr
}
Array_Unique(arr, func="Array_CompareFunc"){	; by infogulch
	i := 0
	while ++i < arr.len(), j := i + 1
		while j <= arr.len()
			if !%func%(arr[i], arr[j], i-j)
				arr.delete(j) ; j comes after
			else
				j++ ; only increment to next element if not removing the current one
	Return arr
}
Array_CompareFunc(a, b, c){
; this setup is compatible with the sort command's syntax
; if a > b return positive
; if a = b return false
; if a < b return negative
; c is element offset (a.pos - b.pos)
	return a > b ? 1 : a = b ? 0 : -1
}

Array_Extend(arr, p1="……", p2="……", p3="……", p4="……", p5="……", p6="……"){
	While (_:=p%A_Index%)!="……" && A_Index<=6
		If IsObject(_)
			Loop, % _.len()
				arr.append(_[A_Index])
		Else
			Loop, % %_%0
				arr.append(%_%%A_Index%)
	Return arr
}
Array_Pop(arr){
	Return arr.delete(arr.len())
}
Array_Delete(arr, p1="……", p2="……", p3="……", p4="……", p5="……", p6="……"){
	While (_:=p%A_Index%)!="……" && A_Index<=6
		arr._Remove(_)
	Return arr
}

Array_Length(arr){
	len := arr._MaxIndex()
	Return len="" ? 0 : len
}
