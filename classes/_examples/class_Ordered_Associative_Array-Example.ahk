; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=37083
; Author:	Capn Odin
; Date:   	15.07.2017
; for:     	AHK_L

/*


*/

#include %A_ScriptDir%\..\class_Ordered_Associative_Array.ahk
lst := new OrderedAssociativeArray()

lst["x"] := 14
lst["a"] := 1
lst["h"] := 15

test(lst)
lst.Delete("a")
test(lst)
lst.InsertAt(1, "w", 3535)
test(lst)
lst.RemoveAt(2)
test(lst)

test(obj) {
	res := ""
	for i, v in obj {
		res .= i " = " v "`n"
	}
	MsgBox, % res
}