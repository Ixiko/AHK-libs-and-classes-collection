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
; And dont forget to exit the Application! (ExitApp, on GuiClose)

MsgBox, This Screensaver has no Settings!
ExitApp


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
}

; This function draws the Screensaver and/or the Screensaver-Preview.
; The mode parameter can be "DEFAULT" for the default mode or "PREVIEW", if a screensaver preview is required.
; rect is the rectangle in that the OpenGL-Output had to be and contains the variables left, top, right, bottom, width and height.
; Note: The X and Y Axis of the OpenGL-Output reaches from -1 to 1 in Orthographic Mode.
; Use the functions defined in glLite.ahk
DrawScreensaver(mode, rect)
{
}


