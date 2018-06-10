#NoEnv
#SingleInstance, force
#include ..\..\include\ahk\overlay.ahk

text_id := -1

InputBox, process, Enter process name,Enter the process`, where die overlay should be initialized
if(!strLen(process))
	ExitApp

SetParam("process", process)
DestroyAllVisual()
text_id := TextCreate("Arial", 10, false, false, 10, 580, 0xFFFFFFFF, "Framerate: ", true, true)
if(text_id == -1)
{
	MsgBox, The overlay couldn't be created!
	ExitApp
}

Gui, Add, Text, x12 y20 w260 h20 vFramerate, %A_Space%
Gui, Show, w286 h64, Framerate

SetTimer, update, 10
return

GuiClose:
cleanOverlay()
ExitApp

update:
frames := GetFrameRate()
if(frames == -1)
{
	cleanOverlay()
	ExitApp
}

TextSetString(text_id, "Framerate: {FFFF00}" . frames)
GuiControl, Text, Framerate, Framerate: %frames%
return

cleanOverlay()
{
	DestroyAllVisual()
}