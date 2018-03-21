; AutoHotkey
; Language:       	English 
; Authors:		esunder | https://github.com/esunder
;				Eruyome |	https://github.com/eruyome
;
; Class Function:
;	GDI+ Tooltip
;	
;
; Arguments:
;	boSize			Border size in pixel: string or array (w, h)
;	padding			Padding in pixel: string or array (left/right, top/bottom)
;	w				Init window width in pixel, will get changed to actual tooltip size later
;	h				Init window height in pixel, will get changed to actual tooltip size later
;
;	wColor			Array or String, possible values:
;	bColor				"0xFFFFFFFF" or "FFFFFFFF"
;	fColor				["0xFF", "0xFFFFFF"] or ["0xFF", "FFFFFF"]
;						[255, "FFFFFF"] (decimal opacity value in hex base)
;						[100, "FFFFFF", 10] (decimal opacity value, specifying the decimal base)
;
;	innerBorder		Renders a second inner border, using the default color or a color set by SetInnerBorder()
;	renderingHack		For some reason all graphics are rendered "blurry" (shifted), despite their starting coordinates being whole pixels.
;					They need an offset of (about) 0.4 to render correctly and sharp.
;	luminosityFactor	Positive or negative luminosity change for the inner border (+/- 0-1).

#Include, %A_ScriptDir%\lib\Gdip2.ahk

class GdipTooltip
{	
	__New(params*)
	{
		c := params.MaxIndex()
		If (c > 10) {
			throw "Too many parameters passed to GdipTooltip.New()"
		}
		
		; set defaults
		boSize	:= (params[1] = "" or not params[1]) ? 2 : params[1]
		padding	:= (params[2] = "" or not params[2]) ? 5 : params[2]
		w		:= (params[3] = "" or not params[3]) ? 800 : params[3]
		h		:= (params[4] = "" or not params[4]) ? 600 : params[4]
		wColor	:= (params[5] = "" or not params[5]) ? 0xE5000000 : this.ConvertColorToARGBhex(this.ValidateInitColors(params[5]))
		bColor	:= (params[6] = "" or not params[6]) ? 0xE57A7A7A : this.ConvertColorToARGBhex(this.ValidateInitColors(params[6]))
		fColor	:= (params[7] = "" or not params[7]) ? 0xFFFFFFFF : this.ConvertColorToARGBhex(this.ValidateInitColors(params[7]))
		innerBorder		:= (params[8] = "" or not params[8]) ? false : params[8]
		renderingHack		:= (params[9] = "" or not params[9]) ? true : params[9]
		luminosityFactor	:= (params[10] = "" or not params[10]) ? 0 : params[10]		
		
		; Initialize Gdip
		this.gdip				:= new Gdip()
		this.parentWindowHwnd	:= ""
		this.window			:= new gdip.Window(new gdip.Size(w, h))
		this.fillBrush			:= new gdip.Brush(wColor)
		this.borderBrush 		:= new gdip.Brush(bColor)
		this.borderBrushInner	:= new gdip.Brush(0xE50000FF)
		this.fontBrush			:= new gdip.Brush(fColor)

		this.innerBorder	:= innerBorder
		this.luminosityFactor := luminosityFactor
		If (innerBorder) {
			boSize := StrLen(boSize) ? Floor(boSize / 2) : [Floor(boSize / 2), Floor(boSize / 2)]	
		}		
		this.borderSize	:= StrLen(boSize) ? new this.gdip.Size(boSize, boSize) : new this.gdip.Size(boSize)
		this.padding		:= StrLen(padding) ? new this.gdip.Size(padding, padding) : new this.gdip.Size(padding)
		this.renderingHack	:= renderingHack
		this.isVisible		:= false
		
		this.SetInnerBorder(this.innerBorder, this.luminosityFactor)
		; Start off with a clear window
		this.HideGdiTooltip()
	}

