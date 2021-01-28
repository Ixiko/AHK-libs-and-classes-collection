SetBatchLines, -1
#include SVGraph.ahk
#include *i <Gdip>

Plots := [], locked := False

Gui, 1:New, +Resize, SVGraph
Gui, Add, Text, x+m y+m, FunX
Gui, Add, Combobox, ys-2 w200 vEditX, x||Math.sin(x)|Math.cos(x)|Math.pow(x,2)/100 + 0.1|Math.pow(x,3)/100 + Math.pow(x,2)/100 + x/100
Gui, Add, Text, ys x+20, FunY
Gui, Add, Combobox, ys-2 w200 vEditY, Math.sin(x)||Math.cos(x)|Math.pow(x,2)/100 + 0.1|Math.pow(x,3)/100 + Math.pow(x,2)/100 + x/100|x
Gui, Add, Text, ys x+20, Colour
Gui, Add, Combobox, ys-2 w70 vColour, #0000FF||#FF0000|#00FF00
Gui, Add, Text, ys x+20, Resolution
Gui, Add, Edit, ys-2 w70 vResolution, 200
Gui, Add, Text, ys x+20, Axis
Gui, Add, Combobox, ys-2 w70 vAxis, x||y|[min,max]
Gui, Add, Checkbox, ys+3 x+15 vOptimize, Optimize
Gui, Add, Button, ys-2 x+5 gPlot, Plot

Gui, Add, Button, ys-2 x+20 gDeletePlt, Delete

Gui, Add, Text, xs+m Section, xmin
Gui, Add, Edit, ys-2 w70 vxmin gAxes, -10
Gui, Add, Text, ys, xmax
Gui, Add, Edit, ys-2 w70 vxmax gAxes, 10
Gui, Add, Text, ys, ymin
Gui, Add, Edit, ys-2 w70 vymin gAxes, -1
Gui, Add, Text, ys, ymax
Gui, Add, Edit, ys-2 w70 vymax gAxes, 1
Gui, Add, Checkbox, ys+3 x+15 vboxed gAxes, Boxed
Gui, Add, Checkbox, ys+3 x+15 vGrid gGrid, Grid

Gui, Add, Button, ys-2 x+5 gShowMsg vScatter, ScatterImage

Gui, Add, Button, ys-2 x+5 gShowMsg vLable, Labels, Ticks and Margin

Gui, Add, Button, ys-2 x+5 vSave gSave, Save

Gui, Add, Checkbox, ys+3 x+20 vScrollvar gScroll, Scroll

; Call sequence needed before making any plots
Gui, Add, ActiveX, xs w500 h500 vIE, Shell.Explorer
SVGraph_Attach(IE)
SVGraph_Start()

SVGraph_Chart(960, 500, 40)

SVGraph_ShowScrollbar(False)

Gui, Show, AutoSize

;-------------------------------- MSGs ----------------------------------------------

Gui, Scatter:+Owner1
Gui, Scatter:Font, s20
Gui, Scatter:Add, Text, , Scatter Image
Gui, Scatter:Font, s9
Gui, Scatter:Add, Text, y+m, Image:
Gui, Scatter:Add, Edit, x+m vScatterImage
Gui, Scatter:Add, Button, x+m gSelectImage, Browse
Gui, Scatter:Add, Text, xs, Resolution:
Gui, Scatter:Add, Edit, x+m w70 vScatterResolution, 200
Gui, Scatter:Add, Text, xs, Circle Size:
Gui, Scatter:Add, Edit, x+m w40 vScatterSize, 3
Gui, Scatter:Add, Text, xs, Background Colour:
Gui, Scatter:Add, Edit, x+m vScatterBackground, #FFFFFF

Gui Scatter:Add, Button, xs gScatter, Scatter
Gui Scatter:Add, Button, x+m gCancel, Cancel


Gui, Lable:+Owner1
Gui, Lable:Font, s20
Gui, Lable:Add, Text, , Labels and Ticks
Gui, Lable:Font, s9
Gui, Lable:Add, Text, xs, x-lable:
Gui, Lable:Add, Edit, x+m w70 vLableXlable,
Gui, Lable:Add, Text, xs, y-lable:
Gui, Lable:Add, Edit, x+m w70 vLableYlable,
Gui, Lable:Add, Text, xs y+40, Axis:
Gui, Lable:Add, Combobox, x+m w70 vLableXorY, ||x|y
Gui, Lable:Add, Text, xs, Approx # of Ticks:
Gui, Lable:Add, Combobox, x+m w70 vLableMajor, 10||[-5,0,5]
Gui, Lable:Add, Text, xs, # of Minor Ticks:
Gui, Lable:Add, Edit, x+m w40 vLableMinor, 0
Gui, Lable:Add, Text, xs, Grid Colour:
Gui, Lable:Add, Combobox, x+m vLableColour, lightgrey||#FF00FF
Gui, Lable:Add, Text, xs, Grid Style:
Gui, Lable:Add, Combobox, x+m vLableDasharray, 5||0|1,1,1,5,3,3

Gui, Lable:Add, Text, xs y+40, Margin:
Gui, Lable:Add, Combobox, x+m w150 vLableMargin, 40||{top: , left: , bottom: , right: }

Gui, Lable:Add, Button, xs gLable, Set
Gui, Lable:Add, Button, x+m gCancel, Cancel
return

;-------------------------------------------------------------------------------------

GuiSize:
	if(!locked){
		GuiControlGet, top, Pos, Save
		GuiControlGet, side, Pos, IE
		GuiControl, Move, IE, % "w" A_GuiWidth - 2*sideX " h" A_GuiHeight - (topY + 2*sideX)
		SVGraph_UpdateChart(A_GuiWidth - 2*sideX - 20, A_GuiHeight - topY - 2*sideX - 20)
		SetTimer, Axes, -100
	}
