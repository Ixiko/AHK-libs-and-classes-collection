#Include %A_ScriptDir%/../
#include MCLib.ahk

C =
( %

double __main(double In) {
	return In * 2.5;
}

)

pCode := MCLib.FromC(C)

MsgBox, % DllCall(pCode, "Double", 11.7, "Double")