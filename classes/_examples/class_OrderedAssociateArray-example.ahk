; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

#include OrderedAssociativeArray.ahk
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