	ShowGdiTooltip(fontSize, String, XCoord, YCoord, relativeCoords = true, parentWindowHwnd = "", fixedCoords = false)
	{
		; Ignore empty strings
		If (String == "")
			Return
		
		position := new this.gdip.Point(XCoord, YCoord)
		fontSize := fontSize + 3

		this.CalculateToolTipDimensions(String, fontSize, ttWidth, ttLineHeight, ttheight)
		
		renderingOffset := this.renderingHack ? 0.3999 : 0	
		;textAreaWidth	:= ttWidth  + (Floor(this.padding.width / 2))  + renderingOffset
		textAreaWidth	:= ttWidth  + renderingOffset
		textAreaHeight	:= ttHeight + (2 * this.padding.height) + renderingOffset

		this.window.Clear()
		this.window.size.width	:= Round(textAreaWidth  + this.borderSize.width, 5)
		this.window.size.height	:= Round(textAreaHeight + this.borderSize.height, 5)
		this.window.FillRectangle(this.fillBrush, new this.gdip.Point(this.borderSize.width, this.borderSize.height), new this.gdip.Size(textAreaWidth-(this.borderSize.width*2), textAreaHeight-(this.borderSize.height*2)))
		
		; optional inner border - default = false
		If (this.innerBorder) {
			this.window.FillRectangle(this.borderBrushInner, new this.gdip.Point(this.borderSize.width + renderingOffset, this.borderSize.height + renderingOffset), new this.gdip.Size(this.borderSize.width, textAreaHeight - this.borderSize.height - renderingOffset))
			this.window.FillRectangle(this.borderBrushInner, new this.gdip.Point(textAreaWidth - this.borderSize.width - this.borderSize.width, 0 + renderingOffset), new this.gdip.Size(this.borderSize.width, textAreaHeight - this.borderSize.height - renderingOffset))
			this.window.FillRectangle(this.borderBrushInner, new this.gdip.Point(this.borderSize.width + renderingOffset, this.borderSize.height + renderingOffset), new gdip.Size(textAreaWidth - this.borderSize.width - renderingOffset, this.borderSize.height))
			this.window.FillRectangle(this.borderBrushInner, new this.gdip.Point(0 + renderingOffset, textAreaHeight - this.borderSize.height - this.borderSize.height), new gdip.Size(textAreaWidth - this.borderSize.width - renderingOffset, this.borderSize.height))
		}
		
		; left border
		this.window.FillRectangle(this.borderBrush, new this.gdip.Point(0 + renderingOffset, 0 + renderingOffset), new this.gdip.Size(this.borderSize.width, textAreaHeight - renderingOffset))
		; right border
		this.window.FillRectangle(this.borderBrush, new this.gdip.Point(textAreaWidth - this.borderSize.width, 0 + renderingOffset), new this.gdip.Size(this.borderSize.width, textAreaHeight - renderingOffset))
		; top border
		this.window.FillRectangle(this.borderBrush, new this.gdip.Point(0 + renderingOffset, 0 + renderingOffset), new gdip.Size(textAreaWidth - renderingOffset, this.borderSize.height))
		; bottom border
		this.window.FillRectangle(this.borderBrush, new this.gdip.Point(0 + renderingOffset, textAreaHeight - this.borderSize.height), new gdip.Size(textAreaWidth - renderingOffset, this.borderSize.height))
		
		options := {}
		options.font	:= "Consolas"
		options.brush	:= this.fontBrush
		options.width	:= ttWidth
		options.height	:= ttHeight
		options.size	:= fontSize
		options.left	:= Round(this.padding.width  + renderingOffset, 5)
		options.top	:= Round(this.padding.height + renderingOffset, 5)

		If (not StrLen(parentWindowHwnd) or not WinActive("ahk_id" parentWindowHwnd) or fixedCoords) {
			this.GetActiveMonitorInfo(screenX, screenY, screenWidth, screenHeight)
		} Else {
			WinGetPos, screenX, screenY, screenWidth, screenHeight, ahk_id %parentWindowHwnd%
			If (relativeCoords) {
				XCoord := XCoord + screenX
				YCoord := YCoord + screenY
				screenWidth := screenWidth + screenX
				screenHeight := screenHeight + screenY
			}
		}
		
		; make sure that the tooltip is completely visible on screen/window
		ttRightX	:= Round(XCoord + this.window.size.width, 5)
		ttBottomY	:= Round(YCoord + this.window.size.height, 5)
		XCoord	:= ttRightX  > screenWidth  ? XCoord - (Abs(ttRightX  - screenWidth))  : XCoord
		YCoord	:= ttBottomY > screenHeight ? YCoord - (Abs(ttBottomY - screenHeight)) : YCoord
		
		this.window.WriteText(String, options)
		this.window.Update({ x: Round(XCoord, 5), y: Round(YCoord, 5)})
		
		ttWindowHwnd := this.window.hwnd
		WinSet, ExStyle, +0x20, ahk_id %ttWindowHwnd% ; 0x20 = WS_EX_CLICKTHROUGH
		this.isVisible := true
	}
	
