/*
;___________________
; example

List =
(
New, Agnes
New Jersey
New, Thomas
New York
"New York Dining"
New York (NY)
New York: Visitor’s Guide
Newark (NJ)
TYPE-ADF command
type font
type foundry
type metal
Type/Specs Inc.
typeface
typeset
)

Msgbox % AlphaSortEx(List,"`n") ; <- AlphaSortEx(var containing items, delimiter)
*/

;___________________
; function

AlphaSortEx(l,del){
    n:=RegExReplace(l,"[^\w" del "]")
    Sort, n

    Loop, Parse, l, % (del,p:=1)
        p:=RegExMatch(l,"(.*?)" del,_,StrLen(_)+p),itm:=RegExReplace(A_LoopField,"\W+")
            ,n:=RegExReplace(n,"\b" itm "\b",_1?_1:itm)

    Return n
}