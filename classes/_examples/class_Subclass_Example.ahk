#Include %A_ScriptDir%\..\class_Subclass.ahk

WM_Copy := 0x301

gui, +AlwaysOnTop
Gui, Add, Edit, hwndEdithWnd
Gui, Show
Subclass.AddListener(EdithWnd, WM_Copy, "WM_Copy")
return


WM_Copy(Hwnd, Message, wParam, lParam) {
	ToolTip, % Clipboard "`nMessage: " Format("0x{:X}",Message) "`nwParam: " wParam "`nlParam: " lParam,1000, 1, 5
	; Exit
}

GuiClose:
GuiEscape:
ExitApp

esc::ExitApp
F1::
	Subclass.RemoveListener(MyhWnd, 0x301)
return
