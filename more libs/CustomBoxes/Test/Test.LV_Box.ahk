#NoEnv
#SingleInstance, Force

    p0 := {x: 100, y: 100}
    p1 := {x: 500, y: 500}
    p2 := {x: 500, y: 100}
    p3 := {x: 100, y: 500}
    Points := [p0, p1, p2, p3]

    MsgBox, % LV_Box(Points, config())

ExitApp

#Include, ..\LV_Box.ahk



;-------------------------------------------------------------------------------
config() { ; return a config array for LV_Box()
;-------------------------------------------------------------------------------
    return [ ; an array of strings to define each column of table
    ( LTrim Join, Comments
        ;  content   header options
        [" A_Index "," #  "," AutoHdr Integer Center "]
        [" x       "," x  "," AutoHdr "]
        [" y       "," y  "," AutoHdr "]
    )]
}
