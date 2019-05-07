#Include WRandom.ahk

; =============================

MsgBox % "** EXAMPLE 1 **"

aux := "Field , Chance , %->Dec , Dec->%`n"
aux .= "`n" WRandom("50,50",1,1,1)
aux .= "`n" WRandom("20,30",1,1,1)
aux .= "`n" WRandom("30,30,40",1,1,1)
aux .= "`n" WRandom("200,600",1,1,1)
aux .= "`n" WRandom("99,1",1,1,1)
aux .= "`n" WRandom("15,14",1,1,1)
aux .= "`n" WRandom("123,276,57,93",1,1,1)
aux .= "`n" WRandom("50.3,27.9,36.5,42.8,50.3,27.9,36.5,42.8,50.3,27.9,6.5,42.8",1,1,1)
MsgBox % aux

; =============================

MsgBox % "** EXAMPLE 2 **"

aux := ""
Loop, 9
  aux .= ( aux ? "," : "" ) Field%A_Index% := (A_Index*10)+A_Index
aux := WRandom(aux,1) ; same as WRandom( "11,22,33,44,55,66,77,88,99" , 1 )
Loop, Parse, aux, `,
  If ( A_Index = 1 )
    num := A_LoopField
  Else
    aux := A_LoopField
MsgBox % "Field " num "/9 was selected (had " aux "% chance!)"

; =============================

Return