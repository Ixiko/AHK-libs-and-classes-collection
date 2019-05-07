#include ..\Thumbnail.ahk
#SingleInstance force
#KeyHistory 0

OnExit, GuiClose

WinGet, hSource, ID, A

Gui +LastFound +AlwaysOnTop
hDest := WinExist()

thumb := new Thumbnail(hDest, hSource)

xSource := 0
ySource := 0
wSource := thumb.GetSourceWidth()
hSource := thumb.GetSourceHeight()
xDest := 25
yDest := 25
wDest := 750
hDest := round(hSource / wSource * wDest)
opacity := 255
includeNC := true

Update()

thumb.Show()
Gui Show, % "w800 h" hDest + 50
return

!#1::
xSource += 50
Update()
return

!#2::
ySource += 50
Update()
return

!#3::
wSource *= 2
hSource *= 2
Update()
return

!#4::
wSource /= 2
hSource /= 2
Update()
return

!#5::
opacity -= 25
Update()
return

!#6::
includeNC := !includeNC
Update()
return

!#7::Reload

GuiClose:
thumb.Destroy()
Thumbnail.Unload()
ExitApp
return

Update()
{
	global
	thumb.SetDestinationRegion(xDest, yDest, wDest, hDest)
	thumb.SetSourceRegion(xSource, ySource, wSource, hSource)
	thumb.SetOpacity(opacity)
	thumb.SetIncludeSourceNC(includeNC)
}
