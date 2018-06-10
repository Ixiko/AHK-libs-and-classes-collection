#SingleInstance, force
#NoEnv
#include ..\..\include\ahk\overlay.ahk

text_overlay:=-1

SetParam("use_window", "1")
SetParam("window", "GTA:SA:MP")
return


~1::
if(text_overlay != -1)
	return

text_overlay := TextCreate("Arial", 25, false, false, 300, 300, 0xFFFFFFFF, "Hello world", true, true)
return

~2::
if(text_overlay == -1)
	return

TextDestroy(text_overlay)
text_overlay := -1
return