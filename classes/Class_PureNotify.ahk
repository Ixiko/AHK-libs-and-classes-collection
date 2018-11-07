Class PureNotify
{
	__New(X := 0, Y:= 0, Width := 0, Height := 0, BgColor := "263238")
	{
		If !(pToken) := Gdip_Startup() {
		   MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		   ExitApp
		}

		this.pToken := pToken

		this.X := X
		this.Y := Y
		If !Width
			Width := A_ScreenWidth * 0.27
		If !Height
			Height := A_ScreenWidth * 0.17
		this.Width := Width
		this.Height := Height

		this.FadeFlag := True ; for future use of fade-in/fade-out animation

		Gui, New, HwndPN_hwnd
		Gui, %PN_hwnd%:Default 
		Gui, -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20
		Gui, Show, NA

		this.hwnd := WinExist() ; Get a handle to this window we have created in order to update it later

		this.hbm := CreateDIBSection(Width, Height) ; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
		this.hdc := CreateCompatibleDC() ; Get a device context compatible with the screen
		this.obm := SelectObject(this.hdc, this.hbm) ; Select the bitmap into the device context
		this.G := Gdip_GraphicsFromHDC(this.hdc) ;Get a pointer to the graphics of the bitmap, for use with drawing functions
		Gdip_SetSmoothingMode(this.G, 4) ; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
		
		this.BgColor := "0xEE" . BgColor
		this.pBrush := Gdip_BrushCreateSolid(this.BgColor) ; Create a partially transparent, black brush (ARGB = Transparency, red, green, blue) to draw a rounded rectangle with

		; Fill the graphics of the bitmap with a rounded rectangle using the brush created
		; Filling the entire graphics - from coordinates (0, 0) the entire width and height
		; The last parameter (20) is the radius of the circles used for the rounded corners
		Gdip_FillRoundedRectangle(this.G, this.pBrush, 0, 0, this.Width, this.Height, 25)
		Gdip_DeleteBrush(this.pBrush) ; Delete the brush as it is no longer needed and wastes memory
	}

	Text(Head, Body)
	{
		this.Head(Head)
		this.Body(Body)
	}

	Head(Text, Color := "", Font := "Segoe UI")
	{
		Options := "x10p y10p w80p Centre cffC792EB s30"
		Gdip_TextToGraphics(this.G, Text, Options, Font, this.Width, this.Height)
	}

	Body(Text, Color := "", Font := "Segoe UI")
	{
		Options := "x10p y30p w80p Centre cffF78C6C s25"
		Gdip_TextToGraphics(this.G, Text, Options, Font, this.Width, this.Height)

		; Update the specified window we have created (hwnd) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
		; With some simple maths we can place the gui in the centre of our primary monitor horizontally and vertically at the specified heigth and width
		;UpdateLayeredWindow(this.hwnd, this.hdc, (A_ScreenWidth-this.Width)//2, (A_ScreenHeight-this.Height)//2, this.Width, this.Height)
		this.Fade()

	}

	Fade(X := 0, Y := 0)
	{
		If !X
			this.X := (A_ScreenWidth-this.Width)/2
		If !Y
			this.Y := (A_ScreenHeight-this.Height)/2
		Loop
		{
			UpdateLayeredWindow(this.hwnd, this.hdc, this.X,this.Y, this.Width, this.Height
			, (this.FadeFlag = True) ? A_Index*5 : (255 - A_Index*5))
			Sleep, 10
		} Until A_Index*5 >= 255
		this.FadeFlag := !this.FadeFlag ; So the gui will fade in when this method is called (:= exit, when u free the obj)
		
		;UpdateLayeredWindow(this.hwnd, this.hdc, (A_ScreenWidth-this.Width)//2, (A_ScreenHeight-this.Height)//2, this.Width, this.Height, 255)
	}

	__Delete()
	{
		this.Destroy()
		Gdip_Shutdown(this.pToken)
	}

	Destroy()
	{
		this.Fade()
		SelectObject(this.hdc, this.obm) ; Select the object back into the hdc
		DeleteObject(this.hbm) ; Now the bitmap may be deleted
		DeleteDC(this.hdc) ; Also the device context related to the bitmap may be deleted
		Gdip_DeleteGraphics(this.G) ; The graphics may now be deleted
		Gui, Destroy
	}
}


#Include %A_LineFile%\..\gdip.ahk