; Text drawing taken from: gdi+ ahk tutorial 8 written by tic (Tariq Porter). Thanks!
; Requires Gdip.ahk either in your Lib folder as standard library or using #Include
; Uncomment if Gdip.ahk is not in your standard library
;#Include, Gdip.ahk

#SingleInstance, Force
#NoEnv
SetBatchLines, -1
#include ..\..\class_taskbarInterface.ahk
#include ..\..\..\lib-a_to_h\Gdip-All.ahk

; Start gdi+
If !pToken := Gdip_Startup()
{
   MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
   ExitApp
}
OnExit, Exit
global counter := 0	; Some counter
Gui, new, +hwndhWnd
Gui, font, s24,Courier new
Gui, add, text,Center, Hover the mouse over the taskbar icon.`nClick the buttons.

tbi:= new taskbarInterface(hWnd,"buttonCallback")					; Attach the window to the interface, call buttonCallback(n,ref) when a button is clicked.
tbi.enableCustomThumbnailPreview("drawTime",25,false)				; call drawTime() every 25 ms when thumbnail preview is showing, "false", to not automatically delete the bitmap.
tbi.disallowPeek()													; Disallow peek because enableCustomThumbnailPreview also invalidates the peek preview.
tbi.setThumbnailToolTip("This is a custom tooltip.")				; Set a custom thumnail preview tooltip, hover the mouse over the thumbnail preview to see it.
sz:=tbi.queryButtonIconSize()										; Get required size for tooltip icons
h1:=LoadPicture("Shell32.dll","Icon302  w" sz.w "h" sz.h,isIcon)	; Load icons
h2:=LoadPicture("Shell32.dll","Icon303  w" sz.w "h" sz.h,isIcon)
h3:=LoadPicture("Shell32.dll","Icon247  w" sz.w "h" sz.h,isIcon)
h4:=LoadPicture("Shell32.dll","Icon248  w" sz.w "h" sz.h,isIcon)
h5:=LoadPicture("wmploc.dll", "Icon70   w" sz.w "h" sz.h,isIcon)
h6:=LoadPicture("wmploc.dll", "Icon71   w" sz.w "h" sz.h,isIcon)
tbi.setButtonIcon(1,h1)												; Set buttons icons
tbi.setButtonIcon(2,h2)
tbi.setButtonIcon(3,h3)
tbi.setButtonIcon(4,h4)
tbi.setButtonIcon(5,h5)
tbi.setButtonIcon(6,h6)
tbi.showButton(1)													; Show buttons
tbi.showButton(2)
tbi.showButton(3)
tbi.showButton(4)
tbi.showButton(5)
tbi.showButton(6)
tbi.setButtonToolTip(1,"Change to pink color")						; Set button tooltips
tbi.setButtonToolTip(2,"Change to some color")
tbi.setButtonToolTip(3,"Increment counter")
tbi.setButtonToolTip(4,"Decrement counter")
tbi.setButtonToolTip(5,"Unlock buttons")
tbi.setButtonToolTip(6,"Lock buttons")
gui,show,h150, my window


buttonCallback(n,ref){
	if (n==1)																		; Button 1 (left-most)	- some pink text color
		drawTime(-1," y40p Centre  c99FF66B4  r4 s20 Bold",ref)
	else if (n==2){																	; Button 2 - random text color
		Random,rnd, % 0x0, % 0xFFffff
		col:= format("cFF{:06x}", rnd)
		drawTime(-1," y40p Centre " col " r4 s20 Bold Italic",ref)
	} else if (n==3)																; Button 3 	- increment counter
		counter++
	else if (n==4)																	; Button 4  - decrement counter
		counter--
	else if (n==5){																	; Button 5 - enable buttons
		ref.enableButton(1)
		ref.enableButton(2)
		ref.enableButton(3)
		ref.enableButton(4)
	} else if (n==6) {																; Button 6 (right-most) - disable buttons
		ref.disableButton(1)
		ref.disableButton(2)
		ref.disableButton(3)
		ref.disableButton(4)
	}
}
drawTime(Width,Height,ref) {
	; Returns a bitmap handle at a specified rate when the thumbnail preview is shown.
	static gdio
	if !gdio { ; First time setup
		gdio:=[]
		gdio.hbm := CreateDIBSection(Width, Height)
		gdio.hdc := CreateCompatibleDC()
		gdio.obm := SelectObject(gdio.hdc, gdio.hbm)
		gdio.G := Gdip_GraphicsFromHDC(gdio.hdc)
		Gdip_SetSmoothingMode(gdio.G, 4)
		gdio.pBrush := Gdip_BrushCreateSolid(0xaaC0FFEE)
		gdio.Font := "Courier new"
		if !gdio.Font
			gdio.Font := "Arial"
		gdio.Options := " y40p Centre c99000000 r4 s20 Bold Italic"
	}
	if (width == -1){ ; change options
		gdio.Options:=Height
		return
	}
	if (ref == -1) {	; clean up
		DeleteObject(gdio.hbm)
		Gdip_DeleteBrush(gdio.pBrush)
		DeleteDC(gdio.hdc)
		Gdip_DeleteGraphics(gdio.G)
		return
	}
	; draw bitmap
	Gdip_GraphicsClear(gdio.G)
	Gdip_FillRoundedRectangle(gdio.G, gdio.pBrush, 0, 0, Width, Height, 30)
	Gdip_TextToGraphics(gdio.G, (counter == 37) ? "Get a life :)" : (A_hour ":" A_Min ":" A_Sec ":" substr(A_MSec,1,2) (counter? "`n" counter:"")) , gdio.Options, gdio.Font, Width, Height)
	SelectObject(gdio.hdc, gdio.obm)
	return gdio.hbm	; return bitmap handle to taskbarInterface
}

return
esc::
guiclose:
Exit:
	Gdip_Shutdown(pToken)
	drawTime(0,0,-1)
	ExitApp
return