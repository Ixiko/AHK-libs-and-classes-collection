;Required Lib for use with these Functions:
;=====================================================
;http://ahk4.me/1nrXKSH - Acc Lib Written by Jethrew
;=====================================================
DetectHiddenWindows,On
;Some Excel Constants for use with COM
xlup 				:= -4162
xldown 				:= -4121
xlLeft 				:= -4159
xlRight 				:= -4161
xlFormulas 			:= -4123
xlValues 				:= -4163
xlCenter 				:= -4108
xlCalculationAutomatic 	:= -4105
xlCalculationManual 	:= -4135
xlAscending			:= 1
xlDescending			:= 2
xlSortOnValues			:= 0
xlWhole 				:= 1
xlPart 				:= 2
xlPrevious 			:= 2
xlNext 				:= 1
xlByrows 				:= 1
xlByColumns 			:= 2
xlYes 				:= 1
xlNo 				:= 2

;a(XL_GetHPageBreaks("",""))
;a(XL_GetVPageBreaks("",""))

/*
	sKeys := {}
	sKeys["B","AscDesc"] := xlAscending
	sKeys["B","SortOn"] := xlSortonValues
	
	sKeys["F","AscDesc"] := xldescending
	sKeys["F","SortOn"] := xlSortonValues
	
	;;;{"B":{"AscDesc":"" . xlAscending . "","SortOn":"" . xlSortonValues . ""},"F":{"AscDesc":"" . xlAscending . "","SortOn":"" . xlSortonValues . ""}}
	
	XL_SortColRange("","","A:I",sKeys)
*/

;XL_SortSingleCol("","","B",xlDescending)
;XL_RemoveDuplicates("","","A1:F100")

/*
	xlobj := xl_RangeToObj("","","A1:C20")		;Grab Range A1:C20....Do some stuff
	XL_ObjToRange("","Sheet2","DD50",xlobj)		;Set the object values back to Excel
	
*/

/*
	xlobj := xl_RangeToObj("","","D20:Z25")
	msgbox % "Written like xlobj.D.23:    " . xlobj.D.23 . "`n`nWritten likexlObj[""D"",23]:   " . xlObj["D",23]
	a(xlobj)
*/

;msgbox % XL_VLookup("","Datasheet","0.95","I2:J13",2,0)
;msgbox % XL_GetCell("","","C11","value")

/*
	x := xl_rangefindall("level_temp.xlsm - Excel","","C1:C30","*","C30",xlvalues,xlwhole,xlbycolumns,xlnext,"value")
	for k,v in x
		msgbox % k "`n" v
*/

;msgbox % xl_rangefind("","","F1:F200","6 minutes","F200",xlvalues,xlwhole,xlbycolumns,xlnext,"Row")

;XL_ToPDF("","","A1:E30","C:\test1113.pdf",0)

;XL_Save("",1,"C:\test111.xls")

;XL_SetCell("","","D7","Value1234")

;msgbox % XL_GetLast("","","E299",xlup)



/*
;XL_ToPDF() Function
;=========================================
;Params:
;		
;Name -Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;Sht -Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
;
;Range-Range that will be printed to PDF
;
;PDFPath - Full Pathname where you want PDF to be saved at
;
;Display - 0 to save without displaying, 1 to save and display PDF
;
;==========================================
*/
XL_ToPDF(Name, Sht, Range, PDFPath, Display) {
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ?  xla.activesheet.name : sht) 
	xla.sheets(sht).range(Range).ExportAsFixedFormat(0,PDFPath,0,,,,,Display)
	return
}

/*
;XL_Save() Function
;=========================================
;Params:
;
;Name -Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;New - Save current Workbook or save as a new workbook
;		Values 0,1
;		0 = Save current WB
;		1 = Save as New Workbook (Requires next two params)
;
;Path - Path to save new workbook at(Without Extension)
;
;Ext - Self Explanatory
;		Valid Extensions are xls,xlsx, and xlsm
;
;=========================================
*/
XL_Save(Name,New,Path) {
	xla := XLCheck(Name)
	if xla = False
		return
	
	SplitPath,Path,,,pathext
	if (pathext = "xlsm")
		xtcode = 52
	if (pathext = "xls")
		xtcode = 56
	if (pathext = "xlsx")
		xtcode = 51
	
	if New = 0
		xla.activeworkbook.saved := True
	If New = 1
		xla.activeworkbook.SaveAs(Path,xtcode)
	
	return
}

