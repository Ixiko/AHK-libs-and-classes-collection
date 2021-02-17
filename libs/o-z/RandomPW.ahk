; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=78525&sid=5109901aba1c63522665c63b6bc73608
; Author:	SKAN
; Date:
; for:     	AHK_L

/* RandowPW(Len)

    ;By default, the function returns a 10 char random string.

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
