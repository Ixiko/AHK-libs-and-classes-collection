/*
#NoEnv
CoordMode, Mouse ; Required: change coord mode to screen vs relative.

LetUserSelectRect(x1, y1, x2, y2)
MsgBox %x1%,%y1%  %x2%,%y2%

ExitApp
*/

LetUserSelectRect(ByRef X1, ByRef Y1, ByRef X2, ByRef Y2) {
  static r := 3
  ; Create the "selection rectangle" GUIs (one for each edge).
  Loop 4 {
    Gui, %A_Index%: -Caption +ToolWindow +AlwaysOnTop
    Gui, %A_Index%: Color, Red
  }
  ; Disable LButton.
  Hotkey, *LButton, lusr_return, On
  ; Wait for user to press LButton.
  KeyWait, LButton, D
  ; Get initial coordinates.
  MouseGetPos, xorigin, yorigin
  ; Set timer for updating the selection rectangle.
  SetTimer, lusr_update, 10
  ; Wait for user to release LButton.
  KeyWait, LButton
  ; Re-enable LButton.
  Hotkey, *LButton, Off
  ; Disable timer.
  SetTimer, lusr_update, Off
  ; Destroy "selection rectangle" GUIs.
  Loop 4
  Gui, %A_Index%: Destroy
  return

  lusr_update:
  MouseGetPos, x, y
  if (x = xlast && y = ylast)
    ; Mouse hasn't moved so there's nothing to do.
  return
  if (x < xorigin)
    x1 := x, x2 := xorigin
  else x2 := x, x1 := xorigin
  if (y < yorigin)
    y1 := y, y2 := yorigin
  else y2 := y, y1 := yorigin
  ; Update the "selection rectangle".
  Gui, 1:Show, % "NA X" x1 " Y" y1 " W" x2-x1 " H" r
  Gui, 2:Show, % "NA X" x1 " Y" y2-r " W" x2-x1 " H" r
  Gui, 3:Show, % "NA X" x1 " Y" y1 " W" r " H" y2-y1
  Gui, 4:Show, % "NA X" x2-r " Y" y1 " W" r " H" y2-y1
  lusr_return:
  return
}
