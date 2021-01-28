#Include FloatToFraction.ahk

InputBox, UserInput, Decimal to fraction, Insert a positive float, , 320, 120
If ErrorLevel OR ( UserInput = "" )
  ExitApp ; exit because the user canceled or didn't input anything
MsgBox, % "Result:`t`t" FloatToFraction(UserInput) "`nErrorLevel:`t`t" ErrorLevel