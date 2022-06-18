; Title:   	Make bound funcs consistent with func objects
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=33666
; Author:	just me?
; Date:   	28.06.2017
; for:     	AHK_L

/*


*/

IsFuncOrBoundFunc(P) { ; v1.1
   ; Extracted from Type() for v1 by Coco (as far as I remember)
   Static BF := NumGet(&(_ := Func("IsFuncOrBoundFunc").Bind()), "Ptr")
   Return (IsFunc(P) || (IsObject(P) && (NumGet(&P, "Ptr") = BF)))
}