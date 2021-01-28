#include _guiCreate.ahk
main := _GuiCreate("+resize").onEvent("close", "exitapp").onEvent("size", Gui_Size(GuiObj, MinMax, Width, Height) => tooltip(Width  "`t"  Height))
list := main.Add("DropDownList", "vddl", "Red|Green|Blue").OnEvent("Change", "listChange")
main.show()

Msgbox(list.hwnd)

listChange(ctrl) {
    MsgBox(ctrl.text)
}