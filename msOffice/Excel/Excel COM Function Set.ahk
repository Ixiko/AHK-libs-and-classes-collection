; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=13382
; Author:
; Date:
; for:     	AHK_L
;Required Lib for use with these Functions:
;=====================================================
;http://ahk4.me/1nrXKSH - Acc Lib Written by Jethrew
;=====================================================

/*

#SingleInstance Force
#Persistent
SetBatchLines, -1
comobjerror(0)

;XL_ToPDF("","","A1:E30","C:\test1113.pdf",0)

;XL_Save("",1,"C:\test111.xls")

;msgbox % XL_GetCell("","","D7")

;XL_SetCell("","","J6","Value1234")

;msgbox % XL_GetLast("","","D7",xldown)

;Result := XL_RangeFindAll("","","A1:A30","1","A26",xlValues,2)

;Result := XL_RangeFind("","","A1:A30","row2","A30",xlValues
*/



;Some Excel Constants for use with COM
xlup := -4162
xldown := -4121
xlLeft := -4159
xlRight := -4161
xlFormulas := -4123
xlValues := -4163
xlCenter := -4108
xlCalculationAutomatic := -4105
xlCalculationManual := -4135




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
XL_ToPDF(Name, Sht, Range, PDFPath, Display) {
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ?  xla.activesheet.name : sht)
	xla.sheets(sht).range(Range).ExportAsFixedFormat(0,PDFPath,0,,,,,Display)
	return
}

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
;GetCell Vs SetCell - Just like it sounds, GetCell returns value of cell specified
;						Set cell puts the value you specify into the cell referenced
;
;==========================================
XL_GetCell(Name,Sht,Range) {
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ?  xla.activesheet.name : sht)

	return xla.sheets(sht).range(range).value
}

XL_SetCell(Name,Sht,Range,Value) {
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ?  xla.activesheet.name : sht)

	xla.sheets(sht).range(range) := Value
	return
}

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
XL_GetLast(Name,Sht,Range,Direction) {
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ?  xla.activesheet.name : sht)

	if direction = -4159
			Last := xla.sheets(sht).range(Range).end(Direction).address
	if direction = -4161
			Last := xla.sheets(sht).range(Range).end(Direction).address
	if direction = -4162
			Last := xla.sheets(sht).range(Range).end(Direction).address
	if direction = -4121
			Last := xla.sheets(sht).range(Range).end(Direction).address
return Last
}

;XL_RangeFind() Function - Thanks Tidbit ;)
;=========================================
;Params:
;
;Note - This function returns ONE result, dependng on how you set the parameters up
;		If you want to return all results found within a range, use XL_RangeFindAll
;
;Name -Specify "" if you want to retrive handle to active excel workbook
;	Otherwise, use the full name of the workbook you want a handle to - e.g. "Book1.xlsx - Excel"
;
;Sht -Specify "" if you want to use the active sheet, otherwise use the Sheet Name e.g. "Sheet1"
;
;SearchRange-Range representing where you want to 'Fnd' the value e.g. "A1:A100"
;
;What -Pretty straight forward...what are you searching for?
;
;After - You you must it where to start e.g. "A30"
;		This will affect the Search Order Param - See the MSDN for details
;		I normally use the last cell in my rang to search from, otherwise in some cases you may miss the first result
;
;LookIn - One of the options XlValues, or XlFormulas
;
;You will notice that some paramteers listed in the MSDN are not used here
;I chose to include what i see to be at 90% of the use cases for the Range.Find Method
;I will add others if people have a need....
;
;
;=========================================
XL_RangeFind(Name,Sht,Range,What, After, LookIn) {
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ?  xla.activesheet.name : sht)

	return xla.sheets(Sht).range(Range).Find(What,xla.sheets(Sht).range(After),LookIn,,,1).row
}

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
;ResultType - Values 1,2,3
;				1 = Returns an object of Row values where Value was found
;				2 = Returns an object of Column values(Shown as column Index e.g. 1,2,3,4...etc) where Value was found
;				3 = Returns an object of Address values(e.g. $A$1) where Value was found
;
;=========================================
XL_RangeFindAll(Name,Sht,Range,What, After, LookIn, ResultType) {
	xla := XLCheck(Name)
	if xla = False
		return
	sht := ((sht="") ?  xla.activesheet.name : sht)

	Rarr := []
	RTS := xla.sheets(Sht).range(Range).Find(What,xla.sheets(Sht).range(After),LookIn,,,1)
	First := RTS.row
	Loop
	{
		if ResultType = 1
			Rarr[A_Index] := RTS.Row
		if ResultType = 2
			Rarr[A_Index] := RTS.Column
		if ResultType = 3
			Rarr[A_Index] := RTS.address
		RTS := xla.sheets(Sht).range(Range).FindNext(RTS)
	}until (RTS.row=First)

	return Rarr
}

;Get Handle to Excel Workbook
;==============================
;Param Name="" will get handle to last activated Excel workbook (Credit To Jethrew and SinkFaze for this!)
;Otherwise, specify the full excel workbook name with - Excel at the end
;ex. Book1.xlsx - Excel for workbook Name
;==============================
XLCheck(Name) {
	WinGet, xl, ControlList, ahk_class XLMAIN
	if	RegExMatch(xl,"EXCEL61\nEXCEL71") {
		MsgBox, 48, Warning, Excel is currently in 'Edit cell mode,' please exit any cell being edited and try again.
		xla = False
		return xla
	}
If Name =
	ControlGet, hwnd, hwnd, , Excel71, ahk_class XLMAIN
else
	controlget,hwnd, hwnd,,Excel71,%Name%

window := Acc_ObjectFromWindow(hwnd, -16)
Xla := window.application

if isobject(xla)
	return xla
else
	return "False"
}
