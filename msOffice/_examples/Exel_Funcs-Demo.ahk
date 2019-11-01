SetworkingDir, %A_ScriptDir%
#Include XLFuncs.ahk
#Include Lv_InCellEdit.ahk
setbatchlines, -1

gui,font,s10
Gui,Add,Tab3,,Set Cell||Get Cell|Get Last|Find First|Find All|VLookup|Range to Object|Object to Range

gui,tab,1
Gui,Add,Button,Section w200 gSC,Set Cell Value
Gui,Add,Edit,ys vSSV,Set this value into cell
Gui,Add,Edit,w40 ys vSSR,A1
Gui,Add,Edit,section xs w600 vSCText,
Gui,Add,Text,ys, <--- Function Code

gui,tab,2
Gui,Add,Button,Section w200 gGC,Get Cell Value
Gui,Add,Edit,w40 ys vGCR,A1
Gui,Add,Edit,section xs w600 vGCText,
Gui,Add,Text,ys, <--- Function Code

gui,tab,3
Gui,Add,Button,Section w200 gGL,Get Last Value From Range
Gui,Add,Edit,w40 ys vGLR,C5
Gui,Add,Text,ys,In Direction ->
Gui,Add,DropDownList,ys vGLD,xlup||xldown|xlleft|xlright
gui,Add,Text,ys,Returning ->
Gui,Add,Dropdownlist,ys vGLReturn,Row||Column|Value|Text|Formula
Gui,Add,Edit,section xs w600 vGLText,
Gui,Add,Text,ys, <--- Function Code

gui,tab,4
Gui,Add,Button,Section w200 gFF,Find First Value in Range
Gui,Add,Edit,ys vFFRange,F1:F200
Gui,Add,Text,ys,The Value ->
Gui,Add,Edit,w76 ys vFFWhat,6 minutes
Gui,Add,Text,ys,Starting After ->
Gui,Add,Edit,ys vFFAFter,F200
Gui,Add,Text,ys,Looking in
gui,Add,DropDownList,ys vFFIn,xlvalues||xlformulas
gui,Add,Text,ys,Returning ->
Gui,Add,Dropdownlist,ys vFFReturn,Row||Column|Value|Text|Formula
Gui,Add,Edit,section xs w600 vFFText,
Gui,Add,Text,ys, <--- Function Code

gui,tab,5
Gui,Add,Button,Section w200 gFA ,Find All Values in Range
Gui,Add,Edit,ys vFARange,F1:F200
Gui,Add,Text,ys,The Value ->
Gui,Add,Edit,w75 ys vFAWhat,*
Gui,Add,Text,ys,Starting After ->
Gui,Add,Edit,ys vFAAFter,F200
Gui,Add,Text,ys,Looking in
gui,Add,DropDownList,ys vFAIn,xlvalues||xlformulas
gui,Add,Text,ys,Returning ->
Gui,Add,Dropdownlist,ys vFAReturn,Row|Column|Value||Text|Formula
Gui,Add,Edit,section xs w600 vFAText,
Gui,Add,Text,ys, <--- Function Code

gui,tab,6
Gui,Add,Button,Section w200,Do Vlookup
Gui,Add,Edit,section xs w400 vVLText,
Gui,Add,Text,w600 ys, <--- Function Code

gui,tab,7
Gui,Add,Button,Section w200 gRTO,Excel Range to AHK Obj
gui,Add,Edit,ys vRTOR,C3:F30
Gui,Add,Edit,section xs w600 vRTOText,
Gui,Add,Text,ys, <--- Function Code

gui,tab,8
Gui,Add,Button,section w200 gOTR,AHK Obj to Excel Range
Gui,Add,Edit,ys vOTRR,A400
Gui,Add,Edit,section xs w600 vOTRText,
Gui,Add,Text,ys, <--- Function Code

gui,tab
gui,Add,Listview,Section xm w700 r15 -ReadOnly Altsubmit hwndLV1 gLV grid


gui,show,autosize
return

