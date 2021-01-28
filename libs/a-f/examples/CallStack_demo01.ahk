#include %A_ScriptDir%\..\lib\CallStack.ahk

foo1()
return

; ----------------
foo1(){
  foo2()
}
; ----------------
foo2(){
  foo3()
}
; ----------------
foo3(){
  foo4()
}
; ----------------
foo4(){
  foo5()
}
; ----------------
foo5(){
	x:= CallStack()
	str := ""

	; Example 1
	str := "I'm function <" . x[0].function . ">`n"
	str := str . "=> I was called from function <" . x[-1].function . ">`n"
	str := str . "   from file <" . x[-1].file . ">, line <" . x[-1].line . ">`n"
	str := str . "   (line contents: <" . x[-1].contents . ">`n"
	str := str . "   I'm " . x[0].depth . " levels away from main function `n"
	MsgBox str

	; Example 2
	str := ""
	for key, value in x { ; Show the callstack for foo5()
		if (A_Index > 1 )
			str := str . " => "
		  str := str . value.function " (" value.depth ")"	
	}
	MsgBox str
}