; http://www.autohotkey.com/board/topic/9350-get-the-current-path-of-a-window-explorer/
GetWindowsExplorerPath(_hWnd)
{
	local pid, hMem, pv, pidl, pidl?, explorerPath

	If (A_OSType = "WIN32_NT")
	{
		pid := DllCall("GetCurrentProcessId")
		SendMessage 0x400 + 12	; CWM_GETPATH = WM_USER + 12
				, pid, 0, , ahk_id %_hWnd%
		hMem := ErrorLevel
		if (hMem != 0)
		{
			pv := DllCall("Shell32\SHLockShared"
				, "UInt", hMem, "UInt", pid)
			if (pv != 0)
			{
				pidl := DllCall("Shell32\ILClone", "UInt", pv)
				DllCall("Shell32\SHUnlockShared", "UInt", pv)
			}
			DllCall("Shell32\SHFreeShared"
				, "UInt", hMem, "UInt", pid)
		}
	}
	Else	; Win9x
	{
		SendMessage 0x400 + 12	; CWM_GETPATH = WM_USER + 12
				, 0, 0, , ahk_id %_hWnd%
		pidl? := ErrorLevel
		if (pidl? != 0)
		{
			pidl := DllCall("Shell32\ILClone", "UInt", pidl?)
			DllCall("Shell32\ILGlobalFree", "UInt", pidl?)
		}
	}
	VarSetCapacity(explorerPath, 512, 0)
	DllCall("Shell32\SHGetPathFromIDList"
		, "UInt", pidl, "Str", explorerPath)
	Return explorerPath
}

;-- Example of use

hWnd := WinExist("A")
WinGetClass wClass, ahk_id %hWnd%
If (wClass != "ExploreWClass" and wClass != "CabinetWClass")
	MsgBox Use this only with a Windows Explorer window!
Else
	MsgBox % GetWindowsExplorerPath(hWnd)
