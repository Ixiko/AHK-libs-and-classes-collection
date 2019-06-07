#SingleInstance force
Loop % Lyt.GetList().MaxIndex()
	str .= A_Index ": " Lyt.GetList()[A_Index].LocName " - " Lyt.GetList()[A_Index].LayoutName
	. "`n" Format("{:#010x}", Lyt.GetList()[A_Index].hkl) "`n"

MsgBox,, Your system loaded layout list, % str "`n" defaulSystemLayout
F1::ToolTip % Lyt.Set("EN")           ; set first EN locale layout in system loaded layout list
F2::ToolTip % Lyt.Set("switch")       ; switch input locale. Lyt.Set() do the same.
F3::ToolTip % Lyt.Set("forward")      ; move forward (cycle) in layout list
F4::ToolTip % Lyt.Set(2)              ; set second layout in list
F7::ToolTip % Lyt.Set("-EN")          ; set first non-english layout in list
F8::ToolTip % Lyt.Set(0x4090409)      ; set en-US layout by HKL
F9::Lyt.Set("forward", WinExist("AutoHotkey Help ahk_class HH Parent")) ; in AutoHotkey.chm windows
F10::Lyt.Set("en", "AutoHotkey Help ahk_class HH Parent")
F11::MsgBox % Lyt.GetLayoutName("AutoHotkey Help ahk_class HH Parent")
F12::MsgBox % "HKL: " Format("{:#010x}", Lyt.GetInputHKL()) "`n№: " Lyt.GetNum() " in system loaded list"
 . "`nLayoutName: " Lyt.GetLayoutName() "`nLocale: " Lyt.GetLocaleName()
 . " (" Lyt.GetLocaleName(,, true) ")`n" Lyt.GetList()[3].KLID
; . "`n" Lyt.GetList()[2].LayoutName " " Lyt.GetList()[2].LocName " " Lyt.GetList()[2].LocFullName
Esc::ExitApp

#include %A_ScriptDir%\..\class_lyt.ahk