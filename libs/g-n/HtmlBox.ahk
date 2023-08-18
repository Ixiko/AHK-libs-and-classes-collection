HtmlBox(HTML, Title="HtmlBox", Body=True, Full=False, URL=False, width=300, height=200)
{ ; Creates a MsgBox style GUI that has embedded HTML
	global MsgBoxOK, MsgBoxActiveX, MsgBoxFull=Full
	
	; Set up the GUI
	Gui, +HwndDefault
	Gui, MsgBox:New, +HwndMsgBox +Resize +MinSize +LabelMsgBox 
	if Full
		Gui, Margin, 0, 0
	else
		Gui, Margin, 10, 10
	
	; Embed IE
	Gui, Add, ActiveX, w%width% h%height% vMsgBoxActiveX, Shell.Explorer
	
	; If the HTML is actually a URL
	if URL
	{
		MsgBoxActiveX.Navigate(HTML)
		while MsgBoxActiveX.ReadyState < 3
			Sleep, 50
	}
	else
	{
		MsgBoxActiveX.Navigate("about:blank")
		while MsgBoxActiveX.ReadyState < 3
			Sleep, 50
		if Body
			HTML = 
			(
				<!DOCTYPE HTML>
				<html>
					<head>
						<style>html{overflow:hidden;}</style>
					</head>
					<body>
						%HTML%
					</body>
				</html>
			)
		MsgBoxActiveX.Document.Write(HTML)
	}
	
	; Add OK button
	if !Full
		Gui, Add, Button, % "x" width/2+50 " w80 h20 vMsgBoxOK gMsgBoxClose", OK
	
	; Show and reset default GUI
	Gui, Show,, %Title%
	Gui, %Default%:Default
	
	; Wait for window to close
	WinWaitActive, ahk_id %MsgBox%
	WinWaitClose, ahk_id %MsgBox%
	return
	
	MsgBoxEscape:
	MsgBoxClose:
	Gui, Destroy
	return
	
	MsgBoxSize:
	if !(A_GuiWidth || A_GuiHeight) ; Minimized
		return
	if MsgBoxFull
		GuiControl, Move, MsgBoxActiveX, % "w" A_GuiWidth "h" A_GuiHeight
	else
	{
		GuiControl, Move, MsgBoxActiveX, % "w" A_GuiWidth - 20 "h" A_GuiHeight - 50
		GuiControl, MoveDraw, MsgBoxOK, % "x" A_GuiWidth / 2 - 40 "y" A_GuiHeight - 30
	}
	return
}