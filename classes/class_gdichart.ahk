
class gdichart
{
	static Margin:=Object()
	static dash:=5	;默认虚线单位线长
	static blank:=2	;默认虚线单位空白长
	static pieR:=3	;默认折线图数据点尺寸
	static TextOptions:=" s14 r1 cff000000"
	static Font:="Arial"
	__New(hwnd)
	{
		If not hwnd
		Exit
		this.hwnd:=hwnd
		GuiControlGet, Control, Pos, %hwnd%
		this.w:=Controlw
		this.h:=Controlh
		this.Margin["left"]:=Round(this.w*0.1)
		this.Margin["right"]:=Round(this.w*0.05)
		this.Margin["top"]:=Round(this.h*0.05)
		this.Margin["bottom"]:=Round(this.h*0.15)
		Try
		{
			If(!this.pToken := Gdip_Startup())
			Throw Gdi库初始化失败。
		}
		Catch e
		{
			MsgBox, %e%
			ExitApp
		}
		this.pBitmap := Gdip_CreateBitmap(this.w, this.h)
		, this.G := Gdip_GraphicsFromImage(this.pBitmap)
		, Gdip_SetSmoothingMode(this.G, 4)
		, Gdip_SetInterpolationMode(this.G, 7)
		pBrush:=Gdip_BrushCreateSolid(0xf0ffffff)
		Gdip_FillRectangle(this.G, pBrush, -1, -1, Controlw+1,Controlh+1)
		Gdip_DeleteBrush(pBrush)
	}
	
	__Delete()
	{
		Gdip_Shutdown(this.pToken)
	}
	
	_Axis()
	{
		pPenLine:=Gdip_CreatePen(0xff000000, 2)
		Gdip_DrawLine(this.G, pPenLine, this.Margin["left"], this.h-this.Margin["bottom"]
		, this.Margin["left"], this.Margin["top"])
		Gdip_DrawLine(this.G, pPenLine, this.Margin["left"], this.Margin["top"]+5
		, this.Margin["left"]-2, this.Margin["top"]+15)
		Gdip_DrawLine(this.G, pPenLine, this.Margin["left"], this.Margin["top"]+5
		, this.Margin["left"]+2, this.Margin["top"]+15)
		
		Gdip_DrawLine(this.G, pPenLine, this.Margin["left"], this.h-this.Margin["bottom"]
		, this.w-this.Margin["right"], this.h-this.Margin["bottom"])
		Gdip_DrawLine(this.G, pPenLine, this.w-this.Margin["right"]-5, this.h-this.Margin["bottom"]
		, this.w-this.Margin["right"]-15, this.h-this.Margin["bottom"]+2)
		Gdip_DrawLine(this.G, pPenLine, this.w-this.Margin["right"]-5, this.h-this.Margin["bottom"]
		, this.w-this.Margin["right"]-15, this.h-this.Margin["bottom"]-2)
		Gdip_DeletePen(pPenLine)
	}
	
