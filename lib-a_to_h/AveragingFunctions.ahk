#NoEnv

SimpleMovingAverage(NumberToAppend,Method = "Mean",MaxListLen = 10) {
 static NumList
 NumList .= NumberToAppend . "`n"
 StringReplace, NumList, NumList, `n, `n, UseErrorLevel
 If ErrorLevel > %MaxListLen%
 {
  StringGetPos, Temp1, NumList, `n, % "R" . MaxListLen + 1
  StringTrimLeft, NumList, NumList, Temp1 + 1
 }
 Return, %Method%Average(SubStr(NumList,1,-1))
}

MeanAverage(NumList) {
 Mean = 0
 Loop, Parse, NumList, `n
  Mean += A_LoopField, Index := A_Index
 Return, Mean / Index
}

MedianAverage(NumList) {
 IfNotInString, NumList, `n
  Return, NumList
 Sort, NumList, N
 StringReplace, NumList, NumList, `n, `n, UseErrorLevel
 Temp1 := ErrorLevel, NumList .= "`n"
 StringGetPos, Temp2, NumList, `n, % "L" . (Temp1 // 2)
 Temp2 += 2
 If Mod(Temp1,2)
 {
  Temp3 := InStr(NumList,"`n",False,Temp2), Temp1 := SubStr(NumList,Temp2,Temp3 - Temp2), Temp3 ++, Temp2 := SubStr(NumList,Temp3,InStr(NumList,"`n",False,Temp3) - Temp3)
  Return, (Temp1 + Temp2) / 2
 }
 Return, SubStr(NumList,Temp2,InStr(NumList,"`n",False,Temp2) - Temp2)
}

ModeAverage(NumList) {
 MostCommon = 0
 Loop, Parse, NumList, `n
 {
  StringReplace, NumList, NumList, %A_LoopField%, %A_LoopField%, UseErrorLevel
  ErrorLevel > MostCommon ? (MostCommon := ErrorLevel, Mode := A_LoopField)
 }
 Return, Mode
}

RangeAverage(NumList) {
 IfNotInString, NumList, `n
  Return, NumList
 Sort, NumList, N
 Return, (SubStr(NumList,1,InStr(NumList,"`n") - 1) + SubStr(NumList,InStr(NumList,"`n",False,0) + 1)) / 2
}