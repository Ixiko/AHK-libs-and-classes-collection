#Include OGdip.ahk

Gui, New
Gui, Add, Picture, x10 y10 w256 h256 +0x0E hwndHPic
Gui, Add, Button , x10 y276 w256 h40 +0x80 hwndHBtn

Gdip.Startup()
bmpPic := new Gdip.Bitmap(256,256)  ; Create empty bitmap
bmpPic.G.SetPen(0xFFAA0000, 16)     ; .G refers to auto-created Graphics of this bitmap
bmpPic.G.SetBrush(0xFFFFFFFF)
bmpPic.G.SetOptions("+Antialias +Pixel")

Loop 4 {
	xy := 8 + (A_Index-1) * 32
	hw := 256 - 2*xy
	bmpPic.G.DrawEllipse(xy, xy, hw, hw)
}

bmpPic.SetToControl(HPic)
bmpPic.SetToControl(HBtn)

bmpHIcon := bmpPic.CreateHICON()
Menu,Tray,Icon, HICON:%bmpHIcon%

bmpPic := ""  ; Dispose bitmap and all related objects
Gdip.Shutdown()

Gui, Show
Return

GuiClose:
ExitApp