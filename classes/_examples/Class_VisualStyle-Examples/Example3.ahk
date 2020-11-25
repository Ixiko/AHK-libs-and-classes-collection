#NoEnv
#NoTrayIcon
#Include <Class_VisualStyle>

SendMode Input
SetBatchLines -1

Window := new VisualStyle()
WinProp  := Window.WinCreate("Content Link Example", "", "", "GuiClose", "", ((A_ScreenWidth/2)-150), 50, 300, 200, "Win")

HeaderFont	:= Window.GetFontProperties("AEROWIZARD", AW_HEADERAREA)
ContentFont	:= Window.GetFontProperties("AEROWIZARD", AW_CONTENTAREA)

Gui, % WinProp.hwnd ": Font", % "s" HeaderFont.Size " c" HeaderFont.Color,
Gui, % WinProp.hwnd ": Add", Text, x10 y10, To test, click the content links below

Gui, % WinProp.hwnd ": Font", % "s" ContentFont.Size " c" ContentFont.Color,

Window.ContentLink("https://www.autohotkey.com","AutoHotkey", "p", "+10", "SECTIONTITLELINK")
Window.ContentLink("https://autohotkey.com/board/topic/28522-help-with-extending-client-area-in-vista-gui/","Original Post", "p", "+10", "CONTENTLINK") 
Window.ContentLink("https://www.google.com","", "p", "+10", "TASKLINK")
Window.ContentLink("https://www.yahoo.com","", "p", "+10", "HELPLINK")

GuiControl,, % WinProp.CmdBtnCancel, OK
Window.WinShow()
Return 

GuiClose:
ExitApp
