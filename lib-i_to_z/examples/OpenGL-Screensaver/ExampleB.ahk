#SingleInstance, force
#NoTrayIcon
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir
OnExit, ExitSub

if (!A_IsCompiled)
{
  icon := "icon\ahk screensaver.ico"  ;Specify an Icon-File (.ico) for the compiled Screensaver
  bin := "AutoHotkeySC.bin"           ;Specify the bin-File (.bin) for compiling the Script ("AutoHotkeySC.bin", "ANSI 32-bit.bin", "Unicode 32-bit.bin" or "Unicode 64-bit.bin")
}

OPENGL_PERSPECTIVE := false           ;Use Perspective Mode for the OpenGL-Output. Otherwise the Orthographic Mode will be used. (Can not be used with MULTIMONITOR_EXPAND_AREA)
MULTIMONITOR_EXPAND_AREA := true      ;Expands the OpenGL-Output over all Monitors. Can't be used with MULTIMONITOR_COPY. If this and MULTIMONITOR_COPY is false, only the first Display will be used.
MULTIMONITOR_COPY := false            ;Copy's the OpenGL-Output to all Monitors. Can't be used with MULTIMONITOR_EXPAND_AREA. If this and MULTIMONITOR_EXPAND_AREA is false, only the first Display will be used.
EXIT_MESSAGES := [0x100, 0x101, 0x201, 0x202, 0x204, 0x205] ;KEYDOWN | KEYUP | LBUTTONDOWN | LBUTTONUP | RBUTTONDOWN | RBUTTONUP (the Window-Messages on that the Screensaver will exit)
HIDE_CURSOR := true                   ;Hides the cursor

; Load your Screensaver settings here! (before including Screensaver.ahk)

#include, lib\
#include, Screensaver.ahk
#include, glLite.ahk

; Create a Screensaver-Settings Gui here, otherwise use ExitApp.
; To save the settings use an INI-File, the Registry or something similar.
; And dont forget to exit the Application! (ExitApp, on GuiClose)

Gui, -MaximizeBox -MinimizeBox
Gui, margin, 10, 10
Gui, add, pic, icon1 x20 y20 w64 h64, % A_ScriptFullPath
Gui, font, w800
Gui, add, text, x+20 yp+10, AutoHotkey Screensaver v1.2
Gui, font
Gui, add, text, y+5, Autor:`t`tBentschi
Gui, add, text, y+0, Screensaver:`tExampleB
Gui, add, text, x10 y100 w400 h2 +0x1000
Gui, add, text, y+10, This Screensaver was created using the Scripting-Language AutoHotkey.
Gui, font, cblue underline
Gui, add, text, y+0 gRunWeb, http://www.autohotkey.com/
Gui, font
Gui, add, text, y+10, Visit also the Project-Site in the Community at AutoHotkey (DE).
Gui, font, cblue underline
Gui, add, text, y+0 gRunCommunity, http://de.autohotkey.com/forum/viewtopic.php?p=72151
Gui, font
Gui, add, text, y+15, This Screensaver has no settings!
Gui, add, text, x10 y+10 w400 h2 +0x1000
Gui, add, button, x300 y+10 w100 gExit, OK
Gui, show,, Settings
return

Exit:
GuiClose:
ExitApp

RunWeb:
Run, http://www.autohotkey.com/
return

RunCommunity:
Run, http://de.autohotkey.com/forum/viewtopic.php?p=72151
return


ExitSub:
DestroyScreensaver() ;Ensures that everything is cleaned up
ExitApp

; This function draws the Screensaver and/or the Screensaver-Preview.
; The mode parameter can be "DEFAULT" for the default mode or "PREVIEW", if a screensaver preview is required.
; rect is the rectangle in that the OpenGL-Output had to be and contains the variables left, top, right, bottom, width and height.
; Note: The Y-Axis is positive to the top and negative to the bottom.
; The middle of the Screen (or displayarea if MULTIMONITOR_EXPAND_AREA used) is x0, y0.
; Use the functions defined in glLite.ahk
InitScreensaver(mode, rect)
{
  global obj
  static num := 24
  if (mode!="PREVIEW")
    glLineWidth(3)
  glEnable("blend")
  glBlendFunc("src-alpha", "one-minus-src-alpha")
  glClearColor(0.2, 0.2, 0.2)
  glClear("color")
  obj := []
  loop, % num
    obj.insert(1)
  for i, o in obj
    obj[i] := {i:0, x:0, y:0, r:i/num*360, rot:2, cR:1, cG:0.2, cB:1}
}

; This function draws the Screensaver and/or the Screensaver-Preview.
; The mode parameter can be "DEFAULT" for the default mode or "PREVIEW", if a screensaver preview is required.
; rect is the rectangle in that the OpenGL-Output had to be and contains the variables left, top, right, bottom, width and height.
; Note: The Y-Axis is positive to the top and negative to the bottom.
; The middle of the Screen (or displayarea if MULTIMONITOR_EXPAND_AREA used) is x0, y0.
; Use the functions defined in glLite.ahk
DrawScreensaver(mode, rect)
{
  global obj
  static minmax := 1.2, cminmax := 0.05, cmin := 0.33
  glColor(0, 0, 0, 0.03)
  glBegin("quads")
  glVertex(rect.left, rect.top)
  glVertex(rect.right, rect.top)
  glVertex(rect.right, rect.bottom)
  glVertex(rect.left, rect.bottom)
  glEnd()
  
  dist := (mode="PREVIEW") ? 0.5 : 0.1
  s := (rect.width+rect.height)/32
  
  for i, o in obj
  {
    Random, r, % (o.cR-cminmax<cmin) ? cmin : o.cR-cminmax, % (o.cR+cminmax>1) ? 1 : o.cR+cminmax
    Random, g, % (o.cG-cminmax<cmin) ? cmin : o.cG-cminmax, % (o.cG+cminmax>1) ? 1 : o.cG+cminmax
    Random, b, % (o.cB-cminmax<cmin) ? cmin : o.cB-cminmax, % (o.cB+cminmax>1) ? 1 : o.cB+cminmax
    o.cR := r
    o.cG := g
    o.cB := b
    o.i ++
    if (o.x>rect.right*minmax || o.x<rect.left*minmax || o.y>rect.top*minmax || o.y<rect.bottom*minmax)
      o.r += 5
    else if (o.i > 60)
    {
      Random, rot, -3.0, 3.0
      o.rot := rot
      o.i := 0
    }
    else
      o.r += o.rot
    glBegin("lines")
    glColor(o.cR, o.cG, o.cB, 0)
    glVertex(o.x+(cos(o.r*0.017453)*s), o.y+(sin(o.r*0.017453)*s))
    glColor(o.cR, o.cG, o.cB)
    glVertex(o.x, o.y)
    glVertex(o.x, o.y)
    glColor(o.cR, o.cG, o.cB, 0)
    glVertex(o.x-(cos(o.r*0.017453)*s), o.y-(sin(o.r*0.017453)*s))
    glEnd()
    o.x += sin(o.r*0.017453)*s*dist
    o.y -= cos(o.r*0.017453)*s*dist
  }
}


