/* Function: CpyData_Send
 *     Send a string to another script using WM_COPYDATA
 * Syntax:
 *     el := CpyData_Send( str, rcvr [ , data := 0 ] )
 * Return Value:
 *     SendMessage %WM_COPYDATA% ErrorLevel
 * Parameters:
 *     str   [in, ByRef] - string to send (lpData member of COPYDATASTRUCT)
 *     rcvr         [in] - receiver script, argument can be anything that fits
 *                         the WinTitle parameter.
 *     data    [in, opt] - dwData member of COPYDATASTRUCT
 */
CpyData_Send(ByRef str, rcvr, data:=0)
{
	VarSetCapacity(CDS, 4 + 2*A_PtrSize, 0)           ; http://goo.gl/9wOljy
	, NumPut(&str                                     ; lpData
	, NumPut((StrLen(str)+1) * (A_IsUnicode ? 2 : 1)  ; cbData
	, NumPut(data, CDS), "UInt"))                     ; dwData
	
	prev_DHW := A_DetectHiddenWindows, prev_TMM := A_TitleMatchMode
	DetectHiddenWindows On
	SetTitleMatchMode 2
	SendMessage 0x4a, %A_ScriptHwnd%, % &CDS,, % "ahk_id " . WinExist(rcvr)
	DetectHiddenWindows %prev_DHW%
	SetTitleMatchMode %prev_TMM%
	
	return ErrorLevel
}
/* Function: CpyData_OnRcv
 *     Set the callback function to call anytime a scripts receives WM_COPYDATA
 * Syntax:
 *     CpyData_OnRcv( [ fn ] )
 * Parameters:
 *     fn      [in, opt] - a callback function, either the name or a Func object.
 *                         If omitted, the current callback function(if any) is
 *                         returned as a Func object. If explicitly blank (""),
 *                         monitoring is disabled.
 */
CpyData_OnRcv(fn:=0) ;// GET=0, SET=Func, DEL=""
{	
	return _CpyData_OnRcv(fn ? (IsObject(fn) ? fn : Func(fn)) : fn, "CPYDATA")
}
/* PRIVATE
 */
_CpyData_OnRcv(wParam, lParam) ;// wParam=hSender, lParam=COPYDATASTRUCT
{
	static callback
	
	if (lParam == "CPYDATA") ;// called by CpyData_OnRcv()
		return wParam == 0 ? callback : OnMessage(0x4a, (callback := wParam) ? A_ThisFunc : "")
	
	;// args := [ lpData, hSender, dwData ]
	%callback%(StrGet(NumGet(lParam + 2*A_PtrSize)), wParam, NumGet(lParam + 0))
	return true
}