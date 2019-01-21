SetWorkingDir %A_ScriptDir%
#NoEnv
#Include <MinHook>

hook1 := New MinHook("user32.dll", "MessageBoxW", "MessageBoxW_Hook")

hook1.Enable()
MsgBox, 64, Hello, World

hook1.Disable()
MsgBox, 64, Hello, I'm back.

hook1 := "" ; Remove hook

MessageBoxW_Hook(hWnd, lpText, lpCaption, uType) {
	global hook1
	return DllCall(hook1.original, "ptr", hWnd, "str", "Hooked!", "ptr", lpCaption, "uint", 48)
}