/*
;XL_GetCell() and XL_SetCell() Functions
;=========================================
;Params:
;		
;Name -Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;Sht -Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
;
;Range-Cell Representing What you want to retrieve/set
;
;Dtype - Only for use with XL_GetCell, any of the following as text string: Value,Text,Formula,Address,Row,Column
;
;GetCell Vs SetCell - Just like it sounds, GetCell returns value of cell specified
;						Set cell puts the value you specify into the cell referenced
;
;==========================================
*/
XL_GetCell(Name,Sht,Range,Dtype) {
	xla := XLCheck(Name)
	if xla = False
		return
	
	sht := ((sht="") ?  xla.activesheet.name : sht) 
	
	return xla.sheets(sht).range(range)[Dtype]
}

XL_SetCell(Name,Sht,Range,Value) {
	xla := XLCheck(Name)
	if xla = False
		return
	
	sht := ((sht="") ?  xla.activesheet.name : sht) 
	
	xla.sheets(sht).range(range) := Value
	return
}

/*
;XL_GetLast() Function
;=========================================
;Params:
;		
;Name -Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;Sht -Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
;
;Range-Cell Representing where you want to start your search from
;		
;Direction - What direction do you want to look for the last used cell in?
;			Valid values: xlleft,xlright,xlup,xldown
;
;usage example:
;	msgbox % XL_GetLast("","","D7",xldown)
;	Will find the last cell used(has a value) that is below cell D7
;=======================================
*/
XL_GetLast(Name,Sht,Range,Direction,Dtype) {
	
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ?  xla.activesheet.name : sht) 
	
	Last := xla.sheets(sht).range(Range).end(Direction)[Dtype]	
	return Last	
}

/*
;XL_RangeFind() Function - Thanks Tidbit ;)
;=========================================
;Params:
;
;Note - This function returns ONE result, dependng on how you set the parameters up
;		If you want to return all results found within a range, use XL_RangeFindAll
;
;Name - Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;Sht - Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
;
;Range - Range representing where you want to 'Fnd' the value e.g. "A1:A100"
;
;What -Pretty straight forward...what are you searching for?
;
;After - You you must it where to start e.g. "A30"
;		This will affect the Search Order Param - See the MSDN for details
;		I normally use the last cell in my rang to search from, otherwise in some cases you may miss the first result
;
;LookIn - One of the options XlValues, or XlFormulas
;
;Lookat - One of the values xlwhole, or xlPart
;
;Order - xlbyrows, or xlbycolumns
;
;Direction - xlnext or xlprevious
;
;Dtype - OAny of the following as text string: Value,Text,Formula,Address,Row,Column
;
;=========================================
*/
XL_RangeFind(Name,Sht,Range,What, After, LookIn,LookAt,Order,Direction,Dtype) {
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ?  xla.activesheet.name : sht) 
	
	return xla.sheets(Sht).range(Range).Find(What,xla.sheets(Sht).range(After),LookIn,Lookat,Order,Direction)[Dtype]
}

/*
;XL_RangeFindAll() Function
;=========================================
;Params:
;
;Note - This function returns ALL Results in Specified Range
;		
;Name -Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;Sht -Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
;
;Range-Range representing where you want to 'Fnd' the value e.g. "A1:A100"
;
;What -Pretty straight forward...what are you searching for?
;
;After - You you must it where to start e.g. "A30"
;		This will affect the Search Order Param - See the MSDN for details
;		I normally use the last cell in my rang to search from, otherwise in some cases you may miss the first result
;
;LookIn - One of the options XlValues, or XlFormulas
;
;Lookat - One of the values xlwhole, or xlPart
;
;Order - xlbyrows, or xlbycolumns
;
;Direction - xlnext or xlprevious
;
;Dtype - Any of the following as text string: Value,Text,Formula,Address,Row,Column
;
;
;=========================================
*/
XL_RangeFindAll(Name,Sht,Range,What, After, LookIn, LookAt, Order, Direction,DType) {
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ?  xla.activesheet.name : sht) 
	
	Rarr := []
	RTS := xla.sheets(Sht).range(Range).Find(What,xla.sheets(Sht).range(After),LookIn,LookAt,Order,direction,1)
	First := RTS.row
	Loop 
	{
		Rarr[A_Index] := RTS[Dtype]
		RTS := xla.sheets(Sht).range(Range).FindNext(RTS)
	}until (RTS.row=First)
	
	return Rarr
} 

