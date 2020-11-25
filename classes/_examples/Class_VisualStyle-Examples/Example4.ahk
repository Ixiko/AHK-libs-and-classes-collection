#NoEnv
#NoTrayIcon
#Include <Class_VisualStyle>

SendMode Input
SetBatchLines -1

posY := ((A_ScreenHeight - 600) - 50)

Wizard  := new VisualStyle()
WizProp := Wizard.WinCreate("AutoHotkey Setup", "Back", "Next", "ButtonCancel", icon, 50, posY, 600, 400)
hwnd1   := WizProp.hwnd
hPrev   := WizProp.NavBtn
hNext   := WizProp.CmdBtnNext
hCancel := WizProp.CmdBtnCancel

AutoHotkeyKey := "SOFTWARE\AutoHotkey"
DetermineVersion()
type := DefaultType="ANSI" ? "ANSI 32-bit" : "Unicode " (DefaultType="x64"?"64":"32") "-bit"

	HeaderFont	:= Wizard.GetFontProperties("AEROWIZARD", AW_HEADERAREA)
	ContentFont	:= Wizard.GetFontProperties("AEROWIZARD", AW_CONTENTAREA)
	LinkFont	:= Wizard.GetFontProperties("TEXTSTYLE", TEXT_HYPERLINKTEXT, TS_HYPERLINK_DISABLED)
	cbxpFont	:= Wizard.GetFontProperties("CONTROLPANEL", CPANEL_SECTIONTITLELINK, CPSTL_NORMAL)
	cbxsFont	:= Wizard.GetFontProperties("CONTROLPANEL", CPANEL_TASKLINK, CPTL_NORMAL)

Wizard.PagingCreate(6)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wizard.PageAdd(1)

Gui %hWnd1%: Font, % "s" HeaderFont.Size " c" HeaderFont.Color,
Gui %hwnd1%: Add, Text, x40 y50, % "Install " CurrentName " v" CurrentVersion " to your computer"

Gui %hWnd1%: Font, % "s" ContentFont.Size " c" ContentFont.Color,
Gui %hwnd1%: Add, Text, xp y+15, Please select the type of installation you wish to perform.

Ext := Wizard.GetTextExtent("Express Installation", "BUTTON", 6, 0, "")
Wizard.CommandLink("AnsiorUni", "p", "+30", (600-80), (Ext.H+55), "Express Installation", "Default version:  " type "`nInstall in:  " A_ProgramFiles "\AutoHotkey", 1)
Wizard.CommandLink("AnsiorUni", "p", "+5" , "p", (Ext.H+20), "Custom Installation", "")

Gui %hWnd1%: Font, % " c" LinkFont.Color,
Gui %hwnd1%: Add, Text, % "x40 y" (390-(DWM_WINEXTENT*2)), AutoHotkey is open source software:

Wizard.ContentLink(CurrentPath "\license.txt", "read license", "+1", "p") 

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wizard.PageAdd(2)

Gui %hWnd1%: Font, % "s" HeaderFont.Size " c" HeaderFont.Color,
Gui %hwnd1%: Add, Text, x40 y50, % "Make changes to " CurrentName " v" CurrentVersion " (" type ")"

Gui %hWnd1%: Font, % "s" ContentFont.Size " c" ContentFont.Color,
Gui %hwnd1%: Add, Text, xp y+15, What do you want to do?

Ext := Wizard.GetTextExtent("Reinstall (download required)", "AEROWIZARD", AW_HEADERAREA, 0, "")
Wizard.CommandLink("TestButton2", "p", "+20", (600-80), (Ext.H+20), "Reinstall (dowload required)", "")
Wizard.CommandLink("TestButton2", "p", "+5" , (600-80), (Ext.H+20), "Modify", "", 1)
Wizard.CommandLink("TestButton2", "p", "+5" , (600-80), (Ext.H+20), "Uninstall", "")

Wizard.ContentLink("gExtract", "extract to...", "p", (390-(DWM_WINEXTENT*2))) 

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wizard.PageAdd(3)

