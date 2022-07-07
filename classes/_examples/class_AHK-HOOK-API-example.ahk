#include AHK-HOOK-API.ahk

global MsgBoxHook := new Hook("user32.dll", "MessageBoxA", "Hook_MessageBoxA") ; ��������� ����.
MsgBox, 0, ���������, �����

Hook_MessageBoxA(hWnd, lpText, lpCaption, uiType)
{
	MsgBoxHook.SetStatus(false) ; ������� ���.
	retValue := DllCall("MessageBoxA", "UInt", hWnd, "Str", StrGet(lpText), "Str", "Hooked MsgBox", "UInt", uiType) ; �������� ������������ �������, �� ��������� ��������.
	MsgBoxHook.SetStatus(true) ; ������ ��� �������.
	return retValue
}