;http://www.autohotkey.com/forum/viewtopic.php?p=388494#388494
;Created by MasterFocus on the forums
;This function cycles through various

;Loop, 30
   ;msg.=cycle("a|b|c")
;msgbox, %msg%

;his examples
;Loop
;{
  ;MsgBox % Cycle(  "abcdefgh"  ,  1  ,  ""  )
  ;MsgBox % Cycle(  "a2|b2|c2|d2|e2|f2|g2|h2"  ,  0  ,  "|"  )
  ;MsgBox % Cycle(  "a3,b3,c3,d3,e3,f3,g3,h3"  ,  0  )
  ;;; MsgBox % Cycle(  "this,should,not,be,visible,at,all,!!!"  ,  -1  )
;}

Cycle(p_Input,p_Step=1,p_Delim="|",p_Omit=" `t")
{
  static l_Idx := 0
  StringSplit, l_Arr, p_Input, %p_Delim%, %p_Omit%
  Return (!l_Arr0)OR((l_Idx:=Abs(1+Mod(l_Idx+p_Step-1,l_Arr0)))=0)
    ? "" : l_Arr%l_Idx%
}

