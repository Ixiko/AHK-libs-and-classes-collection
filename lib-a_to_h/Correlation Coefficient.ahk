/*
#SingleInstance force
#NoEnv
SetBatchLines, -1

;__________Sample Data>
X=
(
60
61
62
63
65
)
Y=
(
3.1
3.6
3.8
4
4.1
)
;__________Sample Data<

Gui, Add, Text,,X values
Gui, Add, Edit, r10 w120 -Wrap vX, %X%
Gui, Add, Text, ym, Y values
Gui, Add, Edit, r10 w120 -Wrap vY, %Y%
Gui, Add, Button, xm gCalc, Calculate
Gui, Add, Text,,Correlation Coefficient:
Gui, Add, Edit, x+10 ReadOnly vCC

Gui, Show
return
GuiClose:
ExitApp

Calc:
Gui, Submit, NoHide
GuiControl,,CC,% Correl(X,Y)
return
*/

Correl(X,Y) {
 StringSplit, X, X, `n
 StringSplit, Y, Y, `n
 If (X0 != Y0)
 {
  MsgBox, 48,,Error:`nX and Y have an unequal number of elements.
  Return
 }
 Loop, %X0%
 {
  SumX += X%A_Index%
  SumY += Y%A_Index%
  SumX2 += X%A_Index%**2
  SumY2 += Y%A_Index%**2
  SumXY += X%A_Index%*Y%A_Index%
 }
 Return, (X0*SumXY-SumX*SumY)/Sqrt((X0*SumX2-SumX**2)*(X0*SumY2-SumY**2))
}