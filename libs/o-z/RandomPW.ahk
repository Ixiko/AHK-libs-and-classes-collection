; Title:   	RandomPW() : Random password and simple string hash.
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=78525
; Author:	SKAN
; Date:
; for:     	AHK_L

/*


 #SingleInstance, Force

 Loop % (128, Q:="")
   Q .= RandomPW() . A_Tab
 MsgBox % Q

*/

RandomPW(L:=10, A:=1, R:="", C:="") { ; SKAN, D37D @ tiny.cc/randompw
Loop % (L+1, C:="23456789ABCDEFGHJKMNPQRSTUVWXYZ")
 Random, A, 1, % (248, R .= "{" . A . ":" . (A & 1 ? "L" : "") . "}")
Return Substr(Format(R, StrSplit(C . C . C . C . C . C . C . C)*), 2)
}