Gui %hWnd1%: Font, % "s" HeaderFont.Size " c" HeaderFont.Color,
Gui %hwnd1%: Add, Text, x40 y50, Select an AutoHotkey installation

Gui %hWnd1%: Font, % "s" ContentFont.Size " c" ContentFont.Color,
Gui %hwnd1%: Add, Text, xp y+15, Which version of AutoHotkey.exe should run by default?

Ext := Wizard.GetTextExtent("Recommended for new installations/scripts.", "AEROWIZARD", AW_HEADERAREA, 0, "")
Wizard.CommandLink("AnsiorUni", "p", "+30", (600-80), (Ext.H+50), "Unicode 32-bit", "Recommended for new installations/scripts.", 1)
Wizard.CommandLink("AnsiorUni", "p", "+5" , (600-80), "p", "ANSI 32-bit", "Better compatibility with some legacy scripts.")

Wizard.ContentLink("gTestButton3", "More information", "p", (390-(DWM_WINEXTENT*2)))

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wizard.PageAdd(4)

Gui %hWnd1%: Font, % "s" HeaderFont.Size " c" HeaderFont.Color,
Gui %hwnd1%: Add, Text, x40 y50, Select additional options for AutoHotkey installation

Gui %hWnd1%: Font,,

Gui %hWnd1%: Font, % "s" cbxpFont.Size, % cbxpFont.Name
Gui %hwnd1%: Add, Checkbox, Checked xp y+15, Install script compiler

Gui %hWnd1%: Font, % "s" cbxsFont.Size " c" cbxsFont.Color,
Ext := Wizard.GetTextExtent("Install script compiler", "CONTROLPANEL", 11, 0, "")
Gui %hwnd1%: Add, Text, % "xp+18 yp+" Ext.H, Installs Ahk2Exe, a tool to convert any .ahk script into a stand-alone EXE.`nAlso adds a "Compile" option to .ahk context menus.

Gui %hWnd1%: Font,,

Gui %hWnd1%: Font, % "s" cbxpFont.Size, % cbxpFont.Name
Gui %hwnd1%: Add, Checkbox, Checked x40 y+15, Enable drag `&& drop