	SetInnerBorder(state = true, luminosityFactor = 0, autoColor = true, argbColorHex = "") {
		this.innerBorder := state
		luminosityFactor := luminosityFactor == 0 ? this.luminosityFactor : luminosityFactor
		
		; use passed color 
		argbColorHex := RegExReplace(Trim(argbColorHex), "i)^0x")
		If (StrLen(argbColorHex) and not autoColor) {
			argbColorHex := "0x" this.ValidateRGBColor(argbColorHex, "E5FFFFFF", true)
			this.borderBrushInner := new gdip.Brush(argbColorHex)
		}
		; darken/lighten the default borders color
		Else {
			_r := this.ChangeLuminosity(this.borderBrush.Color.r, luminosityFactor)
			_g := this.ChangeLuminosity(this.borderBrush.Color.g, luminosityFactor)
			_b := this.ChangeLuminosity(this.borderBrush.Color.b, luminosityFactor)
			_a := this.borderBrush.Color.a
			this.borderBrushInner := new gdip.Brush(_a, _r, _g, _b)			
		}
	}	
	
	SetRenderingFix(state) {
		this.renderingHack := state
	}
	
	SetBorderSize(w, h) {
		this.borderSize := new this.gdip.Size(w, h)
	}
	
	SetPadding(w, h) {
		this.padding := new this.gdip.Size(w, h)
	}

	HideGdiTooltip(debug = false)
	{
		this.isVisible := false
		this.window.Clear()
		this.window.Update()
	}
	
	GetVisibility() {
		Return this.isVisible
	}
	
	CalculateToolTipDimensions(String, fontSize, ByRef ttWidth, ByRef ttLineHeight, ByRef ttHeight) {
		ttWidth	:= 0
		ttHeight	:= 0
		StringArray := StrSplit(String, "`n")
		Loop % StringArray.MaxIndex()
		{
			element := StringArray[A_Index]
			dim	:= this.MeasureText(element, fontSize + 1, "Consolas")
			len	:= dim["W"] * (fontSize / 10)
			hi	:= dim["H"] * ((fontSize - 1) / 10)
			
			If (len > ttWidth)
			{
				ttWidth := len
			}
			
			ttHeight += hi
			ttLineHeight := hi
		}
		
		ttWidth  := Ceil(ttWidth)
		ttHeight := Ceil(ttHeight)
	}

	MeasureText(Str, FontOpts = "", FontName = "") {
		Static DT_FLAGS := 0x0520 ; DT_SINGLELINE = 0x20, DT_NOCLIP = 0x0100, DT_CALCRECT = 0x0400
		Static WM_GETFONT := 0x31
		Size := {}
		Gui, New
		If (FontOpts <> "") || (FontName <> "")
			Gui, Font, %FontOpts%, %FontName%
		Gui, Add, Text, hwndHWND
		SendMessage, WM_GETFONT, 0, 0, , ahk_id %HWND%
		HFONT := ErrorLevel
		HDC := DllCall("User32.dll\GetDC", "Ptr", HWND, "Ptr")
		DllCall("Gdi32.dll\SelectObject", "Ptr", HDC, "Ptr", HFONT)
		VarSetCapacity(RECT, 16, 0)
		DllCall("User32.dll\DrawText", "Ptr", HDC, "Str", Str, "Int", -1, "Ptr", &RECT, "UInt", DT_FLAGS)
		DllCall("User32.dll\ReleaseDC", "Ptr", HWND, "Ptr", HDC)
		Gui, Destroy
		Size.W := NumGet(RECT,  8, "Int")
		Size.H := NumGet(RECT, 12, "Int")
		Return Size
	}	

	UpdateColors(wColor, wOpacity, bColor, bOpacity, tColor, tOpacity, opacityBase = 16, colorBase = 16)
	{
		; valid color formats -> see this.ConvertColorToARGBhex()
		; valid opacity formats = decimal (0-100) or hex (0-255)
		; opacityBase/colorBase = 10 or 16

		; validate opacity and convert to hex values (in decimal)
		If (opacityBase == 10) {
			wOpacity := this.ValidateOpacity(wOpacity, "", opacityBase, "16")
			bOpacity := this.ValidateOpacity(bOpacity, "", opacityBase, "16")
			tOpacity := this.ValidateOpacity(tOpacity, "", opacityBase, "16")
		}
		this.fillBrush		:= new gdip.Brush(this.ConvertColorToARGBhex([wOpacity, wColor]))
		this.borderBrush	:= new gdip.Brush(this.ConvertColorToARGBhex([bOpacity, bColor]))	
		this.fontBrush		:= new gdip.Brush(this.ConvertColorToARGBhex([tOpacity, tColor]))
		
		this.SetInnerBorder(this.innerBorder, this.luminosityFactor)
	}
	