/*
;XL_VLookup() Function
;=========================================
;Params:
;		
;Name -Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;Sht -Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
;
;
;What -Pretty straight forward...what are you searching for?
;
;FindRange - The complete range of cells(including column you are searching, and the column which will show the result i.e. A1:D50)
;
;RetCol - which column should the return value come from?  i.e 3 would return the value from column C if our search range was A1:D50
;
;MatchType - 0 or 1 for approximate or exact match.  See MSDN for details:  https://msdn.microsoft.com/en-us/library/office/ff194701.aspx
;
;;=========================================
*/
XL_VLookup(Name,Sht,What,FindRange,RetCol,MatchType)
{
	xla := XLCheck(Name)
	if xla = False
		return
	
	if(regexmatch(what,"[0-9]"))
		what:=what + 0
	
	sht := ((sht="") ?  xla.activesheet.name : sht) 
	return xla.application.VLookup(what, xla.sheets(sht).Range(FindRange),retcol,matchtype)
}

/*
;XL_RemoveDuplicates() Function
;=========================================
;Params:
;		
;Name -Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;Sht -Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
;
;
;Range -Range of columns to remove duplicate rows from...i.e. D1:F100
;
;Header - Default is 2(No headers), can specify xlYes if your columns have Headers
;
;;=========================================
*/
XL_RemoveDuplicates(Name,Sht,Range,hdr:=2)
{
	xla := XLCheck(Name)
	if xla = False
		return
	
	Try
	{
		Speedup(xla,0)
		sht := ((sht="") ? xla.activesheet.name : sht) 
		sArr  := xla.sheets(sht).Range(Range).value
		tColumns:= SArr.MaxIndex(2)					; total columns
		Columns := ComObjArray(0xC, tColumns) 			; Create an array of variants (VT_VARIANT = 0xC)
		Loop % tColumns
			Columns[A_Index-1]:=A_Index
		xla.sheets(sht).Range(Range).RemoveDuplicates(Columns,hdr)
		Speedup(xla,1)
	}
	Catch
	{
		msgbox,Remove Duplicates failed - Check Range Param
		Speedup(xla,1)
	}
	
}

/*
;XL_SortSingleCol() Function
;=========================================
;Params:
;		
;Name -Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;Sht -Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
;
;
;Col - Column to sort...can be of format "B" or 2
;
;AscDesc - xlAscending or xlDescending
;
;;=========================================
*/
XL_SortSingleCol(Name,sht,Col,AscDesc)
{
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ? xla.activesheet.name : sht) 
	
	RegexMatch(col,"i)[a-zA-Z]+",ColumnLetter)
	Coln := (ColumnLetter) ? Converttonumbers(ColumnLetter) : col
	
	xla.sheets(sht).sort.SortFields.Clear()
	xla.sheets(sht).columns(coln).sort(xla.sheets(sht).columns(coln),AscDesc)
}

