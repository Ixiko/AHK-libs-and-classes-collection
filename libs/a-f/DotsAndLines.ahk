#SingleInstance, Force
#NoEnv
SetBatchLines, -1

; Start gdi+
If !pToken := Gdip_Startup()
{
    MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
    ExitApp
}
OnExit, ExitSub

Gui, +hWndhWnd
Gui, Show, w500 h500

hDC_Window := GetDC(hWnd)
hDC := CreateCompatibleDC()
hDIB := CreateDIBSection(500, 500)
SelectObject(hDC, hDIB)
pGraphics := Gdip_GraphicsFromHDC(hDC)
Gdip_SetSmoothingMode(pGraphics, 4)

Clust := new Cluster(10, pGraphics, hDC, hDC_Window)

OnMessage(0xF, "WM_PAINT")
OnMessage(0x200, "WM_MOUSEMOVE")
OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x202, "WM_LBUTTONUP")
OnMessage(0x205, "WM_RBUTTONUP")
return

WM_PAINT(wParam, lParam, Msg, hWnd)
{
	global Clust, pGraphics, hDC, hDC_Window
	Clust.Draw()
}

WM_LBUTTONDOWN(wParam, lParam, Msg, hWnd)
{
	global Dragging
	global Clust
	
	x := lParam & 0xFFFF
	y := lParam >> 16 & 0xFFFF
	
	for each, Dot in Clust.Dots 
		if ((x-Dot.x)**2 + (y-Dot.y)**2 < Dot.r**2)
			return (0, Dragging := Dot)
}

WM_RBUTTONUP(wParam, lParam, Msg, hWnd)
{
	global Dragging
	global Clust
	
	x := lParam & 0xFFFF
	y := lParam >> 16 & 0xFFFF
	
	for Index, Dot in Clust.Dots 
		if ((x-Dot.x)**2 + (y-Dot.y)**2 < Dot.r**2)
			return (0, Clust.Dots.Remove(Index), Clust.Draw())
	
	Clust.Dots.Insert(new Dot(x, y, 6))
	Clust.Draw()
}

WM_LBUTTONUP(wParam, lParam, Msg, hWnd)
{
	global Dragging
	Dragging := ""
}

WM_MOUSEMOVE(wParam, lParam, Msg, hWnd)
{
	static MK_LBUTTON := 1
	global Dragging, Clust
	
	if (wParam & MK_LBUTTON)
	{
		x := lParam & 0xFFFF
		y := lParam >> 16 & 0xFFFF
		Dragging.x := x, Dragging.y := y
		Clust.Draw()
	}
}

GuiClose:
ExitApp
return

ExitSub:
Gdip_DeleteGraphics(pGraphics)
DeleteObject(hDIB)
DeleteDC(hDC)
ReleaseDC(hDC_Window)
Gdip_Shutdown(pToken)
ExitApp

class Cluster
{
	__New(Size, pGraphics, hDC, hDC_Window)
	{
		this.Dots := []
		Loop, % Size
		{
			Random, x, 100, 400
			Random, y, 100, 400
			this.Dots.Insert(new Dot(x, y, 6))
		}
		this.pGraphics := pGraphics
		this.hDC := hDC
		this.hDC_Window := hDC_Window
		
		this.Pens := []
		this.Pens.Small := Gdip_CreatePen(0xFFFF0000, 1)
		this.Pens.Medium := Gdip_CreatePen(0xFFFF0000, 3)
		this.Pens.Large := Gdip_CreatePen(0xFFFF0000, 5)
		
		this.Draw()
	}
	
	Draw()
	{
		pBrush := Gdip_BrushCreateSolid(0xFF000000)
		Gdip_FillRectangle(this.pGraphics, pBrush, 0, 0, 500, 500) 
		Gdip_DeleteBrush(pBrush)
		
		for Index, Dot in this.Dots
		{
			Loop, % this.Dots.MaxIndex()-Index
			{
				c2 := sqrt( (Dot.x-this.Dots[Index+A_Index].x)**2 + (Dot.y-this.Dots[Index+A_Index].y)**2 )
				
				if (c2 <  60)
					pPen := this.Pens.Large
				else if (c2 < 180)
					pPen := this.Pens.Medium
				else
					pPen := this.Pens.Small
				Gdip_DrawLine(this.pGraphics, pPen, Dot.x, Dot.y, this.Dots[Index+A_Index].x, this.Dots[Index+A_Index].y)
			}
		}
		
		pBrush := Gdip_BrushCreateSolid(0xFF0000FF)
		for each, Dot in this.Dots
			Dot.Draw(this.pGraphics, pBrush)
		Gdip_DeleteBrush(pBrush)
		BitBlt(this.hDC_Window, 0, 0, 500, 500, this.hDC, 0, 0)
	}
}

class Dot
{
	__New(x, y, r)
	{
		this.x := x
		this.y := y
		this.r := r
		this.d := r*2
	}
	
	Draw(pGraphics, pBrush)
	{
		x := this.x - this.r
		y := this.y - this.r
		Gdip_FillEllipse(pGraphics, pBrush, x, y, this.d, this.d)
	}
}