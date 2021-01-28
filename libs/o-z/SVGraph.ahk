
SVGraph_Attach(ActiveX := False){
	Static IE
	if(ActiveX){
		IE := ActiveX
	}
	return IE
}

SVGraph_Start(dir := ""){
	SVGraph_Attach().Navigate((dir ? dir : A_ScriptDir) "\SVGraph.html")
	While SVGraph_Attach().ReadyState != 4 || SVGraph_Attach().Busy {
		Sleep, 20
	}
}

SVGraph_Chart(Width, Height, Margin := 40){
	Width := (__IsNum(Width) ? Width : 500), Height := (__IsNum(Height) ? Height : 500), Margin := (__IsNum(Margin) ? Margin : 40)
	SVGraph_Attach().Document.parentWindow.eval("var plot = new Chart(" Width "," Height "," Margin ");")
}

;---------------------------------------------------------------------------------------------------------------------------------

SVGraph_UpdateChart(Width := "", Height := "", Margin := ""){
	SVGraph_Attach().Document.parentWindow.eval("plot.Update(" __IsDefined(Width) "," __IsDefined(Height) "," __IsDefined(Margin) ");")
}

SVGraph_RemovePath(index := ""){
	SVGraph_Attach().Document.parentWindow.eval("plot.RemovePath(" __IsDefinedNum(index) ");")
}

SVGraph_ShowGrid(Bool := True){
	SVGraph_Attach().Document.parentWindow.eval("plot.Axes.Grid(" (Bool = True) ");")
}

SVGraph_ShowScrollbar(Bool := False){
	SVGraph_Attach().Document.body.style.overflow := Bool ? "visible" : "hidden"
}

SVGraph_ShowAxes(Bool := True){
	SVGraph_Attach().Document.parentWindow.eval("plot.Axes.HideAxes(" (Bool = True) ");")
}

;---------------------------------------------------------------------------------------------------------------------------------

SVGraph_SetAxes(xmin := "", xmax := "", ymin := "", ymax := "", Boxed := False){
	xmin := __IsDefinedNum(xmin), xmax := __IsDefinedNum(xmax), ymin := __IsDefinedNum(ymin), ymax := __IsDefinedNum(ymax)
	SVGraph_Attach().Document.parentWindow.eval("plot.SetAxes(" xmin "," xmax "," ymin "," ymax "," Boxed ");")
}

