#NoEnv

String = ghdk563dh1000dsd81001h23jdshj400shj200000dsh500ehja2ld122jfkj100000fdjk40000skj200dslkds700
MsgBox % """" . GreaterThanNumInList(String,500) . """"
MsgBox % """" . LessThanNumInList(String,501) . """"
MsgBox % """" . BetweenNumInList(String,200,81001) . """"

GreaterThanNumInList(ByRef NumList,Num)
{
 Num ++, NumLen := StrLen(Num), Expression := "S)[^\d]("
 Loop, %NumLen%
  Expression .= "(?:"
 Loop, Parse, Num
  Expression .= "[" . A_LoopField . "-9])"
 Expression .= "|(?:\d{" . (NumLen + 1) . ",}))[^\d]"
 FoundPos := 0, Output := " "
 While, (FoundPos := RegExMatch("|" . NumList . "|",Expression,Output,FoundPos + StrLen(Output)))
  Result .= Output1 . ","
 Return, SubStr(Result,1,-1)
}

LessThanNumInList(ByRef NumList,Num)
{
 Num --, NumLen := StrLen(Num), Expression := "S)[^\d]("
 Loop, % NumLen - 1
 {
  Temp1 := SubStr(Num,A_Index,1)
  If Not Temp1
   Continue
  Expression .= "(?:" . SubStr(Num,1,A_Index - 1) . "[0-" . (Temp1 - 1) . "]"
  Loop, % NumLen - A_Index
   Expression .= "\d"
  Expression .= ")|"
 }
 Expression .= "(?:" . SubStr(Num,1,-1) . "[0-" . SubStr(Num,0,1) . "])"
 % (NumLen > 1) ? Expression .= "|(?:\d{1," . (NumLen - 1) . "})"
 Expression .= ")[^\d]", FoundPos := 0, Output := " "
 While, (FoundPos := RegExMatch("|" . NumList . "|",Expression,Output,FoundPos + StrLen(Output)))
  Result .= Output1 . ","
 Return, SubStr(Result,1,-1)
}

BetweenNumInList(ByRef NumList,LowerBound,UpperBound)
{
 LowerLen := StrLen(LowerBound), UpperLen := StrLen(UpperBound), Expression := "S)[^\d]("
 Loop, %LowerLen%
  Expression .= "(?:"
 Loop, Parse, LowerBound
  Expression .= "[" . A_LoopField . "-9])"
 If ((LowerLen + 1) < UpperLen)
  Expression .= "|(?:\d{" . (LowerLen + 1) . "," . (UpperLen - 1) . "})"

 Loop, % UpperLen - 1
 {
  Temp1 := SubStr(UpperBound,A_Index,1)
  If Not Temp1
   Continue
  Expression .= "|(?:" . SubStr(UpperBound,1,A_Index - 1) . "[0-" . (Temp1 - 1) . "]"
  Loop, % UpperLen - A_Index
   Expression .= "\d"
  Expression .= ")"
 }
 Expression .= "|(?:" . SubStr(UpperBound,1,-1) . "[0-" . SubStr(UpperBound,0,1) . "]))[^\d]", FoundPos := 0, Output := " "
 While, (FoundPos := RegExMatch("|" . NumList . "|",Expression,Output,FoundPos + StrLen(Output)))
  Result .= Output1 . ","
 Return, SubStr(Result,1,-1)
}