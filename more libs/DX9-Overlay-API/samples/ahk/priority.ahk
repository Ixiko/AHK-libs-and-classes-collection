#SingleInstance, force
#NoEnv
#include ..\..\include\ahk\overlay.ahk

SetParam("use_window", "0")
SetParam("process", "GFXTest.exe")

text_overlay :=- 1
box_overlay := -1

OnExit, GuiClose
return


createOverlays() {
	global text_overlay, box_overlay
	
	if(text_overlay == -1)
		text_overlay := TextCreate("Arial", 25, false, false, 300, 300, 0xFFFFFFFF, "Hello world", true, true)

	if(box_overlay == -1)
		box_overlay := BoxCreate(200, 200, 200, 200, 0xFFFFFFFF, true)
}

destroyOverlays() {
	global text_overlay, box_overlay
	
	if(text_overlay != -1) {
		TextDestroy(text_overlay)
		text_overlay := -1
	}

	if(box_overlay != -1) {
		BoxDestroy(box_overlay)
		box_overlay := -1
	}
}

~1::
createOverlays()
return

~2::
destroyOverlays()
return

~3::
SetOverlayPriority(box_overlay, 0)
SetOverlayPriority(text_overlay, 1)
return

~4::
SetOverlayPriority(box_overlay, 1)
SetOverlayPriority(text_overlay, 0)
return

GuiClose:
destroyOverlays()
ExitApp, 0
return