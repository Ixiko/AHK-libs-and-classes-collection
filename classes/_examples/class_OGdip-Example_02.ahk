#Include OGdip.ahk
Gdip.Startup()

; I'm wrapping everything into function so I don't have
; to deal with deleting objects myself before shutdown.

GdipExampleFunction_02() {
	bmpCanvas := new Gdip.Bitmap(256, 256)
	bmpCanvas.G.Clear(0xFFFFFFFF)
	bmpCanvas.G.SetOptions("+Antialias +Pixel")  ; Enable antialiasing and half-pixel offset

	myPen := new Gdip.Pen(Gdip.RGBA(224, 0, 0), 4)

	; Showcase of brushes and pens
	bmpCanvas.G.SetPen(myPen)
	bmpCanvas.G.SetBrush(Gdip.RGBA(255, 224, 0))  ; Yellow solid brush
	bmpCanvas.G.DrawRectangle(16, 16,  64, 64)
	; Hatch brush
	bmpCanvas.G.Brush := new Gdip.Brush("HATCH", "D/", Gdip.RGBA(128, 160, 255), Gdip.RGBA(255, 224, 0))
	bmpCanvas.G.DrawRectangle(96, 16,  64, 64)
	; Linear gradient brush
	bmpCanvas.G.Brush := new Gdip.Brush([Gdip.RGBA(128, 160, 255), Gdip.RGBA(255, 224, 0)],  16, 16, 16, 80)
	bmpCanvas.G.Brush.SetGammaCorrection(1)
	bmpCanvas.G.DrawRectangle(176, 16,  64, 64)

	; Showcase of LineJoin types
	bmpCanvas.G.Pen.SetWidth(16)
	bmpCanvas.G.DrawLine(16+0*80, 100,  72+0*80, 100,  24+0*80, 156,  80+0*80, 156)

	bmpCanvas.G.Pen.SetLineJoin("Bevel")
	bmpCanvas.G.DrawLine(16+1*80, 100,  72+1*80, 100,  24+1*80, 156,  80+1*80, 156)

	bmpCanvas.G.Pen.SetLineJoin("Round")
	bmpCanvas.G.DrawLine(16+2*80, 100,  72+2*80, 100,  24+2*80, 156,  80+2*80, 156)

	; Dash styles, compound-array and custom caps
	bmpCanvas.G.Pen.SetWidth(4)
	bmpCanvas.G.Pen.SetDash("DashDotDot")
	bmpCanvas.G.Pen.SetCaps("", "", ">")  ; Set dash caps
	bmpCanvas.G.Brush := ""
	bmpCanvas.G.DrawRectangle(16, 176,  64, 64)

	bmpCanvas.G.Pen.SetColor( Gdip.RGBA(0,0,160) )
	bmpCanvas.G.Pen.SetWidth(8)
	bmpCanvas.G.Pen.SetDash([2, 0.5], -0.5)  ; Set custom dash pattern and offset
	bmpCanvas.G.Pen.SetCaps("Round*", "Arrow", "Flat")  ; Set start, end and dash caps
	bmpCanvas.G.DrawArc(16+1*80, 176,  64, 64,  -135, -270)


	pathCap := new Gdip.Path()
	pathCap.AddPolygon(1,0, 3,2, 3,4, 2,5, 2,3, 1,2, -1,2, -2,3, -2,5, -3,4, -3,2, -1,0)
	pathCap.TransformScale(0.25, 0.25)
	pathCap.TransformMove(0, -0.5)  ; Path must intercept -Y axis

	arrowCap := {width: 2, height: 2, filled: 1, inset: 0.5}

	pathTurns := new Gdip.Path()
	pathTurns.AddLine(0, 0,  48, 0)
	pathTurns.AddArc(32, 0,  32, 32,  -90, 180)
	pathTurns.AddLine(48, 32,  16, 32)
	pathTurns.AddArc(0, 32,  32, 32,  -90, -180)
	pathTurns.AddLine(16, 64,  64, 64)
	pathTurns.TransformMove(2*80+16, 2*80+16)

	bmpCanvas.G.Pen := new Gdip.Pen(Gdip.RGBA(32,48,80))
	bmpCanvas.G.Pen.SetWidth(8, [0.0, 0.4, 0.6, 1.0])  ; Set compound array: two parallel lines
	bmpCanvas.G.Pen.SetCaps(pathCap, arrowCap)
	bmpCanvas.G.DrawPath(pathTurns)

	bmpCanvas.SaveToFile("Example_02.tif")
}

; Call the function
GdipExampleFunction_02()

Gdip.Shutdown()