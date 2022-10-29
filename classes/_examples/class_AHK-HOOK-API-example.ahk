#include AHK-HOOK-API.ahk

global MsgBoxHook := new Hook("user32.dll", "MessageBoxA", "Hook_MessageBoxA") ; Óñòàíîâêà õóêà.
MsgBox, 0, Çàãîëîâîê, Òåêñò

Hook_MessageBoxA(hWnd, lpText, lpCaption, uiType)
{
	MsgBoxHook.SetStatus(false) ; Ñíèìàåì õóê.
	retValue := DllCall("MessageBoxA", "UInt", hWnd, "Str", StrGet(lpText), "Str", "Hooked MsgBox", "UInt", uiType) ; Âûçûâàåì îðèãèíàëüíóþ ôóíêöèþ, íî ïîäìåíÿåì íàçâàíèå.
	MsgBoxHook.SetStatus(true) ; Ñòàâèì õóê îáðàòíî.
	return retValue
}