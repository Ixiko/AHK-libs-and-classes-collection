; Shows a beautful and practical cursor. Press escape to end the fun. (Note, only the arrow cursor is replaced)
#Include %A_ScriptDir%\..\class_LoadPictureType.ahk
OnExit, restore
transCol:=0x55FF51
IMAGE_CURSOR:=2			; Request to recieve a cursor handle
xHotspot:=153			; Where the click is. In this case, at the tip of the arrow.
yHotspot:=18

myCursor:= new LoadPictureType("hx.bmp", "", IMAGE_CURSOR,transCol,xHotspot,yHotspot)
SetCursor(myCursor.getHandle())


; If you want this to free the handle,
; myCursor:=""
; Then do:
; myCursor.setAutoFreeHandles()
; Or change the default:
; doAutoFreeHandles:=false to true


Esc::
restore:
	restoreCursor()
	exitapp
return



SetCursor(hcur,id:=32512){
	; OCR_NORMAL:=32512
	return DllCall("User32.dll\SetSystemCursor", "Ptr", hcur, "Uint", id)
}
restoreCursor(){
	static SPI_SETCURSORS:=0x0057
	;	Reloads the system cursors. Set the uiParam parameter to zero and the pvParam parameter to NULL.
	;		      ("SystemParametersInfo", "Uint", uiAction, "Uint", uiParam, "Ptr", pvParam, "Uint",  fWinIni)
	return DllCall("User32.dll\SystemParametersInfo", "Uint", SPI_SETCURSORS,  "Uint", 0, "Ptr", 0, "Uint", 0)
}