SVGraph_SetGrid(xory := "", Major := "", Minor := "", Colour := "", DashArray := ""){
	SVGraph_Attach().Document.parentWindow.eval("plot.Axes.SetGrid(""" xory """," __IsDefined(Major) "," __IsDefined(Minor) "," __IsDefined("""" Colour """") "," __IsDefined("""" DashArray """") ");")
}

SVGraph_SetLabels(xLabel := "", yLabel := ""){
	SVGraph_Attach().Document.parentWindow.eval("plot.Axes.SetLabels(" __IsDefined("""" xLabel """") "," __IsDefined("""" yLabel """") ");")
}

SVGraph_MakeLegend(Data := "", Colour := ""){
	StrColor := Colour ? ObjectToString(Colour) : "undefined"
	StrData  := Data   ? ObjectToString(Data)   : "undefined"
	
	SVGraph_Attach().Document.parentWindow.eval("plot.MakeLegend(" StrData "," StrColor ");")
}

;---------------------------------------------------------------------------------------------------------------------------------

SVGraph_LinePlot(FunX, FunY, Colour := "#999", Width := 4, Resolution := 0, Axis := "x", Optimize := True){
	Axis := InStr(Axis, "[") ? Axis : """" Axis """"
	SVGraph_Attach().Document.parentWindow.eval("plot.LinePlot(""" FunX """,""" FunY """,""" Colour """,""" Width """," Resolution "," Axis "," Optimize ");")
}

SVGraph_LinePlot2(LstX, LstY, Colour := "#999", Width := 4, ScaleAxes := False, Curve := ""){
	StrX := ObjectToString(LstX), StrY := ObjectToString(LstY), Curve := __IsDefined("""" Curve """")
	SVGraph_Attach().Document.parentWindow.eval("plot.LinePlot2(" StrX "," StrY ",""" Colour """,""" Width """," ScaleAxes "," Curve ");")
}

SVGraph_ScatterPlot(LstX, LstY, Colour := "#999", Size := 4, Opacity := 1, ScaleAxes := False, Group := False){
	Group := Group ? Group : "undefined"
	StrX := ObjectToString(LstX), StrY := ObjectToString(LstY)
	SVGraph_Attach().Document.parentWindow.eval("plot.ScatterPlot(" StrX "," StrY ",""" Colour """,""" Size """," Opacity "," ScaleAxes "," Group ");")
}

SVGraph_BarPlot(Data, Colour := "", Width := 10, Axis := "x", Opacity := 1){
	StrColor := Colour ? ObjectToString(Colour) : "undefined"
	StrData  := ObjectToString(Data)
	SVGraph_Attach().Document.parentWindow.eval("plot.BarPlot(""" Axis """," StrData "," StrColor ",""" Width """," Opacity ");")
}

;---------------------------------------------------------------------------------------------------------------------------------

SVGraph_SaveSVG(Filename){
	Critical
	SVG := FileOpen(Filename, "w")
	SVG.Write(SVGraph_FormatXML(SVGraph_Attach().Document.getElementById("svg").outerHTML))
	SVG.Close()
}

SVGraph_Group(ID){
	SVGraph_Attach().Document.parentWindow.eval("var " ID " = plot.NewGroup(""" ID """);")
	return ID
}

SVGraph_FormatXML(XML){
	SvgLst := StrSplit(RegExReplace(XML, "(`r|`n|`t)*"), "<")
	SvgLst.Delete(1)
	XML := ""
	for index, str in SvgLst {
		newLn := True
		str := "<" str
		RegExMatch(str, "<.*?>", tag)
		
		if(InStr(tag, "</")) {
			tab := SubStr(tab, 2)
			if(preTag = StrReplace(tag, "/")){
				newLn := False
			}
		}
		
		XML .= (newLn ? "`n" tab : "") str
		
		if((!InStr(tag, "/>") && !InStr(tag, "</"))) {
			tab .= "`t"
			if(pos := InStr(tag, " ")){
				tag := SubStr(tag, 1, pos - 1) ">"
			}
			preTag := tag
		} else {
			preTag := ""
		}
	}
	return SubStr(XML, 2)
}

SVGraph_MiniFormatXML(XML){
	SvgLst := StrSplit(RegExReplace(XML, "(`r|`n|`t)*"), "<")
	SvgLst.Delete(1)
	XML := "", opacity := True, bool := False
	for index, str in SvgLst {
		newLn := True
		str := "<" str
		RegExMatch(str, "<.*?>", tag)
		
		if(InStr(tag, "opacity=""0""") && !InStr(tag, "/>")){
			opacity := False
			if(pos := InStr(tag, " ")){
				opacityTag := SubStr(tag, 1, pos - 1) ">"
			}
		}
		
		if(InStr(tag, "</")) {
			tab := SubStr(tab, 2)
			if(preTag = StrReplace(tag, "/")){
				newLn := False
			}
		}
		
		XML .= (opacity && !InStr(str, "opacity=""0""") ? (newLn ? "`n" tab : "") str : "")
		
		if(!opacity && InStr(tag, "</") && opacityTag = StrReplace(tag, "/")) {
			MsgBox, % tag "`n" preTag
			opacity := True
		}
		
		if((!InStr(tag, "/>") && !InStr(tag, "</"))) {
			tab .= "`t"
			if(pos := InStr(tag, " ")){
				tag := SubStr(tag, 1, pos - 1) ">"
			}
			preTag := tag
		} else {
			preTag := ""
		}
	}
	return SubStr(XML, 2)
}

__IsNum(Num){
	if Num is Number
		return 1
	return 0
}

__IsDefined(val){
	if(val = "" || val = """""")
		return "undefined"
	return val
}

__IsDefinedNum(Num){
	if Num is Number
		return Num
	return "undefined"
}

ObjectToString(obj){
	if(!IsObject(obj)){
		return __IsNum(obj) ? obj : """" obj """"
	}
	res .= "["
	for key, value in obj {
		res .= ObjectToString(value) ","
	}
	return SubStr(res, 1, -1) "]"
}

