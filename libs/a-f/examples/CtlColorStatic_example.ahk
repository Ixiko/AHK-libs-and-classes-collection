#NoEnv
SetBatchLines, -1
Keys := {C: "CapsLock", S: "ScrollLock", N: "NumLock"}
StateColor := {0: 0x5481E6, 1: 0x98CB4A} ; 0 = Off, 1 = On
Controls := {C: {}, S: {}, N: {}}
For Ctrl, Key In Keys
   Controls[Ctrl].State := GetKeyState(Key, "T")

gui, -caption +toolwindow +alwaysontop +lastfound
gui, color, 8b0fc6
gui, font, s10 w600, Arial Bold
Gui, Margin, 0, 0
winset, transcolor, 8b0fc6

gui, add, text, x0 y0 w60 h16 0x201 gClicked vC hwndHWND, C
gui, add, text, x0 y16 w60 h4 0x04 ; 0x04 = SS_BLACKRECT
Controls.C.Hwnd := HWND

gui, add, text, x63 y0 w60 h16 0x201 gClicked vS hwndHWND, S
gui, add, text, x63 y16 w60 h4 0x04 ; 0x04 = SS_BLACKRECT
Controls.S.Hwnd := HWND

gui, add, text, x126 y0 w60 h16 0x201 gClicked vN hwndHWND, N
gui, add, text, x126 y16 w60 h4 0x04 ; 0x04 = SS_BLACKRECT
Controls.N.Hwnd := HWND

gui, show

For Each, Ctrl In Controls
   CtlColorStatic(Ctrl.Hwnd, StateColor[Ctrl.State], 0xFFFFFF)

return

guiclose:
guiescape:
exitapp

Clicked:
   If (A_GuiEvent <> "DoubleClick") && (Ctrl := Controls[A_GuiControl])
      CtlColorStatic(Ctrl.Hwnd, StateColor[Ctrl.State := !Ctrl.State], 0xFFFFFF)
return

GetStates:
   For Ctrl, Key In Keys
      Controls[Ctrl].State := GetKeyState(Key, "T")
Return

#Include %A_ScriptDir%\..\CtlColorStatic.ahk