; Usage: BlockSysMenu(ControlHwnd)
BlockSysMenu(wParam:="", lParam:="", msg:="", hwnd:="") {
	static oHwnd := {}, WM_RBUTTONUP := 0x205, WM_CONTEXTMENU := 0x7B
	     , ____a := OnMessage(WM_RBUTTONUP, "BlockSysMenu")
	     , ____b := OnMessage(WM_CONTEXTMENU, "BlockSysMenu")
	If !hwnd
		Return oHwnd[wParam] := 1
	If oHwnd[hwnd] || !oHwnd.MaxIndex() {
		If IsLabel("GuiContextMenu") || IsFunc("GuiContextMenu")
			SetTimer, GuiContextMenu, -0
		Return 0
	}
}