	ValidateRGBColor(Color, Default, hasOpacity = false) {
		; hex RGB = 0xFFFFFF or FFFFFF
		; hex ARGB = 0xFFFFFFFF or FFFFFFFF
		Color := RegExReplace(Color, "i)^0x")
		StringUpper, Color, Color
		If (hasOpacity) {
			RegExMatch(Trim(Color), "i)(^[0-9A-F]{8}$)", hex)	
		} Else {
			RegExMatch(Trim(Color), "i)(^[0-9A-F]{6}$)", hex)
		}
		Return StrLen(hex) ? hex : Default
	}
	
	ValidateOpacity(Opacity, Default, inBase = 16, outBase = 16) {
		;console.log("---------Opacity: " Opacity)
		;console.log("out: " outBase ", in: " inBase)
		; inBase/outBase = 10 or 16
		; valid opacity = (0x00 - 0xFF) or (0-255)		
		Opacity	:= Opacity + 0	; convert string to int
		outBase	:= outBase + 0	; convert string to int
		inBase	:= inBase + 0	; convert string to int
		
		If (not RegExMatch(Opacity, "i)[0-9]+")) {
			;console.log("wrong format | default: " Default)
			Opacity := Default
		}

		If (inBase == 16) {			
			RegExMatch(Trim(Opacity), "i)^0x([0-9A-F]{2})$", match)
			If (match1) {
				;console.log("hex in | opacity: " Opacity)
				Return match1
			} Else {
				;console.log("hex in | default: " Default)
				Return Default
			}
		}
		
		If (Opacity > (inBase == 16 ? 255 : 100)) {
			Opacity := (inBase == 16 ? 255 : 100)
		} Else If (Opacity < 0) {
			Opacity := 0
		}
		
		If ((outBase == 16 and inBase == 16) or (outBase == 10 and inBase == 10)) {
			If (outBase == 10) {
				;console.log("1 (dec in, dec out): " Opacity)	
			} Else {
				;console.log("1 (hex in, hex out): " Opacity)
			}			
			Return Opacity
		}
		Else If (outBase == 16 and inBase == 10) {
			;console.log("2 (dec in, hex out): " Round(Opacity / 100 * 255))
			Return Round(Opacity / 100 * 255)
		}
		Else If (outBase == 10 and inBase 16) {
			;console.log("3 (hex in, dec out): " Round(Opacity / 255 * 100))
			Return Round(Opacity / 255 * 100)
		}
		
		;console.log("return: " Opacity)
		Return Opacity
	}
	
	ValidateInitColors(params) {
		; opacity (dec/hex), color (hex), opacityBase (10/16)
		; ARGB hex
		; A dec (dec/hex base), RGB hex 
		c := params.MaxIndex()
		If ((c < 1 and c > 3 and not StrLen(params))) {
			Throw "Incorrect number of parameters for GdipTooltip.__New() -> ValidateInitColors()"
		}
		
		debugStr := ""
		If (c) {
			Loop, % c
			{
				debugStr .= A_Index = c ? params[A_Index] : params[A_Index] ", "
			}
		} Else {
			debugStr := params
		}
		
		color := 
		op := 
		If (c = 1) {
			color := params[1]
		} Else If (StrLen(params)) {
			color := params
		} Else If (c > 1) {
			color := params[2]
			op := params[1]
		}
		If (c = 3) {
			base := params[3]
		} Else {
			base := 16
		}
		
		inV := RegExReplace(color, "i)^0x")
		r :=
		If (not op) {			
			If (RegExMatch(Trim(inV), "i)(^[0-9A-F]{8}$)")) {
				r := "0x" inV
			}		
		} Else If (RegExMatch(Trim(inV), "i)(^[0-9A-F]{6}$)")) {
			r := inV
		} Else {
			Throw "Invalid color value for GdipTooltip.__New() -> ValidateInitColors(" debugStr ")"
		}
		
		If (op and InStr(op, "0x")) {
			RegExMatch(Trim(op), "i)^0x([0-9A-F]{2})$", hex)
			If (not hex1) {
				Throw "Invalid opacity value for GdipTooltip.__New() -> ValidateInitColors(" debugStr ")"
			}
			r := "0x" hex1 . r
		} Else If (op) {
			op := base = 16 ? op : Round(op / 100 * 255)
			If (op < 0 or op > 255) {
				Throw "Invalid opacity value for GdipTooltip.__New() -> ValidateInitColors(" debugStr ")"
			}
			r := [op, r]
		}
		
		Return r
	}
	
