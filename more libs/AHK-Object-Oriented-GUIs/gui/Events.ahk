GuiClose(GuiHwnd) {
	if GuiInstance := GuiBase.GetGui(GuiHwnd)
		GuiInstance.Close.Call(GuiInstance)
	
}

GuiEscape(GuiHwnd) {
	if GuiInstance := GuiBase.GetGui(GuiHwnd)
		GuiInstance.Escape.Call(GuiInstance)
	
}

GuiSize(GuiHwnd, EventInfo, Width, Height) {
	if GuiInstance := GuiBase.GetGui(GuiHwnd)
		return GuiInstance.Size.Call(GuiInstance, EventInfo, Width, Height)
}

GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
	if GuiInstance := GuiBase.GetGui(GuiHwnd)
		return GuiInstance.DropFiles.Call(GuiInstance, FileArray, GuiInstance.GetControl(CtrlHwnd), X, Y)
}

GuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y) {
	if GuiInstance := GuiBase.GetGui(GuiHwnd)
		return GuiInstance.ContextMenu.Call(GuiInstance, GuiInstance.GetControl(CtrlHwnd), EventInfo, IsRightClick, X, Y)
}