Gui %hWnd1%: Font, % "s" cbxsFont.Size " c" cbxsFont.Color,
Ext := Wizard.GetTextExtent("Enable drag `& drop", "CONTROLPANEL", 11, 0, "")
Gui %hwnd1%: Add, Text, % "xp+18 yp+" Ext.H, Files dropped onto a .ahk script will launch that script (the files will be passed as`nparameters). This can lead to accidental launching so you may wish to disable it.

Gui %hWnd1%: Font,,

Gui %hWnd1%: Font, % "s" cbxpFont.Size, % cbxpFont.Name
Gui %hwnd1%: Add, Checkbox, Checked x40 y+15, Separate taskbar buttons

Gui %hWnd1%: Font, % "s" cbxsFont.Size " c" cbxsFont.Color,
Ext := Wizard.GetTextExtent("Enable drag `& drop", "CONTROLPANEL", CPANEL_SECTIONTITLELINK, "", "")
Gui %hwnd1%: Add, Link, % "xp+18 yp+" Ext.H " gMyFunction"
, Causes each script which has visible windows to be treated as a separate program, but`nprevents AutoHotkey.exe from being pinned to the taskbar. <a id="/docs/Program.htm#Installer_IsHostApp">[help]</a>

Gui %hWnd1%: Font,,

Gui %hWnd1%: Font, % "s" cbxpFont.Size, % cbxpFont.Name
Gui %hwnd1%: Add, Checkbox, x40 y+15, Add 'Run with UI Access' to context menus

Gui %hWnd1%: Font, % "s" cbxsFont.Size " c" cbxsFont.Color,
Ext := Wizard.GetTextExtent("Enable drag `& drop", "CONTROLPANEL", 11, 0, "")
Gui %hwnd1%: Add, Link, % "xp+18 yp+" Ext.H " gMyFunction", UI Access enables scripts to automate administrative programs. <a id="/docs/Program.htm#Installer_uiAccess">[help]</a>

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wizard.PageAdd(5)

Gui %hWnd1%: Font, % "s" HeaderFont.Size " c" HeaderFont.Color,
Gui %hwnd1%: Add, Text, x40 y50 hwndhText11, Removing AutoHotkey installation

Gui %hWnd1%: Font, % "s" ContentFont.Size " c" ContentFont.Color,
Gui %hwnd1%: Add, Text, xp y+20, This shouldn't take long...

Gui %hwnd1%: Add, Progress, xp+80 y+30 w360 h15 hWndhPrg -Smooth, 0

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wizard.PageAdd(6)

Gui %hWnd1%: Font, % "s" HeaderFont.Size " c" HeaderFont.Color,
Gui %hwnd1%: Add, Text, x40 y50, Installation complete

Ext := Wizard.GetTextExtent("View Changes `& New Features", "AEROWIZARD", AW_HEADERAREA, 0, "")
Wizard.CommandLink("TestButton4", "p", "+20",(600-80), (Ext.H+23), "View Changes `& New Features", "", 1)
Wizard.CommandLink("TestButton5", "p", "+7", (600-80), (Ext.H+23), "View the Tutorial", "")
Wizard.CommandLink("TestButton6", "p", "+7", (600-80), (Ext.H+23), "Run AutoHotkey", "")
Wizard.CommandLink("GuiClose"   , "p", "+7", (600-80), (Ext.H+23), "Exit", "")

Gui %hWnd1%: Font, % "s" LinkFont.Size " c" LinkFont.Color,
Gui %hwnd1%: Add, Text, % "x40 y" . (390-(DWM_WINEXTENT*2)), Did you know AutoHotkey has a

Wizard.ContentLink("gViewWebsite", "new home", "+2", "p") 

Gui %hwnd1%: Add, Text, x+1 yp+1, ?

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wizard.WinShow()
Return

ButtonCancel:
GuiClose:
	if (A_GuiEvent = "Normal") and (A_EventInfo = 0x0000)
		ExitApp
Return

Back:
	Gui %hWnd1%: Submit, NoHide

	pBtnSt := (PageCtrl <= 2) ? 1 : 0
	nBtnSt := (PageCtrl <= 4) ? 0 : 1

	GuiControl, Disable%nBtnSt%, %hNext%
	GuiControl, Disable%pBtnSt%, %hPrev%
	GuiControl,, %hNext%, Next
	Wizard.PageChoose(PageCtrl - 1)		
Return 	

Next:
	if (lastButton = "Uninstall")
	{
		GoSub, UnInstall
		Return
	}

	if (lastButton = "Express Installation")
	{
		Ext := Wizard.GetTextExtent("Installing " CurrentName " v" CurrentVersion " (" type ")", "AEROWIZARD", AW_HEADERAREA, 0, "")
		GuiControl, Move, %hText11%, % "w" Ext.W
		GuiControl,, %hText11%, % "Installing " CurrentName " v" CurrentVersion " (" type ")"
		GoSub, UnInstall
		Return 
	}

	if (lastButton = "Reinstall (dowload required)")
	{
		Ext := Wizard.GetTextExtent("Downloading Updates...", "AEROWIZARD", AW_HEADERAREA, 0, "")
		GuiControl, Move, %hText11%, % "w" Ext.W
		GuiControl,, %hText11%, Downloading Updates...
		GoSub, UnInstall
		Return 
	}

	Gui %hWnd1%: Submit, NoHide

	nBtnSt := (PageCtrl >= 3) ? 1 : 0
	pBtnSt := (PageCtrl >= 1) ? 0 : 1

	if ((PageCtrl + 1) < 4)
	{	
		GuiControl, Disable%nBtnSt%, %hNext%
		GuiControl, Disable%pBtnSt%, %hPrev%
		Wizard.PageChoose(PageCtrl + 1)
	}

	if ((PageCtrl + 1) = 4)
	{
		GuiControl,, %hNext%, Install	
		GuiControl, Disable%pBtnSt%, %hPrev%
		Wizard.PageChoose(PageCtrl + 1)
	}
	
	if ((PageCtrl + 1) = 5)
	{
		lastButton := "Express Installation"
		GoSub, Next
	}
Return

TestButton2:
	if (A_GuiEvent = "Normal") and (A_EventInfo = 0x0000)
	{

		if (hControl_p1)
			Wizard.ButtonSetImage(hControl_p1)
		
		GuiControlGet, hControl_p1, Hwnd, %A_GuiControl%

		lastButton := A_GuiControl

		Wizard.ButtonSetImage(hControl_p1, "C:\Windows\system32\netshell.dll", 98, 16)
	}
Return

TestButton3:
	ViewHelp("/docs/Compat.htm#Format")
Return

TestButton4:
	if (A_GuiEvent = "Normal") and (A_EventInfo = 0x0000)
		ViewHelp("/docs/AHKL_ChangeLog.htm")
Return

TestButton5:
	if (A_GuiEvent = "Normal") and (A_EventInfo = 0x0000)
		ViewHelp("/docs/Tutorial.htm")
Return

TestButton6:
	if (A_GuiEvent = "Normal") and (A_EventInfo = 0x0000)
		Run, % A_ProgramFiles "\AutoHotkey\installer.ahk /exec runahk"
Return

ViewWebsite:
	Run_("https://autohotkey.com/")
Return 

Extract:
	FileSelectFolder, dstDir,,, Select a folder to copy program files to.
	if ErrorLevel
		Return
	else
		MsgBox, 0x2030, AutoHotkey Setup, This is just an example.
Return 

AnsiorUni:
	if (A_GuiEvent = "Normal") and (A_EventInfo = 0x0000)
	{
		if (hControl_p2)
			Wizard.ButtonSetImage(hControl_p2)
		
		GuiControlGet, hControl_p2, Hwnd, %A_GuiControl%

		lastButton := A_GuiControl
		
		Wizard.ButtonSetImage(hControl_p2, "C:\Windows\system32\netshell.dll", 98, 16)
	}
Return

UnInstall:
	GuiControl, Hide, %hNext%
	GuiControl, Disable, %hPrev%
	
	Wizard.PageChoose(5)
	
	if (lastButton = "Reinstall (dowload required)")
	{
		Loop, 100
		{
			GuiControl,, %hPrg%, +1
			Sleep, 10
		}

		Ext := Wizard.GetTextExtent("Installing " CurrentName " v" CurrentVersion " (" type ").", "AEROWIZARD", AW_HEADERAREA, 0, "")
		GuiControl, Move, %hText11%, % "w" Ext.W
		GuiControl,, %hText11%, % "Installing " CurrentName " v" CurrentVersion " (" type ")."
	}
	
	Wizard.ProgBarSetState(hPrg, "Marquee")
	
	Sleep, 7000

	Wizard.ProgBarSetState(hPrg, "Marquee", 0)
		
	Wizard.PageChoose(6)

	GuiControl,, %hCancel%, Close	
Return

MyFunction(CtrlHwnd, GuiEvent, LinkIndex, HrefOrID)
{
	ViewHelp(HrefOrID)
}

; **************************************************************************************************************************************************;
; The folowing functions courtesy of AutoHotkey installer.  Thanks Lexicos!
; ==================================================================================================================================================;
DetermineVersion() {
	global
	local url, v
	; This first section has two purposes:
	;  1) Determine the location of any current installation.
	;  2) Determine which view of the registry it was installed into
	;     (only applicable if the OS is 64-bit).
	CurrentRegView := ""
	Loop % (A_Is64bitOS ? 2 : 1) {
		SetRegView % 32*A_Index
		RegRead CurrentPath, HKLM, %AutoHotkeyKey%, InstallDir
		if !ErrorLevel {
			CurrentRegView := A_RegView
			break
		}
	}
	if ErrorLevel {
		CurrentName := ""
		CurrentVersion := ""
		CurrentType := ""
		CurrentPath := ""
		CurrentStartMenu := ""
		return
	}
	RegRead CurrentVersion, HKLM, %AutoHotkeyKey%, Version
	RegRead CurrentStartMenu, HKLM, %AutoHotkeyKey%, StartMenuFolder
	RegRead url, HKLM, %UninstallKey%, URLInfoAbout
	; Identify by URL since uninstaller display name is the same:
	if (url = "http://www.autohotkey.net/~Lexikos/AutoHotkey_L/"
		|| url = "http://l.autohotkey.net/")
		CurrentName := "AutoHotkey_L"
	else
		CurrentName := "AutoHotkey"
	; Identify which build is installed/set as default:
	FileAppend ExitApp `% (A_IsUnicode=1) << 8 | (A_PtrSize=8) << 9, %A_Temp%\VersionTest.ahk
	RunWait %CurrentPath%\AutoHotkey.exe "%A_Temp%\VersionTest.ahk",, UseErrorLevel
	if ErrorLevel = 0x300
		CurrentType := "x64"
	else if ErrorLevel = 0x100
		CurrentType := "Unicode"
	else if ErrorLevel = 0
		CurrentType := "ANSI"
	else
		CurrentType := ""
	FileDelete %A_Temp%\VersionTest.ahk
	; Set some default parameter based on current installation:
	if CurrentType
		DefaultType := CurrentType
	DefaultPath := CurrentPath
	DefaultStartMenu := CurrentStartMenu
	DefaultCompiler := FileExist(CurrentPath "\Compiler\Ahk2Exe.exe") != ""
	RegRead v, HKCR, %FileTypeKey%\ShellEx\DropHandler
	DefaultDragDrop := ErrorLevel = 0
	RegRead v, HKCR, Applications\AutoHotkey.exe, IsHostApp
	DefaultIsHostApp := !ErrorLevel
	RegRead v, HKCR, %FileTypeKey%\Shell\uiAccess\Command
	DefaultUIAccess := !ErrorLevel && UACIsEnabled
	RegRead v, HKCR, %FileTypeKey%\Shell\Open\Command
	DefaultToUTF8 := InStr(v, " /CP65001 ") != 0
}

ViewHelp(topic) {
	local path
	if FileExist(A_ScriptDir "\AutoHotkey.chm")
		path := A_ScriptDir "\AutoHotkey.chm"
	else
		path := CurrentPath "\AutoHotkey.chm"
	if FileExist(path)
		Run_("hh.exe", "mk:@MSITStore:" path "::" topic)
	else
		Run_("https://autohotkey.com" topic)
}

Run_(target, args:="", workdir:="") {
	try
		ShellRun(target, args, workdir)
	catch e
		Run % args="" ? target : target " " args, % workdir
}

RunAutoHotkey() {
	; Setup may be running as a user other than the one that's logged
	; in (i.e. an admin user), so in addition to running AutoHotkey.exe
	; in user mode, have it call the function below to ensure the script
	; file is correctly located.
	Run_("AutoHotkey.exe", """" A_AhkPath "\Installer.ahk"" /exec runahk")
}

ShellRun(prms*)
{
	shellWindows := ComObjCreate("Shell.Application").Windows
	VarSetCapacity(_hwnd, 4, 0)
	desktop := shellWindows.FindWindowSW(0, "", 8, ComObj(0x4003, &_hwnd), 1)
	if ptlb := ComObjQuery(desktop
		, "{4C96BE40-915C-11CF-99D3-00AA004AE837}"  ; SID_STopLevelBrowser
		, "{000214E2-0000-0000-C000-000000000046}") ; IID_IShellBrowser
	{
		if DllCall(NumGet(NumGet(ptlb+0)+15*A_PtrSize), "ptr", ptlb, "ptr*", psv:=0) = 0
		{
			VarSetCapacity(IID_IDispatch, 16)
			NumPut(0x46000000000000C0, NumPut(0x20400, IID_IDispatch, "int64"), "int64")
			DllCall(NumGet(NumGet(psv+0)+15*A_PtrSize), "ptr", psv
				, "uint", 0, "ptr", &IID_IDispatch, "ptr*", pdisp:=0)
			shell := ComObj(9,pdisp,1).Application
			shell.ShellExecute(prms*)
			ObjRelease(psv)
		}
		ObjRelease(ptlb)
	}
}