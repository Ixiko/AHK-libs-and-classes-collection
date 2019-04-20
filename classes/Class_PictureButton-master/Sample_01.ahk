return
#Include lib\GDIp.ahk
#Include lib\Class_PictureButton_v2.ahk


;<----SUPER-GLOBAL VARIABLES---->
class PictureButton { ;BUG (or not) :0 -> super-global variable
}
;<------------------------------>


F1::reload
main() {
	static main:=main() ;start this function
	PictureButton:=new _PictureButton() ;init class
	global hGui
	GUI, +hwndhGui

	if(!(pToken:=Gdip_Startup())) ;starting GDI+
		return 1

	iconset:=load_iconset("resource\buttons.png") ;loading bitmaps
	
	options:={y:10,state:"normal",on_click:func("ON_PRESS")} ;try state:disable
	Loop % 3 {
		i:=A_Index-1
		if(i=2)
			i:=3
		btn:=[iconset[i][0],iconset[i][1],iconset[i][2],iconset[i][3]]
		options.btn:=btn
		PictureButton.add(hGui,options) ;adding button with options
	}

	GUI, SHOW, w200 h50
	PictureButton.show(-1)

	SetTimer, toggle_button,3000


	;<--------------INIT HOOKS-------------->
	OnMessage(0x200, "WM_MOUSEMOVE")
	OnMessage(0x201, "WM_LBUTTONDOWN")
	OnMessage(0x202, "WM_LBUTTONUP")
	OnMessage(0x2A3, "WM_MOUSELEAVE")
	;<-------------------------------------->
	OnMessage(0x112,"WM_SYSCOMMAND")
	return 1
}

ON_PRESS(id,hwnd) {
	static i:=0
	MsgBox,64,WARNING,BUTTON PRESSED!!`nID:%id%`nHWND:%hwnd%
}





toggle_button:
disabled:=!disabled
if(disabled)
	PictureButton.Disable(1)
else PictureButton.Enable(1)
return


GuiClose:
ExitApp

































load_iconset(path,bkg:=0xFFECEEEC) {
	if(!(pBitmap:=Gdip_CreateBitmapFromFile(path)))
		return 2
	Width:=Gdip_GetImageWidth(pBitmap),Height:=Gdip_GetImageHeight(pBitmap)

	w:=h:=14, out:=[]
	loop % Width/14 {
		x:=((i:=A_Index-1))*14+i*2
		y:=0
		out[i]:=[]
		loop % Height/14 {
			y:=((n:=A_Index-1))*14+n*2
			bitmap:=Gdip_CreateBitmap(14,14)
			G:=Gdip_GraphicsFromImage(bitmap)
			pBrush:=Gdip_BrushCreateSolid(bkg),Gdip_FillRectangle(G,pBrush,0,0,w,h) ;for Transparence
			Gdip_DrawImagePointsRect(G,pBitmap,"0,0|" w ",0|0," h,x,y,w,h,1)
			Gdip_DeleteGraphics(G)
			out[i][n]:=bitmap
		}
	} Gdip_DisposeImage(pBitmap)
	return out
}



isNumber(value) {
	if((str:=RegExReplace(value, "\d")) != value && str = "")
		return 1
	return 0
}






























;<--------------HOOKS----------------->

WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd) {
	MouseGetPos,,,, hwnd, 2
	PictureButton.MOUSEMOVE(hwnd)
}
WM_MOUSELEAVE(wParam, lParam, Msg, Hwnd) {
	PictureButton.MOUSEMOVE(0)
}


WM_LBUTTONDOWN(wParam, lParam, Msg, Hwnd) {
	MouseGetPos,,,, hwnd, 2
	PictureButton.LBUTTONDOWN(hwnd)
}

WM_LBUTTONUP(wParam, lParam, Msg, Hwnd) {
	MouseGetPos,,,, hwnd, 2
	PictureButton.LBUTTONUP(hwnd)
}
WM_SYSCOMMAND(wParam) {
	global hGui
	Gui, %hGui%:Default
	if (wParam=0xF120) { ;SC_RESTORE
		Gui,Show
		PictureButton.show(-1)
	} else if (wParam=0xF020) { ;SC_MINIMIZE
		WinMinimize
		return 0
	}
}


TrackMouseEvent(ptr) {
	DllCall("TrackMouseEvent", "UInt", ptr)
}
;<--------------HOOKS----------------->










