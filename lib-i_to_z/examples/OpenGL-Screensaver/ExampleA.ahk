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
MULTIMONITOR_EXPAND_AREA := false     ;Expands the OpenGL-Output over all Monitors. Can't be used with MULTIMONITOR_COPY. If this and MULTIMONITOR_COPY is false, only the first Display will be used.
MULTIMONITOR_COPY := true             ;Copy's the OpenGL-Output to all Monitors. Can't be used with MULTIMONITOR_EXPAND_AREA. If this and MULTIMONITOR_EXPAND_AREA is false, only the first Display will be used.
EXIT_MESSAGES := [0x100, 0x101, 0x201, 0x202, 0x204, 0x205] ;KEYDOWN | KEYUP | LBUTTONDOWN | LBUTTONUP | RBUTTONDOWN | RBUTTONUP (the Window-Messages on that the Screensaver will exit)
HIDE_CURSOR := true                   ;Hides the cursor

; Load your Screensaver settings here! (before including Screensaver.ahk)

#include, lib\
#include, Screensaver.ahk
#include, glLite.ahk

; Create a Screensaver-Settings Gui here, otherwise use ExitApp.
; To save the settings use an INI-File, the Registry or something similar.
; And dont forget to exit the Application! (ExitApp, on GuiClose, Button OK or Cancel, ...)

Gui, -MaximizeBox -MinimizeBox
Gui, margin, 10, 10
Gui, add, pic, icon1 x20 y20 w64 h64, % A_ScriptFullPath
Gui, font, w800
Gui, add, text, x+20 yp+10, AutoHotkey Screensaver v1.2
Gui, font
Gui, add, text, y+5, Autor:`t`tBentschi
Gui, add, text, y+0, Screensaver:`tExampleA
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

; This function initializes the OpenGL-Resources needed to run the Screensaver.
; The mode parameter can be "DEFAULT" for the default mode or "PREVIEW", if a screensaver preview is required.
; rect is the rectangle in that the OpenGL-Output had to be drawn and contains the variables left, top, right, bottom, width and height.
; Note: The resources will be automaticly created for every context (not shared!).
; Use the functions defined in glLite.ahk
InitScreensaver(mode, rect)
{
  global s
  glClearColor(0, 0, 0.5) ;Set the background-color (dark-blue)
  glShadeModel("smooth")
  glEnable("texture") ;Enable the use of 2D-Textures
  glLoadTexture(1, "resources\Cherry.png", 0, 0, 0.5) ;The first parameter is the texid. The last 3 (4 if Alpha is Specified) parameters are the Background-Color (R, G, B, A)
}

; This function draws the Screensaver and/or the Screensaver-Preview.
; The mode parameter can be "DEFAULT" for the default mode or "PREVIEW", if a screensaver preview is required.
; rect is the rectangle in that the OpenGL-Output had to be and contains the variables left, top, right, bottom, width and height.
; Note: The Y-Axis is positive to the top and negative to the bottom.
; The middle of the Screen (or displayarea if MULTIMONITOR_EXPAND_AREA used) is x0, y0.
; Use the functions defined in glLite.ahk
DrawScreensaver(mode, rect)
{
  static rot := 0
  glClear("color") ;Clear the Color-Buffer-Bits
  glColor(1, 1, 1) ;Set the color (white)
  glLoadIdentity() ;Set the Matrix back to default
  
  if (mode="PREVIEW")
    glRotate(rot+=1, 0, 0, 1) ;Rotate left on the Preview
  else
    glRotate(rot-=1, 0, 0, 1) ;else, rotate right
  
  s := (rect.width+rect.height)/8
  glBindTexture(1) ;Bind the Texture, loaded in InitScreensaver
  glBegin("quads") ;Begin to draw quads
  glTexCoord(0, 1)  glVertex(-s, s)   ;left-top corner
  glTexCoord(1, 1)  glVertex(s, s)    ;right-top corner
  glTexCoord(1, 0)  glVertex(s, -s)   ;right-bottom corner
  glTexCoord(0, 0)  glVertex(-s, -s)  ;left-bottom corner
  glEnd() ;End drawing
}