return

Axes:
	if(!locked){
		Gui, Submit, NoHide
		SVGraph_SetAxes(xmin, xmax, ymin, ymax, boxed)
		SVGraph_RemovePath()
		IE.Document.parentWindow.eval("plot.ID = 0;")
		for index, plot in Plots {
			SVGraph_LinePlot(plot[1], plot[2], plot[3], plot[4], plot[5], plot[6])
		}
	}
return

Scroll:
	Gui, Submit, NoHide
	SVGraph_ShowScrollbar(Scrollvar)
return

Grid:
	Gui, Submit, NoHide
	SVGraph_ShowGrid(Grid)
return

Save:
	Gui, Submit, NoHide
	if("D" != FileExist("\SVGs")){
		FileCreateDir, SVGs
	}
	FileSelectFile, FileName, S16, % "\SVGs\" Get_Unique_Name("SVGs\plot.svg"), Save SVG, *.svg
	if(FileName){
		SVGraph_SaveSVG(FileName)
	}
return

Plot:
	Gui, Submit, NoHide
	SVGraph_LinePlot(EditX, EditY, Colour ? Colour : "#999", Resolution, Axis, Optimize)
	Plots.Push([EditX, EditY, Colour ? Colour : "#999", Resolution, Axis, Optimize])
return

DeletePlt:
	Plots.Pop()
	SVGraph_RemovePath(-1)
return

;-------------------------------- MSGs ----------------------------------------------

ShowMsg:
	GuiControlGet, Ctrl, FocusV
	Gui, %Ctrl%:Show, AutoSize
return

Cancel:
	Gui, %A_Gui%:Show, Hide
return

SelectImage:
	FileSelectFile, image, , , Select Image
	GuiControl, , ScatterImage, %image%
return

Scatter:
	Gui, Scatter:Submit
	ScatterImage(ScatterImage, ScatterResolution, ScatterSize, ScatterBackground)
return

Lable:
	Gui, Lable:Submit
	SVGraph_UpdateChart(, , LableMargin)
	SVGraph_SetLabels(LableXlable, LableYlable)
	SVGraph_SetGrid(LableXorY, LableMajor, LableMinor, LableColour, LableDasharray)
return

;-------------------------------------------------------------------------------------

GuiClose:
GuiEscape:
	ExitApp

ScatterImage(image, axisResolution, size := 3, background := "#FFFFFF"){
	Global locked
	Static Gdip_Startup := Func("Gdip_Startup")
		 , Gdip_CreateBitmapFromFile := Func("Gdip_CreateBitmapFromFile")
		 , Gdip_GetImageWidth := Func("Gdip_GetImageWidth")
		 , Gdip_GetImageHeight := Func("Gdip_GetImageHeight")
		 , Gdip_GetPixel := Func("Gdip_GetPixel")
		 , Gdip_DisposeImage := Func("Gdip_DisposeImage")
		 , Gdip_Shutdown := Func("Gdip_Shutdown")
	
	if(Gdip_Startup && Gdip_CreateBitmapFromFile && Gdip_GetImageWidth && Gdip_GetImageHeight && Gdip_GetPixel && Gdip_DisposeImage && Gdip_Shutdown){
		locked := True
		icon := {}
		pToken := Gdip_Startup.Call()
		pBitmap := Gdip_CreateBitmapFromFile.Call(image)
		xmax := Gdip_GetImageWidth.Call(pBitmap)
		ymax := Gdip_GetImageHeight.Call(pBitmap)
		step := (xmax > ymax ? xmax : ymax) / axisResolution

		SVGraph_UpdateChart(xmax, ymax)
		SVGraph_SetAxes(0, xmax, 0, ymax, True)

		loop %axisResolution% {
			y := (A_Index - 1) * step
			loop %axisResolution% {
				x := (A_Index - 1) * step
				if(((c := ARGBtoRGB(Gdip_GetPixel.Call(pBitmap, x, y)))[1] != 0) && c[2] != background){
					if(!icon.HasKey(c[2])){
						icon[c[2]] := {}
					}
					if(!icon[c[2]].HasKey(c[1])){
						icon[c[2]][c[1]] := {"x" : [], "y" : []}
					}
					icon[c[2]][c[1]]["x"].Push(x)
					icon[c[2]][c[1]]["y"].Push(ymax - y)
				}
			}
			ToolTip, % (y < ymax ? y / ymax : 1) * 100 . "%"
		}
		Gdip_DisposeImage.Call(pBitmap)
		Gdip_Shutdown.Call(pToken)
		
		Group := SVGraph_Group("image")
		
		for colour, list in icon {
			for opacity, coords in list {
				SVGraph_ScatterPlot(coords["x"], coords["y"], colour, size, opacity, False, Group)
			}
		}
		ToolTip
	} else {
		MsgBox, Can't find Gdip.ahk in your Library.
	}
	locked := False
}

ARGBtoRGB(ARGB) {
	ARGB := Format("0x{:08X}", ARGB)
	Return [SubStr(ARGB, 1, 4) / 0xFF, Format("#{:06X}", "0x" SubStr(ARGB, 5))]
}

Get_Unique_Name(FileName, Directory := False){
	SplitPath, FileName, , Dir, Ext, Name
	if(!Directory){
		Directory := InStr(Dir, ":") ? Dir : A_WorkingDir "\" Dir
	}
	if(SubStr(Directory, 0) != "\"){
		Directory .= "\"
	}
	While Exist(Directory . Name . (index ? " (" . index . ")." : ".") . Ext) {
		index := A_Index
	}
	Return Name . (index ? " (" . index . ")." : ".") . Ext
}

Exist(path){
	IfExist, %path%
		Return 1
	Return 0
}
	