; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

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
;ByRowsOrCols - Row Indexes, or Column Index (Default is Column)
;
;;=========================================
*/
XL_RangeToObj(Name,Sht,Range,DType="Value",R1C1="",ByRowsOrCols:="")
{
	xlMap:=[]
	
	If Isobject(Name){
		xla := Name
	}else{
		xla := XL_Check()
		if !isobject(xla)
			return
	}
	
	sht := ((sht="") ?  xla.activesheet.name : sht) 
	sArr  := xla.sheets(sht).Range(Range)[Dtype]
	
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
			If (ByRowsOrCols)
				xlMap[oCurRowNum,CurrentCol]:=SArr[CurRowNum, A_Index]
			Else
				xlMap[CurrentCol,oCurRowNum]:=SArr[CurRowNum, A_Index]
		}
	}
	return xlmap
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
	
	If Isobject(Name){
		xla := Name
	}else{
		xla := XL_Check()
		if !isobject(xla)
			return
	}
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
	
	If Isobject(Name){
		xla := Name
	}else{
		xla := XL_Check()
		if !isobject(xla)
			return
	}
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
