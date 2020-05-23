#SingleInstance force

#include winstructs.ahk
#include <_Struct>
#Include <AHK-SizeOf-Checker>

Gui, Add, ListView, w600 h400, Item|Extra Includes|Win|_Struct|OK?
Gui, Show

LV_ModifyCol(1, 250)
LV_ModifyCol(2, 200)
LV_ModifyCol(3, 50)
LV_ModifyCol(4, 50)

sc := new SizeofChecker()

count := 0
good := 0

For key, value in WinStructs.Defines {
	count++
	if (value = -1){
		good++
		continue
	}
	if (value = 1){
		;value := ["Windows.h"]
		;value := []
		value := ""
	}
	s := new _Struct("WinStructs."key)
	s := sizeof(s)
	c := sc.Check(key, value)
	;c += 0
	if (s = c){
		good++
		okstr := "YES"
	} else {
		okstr := "NO"
	}
	
	i := ""
	Loop % value.MaxIndex(){
		if (A_Index > 1){
			i .= ","
		}
		i .= value[A_Index]
	}
	LV_ADD(,key, i, c, s, okstr)
}
msg := good " of " count " items matched OK"
msgbox % msg

Esc::
GuiClose:
	ExitApp