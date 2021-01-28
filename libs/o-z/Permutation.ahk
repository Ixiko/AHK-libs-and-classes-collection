;
; AutoHotkey Version: 1.1.24.03
; Language:       English
; Platform:       Optimized for Windows 10
; Author:         Sam.
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; https://autohotkey.com/board/topic/72724-lexicographical-next-permutation-in-o1-time/
; by nimda , Posted 23 October 2011 - 04:56 PM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
perm_NextObj(obj){
	p := 0, objM := ObjMaxIndex(obj)
	Loop % objM
	{
		If A_Index=1
			continue
		t := obj[objM+1-A_Index]
		n := obj[objM+2-A_Index]
		If ( t < n )
		{
			p := objM+1-A_Index, pC := obj[p]
			break
		}
	}
	If !p
		return false
	Loop
	{
		t := obj[objM+1-A_Index]
		If ( t > pC )
		{
			n := objM+1-A_Index, nC := obj[n]
			break
		}
	}

	obj[n] := pC, obj[p] := nC
	return ObjReverse(obj, objM-p)
}

ObjReverse(Obj, tail){
 o := ObjClone(Obj), ObjM := ObjMaxIndex(O)
 Loop % tail
	o[ObjM-A_Index+1] := Obj[ObjM+A_Index-tail]
 return o
}

ObjDisp(obj){
	s := "["
	For k, v in obj
		s .= v ", "
	return SubStr(s, 1, strLen(s)-2) . "]"
}