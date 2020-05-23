Class Canvas {
	__New(_name, _options, _x, _y, _width, _height, _smoothing := 4, _interpolation := 7, _hide := 0) {
		this.x := _x, this.y := _y, this.width := _width, this.height := _height

		this.pToken := Gdip_Startup()
		this.hbm := CreateDIBSection(_width, _height), this.hdc := CreateCompatibleDC(), this.obm := SelectObject(this.hdc, this.hbm)
		this.G := Gdip_GraphicsFromHDC(this.hdc), Gdip_SetSmoothingMode(this.G, _smoothing), Gdip_SetInterpolationMode(this.G, _interpolation)

		this.pBrush := [Gdip_BrushCreateSolid("0xFFFFFFFF"), Gdip_BrushCreateSolid("0xFF000000")], this.pPen := [Gdip_CreatePen("0xFFFFFFFF", 1)]

		this.camera := {"base": this.__Camera
			, "x": 0
			, "y": 0
			, "z": 0

			, "focal_length": 300}

		this.speedratio := 1.0
		this.time := 0

		Gui, % _name ": New", % _options . " +LastFound +E0x80000"
		Gui, % _name ": Show", % " x" . _x . " y" . _y . " w" . _width . " h" . _height . (_hide ? " Hide" : " NA")
		this.hwnd := WinExist()

		Return (this)
	}

	Class __Camera {
		RotateX(_degrees) {
			;[ a  b  c ] [ x ]   [ x*a + y*b + z*c ]
			;[ d  e  f ] [ y ] = [ x*d + y*e + z*f ]
			;[ g  h  i ] [ z ]   [ x*g + y*h + z*i ]

			;[1      0         0  ]
			;[0    cos(a)   sin(a)]
			;[0   -sin(a)   cos(a)]

			a := ((_degrees >= 0) ? Mod(_degrees, 360) : 360 - Mod(-_degrees, -360))*0.017453292519943295769236907684886127134428718885417254560971914
				, c := Cos(a), s := Sin(a)

			Return (new Point3D(this.x, this.y*c + this.z*s, this.y*-s + this.z*c))
		}

		RotateY(_degrees) {
			;[ cos(a)   0    sin(a)]
			;[   0      1      0   ]
			;[-sin(a)   0    cos(a)]

			a := ((_degrees >= 0) ? Mod(_degrees, 360) : 360 - Mod(-_degrees, -360))*0.017453292519943295769236907684886127134428718885417254560971914
				, c := Cos(a), s := Sin(a)

			Return (new Point3D(this.x*c + this.z*s, this.y, this.x*-s + this.z*c))
		}

		RotateZ(_degrees) {
			;[ cos(a)   sin(a)   0]
			;[-sin(a)   cos(a)   0]
			;[    0       0      1]

			a := ((_degrees >= 0) ? Mod(_degrees, 360) : 360 - Mod(-_degrees, -360))*0.017453292519943295769236907684886127134428718885417254560971914
				, c := Cos(a), s := Sin(a)

			Return (new Point3D(this.x*c + this.y*s, this.x*-s + this.y*c, this.z))
		}
	}

	NewBrush(_alpha := "FF", _colour := "000000") {
		this.pBrush.Push(Gdip_BrushCreateSolid("0x" . _alpha . _colour))

		Return (this.pBrush[this.pBrush.Length()])
	}

	NewLineBrush(_x, _y, _width, _height, _alpha1 := "FF", _colour1 := "000000", _alpha2 := "FF", _colour2 := "000000", _lineargradientmode := 1, _wrapmode := 1) {
		this.pBrush.Push(Gdip_CreateLineBrushFromRect(_x, _y, _width, _height, "0x" . _alpha1 . _colour1, "0x" . _alpha2 . _colour2, _lineargradientmode, _wrapmode))

		Return (this.pBrush[this.pBrush.Length()])
	}

	NewPen(_alpha := "FF", _colour := "000000", _width := 1) {
		this.pPen.Push(Gdip_CreatePen("0x" . _alpha . _colour, _width))

		Return (this.pPen[this.pPen.Length()])
	}

	Update(_clear := 1, _reset := 1) {
		UpdateLayeredWindow(this.hwnd, this.hdc)
		If (_clear)
			Gdip_GraphicsClear(this.G)
		If (_reset)
			Gdip_ResetWorldTransform(this.G)
	}

	Clear() {
		Gdip_GraphicsClear(this.G)
	}

	ShutDown() {
		For i, v in this.pPen
			Gdip_DeletePen(v)
		For i, v in this.pBrush
			Gdip_DeleteBrush(v)

		SelectObject(this.hdc, this.obm), DeleteObject(this.hbm), DeleteDC(this.hdc), Gdip_DeleteGraphics(this.G)
		Gdip_Shutdown(this.pToken)
	}
}
