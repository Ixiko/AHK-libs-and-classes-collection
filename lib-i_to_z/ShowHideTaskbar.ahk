ShowHideTaskbar(ByRef fnShowTaskbar := 0)
{
	; Hides or reveals the windows taskbar
	; MsgBox fnShowTaskbar: %fnShowTaskbar%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If fnShowTaskbar not in 0,1
			Throw, Exception("fnShowTaskbar not in 0,1")


		; initialise variables


		; show or hide taskbar
		If fnShowTaskbar
		{
		  NumPut((ABS_ALWAYSONTOP := 0x2),APPBARDATA,32,"UInt")
		  DllCall("Shell32.dll\SHAppBarMessage","UInt",(ABM_SETSTATE := 0xA),"UInt",&APPBARDATA)
		  WinShow, ahk_class Shell_TrayWnd
		}
		If !fnShowTaskbar
		{
		  DetectHiddenWindows, On
		  VarSetCapacity(APPBARDATA,36,0)
		  NumPut((ABS_ALWAYSONTOP := 0x2)|(ABS_AUTOHIDE := 0x1),APPBARDATA,32,"UInt")
		  DllCall("Shell32.dll\SHAppBarMessage","UInt",(ABM_SETSTATE := 0xA),"UInt",&APPBARDATA)
		  Sleep, 10
		  WinHide, ahk_class Shell_TrayWnd
		}

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
ReturnValue := ShowHideTaskbar(0)
MsgBox, ShowHideTaskbar`n`nReturnValue: %ReturnValue%
*/