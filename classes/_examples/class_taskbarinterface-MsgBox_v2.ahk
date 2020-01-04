; Note that different systems may have different icons available.
; A real application should use its own icons. To load a bitmap as an icon handle, you may use LoadPictureType, see: https://github.com/HelgeffegleH/LoadPictureType
#include %A_ScriptDir%\..\Class_taskbarInterface_v2.ahk
#include %A_ScriptDir%\..\Class_threadfunc_V1.ahk
; Template example. Automatically add taskbar ornaments on window creation, in this example, there is one interface for Error-Msgboxes, and one for Success-msgboxes.
taskbarInterface.makeTemplate("errorMsgboxTemplate","Error ahk_class #32770")
taskbarInterface.makeTemplate("successMsgboxTemplate","Success ahk_class #32770")

; Make a message box with either F1 or F2.
F1::msgbox("Something failed","Error",0x10)
F2::msgbox("Something succeeded","Success",0x40)

Exitapp

; These function will be called when there is a window created matching the WinTitles:
;	"Error ahk_class #32770"
; 	"Success ahk_class #32770"
; The functions recieve the handle to the new window, and sets up an interface for it.
; The interface is then destroyed / freed when the window is destroyed.

errorMsgboxTemplate(hWnd){
	; Make a template for Error msgboxes
	static smallIconHandle:=LoadPicture("shell32.dll","icon132",isIcon)
	static bigIconHandle:=LoadPicture("shell32.dll","icon234",isIcon)
	static overlayIcon:=LoadPicture("wmploc.dll","icon23",isIcon)

	tbi := new taskbarInterface(hwnd) 						; Make the interface
	tbi.setTaskbarIcon(smallIconHandle,bigIconHandle)		; Change taskbar icon
	Sleep(10)												; Wait for the icon to be set, otherwise the overlayIcon is removed.
	tbi.setOverlayIcon(overlayIcon)							; Set overlayIcon
	tbi.flashTaskbarIcon("Red")								; Set taskbar icon color to red
	tbi.setTaskbarIconColor("Red")							; Flash five times
}

successMsgboxTemplate(hwnd){
	; Make a template for Success msgboxes
	static smallIconHandle:=LoadPicture("shell32.dll","icon56",isIcon)
	static bigIconHandle:=LoadPicture("shell32.dll","icon278",isIcon)
	static overlayIcon:=LoadPicture("wmploc.dll","icon22",isIcon)

	tbi := new taskbarInterface(hwnd) 						; Make the interface
	tbi.setTaskbarIcon(smallIconHandle,bigIconHandle)		; Change taskbar icon
	Sleep(10)												; Wait for the icon to be set, otherwise the overlayIcon is removed.
	tbi.setOverlayIcon(overlayIcon)							; Set overlayIcon
	tbi.flashTaskbarIcon("Green")							; Set taskbar icon color to red
	tbi.setTaskbarIconColor("Green")						; Flash five times
}