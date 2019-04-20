; taskbarInterface examples - Buttons
SetWorkingDir, % A_ScriptDir
; Create the gui
Gui, new, hwndhWnd
hbm:=LoadPicture("Shell32.dll","Icon155  w32 h32") 
Gui, Add, pic,x10 y10 w32 h32 hwndpicHwnd, % "hBitmap:" hbm
Gui, Add, text, ys, Hover the mouse over the taskbar icon.
Gui, Add, Button, xs w135 gDone , % "ExitApp"
Gui, Show,h80, My window

tbi:= new taskbarInterface(hwnd,"buttonClicked")							; Attach
dim:=taskbarInterface.queryButtonIconSize()									; Get the required dimensions for the icons. dim:={w:width, h:height}

; Load icons for the buttons
hIcon1:=LoadPicture("Shell32.dll","Icon64  w" dim.w  " h" dim.h,isIcon) 	; Load an icon, note, need to use the output variable isIcon for loadpicture, otherwise hIcon becomes a bitmap handle. 
hIcon2:=LoadPicture("Shell32.dll","Icon42  w" dim.w  " h" dim.h,isIcon) 	; Load an icon
; Set the button icons
tbi.setButtonIcon(1,hIcon1)
tbi.setButtonIcon(2,hIcon2)
; Show the buttons
tbi.showButton(1)
tbi.showButton(2)
; Clip the preview area
tbi.setThumbnailClip(10,10,42,42)

; Change the taskbar icon
tbi.setTaskbarIcon(LoadPicture("Shell32.dll","Icon34  w" dim.w  " h" dim.h,isIcon) ,LoadPicture("Shell32.dll","Icon23  w" dim.w  " h" dim.h,isIcon) ,LoadPicture("Shell32.dll","Icon12  w" dim.w  " h" dim.h,isIcon) )
sleep, 50
; Add a small overlay icon over the taskbar icon.
tbi.setOverlayIcon(LoadPicture("Shell32.dll","Icon76",isIcon))

; You do not need to keep your reference. 
; The class keeps a reference.
; When the window is destroyed, the class' reference is released automatically.
tbi:=""

; Set timer to change the gui picture - to show that the clipped preview is updated live.
SetTimer, rndIcon, 1000
return
rndIcon:
	Random rnd, 1, 200
	hbm:=LoadPicture("Shell32.dll","Icon" rnd " w32 h32")
	GuiControl,, % picHwnd, % "hBitmap:" hbm
return
	
	

buttonClicked(buttonNumber,ref){
	; buttonNumber, the number of the clicked button
	; ref = tbi
	if (buttonNumber=1){				; Button 1 clicked
		Msgbox % "You clicked button 1 @ " A_Now
	} else if (buttonNumber=2) {		; Button 2 clicked
		random, rnd, 1,200
		rhIcon:=LoadPicture("Shell32.dll","Icon" rnd  " w" ref.dim.w  " h" ref.dim.h,isIcon)
		ref.setButtonIcon(2,rhIcon)
	}
}
return
esc::
guiclose:
Done:
	exitapp
#include ..\taskbarInterface.ahk