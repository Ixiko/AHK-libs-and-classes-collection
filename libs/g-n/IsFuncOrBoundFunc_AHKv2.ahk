; Title:   	Make bound funcs consistent with func objects
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=33666
; Author:	just me?
; Date:   	28.06.2017
; for:     	AHK_V2

/*


*/

IsFuncOrBoundFunc(P) { ; v2
   Static Valid := {BoundFunc: "", Func: ""} ; current alpha, might be changed
   Return Valid.HasKey(Type(P))
}