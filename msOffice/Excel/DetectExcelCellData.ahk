wbk := ComExcelConnect( "ahk_class XLMAIN" ).Application ; ComObjActive("Excel.Application")
; a::
F1::

; Loop % UsedRows
While ( A_Index <= wbk.ActiveSheet.UsedRange.Rows.Count )
{
	CurRow := A_Index, Cols := wbk.Cells( CurRow, 256 ).End( -4159 ).Column

	Loop % Cols
	{
		if ( wbk.Cells( CurRow, A_Index ).Value != "" )
		{
			CellObj := wbk.Cells( CurRow, A_Index )


			; place action here!

			; remove below msgbox for display purposes only!
			msgbox % "Cell: " CellObj.Address( 0, 0 ) "`nValue: " CellObj.Value
		}
	}
}

return 

ComExcelConnect( WinTitle )
{
	DetectHiddenWindows, On
    objID    := "-16", objID &= 0xFFFFFFFF
    refID    := -VarSetCapacity( iid, 16 )
    iid_type := NumPut( 0x46000000000000C0
             ,  NumPut( 0x20400, iid, "Int64" )
             ,  "Int64")

    ControlGet, hwnd, hwnd, , EXCEL71, % WinTitle
    DllCall( "oleacc\AccessibleObjectFromWindow", ptr, hwnd, uInt, objID, ptr, refID+iid_type, "ptr*", pObj )

    return ComObjEnwrap( 9, pObj )
}