#Include, <Gdip>

#If (!LoadLib = 1)
	ExitApp
#If


Class Spinner {
	Static ID := 0
	Static Pi := 4 * ATan(1)

	DotCount := 9
	DotSize := 12
	Radius := 20
	Color:= "000000"
	Delay := 250
	bClockwise := False

	__New(oConfig, hParent := 0) {
		If oConfig.HasKey("DotCount")
			this.DotCount := oConfig.DotCount
		If oConfig.HasKey("DotSize")
			this.DotSize := oConfig.DotSize
		If oConfig.HasKey("Radius")
			this.Radius := oConfig.Radius
		If oConfig.HasKey("Color")
			this.Color := oConfig.Color
		If oConfig.HasKey("Delay")
			this.Delay := oConfig.Delay
		If oConfig.HasKey("bClockwise")
			this.bClockwise := oConfig.bClockwise

		If (hParent = 0)
			this.Width := A_ScreenWidth, this.Height := A_ScreenHeight
		Else {
			WinGetPos,,, Width, Height, ahk_id %hParent%
			this.Width := Width, this.Height := Height
		}

		this.MidX := (this.Width // 2) - 10
		this.MidY := (this.Height // 2) - 10

		this.pToken := Gdip_Startup()
		this.hDC := CreateCompatibleDC()
		this.hBM := CreateDIBSection(this.Width, this.Height)
		this.oBM := SelectObject(this.hDC, this.hBM)
		this.pGraphics := Gdip_GraphicsFromHDC(this.hDC)
		Gdip_SetSmoothingMode(this.pGraphics, 4)

		this.ID := Spinner.ID++
		Gui, % "Spinner" this.ID ": New", +AlwaysOnTop +hWndhSpin
		Gui, +E0x80020 ; WS_EX_LAYERED | WS_EX_TRANSPARENT (click through)
		Gui, +0x40000000 -0x80000000 ; +WS_CHILD -WS_POPUP
		DllCall("SetParent", "Ptr", this.hSpin := hSpin, "Ptr", hParent)


		this.DOT := [], this.ARGB := [], this.BRUSHES := []
		Loop, % this.DotCount {
			this.DOT[A_Index, "x"] := this.MidX + this.Radius * Cos(A_Index * 2 * this.Pi / this.DotCount)
			this.DOT[A_Index, "y"] := this.MidY + this.Radius * Sin(A_Index * 2 * this.Pi / this.DotCount)
			this.ARGB.Push(Format("0x{:x}", A_Index * 255 // this.DotCount) this.Color)
			this.BRUSHES.Push(Gdip_BrushCreateSolid(this.ARGB[A_Index]))
		}
	}

	__Delete() {
		Gui, % "Spinner" this.ID ": Destroy"
		SelectObject(this.hDC, this.oBM)
		DeleteObject(this.hBM)
		DeleteDC(this.hDC)
		Gdip_DeleteGraphics(this.pGraphics)
		Loop, % this.DotCount
			Gdip_DeleteBrush(this.BRUSHES[A_Index])
		Gdip_Shutdown(this.pToken)
	}

	Call() {
		;-----------------------------------------------------------------------
		; the timer clears the drawing, the draws all the dots again
		; when drawing, each dot gets a new brush every time
		; I keep the index for brushes in range with Mod(index, DotCount) + 1
		; this.Index is initialized large enough for clockwise direction
		;-----------------------------------------------------------------------

		If (this.Index++ > 2 * this.DotCount)
			this.Index -= this.DotCount

		Gdip_GraphicsClear(this.pGraphics)
		Sign := this.bClockwise ? -1 : 1

		Loop, % This.DotCount {
			Gdip_FillEllipse(this.pGraphics
				, this.BRUSHES[Mod(this.Index + A_Index * Sign, this.DotCount) + 1]
				, this.DOT[A_Index].x, this.DOT[A_Index].y, this.DotSize, this.DotSize)
		UpdateLayeredWindow(this.hSpin, this.hDC, 0, 0, this.Width, this.Height)
		}
	}

	Start() {
		Gui, % "Spinner" this.ID ": Show", % "NA x0 y0 w" this.Width " h" this.Height
		this.Index := this.DotCount
		SetTimer, %this%, % this.Delay
		this.Call()
	}

	Close() {
		this.__Delete()
	}

	Stop() {
		SetTimer, %this%, Off
	}
}