/*
	;XL_SortColRange() Function
	;=========================================
	;Params:
	;		
	;Name -Specify "" if you want to retrive handle to active excel workbook
	;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
	;
	;Sht -Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
	;
	;
	;RangetoSort -Range to be sorted - i.e. A1:G500 or just A:G
	;
	;SortKeys - An Array with Keys as Columns, and members SortOn, and AscDesc i.e.
	
	sKeys := {}
	sKeys["B","AscDesc"] := xlAscending
	sKeys["B","SortOn"] := xlSortonValues
	
	sKeys["F","AscDesc"] := xldescending
	sKeys["F","SortOn"] := xlSortonValues
	
	;;=========================================
*/
XL_SortColRange(Name,Sht,RangeToSort,SortKeys)
{
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ? xla.activesheet.name : sht) 
	
	xla.sheets(sht).sort.SortFields.Clear()
	for k,v in SortKeys
	{
		RegexMatch(k,"i)[a-zA-Z]+",ColumnLetter)
		Coln := (ColumnLetter) ? Converttonumbers(ColumnLetter) : K
		xla.sheets(sht).sort.SortFields.Add(xla.sheets(sht).columns(Coln),v.SortOn,v.AscDesc)
	}
	
	xla.sheets(sht).sort.setRange(xla.sheets(sht).Range(RangeToSort))
	xla.sheets(sht).sort.Apply()
}

/*
;XL_ToObj() Function
;=========================================
;Params:
;		
;
;Name -Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;Sht -Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
;
;Range - Excel Range to convert to an ahk accesible obj i.e. "D10:J100"
;
;DType - Return an object of the cell ranges VALES, or FORMULAS only - Default is Value, specify "Formula" to return formulas
;
;R1C1 - Return object as A1, A2, A3, etc or 1,1; 1,2; 1,3 - Default is Named Columns i.e A1
;
;;=========================================
*/
XL_RangeToObj(Name,Sht,Range,DType="Value",R1C1="")
{
	xlMap:=[]
	
	xla := XLCheck(Name)
	if xla = False
		return
	
	sht := ((sht="") ?  xla.activesheet.name : sht) 
	sArr  := xla.sheets(sht).Range(Range)[DType]
	
	Rows:= SArr.MaxIndex(1)		; total rows
	Columns:= SArr.MaxIndex(2)	; total columns
	
	ColStart:=xla.sheets(sht).range(StrSplit(Range,":").1).column	;Start Column Index
	RowStart:=xla.sheets(sht).range(StrSplit(Range,":").1).Row		;Start Row Index
	
	
	Loop % Rows
	{
		oCurRowNum := (A_Index-1) + RowStart
		CurRowNum := A_Index
		Loop % Columns
		{
			aStart := (a_Index-1) + ColStart
			CurrentCol := (R1C1) ? aStart : ConvertToLetter(aStart)
			xlMap[CurrentCol,oCurRowNum]:=SArr[CurRowNum, A_Index]
		}
	}
	return xlmap
}

/*
;XL_ObjToRange() Function
;=========================================
;Params:
;		
;
;Name -Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;Sht -Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
;
;Range - Excel Range upper left corner you want the data to start in i.e "A1"
;
;obj - an AHK array where keys are Columns, and values are rows i.e (XL_RangeToObj returns an array in this format)
;
;;=========================================
*/
XL_ObjToRange(Name,Sht,Range,obj)
{
	NewObj:=[]
	xla := XLCheck(Name)
	if xla = False
		return
	
	Speedup(xla,0)
	Try
	{
		sht := ((sht="") ?  xla.activesheet.name : sht) 	
		newobj := ConvertToRowKeys(obj)
		
		RegexMatch(Range,"i)[a-zA-Z]+",ColumnLetter)
		RegexMatch(Range,"i)[0-9]+",RowNumber)
		
		For All,Rows in Newobj
		{
			col:=A_Index-1
			t:=
			r=0
			for each,Column in Rows
			{
				t .=  column "`t"
				r++				
			}
			xla.sheets(sht).range(ColumnLetter . RowNumber + col) := t
			xla.sheets(sht).range(ColumnLetter . RowNumber + col).TextToColumns(xla.sheets(sht).Range(ColumnLetter . RowNumber + col),1,-4142,0,1,0,0,0,0)
		}
		Speedup(xla,1)
	}
	Catch
	{
		Speedup(xla,1)
	}
}

