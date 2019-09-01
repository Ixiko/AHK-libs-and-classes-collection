#NoEnv
#SingleInstance, Force
#Include %A_ScriptDir%\..\Class_Toolbar.ahk

; Create an ImageList.
ILA := IL_Create(4, 2, True)
IL_Add(ILA, "shell32.dll", 127)
IL_Add(ILA, "shell32.dll", 128)
IL_Add(ILA, "shell32.dll", 129)
IL_Add(ILA, "shell32.dll", 130)

; TBSTYLE_FLAT     := 0x0800 Required to show separators as bars.
; TBSTYLE_TOOLTIPS := 0x0100 Required to show Tooltips.
Gui, -Caption
Gui, Add, Custom, ClassToolbarWindow32 hwndhToolbar 0x0800 0x0100
Gui, Add, Text, xm, Press F1 to customize.
Gui, Show,, Test

; Initialize Toolbars.
; The variable you choose will be your handle to access the class for your toolbar.
MyToolbar := New Toolbar(hToolbar)

; Set ImageList.
MyToolbar.SetImageList(ILA)

; Add buttons.
MyToolbar.Add("", "Label1=Button 1:1", "Label2=Button 2:2", "Label3=Button 3:3", "MyFunction=Button 4:4")

; Removes text labels and show them as tooltips.
MyToolbar.SetMaxTextRows(0)

; Set a function to monitor the Toolbar's messages.
WM_COMMAND := 0x111
OnMessage(WM_COMMAND, "TB_Messages")

; Set a function to monitor notifications.
WM_NOTIFY := 0x4E
OnMessage(WM_NOTIFY, "TB_Notify")

return

; This function will receive the messages sent by both Toolbar's buttons.
TB_Messages(wParam, lParam)
{
    Global ; Function (or at least the Handles) must be global.
	Static Counter := 0
    MyToolbar.OnMessage(wParam, ++Counter, A_Hour, A_Min, A_Sec) ; Handles toolbar's messages.
	; If you pass a function as the label, you can also pass any number
	; of parameters starting from 2nd parameter of OnMessage() method.
}

; This function will receive the notifications.
TB_Notify(wParam, lParam)
{
    Global ; Function (or at least the Handles) must be global.
    ReturnCode := MyToolbar.OnNotify(lParam) ; Handles notifications.
    return ReturnCode
}

; Your labels.
Label1:
Label2:
Label3:
MsgBox, You selected %A_ThisLabel%
return

; You can also use a function to be triggered by the button.
MyFunction(x, h, m, s)
{

	MsgBox, You selected %A_ThisFunc% %x% times.`nLast time at %h%:%m%:%s%
}

; Customize dialog.
F1::MyToolbar.Customize()

GuiClose:
ExitApp
return