
Util_GetAhkPath(){
	RegRead, ov, HKLM, SOFTWARE\AutoHotkey, InstallDir
	if !ov && A_Is64bitOS
	{
		q := A_RegView
		SetRegView, 64
		RegRead, ov, HKLM, SOFTWARE\AutoHotkey, InstallDir
		SetRegView, %q%
	}
	return ov
}

Util_GetAhkVer(){
	RegRead, ov, HKLM, SOFTWARE\AutoHotkey, Version
	if !ov && A_Is64bitOS
	{
		q := A_RegView
		SetRegView, 64
		RegRead, ov, HKLM, SOFTWARE\AutoHotkey, Version
		SetRegView, %q%
	}
	return ov
}

Util_GetWinVer(){
	pack := DllCall("GetVersion", "uint") & 0xFFFF
	pack := (pack & 0xFF) "." (pack >> 8)
	pack += 0
	return pack
}

Util_CreateShortcut(Shrt, Path, Descr, Args := "", Icon := "", IconN := ""){
	SplitPath, Path,, Dir
	FileDelete, %Shrt%
	FileCreateShortcut, %Path%, %Shrt%, %Dir%, %Args%, %Descr%, %Icon%,, %IconN%
}

; Written by Lexikos.
Util_UserRun(target, args := ""){
	try
		_ShellRun(target, args)
	catch e
		Run, % args="" ? target : target " " args
}

; Written by Lexikos.
_ShellRun(prms*){
	shellWindows := ComObjCreate("{9BA05972-F6A8-11CF-A442-00A0C90A8F39}")

	; Find desktop window object.
	VarSetCapacity(_hwnd, 4, 0)
	desktop := shellWindows.FindWindowSW(0, "", 8, ComObj(0x4003, &_hwnd), 1)

	; Retrieve top-level browser object.
	if ptlb := ComObjQuery(desktop
		, "{4C96BE40-915C-11CF-99D3-00AA004AE837}"  ; SID_STopLevelBrowser
		, "{000214E2-0000-0000-C000-000000000046}") ; IID_IShellBrowser
	{
		; IShellBrowser.QueryActiveShellView -> IShellView
		if DllCall(NumGet(NumGet(ptlb+0)+15*A_PtrSize), "ptr", ptlb, "ptr*", psv:=0) = 0
		{
			; Define IID_IDispatch.
			VarSetCapacity(IID_IDispatch, 16)
			NumPut(0x46000000000000C0, NumPut(0x20400, IID_IDispatch, "int64"), "int64")

			; IShellView.GetItemObject -> IDispatch (object which implements IShellFolderViewDual)
			DllCall(NumGet(NumGet(psv+0)+15*A_PtrSize), "ptr", psv
				, "uint", 0, "ptr", &IID_IDispatch, "ptr*", pdisp:=0)

			; Get Shell object.
			shell := ComObj(9,pdisp,1).Application

			; IShellDispatch2.ShellExecute
			shell.ShellExecute(prms*)

			ObjRelease(psv)
		}
		ObjRelease(ptlb)
	}
}