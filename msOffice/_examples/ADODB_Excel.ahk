adOpenStatic = 3
adLockOptimistic = 3
adCmdText = 1
dataSource := A_ScriptDir . "\SampleData.xls"

objConnection := ComObjCreate("ADODB.Connection")
objRecordSet := ComObjCreate("ADODB.Recordset")

objConnection.Open("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" . dataSource . ";Extended Properties=""Excel 8.0;HDR=Yes;"";")

objRecordset.Open("Select * FROM [Sheet1$]", objConnection, adOpenStatic, adLockOptimistic, adCmdText)
Gui, Font, S10 CDefault, Verdana
Gui, Add, Text, x12 y10 h20 , SELECT * from [Sheet1$] WHERE
Gui, Add, DropDownList, R10 x+5 y8 w100 h25 vselMain gUpdateGo,
Gui, Add, Text, x+5 y10 h20 , =
Gui, Add, DropDownList, R10 x+5 y8 w100 h25 vselItem gGo,
pFields := objRecordset.Fields
Loop, % pFields.Count
    tNames .= pFields.Item(A_Index-1).Name . "|"
Gui, Add, ListView, x2 y40 w480 h340 vMyLV, % SubStr(tNames,1,-1)
GuiControl,,selMain,% "|" . SubStr(RegExReplace(tNames,"^.+?\|",""),1,-1) ;RegExReplace removes the first field, DATETIME not supported yet
strObj := Object()
Loop
{
    pFields := objRecordset.Fields
    Loop, % pFields.Count
        strObj[A_Index] := pFields.Item(A_Index-1).Value
    LV_Add("",strObj.1,strObj.2,strObj.3,strObj.4,strObj.5,strObj.6,strObj.7,strObj.8,strObj.9,strObj.10)
    objRecordset.MoveNext
} Until objRecordset.EOF
strObj.Remove(strObj.MinIndex(),strObj.MaxIndex())
LV_ModifyCol()
Gui, Show, w487 h384, ADODB Test
return

UpdateGo:
Gui,Submit,NoHide
objRecordset := objConnection.Execute("Select ``" . selMain . "`` FROM [Sheet1$]")
Loop
{
    pFields := objRecordset.Fields
    tvar := pFields.Item(0).Value
    if tvar not in %str%
        str .= pFields.Item(0).Value . "`,"    
    objRecordset.MoveNext
} Until objRecordset.EOF
StringReplace,str,str,`,,|,All
str := "|" . SubStr(str,1,-1)
GuiControl,,selItem,%str%
str=
GuiControl,Choose,selItem,1

Go:
Gui,Submit,NoHide
LV_Delete()
if selItem is not number
	selItem := "'" . selItem . "'"
IfInString, selItem,/
    StringReplace,selItem,selItem,/,//,All

objRecordset := objConnection.Execute("Select * FROM [Sheet1$] Where ``" . selMain . "`` = " . selItem)
Loop
{
    pFields := objRecordset.Fields
    Loop, % pFields.Count
        strObj[A_Index] := pFields.Item(A_Index-1).Value
    LV_Add("",strObj.1,strObj.2,strObj.3,strObj.4,strObj.5,strObj.6,strObj.7,strObj.8,strObj.9,strObj.10)
    strObj.Remove(strObj.MinIndex(),strObj.MaxIndex())
    objRecordset.MoveNext
} Until objRecordset.EOF
Return

GuiClose:
objRecordSet.Close()
objConnection.Close()
ExitApp