	drawLabel()
	{
		
		yn:=Ceil(this.ygrid/(this.h//36))
		xn:=Ceil(this.xgrid/(this.w//50))
		
		Loop, % this.ygrid//yn
		{
			
			Gdip_TextToGraphics(this.G, this.ycell*A_Index*yn, "x" this.Margin["left"]-35 " y" this.h-this.Margin["bottom"]-yn*this.ydelta*A_Index-7 this.TextOptions, this.Font, this.w, this.h)
		}
		
		Loop, % this.xgrid//xn
		{
			Gdip_TextToGraphics(this.G, this.xcell*A_Index*xn, "x" this.Margin["left"]+A_Index*xn*this.xdelta-15 " y" this.h-this.Margin["bottom"]  this.TextOptions, this.Font, this.w, this.h)
		}
		
	}
	
	
	Grid(xgrid=1,ygrid=1)
	{
		
		pPenLine:=Gdip_CreatePen(0xff000000, 1.5)
		pPenH:=Gdip_CreatePen(0xff000000, 2)
		xdelta:=this.w*0.80//xgrid	;xgrid的像素域间距
		If(xgrid>1)
		{
			Loop, % xgrid
			{
				Gdip_DrawLine(this.G, pPenH,this.Margin["left"]+xdelta*A_Index,this.h-this.Margin["bottom"]
				,this.Margin["left"]+xdelta*A_Index,this.h-this.Margin["bottom"]-this.dash-this.blank)
				this._drawDash(this.G,pPenLine,this.Margin["left"]+xdelta*A_Index,this.h-this.Margin["bottom"]
				,this.Margin["left"]+xdelta*A_Index,this.Margin["top"],this.dash,this.blank)
			}
		}
		ydelta:=this.h*0.75//ygrid	;ygrid的像素域间距
		If(ygrid>1)
		{
			Loop, % ygrid
			{
				Gdip_DrawLine(this.G, pPenH,this.Margin["left"],this.h-this.Margin["bottom"]-ydelta*A_Index
				,this.Margin["left"]+this.dash+this.blank,this.h-this.Margin["bottom"]-ydelta*A_Index)
				this._drawDash(this.G,pPenLine,this.Margin["left"],this.h-this.Margin["bottom"]-ydelta*A_Index
				,this.w-this.Margin["right"],this.h-this.Margin["bottom"]-ydelta*A_Index,this.dash,this.blank)
			}
		}
		this.xdelta:=xdelta
		this.ydelta:=ydelta
		this.xgrid:=xgrid
		this.ygrid:=ygrid
		Gdip_DeletePen(pPenLine)
		Gdip_DeletePen(pPenH)
	}
	
	drawData(data,color=0xffff0000)
	{
		If(!data["xmax"])
		Loop, % data["maxindex"]
			this.Xmax:=data["x",A_Index]>this.Xmax?data["x",A_Index]:this.Xmax	;数据域
			Else
			this.Xmax:=data["xmax"]
		If(!data["ymax"])
		Loop, % data["maxindex"]
			this.Ymax:=data["y",A_Index]>this.Ymax?data["y",A_Index]:this.Ymax
			Else
			this.Ymax:=data["ymax"]
		power:=Floor(log(this.Xmax//this.xgrid))
		Loop, 10
		{
			If(A_Index=3 or A_Index=7 Or A_Index=9)
			Continue
			If(10**power*A_Index>=this.Xmax//this.xgrid*0.95)
			{
				this.xcell:=10**power*A_Index	;xgrid的数据域间距
				Break
			}
		}
		power:=Floor(log(this.Ymax//this.ygrid))
		
		Loop, 10
		{
			If(A_Index=3 or A_Index=7 Or A_Index=9)
			Continue
			If(10**power*A_Index>=this.Ymax//this.ygrid*0.95)
			{
				this.ycell:=10**power*A_Index	;ygrid的数据域间距
				Break
			}
		}
		
;~ 		折线图(for line)********************************
		If(data["chart"]="line")
		{
			pPen:=Gdip_CreatePen(color, 2)
			pBrush:=Gdip_BrushCreateSolid(color)
			
			xratio:=this.xdelta/this.xcell	;像素数据比
			yratio:=this.ydelta/this.ycell
			Loop, % data["maxindex"]
			{
				x:=data["x",A_Index]*xratio+this.Margin["left"]
				y:=this.h-this.Margin["bottom"]-data["y",A_Index]*yratio
				
				If(A_Index>1)
				{
					Gdip_DrawLine(this.G, pPen, xp, yp, x, y)
				}
				Gdip_FillPie(this.G, pBrush, x-this.pieR, y-this.pieR, 2*this.pieR,2*this.pieR, 0, 360)
				xp:=x
				yp:=y
			}
			Gdip_DeleteBrush(pBrush)
			Gdip_DeletePen(pPen)
		}
;~ 		柱状图(for bar)********************************
		If(data["chart"]="bar")
		{
			this.yratio:=this.ydelta/this.ycell
			Loop, Parse, color, |
			{
				pBrush_%A_Index%:=Gdip_BrushCreateSolid(A_LoopField)
				colorIndex:=A_Index
				
			}
			barwidth:=Ceil(this.xdelta*0.62/colorIndex)
			Loop, % data["maxindex"]
			{
				i:=A_index
				Loop, % colorIndex
				{
					Gdip_FillRectangle(this.G, pBrush_%A_Index%, this.Margin["left"]+this.xdelta*(i-1+0.19)+(A_Index-1)*barwidth, this.h-this.Margin["bottom"]-data["y" A_Index,i]*this.yratio, barwidth,data["y" A_Index,i]*this.yratio)
				}
			}
			
			Loop, % colorIndex
			Gdip_DeleteBrush(pBrush_%A_Index%)
		}
		this._Axis()
	}
	
	
	show()
	{
		hBitmapx := Gdip_CreateHBITMAPFromBitmap(this.pBitmap)
		SetImage(this.hwnd, hBitmapx)
		DeleteObject(hBitmap)
	}
	
	_drawDash(G, pPen,x1,y1,x2,y2,dash=5,blank=2)
	{
		If(y2!=y1){
			slope:=(x2-x1)/(y2-y1)
			dy:=Sqrt(dash**2/(1+slope**2))
			dx:=dy*slope
			dy*=(y2-y1)/Abs(y2-y1)
			dx*=(x2-x1)/Abs(x2-x1)
			stepy:=dy*(dash+blank)/dash
			stepx:=dx*(dash+blank)/dash
			
			While(x1<x2 Or y1>y2)
			{
				Gdip_DrawLine(G, pPen,x1,y1,(x2-x1-dx)*dx<=0 ? x2 : x1+dx,(y2-y1-dy)*dy<=0 ? y2 : y1+dy)
				If((x2-x1-dx)*dx<=0 And (y2-y1-dy)*dy<=0)
				Break
				x1+=stepx
				y1+=stepy
			}
		}
		If(y2=y1)
		{
			dy:=0
			dx:=dash
			stepy:=0
			stepx:=dash+blank
			While(x1<x2)
			{
				Gdip_DrawLine(G, pPen,x1,y1,x1+dx>=x2?x2:x1+dx,y1)
				x1+=stepx
				y1+=stepy
			}
		}
	}

	version()
	{
		Return, "beta 009"
	}
}
