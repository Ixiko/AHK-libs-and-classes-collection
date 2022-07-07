#include AHK-HOOK-API.ahk

global MsgBoxHook := new Hook("user32.dll", "MessageBoxA", "Hook_MessageBoxA") ; Установка хука.
MsgBox, 0, Заголовок, Текст

Hook_MessageBoxA(hWnd, lpText, lpCaption, uiType)
{
	MsgBoxHook.SetStatus(false) ; Снимаем хук.
	retValue := DllCall("MessageBoxA", "UInt", hWnd, "Str", StrGet(lpText), "Str", "Hooked MsgBox", "UInt", uiType) ; Вызываем оригинальную функцию, но подменяем название.
	MsgBoxHook.SetStatus(true) ; Ставим хук обратно.
	return retValue
}