	FHex( int, pad=0 ) {	; Function by [VxE]. Formats an integer (decimals are truncated) as hex.
						; "Pad" may be the minimum number of digits that should appear on the right of the "0x".
		Static hx := "0123456789ABCDEF"
		If !( 0 < int |= 0 )
			Return !int ? "0x0" : "-" this.FHex( -int, pad )
		s := 1 + Floor( Ln( int ) / Ln( 16 ) )
		h := SubStr( "0x0000000000000000", 1, pad := pad < s ? s + 2 : pad < 16 ? pad + 2 : 18 )
		u := A_IsUnicode = 1
		Loop % s
			NumPut( *( &hx + ( ( int & 15 ) << u ) ), h, pad - A_Index << u, "UChar" ), int >>= 4
		Return h
	}
	
	ConvertColorToARGBhex(param) {
		If (StrLen(param)) {
			If (not RegExMatch(param, "i)^0x")) {
				param := "0x" param 
			}
			Return ARGB := param
		}
		Else If (c := param.MaxIndex()) {
			OldMode := A_FormatInteger
			; ARGB = (0xFFFFFFFF) or (FFFFFFFF)
			; A, RGB hex = (128, 0xFFFFFF) or (128, FFFFFF)
			; R, G, B = (255, 255, 255)
			; A, R, G, B = (128, 255, 255, 255)
			If (c = 1)
			{				
				ARGB := param[1]
				;console.log("1: " ARGB)
			}
			Else If (c = 2)
			{	
				If (not RegExMatch(param[2], "i)^0x")) {
					param[2] := "0x" param[2] 
				}
				A := param[1]
				R := ((param[2] & 0xFF0000) >> 16)
				G := ((param[2] & 0xFF00) >> 8)
				B := (param[2] & 0xFF)
				
				SetFormat, Integer, Hex
				ARGB := (A << 24) | (R << 16) | (G << 8) | B
				;console.log("2: " ARGB)
			}
			Else If (c = 3)
			{
				SetFormat, Integer, Hex
				ARGB := (255 << 24) | (param[1] << 16) | (param[2] << 8) | param[3]
				;console.log("3: " ARGB)
			}
			Else If (c = 4)
			{
				SetFormat, Integer, Hex
				ARGB := (param[1] << 24) | (param[2] << 16) | (param[3] << 8) | param[4]
				;console.log("4: " ARGB)
			}
			Else
				Throw "Incorrect number of parameters for GdipTooltip.ConvertColorToARGB()"
			
			SetFormat, Integer, % OldMode
			A := (0xff000000 & ARGB) >> 24
			R := not StrLen(R) ? (0x00ff0000 & ARGB) >> 16 : R
			G := not StrLen(G) ? (0x0000ff00 & ARGB) >> 8 : G
			B := not StrLen(B) ? 0x000000ff & ARGB : B
		}
		
		Return ARGB
	}
	
	ChangeLuminosity(c, l = 0) {
		black := 0
		white := 255
		
		If (l > 0) {
			l := l > 1 ? 1 : l
		} Else {
			l := l < -1 ? -1 : l
		}
		
		c := Round(this.Min(this.Max(0, c + (c * l)), 255))	
		;c := this.Min(this.Max(black, c + (l * white)) , white)
		Return Round(c)
	}
	
	Min(x,x1="",x2="",x3="",x4="",x5="",x6="",x7="",x8="",x9="") { 
		Loop 
			IfEqual x%A_Index%,,Break 
			Else If (x  > x%A_Index%) 
				x := x%A_Index% 
		Return x 
	}
	
	Max(x,x1="",x2="",x3="",x4="",x5="",x6="",x7="",x8="",x9="") { 
		Loop 
			IfEqual x%A_Index%,,Break 
			Else If (x  < x%A_Index%) 
				x := x%A_Index% 
		Return x 
	}
	
	GetActiveMonitorInfo(ByRef X, ByRef Y, ByRef Width, ByRef Height) {
		; retrieves the size of the monitor, the mouse is on	
		CoordMode, Mouse, Screen
		MouseGetPos, mouseX , mouseY
		SysGet, monCount, MonitorCount
		Loop %monCount%
		{ 	SysGet, curMon, Monitor, %a_index%
			If ( mouseX >= curMonLeft and mouseX <= curMonRight and mouseY >= curMonTop and mouseY <= curMonBottom )
			{
				X      := curMonTop
				y      := curMonLeft
				Height := curMonBottom - curMonTop
				Width  := curMonRight  - curMonLeft
				Return
			}
		}
	}
}