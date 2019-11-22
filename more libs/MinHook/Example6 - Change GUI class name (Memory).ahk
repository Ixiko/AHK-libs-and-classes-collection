#NoEnv
#Include <MinHook_Memory>
SetWorkingDir %A_ScriptDir%
#SingleInstance, force

hook1 := New MinHook_Memory("user32.dll", "CreateWindowExW", "CreateWindowExW_Hook")
hook2 := New MinHook_Memory("user32.dll", "RegisterClassExW", "RegisterClassExW_Hook")

; hook1.Enable()
; hook2.Enable()
MH_EnableHook() ; Enable all hooks

Gui, Show, w400 h100, % (A_PtrSize=8) ? "64bit" : "32bit"
Return

GuiClose:
	hook1 := hook2 := "" ; Remove hook
ExitApp

RegisterClassExW_Hook(lpwcx) {

	lpszClassName := StrGet( NumGet(lpwcx+0, A_PtrSize == 8 ? 64 : 40, "Ptr") )
	OutputDebug, % "-->" lpszClassName

	if (lpszClassName = "AutoHotkeyGUI") {
		newClass := "MyClassName"
		NumPut(&newClass, lpwcx+0, A_PtrSize == 8 ? 64 : 40, "Ptr")
	}

	return DllCall(Object(A_EventInfo).original, "ptr", lpwcx, "ushort")
}

CreateWindowExW_Hook(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam) {
	OutputDebug, % sClassName := StrGet(lpClassName)

	if (sClassName = "AutoHotkeyGUI") {
		newClass := "MyClassName"
		lpClassName := &newClass
	}

	return DllCall(Object(A_EventInfo).original
		, "uint", dwExStyle
		, "ptr", lpClassName
		, "ptr", lpWindowName
		, "int", dwStyle
		, "int", X
		, "int", Y
		, "int", nWidth
		, "int", nHeight
		, "ptr", hWndParent
		, "ptr", hMenu
		, "ptr", hInstance
		, "ptr", lpParam
		, "ptr")
}
