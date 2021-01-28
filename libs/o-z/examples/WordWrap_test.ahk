;
; AutoHotkey Version: 1.1.07.03
; Author:        Rainer Friebel
;				 rainer.friebel@googlemail.com
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;
; Forum: http://www.autohotkey.com/community/viewtopic.php?f=2&t=xxx
;        http://de.autohotkey.com/forum/viewtopic.php?t=xxx
;
; Copyright (c) 2012 Rainer Friebel
; Licence: MIT licence
; http://de.wikipedia.org/wiki/MIT-Lizenz
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;#Include ..\wordwrap.ahk

data:="12345 123456789 1234567 12 1234 123456789 12345 123456 12 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 "
data:= "1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 "
data1:= "My point was that one parameter    accepting an array and the other parameter accepting a list of characters as a string would be inconsistent. Requiring OmitList to be an array like [A_Space, A_Tab] would be more consistent but less efficient. (I'll probably just go with the easiest approach: leave OmitList exactly the way it is.)"


out := wordwrap(data1)
test1 := testwordwrap(out)
test2 := testwordwrap(data1)
msgbox, %  "<" . out . "<" . test1 . "<" . test2 . "<"
return

wordwrap(text, linelength=35){
 Array := Object()
 Loop, parse, text, %A_Space%, `n`r
  Array.Insert(A_LoopField)

 for key, val in Array
 {
  if out <> ""
   le := "`n"
  if key=1
   line := val
  else if (!mod(StrLen(line),linelength) or (StrLen(line)=0))
  {
   Out .= le line
   line := val
  }
  else if ((mod(StrLen(line),linelength )+ StrLen(val) +1 ) > linelength)
  {
   out .= le line
   line := val
  }
  else
   line .=  " " val
 }
 return out
}


testwordwrap(text,linelength=35){
 test:=0
  Array := Object()
 Loop, parse, text, `n
  Array.Insert(A_LoopField)

 for key, val in Array
   test += StrLen(val)//(linelength+1)

 if (test)
  return true
 return false
}