SC:
gui,submit,nohide
XL_SetCell("","","" . SSR . "","" . SSV . "")
RawTxt=XL_SetCell("","","%SSR%","%SSV%")
guicontrol,,SCText,%RawTxt%
return

GC:
Gui,Submit,nohide
Found := XL_GetCell("","","" . GCR . "","Value")
loop,10
	LV_DeleteCol(A_Index)
LV_Delete()

LV_InsertCol(1,"","Found Value in cell " GCR)
LV_Add("",Found)

RawTxt=XL_GetCell("","","%GCR%","Value")
guicontrol,,GCText,%RawTxt%
return

GL:
gui,submit,nohide
Found:=XL_GetLast("","","" . GLR . "",%GLD%,"" . GLReturn . "")
loop,10
	LV_DeleteCol(A_Index)
LV_Delete()

LV_InsertCol(1,"","Found " GLReturn)
LV_Add("",Found)

RawTxt=XL_GetLast("","","%GLR%",%GLD%,"%GLReturn%")
guicontrol,,GLText,%RawTxt%
return

FF:
gui,submit,nohide
Found := XL_RangeFind("","","" . FFRange . "","" . FFWhat . "","" . FFAfter . "",%FFIn%,xlwhole,xlbycolumns,xlnext,"" . FFReturn . "")
loop,10
	LV_DeleteCol(A_Index)
LV_Delete()

LV_InsertCol(1,"","Found " FFReturn)
LV_Add("",Found)

RawTxt=XL_RangeFind("","","%FFRange%","%FFWhat%","%FFAfter%",%FFIn%,xlwhole,xlbycolumns,xlnext,"%FFReturn%")
guicontrol,,FFText,%RawTxt%
Return

FA:
gui,submit,nohide
arr:=XL_RangeFindAll("","","" . FARange . "","" . FAWhat . "","" . FAAfter . "",%FAIn%,xlwhole,xlbycolumns,xlnext,"" . FAReturn . "")
Loop,10
	LV_Deletecol(a_Index)
Lv_Delete()

LV_InsertCol(1,"","Found " . FAReturn)
For k,v in Arr
	LV_Add("",v)

RawTxt=XL_RangeFindAll("","","%FARange%","%FAWhat%","%FAAfter%",%FAIn%,xlwhole,xlbycolumns,xlnext,"%FAReturn%")
guicontrol,,FAText,%RawTxt%
Return

RTO:
gui,submit,nohide
Arr := ConvertToRowKeys(XL_RangeToObj("","","" . RTOR . ""))
Loop,10
	LV_Deletecol(a_Index)
Lv_Delete()

For k,v in Arr
{
	If(A_Index=1)
		for x,y in v
			LV_InsertCol(A_Index,"AutoHdr",x)

	Heading := k
	headingcol:=A_Index
	for x,y in v
	{
		if(A_Index=1)
			LV_Add("Col" A_Index,y)
		else
			Lv_Modify(headingcol,"Col" A_Index,y)
		
	}
}
Loop % LV_GetCount()
	LV_ModifyCol(A_Index,"AutoHdr")
ICELV1 := New LV_InCellEdit(LV1)

RawTxt=XL_RangeToObj("","","%RTOR%")
guicontrol,,RTOText,%RawTxt%
return

OTR:
gui,submit,nohide

obj:=[]
Loop % LV_GetCount("Column")
{
	Col:=A_Index
	Loop % LV_GetCount()
	{
		LV_GetText(txt,A_Index,col)
		Obj[Col,A_Index]:=txt
	}
}
XL_ObjToRange("","","" . OTRR . "",obj)

RawTxt=XL_ObjToRange("","","%OTRR%",objectVar[])
guicontrol,,OTRText,%RawTxt%
return


LV:
; Check for changes
If (A_GuiEvent == "F") {
	If (ICELV1["Changed"]) {
		Msg := ""
		For I, O In ICELV1.Changed
			Msg .= "Row " . O.Row . " - Column " . O.Col . " : " . O.Txt
		ICELV1.Remove("Changed")
	}
}
Return

ESC::
GuiClose:
Exitapp


