; function by skan. Added Trim for A_LoopField to remove spaces 
ReFormatTime( Time, Format, Delimiters  ) {
 StringSplit F,Format, %A_Space%
 Loop, Parse, Time, %Delimiters%
   Var := F%A_Index%,  %Var% := Trim(A_LoopField)
Return YYYY MM DD HH MI SS
}