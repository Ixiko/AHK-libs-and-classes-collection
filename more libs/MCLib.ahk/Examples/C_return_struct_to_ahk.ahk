#Include %A_ScriptDir%/../
#include MCLib.ahk

C =
( %

#include <stdlib.h>

typedef struct {
	int X;
	int Y;
} Point;

Point* __main(int a, int b) {
	Point* P = malloc(sizeof(Point));
	
	P->X = a;
	P->Y = b;
	
	return P;
}

)

Code := MCLib.AHKFromC(C, false) ; Compile and stringify the code, but don't format it as an AHK string literal (since we're going to load it again momentarily)

pCode := MCLib.FromString(Code)

pPoint := DllCall(pCode, "Int", 20, "Int", 30, "Ptr")

MsgBox, % NumGet(pPoint+0, 0, "Int") ", " NumGet(pPoint+0, 4, "Int")