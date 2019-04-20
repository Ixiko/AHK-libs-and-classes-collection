splashImageGUI(Picture, X, Y, tColor, Transparent = true)
{
	Gui, XPT99:Margin , 0, 0
	Gui, XPT99:Add, Picture,, %Picture%
	Gui, XPT99:Color, %tColor%
	Gui, XPT99: +LastFound 
	WinSet, ExStyle, +0x80020
	If Transparent
		Winset, TransColor, %tColor%
	Gui, XPT99:-Caption +AlwaysOnTop +ToolWindow -Border 
	Gui, XPT99:Show, x%X% y%Y% NoActivate

}