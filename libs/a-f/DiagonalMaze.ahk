ChInput = 
(
17
+---+---+---+---+---+---+
                        |
                        |
                        |
+---+---+---+---+---+   +
                        |
                        |
                        |
+---+---+---+---+---+---+
|                        
|                        
|                        
+   +---+---+---+---+---+
|                        
|                        
|                        
+---+---+---+---+---+---+
)
;StringReplace, ChInput, ChInput, +, %A_space%, ALL
RegExReplace(ChInput, \+\s(?<!=\-)
Offset := "0"
Row := "1"
Col := "1"

Results := []

For Each, Line in StrSplit(ChInput, "`n", "`r") {
    If (A_Index = 1) {
        Offset := Line    
    }
    Else {
        If (Offset > 0) {
            Col := Offset
            For Each, Char in StrSplit(Line) {
                 Results[Row, Col] := Char
                 Row++
                 Col++          
            }
            Offset--
        }
        Else {
            For Each, Char in StrSplit(Line) { 
                Results[Row, Col] := Char
                Row++
                Col++
            }
        }
     Row := A_Index 
     }
}
Loop, 50 {
    Row := A_Index
    Loop, 50 {
        If (Results[Row, A_Index] = "") 
            Var .= A_Space
        else
            var .= Results[Row, A_Index]
    }
    var .= "`n" 
}
StringReplace, var, var, -, \, All
StringReplace, var, var, |, /, ALL
var := StrSplit(var, "`n")
For each, Line in var {
    If RegExMatch(Line, "\\") {
        Final .= Line . "`n"
    }
    Else Continue
}
    Clipboard := Final
    MsgBox % Final