/*
;XL_GetHPageBreaks() Function
;=========================================
;Params:
;		
;
;Name -Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;Sht -Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
;
;Returns object with each key as row of horizontal page break location
;;=========================================
*/
XL_GetHPageBreaks(Name,Sht)
{
	Obj := {}
	
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ?  xla.activesheet.name : sht)
	
	Try
	{
		Speedup(xla,0)
		xla.application.activewindow.view := 2
		pb := xla.sheets(sht).HPageBreaks
		Loop % pb.Count
			Obj[A_Index] := pb.Item(A_Index).Location.Row
		xla.application.activewindow.view := 1
		Speedup(xla,1)
	}
	Catch
	{
		Speedup(xla,1)
		return "Err Getting Horizontal Page Breaks"
	}
	return Obj
}

/*
;XL_GetVPageBreaks() Function
;=========================================
;Params:
;		
;
;Name -Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;Sht -Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
;
;rType - Default returns Column Letter, specify '1' to return column numbers instead
;
;Returns object with each key as Column/Letter of horizontal page break location
;;=========================================
*/
XL_GetVPageBreaks(Name,Sht,rType:="")
{
	Obj := {}
	
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ?  xla.activesheet.name : sht)
	
	Try
	{
		Speedup(xla,0)
		xla.application.activewindow.view := 2
		pb := xla.sheets(sht).VPageBreaks
		Loop % pb.Count
			Obj[A_Index] := (rType) ? pb.Item(A_Index).Location.Column : ConvertToLetter(pb.Item(A_Index).Location.Column)
		xla.application.activewindow.view := 1	
		Speedup(xla,1)
	}Catch{
		Speedup(xla,1)
		return "Err Getting Vertial Page Breaks"	
	}
	return obj
}

XL_ListWorkbooks()
{
	wbObj:=[]
	i=1
	for name, obj in GetActiveObjects()
		if (ComobjType(obj, "Name") = "_Workbook"){
			splitpath,name,oFN
			wbObj[i++] := oFN
		}
	return wbObj
}

/*
;Get Handle to Excel Workbook
;==============================
;Param Name="" will get handle to last activated Excel workbook (Credit To Jethrew and SinkFaze for this!)
;Otherwise, specify the full excel workbook name at the end
;ex. Book1.xlsx for workbook Name
;==============================
*/
XLCheck(Name) {
	If (ComObjType(Name,"Name") = "_Workbook")
		return Name
	
	controlget,hwnd, hwnd,,Excel71, % (Name="") ? "ahk_class XLMAIN" : Name
	WinGet, xl, ControlList, ahk_class XLMAIN
	if RegExMatch(xl,"EXCEL61\nEXCEL71")
		controlsend,EXCEL71,{Enter},%Name%
	
	Try{
		xla := Acc_ObjectFromWindow(hwnd,-16).parent
	}
	Catch{
		msgbox, Could not connect to Excel object - check if cell in edit mode
		return "False"
	}
	
	return % (isobject(xla)) ? xla : "False"
}

A(Array, Parent=""){
	static
	global GuiArrayTree, GuiArrayTreeX, GuiArrayTreeY
	if Array_IsCircle(Array)
	{
		MsgBox, 16, GuiArray, Error: Circular refrence
		return "Error: Circular refrence"
	}
	if !Parent
	{
		Gui, +HwndDefault
		Gui, GuiArray:New, +HwndGuiArray +LabelGuiArray +Resize
		Gui, Add, TreeView, vGuiArrayTree
		
		Parent := "P1"
		%Parent% := TV_Add("Array", 0, "+Expand")
		A(Array, Parent)
		GuiControlGet, GuiArrayTree, Pos
		Gui, Show,, GuiArray
		Gui, %Default%:Default
		
		WinWaitActive, ahk_id%GuiArray%
		WinWaitClose, ahk_id%GuiArray%
		return
	}
	For Key, Value in Array
	{
		%Parent%C%A_Index% := TV_Add(Key, %Parent%)
		KeyParent := Parent "C" A_Index
		if (IsObject(Value))
			A(Value, KeyParent)
		else
			%KeyParent%C1 := TV_Add(Value, %KeyParent%)
	}
	return
	
	GuiArrayClose:
	Gui, Destroy
	return
	
	GuiArraySize:
	if !(A_GuiWidth || A_GuiHeight) ; Minimized
		return
	GuiControl, Move, GuiArrayTree, % "w" A_GuiWidth - (GuiArrayTreeX * 2) " h" A_GuiHeight - (GuiArrayTreeY * 2)
	return
}

