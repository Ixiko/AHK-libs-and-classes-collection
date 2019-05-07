#SingleInstance force
#NoEnv
#KeyHistory 0
#Include ..\Thumbnail.ahk

SetWorkingDir %A_ScriptDir%
OnExit, GuiClose

WinGet, hSource, ID, A

Gui +LastFound +AlwaysOnTop
hDest := WinExist()

thumb := Thumbnail_Create(hDest, hSource)

xSource := 0
ySource := 0
Thumbnail_GetSourceSize(thumb, wSource, hSource)
xDest := 25
yDest := 25
wDest := 750
hDest := round(hSource / wSource * wDest)
opacity := 255
includeNC := true

Thumbnail_SetRegion(thumb, xDest, yDest, wDest, hDest, xSource, ySource, wSource, hSource)
Thumbnail_Show(thumb)
Gui, Show, % "w800 h" hDest + 50
return

!#1::
xSource += 50
Thumbnail_SetRegion(thumb, xDest, yDest, wDest, hDest, xSource, ySource, wSource, hSource)
return

!#2::
ySource += 50
Thumbnail_SetRegion(thumb, xDest, yDest, wDest, hDest, xSource, ySource, wSource, hSource)
return

!#3::
wSource *= 2
hSource *= 2
Thumbnail_SetRegion(thumb, xDest, yDest, wDest, hDest, 0, 0, wSource, hSource)
return

!#4::
wSource /= 2
hSource /= 2
Thumbnail_SetRegion(thumb, xDest, yDest, wDest, hDest, 0, 0, wSource, hSource)
return

!#5::
opacity-=25
Thumbnail_SetOpacity(thumb, opacity)
return

!#6::
Thumbnail_SetIncludeNC(thumb, includeNC := !includeNC)
return

!#7::Reload

GuiClose:
Thumbnail_Destroy(thumb)
ExitApp
return