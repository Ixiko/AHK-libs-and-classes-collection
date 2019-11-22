SetWorkingDir %A_ScriptDir%
#NoEnv
#Persistent

code =
(LTrim
	SetWorkingDir, %A_ScriptDir%
	#Include %A_ScriptDir%\Lib\MinHook.ahk

	address_SetDlgItemTextW := DllCall("GetProcAddress", Ptr, DllCall("GetModuleHandle", Str, "user32", "Ptr"), AStr, "SetDlgItemTextW", "Ptr")
	hook1 := New MinHook("", address_SetDlgItemTextW, "SetDlgItemTextW_Hook")
	hook1.Enable()
	return

	SetDlgItemTextW_Hook(hDlg, nIDDlgItem, lpString) {
		global hook1
		return DllCall(hook1.original, "ptr", hDlg, "int", nIDDlgItem, "str", "Hello ^_^")
	}
)

if (A_Is64bitOS && A_PtrSize = 4)
{
	Run, %A_AhkPath%\..\AutoHotkeyU64.exe "%A_ScriptFullPath%", %A_ScriptDir%
	ExitApp
}
Run, notepad,,, pid
WinWait, ahk_pid %pid%

dllFile := FileExist("AutoHotkeyMini.dll") ? A_ScriptDir "\AutoHotkeyMini.dll"
          : (A_PtrSize = 8)                  ? A_ScriptDir "\ahkDll\x64\AutoHotkeyMini.dll"
          : A_ScriptDir "\ahkDll\x32\AutoHotkeyMini.dll"
rThread := InjectAhkDll(pid, dllFile, "")
rThread.Exec(code)

WinMenuSelectItem,,, 5&, 3&
return

