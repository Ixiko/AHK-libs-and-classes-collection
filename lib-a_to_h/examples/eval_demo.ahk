; #Include Eval.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance Force
SetBatchLines -1
Process Priority,,High

MsgBox % "Eval(""100 + 22 - 55"") expresses to: " .  Eval("100 + 22 - 55")
MsgBox Next, the script waits for the hotkeys WIN+- and WIN+= (Win and minus key and Win and equal sign). Select any text to express and see the result. One key replaces and the other one append the result.

; Monster by Laszlo
#-::                                  ; Replace selection or `expression with result
#=::                                  ; Append result to selection or `expression
   ClipBoard =
   SendInput ^c                        ; copy selection
   ClipWait 0.5
   If (ErrorLevel) {
      SendInput +{HOME}^c              ; copy, keep selection to overwrite (^x for some apps)
      ClipWait 1
      IfEqual ErrorLevel,1, Return
      If RegExMatch(ClipBoard, "(.*)(``)(.*)", y)
         SendInput %  "{RAW}" y1 . (A_ThisHotKey="#=" ? y3 . " = "  : "") . Eval(y3)
   } Else
      SendInput % "{RAW}" . (A_ThisHotKey="#=" ? ClipBoard . " = "  : "") . Eval(ClipBoard)
Return
