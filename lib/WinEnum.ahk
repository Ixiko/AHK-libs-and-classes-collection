/* Function: WinEnum
 *     Wrapper for Enum(Child)Windows [http://goo.gl/5eCy9 | http://goo.gl/FMXit]
 * License:
 *     WTFPL [http://wtfpl.net/]
 * Syntax:
 *     windows := WinEnum( [ hwnd ] )
 * Parameter(s) / Return Value:
 *     windows   [retval] - an array of window handles
 *     hwnd     [in, opt] - parent window. If specified, EnumChildWindows is
 *                          called. Accepts a window handle or any string that
 *                          match the WinTitle[http://goo.gl/NdhybZ] parameter.
 * Example:
 *     win := WinEnum() ; calls EnumWindows
 *     children := WinEnum("A") ; enumerate child windows of the active window
 */
WinEnum(hwnd:=0, lParam:=0) ;// lParam (internal, used by callback)
{
	static pWinEnum := "X"
	if (A_EventInfo != pWinEnum)
	{
		if (pWinEnum == "X")
			pWinEnum := RegisterCallback(A_ThisFunc, "F", 2)
		if hwnd
		{
			;// not a window handle, could be a WinTitle parameter
			if !DllCall("IsWindow", "Ptr", hwnd)
			{
				prev_DHW := A_DetectHiddenWindows
				prev_TMM := A_TitleMatchMode
				DetectHiddenWindows On
				SetTitleMatchMode 2
				hwnd := WinExist(hwnd)
				DetectHiddenWindows %prev_DHW%
				SetTitleMatchMode %prev_TMM%
			}
		}
		out := []
		if hwnd
			DllCall("EnumChildWindows", "Ptr", hwnd, "Ptr", pWinEnum, "Ptr", &out)
		else
			DllCall("EnumWindows", "Ptr", pWinEnum, "Ptr", &out)
		return out
	}

	;// Callback - EnumWindowsProc / EnumChildProc
	static ObjPush := Func(A_AhkVersion < "2" ? "ObjInsert" : "ObjPush")
	%ObjPush%(Object(lParam + 0), hwnd)
	return true
}