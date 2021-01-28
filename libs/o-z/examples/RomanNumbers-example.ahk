#Include RomanNumbers.ahk

MsgBox % "** Dec2Roman() EXAMPLES **"

MsgBox % "3999: " Dec2Roman(3999)
MsgBox % "4000: " Dec2Roman(4000)
MsgBox % "8000: " Dec2Roman(8000)
MsgBox % "15564: " Dec2Roman(15564)
MsgBox % "text: " Dec2Roman("text")
MsgBox % "-1294: " Dec2Roman(-1294)
MsgBox % "-1294,true: " Dec2Roman(-1294,true)

MsgBox % "** Roman2Dec() EXAMPLES **"

MsgBox % "[M][C][D]MCDXLIV: " Roman2Dec( "[M][C][D]MCDXLIV" )
MsgBox % "-[M][C][D]MCDXLIV: " Roman2Dec( "-[M][C][D]MCDXLIV" )
MsgBox % "-[M][C][D]MCDXLIV,true: " Roman2Dec( "-[M][C][D]MCDXLIV" , true )