Array_IsCircle(Obj, Objs=0){
	if !Objs
		Objs := {}
	For Key, Val in Obj
		if (IsObject(Val)&&(Objs[&Val]||Array_IsCircle(Val,(Objs,Objs[&Val]:=1))))
			return 1
	return 0
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;===========HELPER FUNCTIONS===================================================
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;All Credit to jNizM on this function - Thanks so much!!!
ConvertToLetter(n)
{
	while (n != 0) {
		t := Mod((n - 1), 26)
		n := (n - t) // 26
		l := chr(65 + t) l
	}
	return l
}

ConvertToNumbers(l)
{
	colnum:=0
	Loop % strlen(l)
		colnum := (colnum*26) + (asc(SubStr(l,A_Index,1))-64)
	return colnum+0
}

;Used in ObjToRange Funtion - reorders array so the the rows are the keys instead of the columns
ConvertToRowKeys(obj)
{
	NewObj := []
	For k,v in obj
	{
		col:=k
		for each,row in v
			NewObj[Each,col]:=row
	}
	return newobj
}

;Helps COM functions work faster/prevent screen flickering, etc.
Speedup(xla,i)
{
	if(i=0)
	{
		xla.application.displayalerts := 0
		xla.application.EnableEvents := 0
		xla.application.ScreenUpdating := 0
		xla.application.Calculation := -4135
	}
	else
	{
		xla.application.displayalerts := 1
		xla.application.EnableEvents := 1
		xla.application.ScreenUpdating := 1
		xla.application.Calculation := -4105		
	}
}

Acc_Init()
{
	Static	h
	If Not	h
		h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
}

Acc_ObjectFromWindow(hWnd, idObject = 0)
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
		Return	ComObjEnwrap(9,pacc,1)
}

GetActiveObjects(Prefix:="", CaseSensitive:=false) {
	objects := {}
	DllCall("ole32\CoGetMalloc", "uint", 1, "ptr*", malloc) ; malloc: IMalloc
	DllCall("ole32\CreateBindCtx", "uint", 0, "ptr*", bindCtx) ; bindCtx: IBindCtx
	DllCall(NumGet(NumGet(bindCtx+0)+8*A_PtrSize), "ptr", bindCtx, "ptr*", rot) ; rot: IRunningObjectTable
	DllCall(NumGet(NumGet(rot+0)+9*A_PtrSize), "ptr", rot, "ptr*", enum) ; enum: IEnumMoniker
	while DllCall(NumGet(NumGet(enum+0)+3*A_PtrSize), "ptr", enum, "uint", 1, "ptr*", mon, "ptr", 0) = 0 ; mon: IMoniker
	{
		DllCall(NumGet(NumGet(mon+0)+20*A_PtrSize), "ptr", mon, "ptr", bindCtx, "ptr", 0, "ptr*", pname) ; GetDisplayName
		name := StrGet(pname, "UTF-16")
		DllCall(NumGet(NumGet(malloc+0)+5*A_PtrSize), "ptr", malloc, "ptr", pname) ; Free
		if InStr(name, Prefix, CaseSensitive) = 1 {
			DllCall(NumGet(NumGet(rot+0)+6*A_PtrSize), "ptr", rot, "ptr", mon, "ptr*", punk) ; GetObject
  ; Wrap the pointer as IDispatch if available, otherwise as IUnknown.
			if (pdsp := ComObjQuery(punk, "{00020400-0000-0000-C000-000000000046}"))
				obj := ComObject(9, pdsp, 1), ObjRelease(punk)
			else
				obj := ComObject(13, punk, 1)
  ; Store it in the return array by suffix.
			objects[SubStr(name, StrLen(Prefix) + 1)] := obj
		}
		ObjRelease(mon)
	}
	ObjRelease(enum)
	ObjRelease(rot)
	ObjRelease(bindCtx)
	ObjRelease(malloc)
	return objects
}
