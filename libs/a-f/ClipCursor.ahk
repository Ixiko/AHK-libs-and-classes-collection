; https://www.autohotkey.com/boards/viewtopic.php?t=39558
; HELGEF
; ; Example:
; f1::ClipCursor(10,10,900,500)
; esc::exitapp

ClipCursor(x,y:=0,w:=0,h:=0){
	; By Anyone
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648383(v=vs.85).aspx
	; Specify the rectangle to confine the mouse to. Posiition x,y, dimension w, width and h, height.
	; Specify x := "unclip" to free to mouse. (This is automatically done when the script closes)
	; Warning: If the script terminates due to error, the mouse might not be freed, restarting the script frees the mouse.
	static free := dllcall("User32.dll\ClipCursor", "ptr", 0) 			; Frees the mouse on script start up.
	static oe := {base:{__delete:func("clipcursor").bind("unclip")}}	; For freeing the mouse on script exit.
	if (x = "unclip")
		return dllcall("User32.dll\ClipCursor", "ptr", 0)

	varsetcapacity(rect,16)
	numput(x,rect,0,"int")
	numput(y,rect,4,"int")
	numput(x+w,rect,8,"int")
	numput(y+h,rect,12,"int")
	dllcall("User32.dll\ClipCursor", "ptr", &rect)
}