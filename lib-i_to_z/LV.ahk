/*
-------------------------------------------------------------------------------------------------------------
LV.ahk
Useful ListView functions.
Note: No function is dependant upon another within this file.
-------------------------------------------------------------------------------------------------------------
*/

LV_SetDefault(sGUI, sLV)
{
GUI, %sGUI%:Default
GUI, ListView, %sLV%
return
}

LV_GetSel()
{
return LV_GetNext(0, "Focused") == 0 ? 1 : LV_GetNext(0, "Focused")
}

LV_GetSelText(iCol=1)
{
iSel := (LV_GetNext(0, "Focused") == 0 ? 1 : LV_GetNext(0, "Focused"))
LV_GetText(sCurSel, iSel, iCol)
StringReplace, sCurSel, sCurSel, `r, , All ; Sometimes, characters are retrieved with a carriage-return.
return sCurSel
}

LV_GetAsText(iRow=1, iCol=1) ; Too dangerous to use LV_GetText.
{
LV_GetText(sText, iRow, iCol)
return sText
}

LV_SetSel(iRow=1, sOptsOverride="")
{
LV_Modify(0, "-Select") ; Unselect any selected.

LV_Modify(iRow, "Focus")

if (sOptsOverride)
LV_Modify(iRow, "Select " sOptsOverride)
else LV_Modify(iRow, "Select Vis")

return
}

LV_SetSelText(sToSel, sOptsOverride="", iCol=1, bPartialMatch=false, bCaseSensitive=false)
{
Loop % LV_GetCount()
{
LV_GetText(sThisCell, A_Index, iCol)

if (bCaseSensitive)
bExactMatch := (sThisCell == sToSel)
else bExactMatch := (sThisCell = sToSel)

if (bExactMatch || (bPartialMatch && InStr(sThisCell, sToSel)))
{
LV_Modify(A_Index, "Focus")

if (sOptsOverride)
LV_Modify(A_Index, "Select " sOptsOverride)
else LV_Modify(A_Index, "Select Vis")

return true
}
}

return false
}