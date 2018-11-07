class CircleProgressClass {		; http://ahkscript.org/boards/viewtopic.php?p=41794#p41794
	; Credits: Bruttosozialprodukt, Learning one. This code is public domain.
	static Version := 1.04
	__New(Options="") {
		this.BarDiameter := (Options.HasKey("BarDiameter") = 1) ? Options.BarDiameter : 110
		this.BarThickness := (Options.HasKey("BarThickness") = 1) ? Options.BarThickness : 16
		this.BarColor := (Options.HasKey("BarColor") = 1) ? Options.BarColor : "dd228822"
		this.BackgroundColor := (Options.HasKey("BackgroundColor") = 1) ? Options.BackgroundColor : "ffffffff"
		this.TextColor := (Options.HasKey("TextColor") = 1) ? Options.TextColor : "ee000000"
		this.TextSize := (Options.HasKey("TextSize") = 1) ? Options.TextSize : 11
		this.TextRendering := (Options.HasKey("TextRendering") = 1) ? Options.TextRendering : 5
		this.TextFont := (Options.HasKey("TextFont") = 1) ? Options.TextFont : "Arial"
		this.TextStyle := (Options.HasKey("TextStyle") = 1) ? Options.TextStyle : ""									; you can use for example  "Bold Italic"
		this.X := (Options.HasKey("X") = 1) ? Options.X : Round(A_ScreenWidth/2-this.BarDiameter/2-this.BarThickness)	; centered is defualt
		this.Y := (Options.HasKey("Y") = 1) ? Options.Y : Round(A_ScreenHeight/2-this.BarDiameter/2-this.BarThickness)	; centered is defualt
		this.W := this.BarDiameter+this.BarThickness*2+2	; it's good to add 2 extra pixels
		this.UseClickThrough := (Options.HasKey("UseClickThrough") = 1) ? Options.UseClickThrough : 1					; 1 = use it, 0 = don't use it
		
		Gui, New, +Hwndhwnd
		Gui %hwnd%: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
		Gui %hwnd%: Show, NA
		if (this.UseClickThrough = 1)
			WinSet, ExStyle, +0x20, % "ahk_id " hwnd	; click through style
		
		hbm := CreateDIBSection(this.W, this.W), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
		pPen:=Gdip_CreatePen("0x" this.BarColor, this.BarThickness)
		if (pPen = 0) {	; GDI+ is not started up - start it up now and shut it down in __Delete() automatically.
			pToken := Gdip_Startup()
			pPen:=Gdip_CreatePen("0x" this.BarColor, this.BarThickness)	; call it again (with GDI+ started up now)
		}
		G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 4)
		
		if (this.BackgroundColor > 0)
			pBrush:=Gdip_BrushCreateSolid("0x" this.BackgroundColor)
			
		this.hwnd := hwnd, this.hdc := hdc, this.obm := obm, this.hbm := hbm, this.pPen := pPen, this.pBrush := pBrush, this.G := G, this.pToken := pToken
	}
	Update(Percent=0, Text="") {
		Gdip_GraphicsClear(this.G)		
		if (this.BackgroundColor > 0)
			Gdip_FillEllipse(this.G, this.pBrush, this.BarThickness+1, this.BarThickness+1, this.BarDiameter,this.BarDiameter)
		if (Percent>0)
			Gdip_DrawArc(this.G, this.pPen, Round(this.BarThickness/2)+1,  Round(this.BarThickness/2)+1, this.BarDiameter+this.BarThickness, this.BarDiameter+this.BarThickness, 270, Round(360/100*percent))
		if (Text!="") {
			Options := Trim("x1 y1 w" this.W-2 " h" this.W-2 " Center Vcenter r" this.TextRendering " s" this.TextSize " c" this.TextColor A_Space this.TextStyle)
			Gdip_TextToGraphics(this.G, Text, Options, this.TextFont)
		}
		;pControlPen:=Gdip_CreatePen("0xffff0000", 1), Gdip_DrawRectangle(this.G, pControlPen, 1, 1, this.W-2,this.W-2), Gdip_DeletePen(pControlPen)
		UpdateLayeredWindow(this.hwnd, this.hdc, this.X, this.Y, this.W, this.W)
	}
	Clear() {	; Just clears the graphics and updates layered window. Doesn't destroy object nor clear resources.
		Gdip_GraphicsClear(this.G)
		UpdateLayeredWindow(this.hwnd, this.hdc, this.X, this.Y, this.W, this.W)
	}
	__Delete() {
		Gdip_DeletePen(this.pPen)
		if (this.BackgroundColor > 0)
			Gdip_DeleteBrush(this.pBrush)
		Gdip_DeleteGraphics(this.G)
		SelectObject(this.hdc, this.obm)
		DeleteObject(this.hbm)
		DeleteDC(this.hdc)
		if (this.pToken != "") 	; GDI+ was obviously automatically started up in __New(), and therefore shut it down automatically now
			Gdip_Shutdown(this.pToken)
		hwnd := this.hwnd
		Gui %hwnd%: Destroy
	}
}