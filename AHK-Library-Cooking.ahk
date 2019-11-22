; ===============================================================
; 	*** AHK-Library-Cooking ***                                                      V0.2 Oktober 31, 2019 by Ixiko
; ===============================================================
; ------------------------------------------------------------------------------------------------------------
; 		This is a try and this is only the beginning of an  - Autohotkey library manager -
;		Yes, there are already these tools. But none of them can cook a new library!
;		Do you read me? ....... No?
;
;		It should take a little bit of this and that. Then it should take a little more of other things and
;		when it is almost done it looks again into the cookbook if not yet an ingredient is missing.
; ------------------------------------------------------------------------------------------------------------
;		And I sincerely hope that I get this magic programmed. Because one thing has always bothered
;		me. Now we have this library with 2500 and more cookbooks, but there is only this old
;		grease-roll on which the names and the chapters of the books are written. I have to borrow 5,
;		10, 15 books to cook a tasty dish! But I just want to have a few copies from the books and I
;		want to know how many duplicate or damn similar recipes are in the books. Most frightening
;		is the search for the one unique recipe, especially if I forgot the damn name.
; ------------------------------------------------------------------------------------------------------------

;{01. script parameters

		#NoEnv
		#Persistent
		#SingleInstance, Force
		#InstallKeybdHook
		#MaxThreads, 250
		#MaxThreadsBuffer, On
		#MaxHotkeysPerInterval 99000000
		#HotkeyInterval 99000000
		#KeyHistory 1
		;ListLines Off

		SetTitleMatchMode     	, 2
		SetTitleMatchMode     	, Fast
		DetectHiddenWindows	, Off
		CoordMode                 	, Mouse, Screen
		CoordMode                 	, Pixel, Screen
		CoordMode                 	, ToolTip, Screen
		CoordMode                 	, Caret, Screen
		CoordMode                 	, Menu, Screen
		SetKeyDelay                	, -1, -1
		SetBatchLines           		, -1
		SetWinDelay                	, -1
		SetControlDelay          	, -1
		SendMode                   	, Input
		AutoTrim                     	, On
		FileEncoding                	, UTF-8

		OnExit("TheEnd")

		Menu, Tray, Icon				, % "hIcon: " Create_GemSmall_png(true)
	;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	; Script Prozess ID
	;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		scriptPID:= DllCall("GetCurrentProcessId")

;}

;{02. variables

		AHKFiles                     	:= Array()    	; indexed array of AHKRare.ahk file, index is corresponding to line number
		RC		                    	:= Object()
		GuiW                       	:= 1200       	; base width of gui on first start
		SR1Width                	:= 250
		highlight                  	:= false        	; flag to highlight search results

		global AHKData         	:= Object()	; contains data from AHKRare.ahk
		global FoundIndex   	:= 0          	; a flag
		global currentFuncNr                  	; contains the currently selected function nr
		global fdecr1, fdecr2
		global EditorPath			:= "C:\Program Files\AutoHotkey\SciTE\Scite.exe"


	; ------------------------------------------------------------------------------------------------------------------------------------------------------------
	;	loading AHK-Rare.txt
	; ------------------------------------------------------------------------------------------------------------------------------------------------------------;{
		If FileExist(A_ScriptDir . "\AHK-FuncReference.txt")
			AHKFiles:= RareLoad(A_ScriptDir "\AHK-FuncReference.txt")
		else
		{
				IniRead, filepattern, % A_ScriptDir "\AHK-Library-Cooking.ini", Properties, RareFolder
				If Instr(filepattern, "ERROR")
				{
						;FileSelectFolder, StartFolder, D:\Eigene Dateien\Eigene Dokumente\AutoIt Scripte\GitHub\AHK-libs-and-classes-collection\lib-a_to_h,, % "Please enter the start folder for function indexing!"
						StartFolder = D:\Eigene Dateien\Eigene Dokumente\AutoIt Scripte\GitHub\AHK-libs-and-classes-collection
						;StartFolder = D:
						If StrLen(StartFolder)=0
							ExitApp

						files:= FileIndexer(Startfolder)
						FuncIndexing(files)
				}

				ExitApp
				;AHKFiles:= RareLoad(filepattern)
		}
	;}

	; ------------------------------------------------------------------------------------------------------------------------------------------------------------
	;	get the last gui size
	; ------------------------------------------------------------------------------------------------------------------------------------------------------------;{
		IniRead, GuiOptions, % A_ScriptDir "\AHK-Library-Cooking.ini", Properties, GuiOptions
		If !Instr(GuiOptions, "Error") && !(GuiOptions = "")
		{
			GuiOptions	:= StrSplit(GuiOptions, "|")
			GuiW       	:= GuiOptions.3
		}

		IniRead, SearchMode, % A_ScriptDir "\AHK-Library-Cooking.ini", Properties, SearchMode
			If Instr(SearchMode, "Error") || (SearchMode = "")
				SearchMode:= "Basic"
	;}

	; ------------------------------------------------------------------------------------------------------------------------------------------------------------
	;	Settings array for the RichCode control (code & examples)
	; ------------------------------------------------------------------------------------------------------------------------------------------------------------;{
		Settings :=
		( LTrim Join Comments
		{
		"TabSize"         	: 4,
		"Indent"           	: "`t",
		"FGColor"         	: 0xEDEDCD,
		"BGColor"        	: 0x172842,
		"Font"              	: {"Typeface": "Bitstream Vera Sans Mono", "Size": 10},
		"WordWrap"    	: False,

		"UseHighlighter"	: True,
		"HighlightDelay"	: 200,

		"Colors": {
			"Comments"	:	0x7F9F7F,
			"Functions"  	:	0x7CC8CF,
			"Keywords"  	:	0xE4EDED,
			"Multiline"   	:	0x7F9F7F,
			"Numbers"   	:	0xF79B57,
			"Punctuation"	:	0x97C0EB,
			"Strings"      	:	0xCC9893,

			; AHK
			"A_Builtins"   	:	0xF79B57,
			"Commands"	:	0xCDBFA3,
			"Directives"  	:	0x7CC8CF,
			"Flow"          	:	0xE4EDED,
			"KeyNames"	:	0xCB8DD9,
			"Descriptions"	:	0xF0DD82,
			"Link"           	:	0x47B856,

			; PLAIN-TEXT
			"PlainText"		:	0x7F9F7F
			}
		}
		)

;}
;}

;{03. draw primary gui

		If A_ScreenWidth>1920 && A_ScreenHeight>1080
		{
			fdecr1:= 1, fdec2:=4
			Logo:= Create_AHKRareGuiLogo2k_png(true)
		}
		else
		{
			fdecr1:= 0, fdecr2:=0
			Logo:= Create_AHKRareGuiLogo4k_png(true)
		}

		global hArg, ARG, hSearch, hTabs
		Gui, ARG: NEW
		Gui, ARG: +LastFound +HwndhARG +Resize -DPIScale
		Gui, ARG: Margin, 0, 0
		;Gui, ARG: Color, 172842
	;-: --------------------------------------
	;-: Logo and Backgroundcolouring
	;-: --------------------------------------
		Gui, ARG: Add, Progress        	, % "x0 y0 w" (GuiW) " h" (Logo.height + 5) " c172842 Disabled vBGColorLogo" , 100
		Gui, ARG: Add, Pic                	, % "x10 y10 BackgroundTrans"  	, % "HBITMAP: " logo.hBitmap
		Gui, ARG: Add, Progress        	, % "x" (logo.width + 10) " y0 w2 h" (Logo.height + 5) , 100
		Gui, ARG: Font, % "S" 7-fdecr1 " CWhite q5"
		Gui, ARG: Add, Text	                , % "x" (Logo.width - 201) " y6 w200 Right vStats2 BackgroundTrans"                   	, % ""
		Gui, ARG: Font, % "S" 7-fdecr1 " c9090FF q5"
		Gui, ARG: Add, Text	                , % "x" (Logo.width - 201) " y+0 w200 Right vStats1 BackgroundTrans"                	, % ""
	;-: --------------------------------------
	;-: temp. text controls
	;-: --------------------------------------
		Gui, ARG: Font, % "S" 12-fdecr2 " Normal CWhite q5"
		Gui, ARG: Add, Text	                , % "x" (Logo.width + 30) " y20 vField1 BackgroundTrans"                                  	, % "  . . . . . create index: "
		GuiControlGet, Field_, ARG: Pos, Field1
		Gui, ARG: Add, Text              	, % "x" (Field_X + Field_W + 3) " y20 w300 vField2 Center BackgroundTrans "    	, % "00.00.000001"
	;-: --------------------------------------
	;-: Edit control for search patterns
	;-: --------------------------------------
		SW:= Logo.width + 20
		Gui, ARG: Font, % "S" 10-fdecr2 " Normal CBlack q5"
		Gui, ARG: Add, DDL             	, % "x" (SW) " y50 vSMode HWNDhSAlgo E0x4000"                                       	, % "Basic|RegEx"				;E0x4000
		GuiControl, ChooseString, SMode, % SearchMode
		Gui, ARG: Font, % "S" 11-fdecr2 " Italic CAAAAAA q5"
		GuiControlGet, SA_, ARG: Pos, SMode
		Gui, ARG: Add, Edit              	, % "x" (SW+SA_W+5) " y50 w500 r1 vLVExpression HWNDhSearch -Theme"          	, % "type your search pattern here"
		GuiControlGet, LVExpression_, ARG: Pos, LVExpression
		PostMessage, 0x153, -1, % LVExpression_H - 5,, ahk_id %hSAlgo%  ; sets the height of DDL
		Gui, ARG: Font, % "S" 16-fdecr2*2 " Normal CWhite q5"
		Gui, ARG: Add, Text             	, % "x" (SW) " y5   w300 vGB1    HWNDhGB1 Border BackgroundTrans"        	, % ""
		Gui, ARG: Add, Text             	, % "x" (SW + 10) " y12 w300 vField3 HWNDhField3 -Wrap BackgroundTrans"	, % ""
		Edit_SetMargins(hField3, 40, 20)
		Edit_SetMargins(hSearch, 20, 20)
		;CTLCOLORS.Attach(hSAlgo, "677892")
	;-: --------------------------------------
	;-: Functions Listview
	;-: --------------------------------------
		Gui, ARG: Font, % "S" 9-fdecr1 " Normal CDefault q5"
		Gui, ARG: Add, Listview        	, % "xm y" (Logo.height + 15) " w" GuiW+5 " r15 HWNDhLVFunc vLVFunc gShowFunction AltSubmit Section", main section|function name|short description|function nr.
		Gui, ARG: Font, % "S" 8-fdecr1 " CDefault q5"
		GuiControlGet, LV_, ARG: Pos, LVFunc
	;-: --------------------------------------
	;-: Short description section
	;-: --------------------------------------
		Gui, ARG: Add, Edit                	, % "xm y" (LV_Y + LV_H + 10) " w" SR1Width " r20 t8 HWNDhShowRoom1 vShowRoom1"
		GuiControlGet, SR_, ARG: Pos, ShowRoom1
	;-: --------------------------------------
	;-: Code highlighted RichEdit control
	;-: --------------------------------------
		Gui, ARG: Add, Tab              	,        % "x" (SR1Width+5) " y" (LV_Y+LV_H+10) " w" (GuiW-SR1Width-5) " h" SR_H-10 " HWNDhTabs vShowRoom2", FUNCTION CODE|EXAMPLE(s)|DESCRIPTION
		Gui, ARG: Tab, 1
		RC[1] := new RichCode(Settings, "ARG", "x" (SR1Width+5) " y" (LV_Y+LV_H+30) " w" (GuiW-SR1Width-5) " h" SR_H-30, 0)
		Gui, ARG: Tab, 2
		RC[2] := new RichCode(Settings, "ARG", "x" (SR1Width+5) " y" (LV_Y+LV_H+30) " w" (GuiW-SR1Width-5) " h" SR_H-30, 0)
		Gui, ARG: Tab, 3
		RC[3] := new RichCode(Settings, "ARG", "x" (SR1Width+5) " y" (LV_Y+LV_H+30) " w" (GuiW-SR1Width-5) " h" SR_H-30, 0)
		Gui, ARG: Tab
		WinRC := GetWindowInfo(RC[1].Hwnd)
	;-: --------------------------------------
	;-: Create a Statusbar - on Win 10 this Gui looks weird without a border
	;-: --------------------------------------
		Gui, ARG: Add, StatusBar, % "x0 y" WinRC.WindowY + 2 " vSB", % "clipboard is empty or does not contain a function"
		GuiControlGet, SB_, ARG: Pos, SB
	;-: --------------------------------------
	;-: Create a ToolTip control
	;-: --------------------------------------
		TT := New GuiControlTips(HARG)
		TT.SetDelayTimes(500, 3000, -1)
		Loop, 3
			TT.Attach(RC[A_Index].Hwnd, "Press the right`nmouse button`nto copy the text.", True)
	;-: --------------------------------------
	;-: Show the gui
	;-: --------------------------------------
		If !Instr(GuiOptions, "Error") && !(GuiOptions = "")
		{
				DPIFactor:= screenDims().DPI / 96
				If (GuiOptions.1 + GuiOptions.3)> A_ScreenWidth || (GuiOptions.2 + GuiOptions.4) > A_ScreenHeight
					Gui, ARG: Show, AutoSize xCenter yCenter, AHK-Rare_TheGui
				else
					Gui, ARG: Show, % "x" GuiOptions.1 " y" GuiOptions.2 " w" (GuiOptions.3) " h" (GuiOptions.4), AHK-Rare_TheGui
		}
		else
				Gui, ARG: Show, AutoSize xCenter yCenter, AHK-Rare_TheGui


		OnMessage(0x200, "OnMouseHover")
		OnMessage(0x03, "ChangeStats")
		OnClipboardChange("RareClipChanged")
		SetTimer, ShowStats, -500

;}

;{04. generate and fill listview with data

	; indexing AHK-Rare
		;AHKData:= RareIndexer(AHKFiles)
	; remove text controls
		GuiControl, ARG: Hide 	, Field1
		GuiControl, ARG: Hide 	, Field2
		GuiControl, ARG: Show	, Field3
	; populate listview with data from AHK-Rare.txt
		GuiControl, +Default, ARG: LVFunc
		For i, function in AHKData
			LV_Add("", function.mainsection, function.name, function.short, function.FnHash), fc:= A_Index
	; show's the sum of functions
		GuiControl, Text, Field3, % "displayed functions: " fc

;}

;{05. Hotkey(s)


	; RButton for getting text to clipboard
		Hotkey, IfWinActive, % "ahk_id " hARG
		Hotkey, ~RButton	, CopyTextToClipboard
		Hotkey, ^f           	, FocusSearchField
		Hotkey, ^s           	, FocusSearchField

	; Listview Hotkey's
		ListviewIsFocused:= Func("ControlIsFocused").Bind("SysListview321")
		Hotkey, If             	, % ListviewIsFocused
		Hotkey, ~Up           	, ListViewUp
		Hotkey, ~Down      	, ListViewDown

	; Edit Hotkey's
		SearchIsFocused:= Func("ControlIsFocused").Bind("Edit1")
		Hotkey, If             	, % SearchIsFocused
		Hotkey, ~Enter    	, GoSearch
		Hotkey, If

		Hotkey, ^#!r        	, ReloadScript

return
;}

;--------------------------------------------------------------------------------------------------------------

;{06. Gui-Labels
;--------------------------------------------------------------------------------------------------------------
ShowFunction:                 	;{

		toshow  	 := []
		selRow:= LV_GetNext(0)

		ShowFunctionsOnUpDown:
		LV_GetText(fnr, selRow , 4)

		For i, function in AHKData
			If Instr(function.FnHash, fnr)
					break

		currentFuncNr:= i

	; adding informations to Edit-Control (ShowRoom1)
		toshow[1]:= "FUNCTION:`n"                    	AHKData[i].name
		toshow[1].= "`n-----------------------------------------------------------------`n"
		toshow[1].= "SHORT DESCRIPTION:`n"    	AHKData[i].short
		toshow[1].= "`n-----------------------------------------------------------------`n"
		toshow[1].= "MAIN SECTION:`n"            	AHKData[i].mainsection
		toshow[1].= "`n-----------------------------------------------------------------`n"
		toshow[1].= "MAIN SECTION DESC.:`n"  	AHKData[i].mainsectionDescription
		toshow[1].= "`n-----------------------------------------------------------------`n"
		toshow[1].= "SUB SECTION:`n"                	AHKData[i].subsection
		toshow[1].= "`n-----------------------------------------------------------------`n"
		GuiControl, ARG:, ShowRoom1, % toshow[1]

	; populate function code tab and examples  tab
		RC[1].Settings.Highlighter := "HighlightAHK"
		RC[1].Value := AHKData[i].code
		If StrLen(AHKData[i].examples) > 0
		{
				HighlightTab(hTabs, 1, 1)
				RC[2].Settings.Highlighter := "HighlightAHK"
				RC[2].Value := AHKData[i].examples
		}
		else
		{
				HighlightTab(hTabs, 1, 0)
				RC[2].Value := ""
		}

	; reading data from the function included description section
		toshow[2]:=""
		If IsObject(AHKData[i]["Description"])
		{
				 For descKey, Text in AHKData[i]["Description"]
				{
						If descKey
							toshow[2].= Format("{:U}", Trim(descKey)) ":`n"
						else
							continue
						Text:= StrReplace(Text, "`n`r`n`r", "`n")
						Text:= StrReplace(Text, "`r`n`r`n", "`n")
						Loop, 5
							Text	:= StrReplace(Text, SubStr("`t`t`t`t`t`t`t`t", 7 - A_Index) , A_Tab)
						Loop, Parse, Text, `n
							toshow[2].= Rtrim(A_LoopField, ",") "`n"
						;toshow[2].= "-----------------------------------------------------------------`n`n"
				}
				If StrLen(toshow[2])> 0
				{
						HighlightTab(hTabs, 2, 1)
					; populate the description Tab
						RC[3].Value := toshow[2]
						RC[3].Settings.Highlighter := "HighlightAHK"
				}
				else
				{
						HighlightTab(hTabs, 2, 0)
						RC[3].Value := ""
				}
		}

	; highlight search terms
		If highlight
		{
				RE_FindTextAndSelect(RC[1].Hwnd, LVExpression, {1:"Down"})
		}
return
;}
;--------------------------------------------------------------------------------------------------------------
GoSearch:                       	;{

		Gui, Arg: Submit, NoHide
		If StrLen(LVExpression) = 0
				return

		foundIndex:= 0
		GuiControl, ARG:Focus, LVFunc

		results:= RareSearch(LVExpression, AHKData, AHKFiles, SMode)
		If results.MaxIndex() > 0
		{
			; fill listview with collection
				highlight:= true				; flag to highlight searchtearms in RichEdit code
				Gui, ARG: Default
				LV_Delete()
				GuiControl, ARG: -Redraw, LVFunc
				Loop, % results.MaxIndex()
				{
					foundIndex:= Results[A_Index]
					For i, function in AHKData
						If Instr(function.FnHash, foundIndex)
							LV_Add("", function.mainsection, function.name, function.short, function.FnHash)
				}
				GuiControl, ARG: +Redraw, LVFunc
				GuiControl, Text, Field3, % "Search result: " results.MaxIndex() " functions"
		}
		else
		{
				highlight:= false
				GuiControl, Text, Field3, % "Search result: nothing matched"
		}

return ;}
;--------------------------------------------------------------------------------------------------------------
ARGGuiSize:                    	;{

	Critical, Off
	Critical
	GuiControl, ARG: Move, BGColorLogo	, % "w" (A_GuiWidth)
	GuiControl, ARG: Move, LVExpression	, % "w" (A_GuiWidth - Logo.width - 32 - SA_W)
	GuiControl, ARG: Move, GB1           		, % "w" (A_GuiWidth - Logo.width - 30) " h40 y5"
	GuiControl, ARG: Move, Field3            	, % "w" (A_GuiWidth - Logo.width - 40) " h30"
	GuiControl, ARG: Move, LVFunc          	, % "w" (A_GuiWidth) ;" h"(A_GuiHeight//3)
	GuiControlGet, LV_, ARG: Pos, LVFunc
	LV_AutoColumSizer(hLVFunc, "10% 15% 60%")
	GuiControl, ARG: Move, ShowRoom1 	, % "y" (LV_Y+LV_H+10)                                                                                 " h" (A_GuiHeight-LV_Y-LV_H-10-SB_H)
	GuiControl, ARG: Move, ShowRoom2 	, % "x" (SR1Width+5) " y" (LV_Y+LV_H+10) " w" (A_GuiWidth-SR1Width-5) " h" (A_GuiHeight-LV_Y-LV_H-10-SB_H)
	GuiControl, ARG: Move, % RC[1].hwnd	, % "x" (SR1Width+5) " y" (LV_Y+LV_H+30) " w" (A_GuiWidth-SR1Width-5) " h" (A_GuiHeight-LV_Y-LV_H-30-SB_H)
	GuiControl, ARG: Move, % RC[2].hwnd	, % "x" (SR1Width+5) " y" (LV_Y+LV_H+30) " w" (A_GuiWidth-SR1Width-5) " h" (A_GuiHeight-LV_Y-LV_H-30-SB_H)
	GuiControl, ARG: Move, % RC[3].hwnd	, % "x" (SR1Width+5) " y" (LV_Y+LV_H+30) " w" (A_GuiWidth-SR1Width-5) " h" (A_GuiHeight-LV_Y-LV_H-30-SB_H)
	GuiControl, ARG: Move, SB                	, % "x" 0 " y" (A_GuiHeight - SB_H) " w" (A_GuiWidth)
	Critical, Off
	SetTimer, ShowStats, -200

return ;}
;--------------------------------------------------------------------------------------------------------------
ARGGuiClose:                  	;{
ARGEscape:

	Gui, Arg: Submit, NoHide
	win := GetWindowInfo(hARG)
	IniWrite, % SMode, % A_ScriptDir "\AHK-Rare.ini", Properties, SearchMode
	IniWrite, % win.WindowX "|" win.WindowY "|" (win.ClientW) "|" (win.ClientH), % A_ScriptDir "\AHK-Rare.ini", Properties, GuiOptions

ExitApp ;}
;--------------------------------------------------------------------------------------------------------------
ShowStats:                       	;{

	WinGetPos, wx, wy, ww, wh, % "ahk_id " hARG
	GuiControl, ARG:, Stats2, % "x" wx "  y" wy "  w" ww "  h" wh

return
ChangeStats() {

	WinGetPos, wx, wy, ww, wh, % "ahk_id " hARG
	GuiControl, ARG:, Stats2, % "x" wx "  y" wy "  w" ww "  h" wh

}
;}
;--------------------------------------------------------------------------------------------------------------
CopyTextToClipboard:     	;{

	toCopy := ""

	MouseGetPos, mx, my,, hControlOver, 2

	RichEditControls:= RC.1.hwnd "," RC.2.hwnd "," RC.3.hwnd
	If Instr(hControlOver, hTabs) || hControlOver in %RichtEditControls%
	{
			Loop, % (AHKData[currentFuncNr].end - AHKData[currentFuncNr].start) + 1
					tocopy .= AHKFiles[AHKData[currentFuncNr].start + A_Index - 1] "`n"
			Clipboard := tocopy
			ToolTip, % "copied to clipboard...", % mx -10, % my + 10, 2
			SetTimer, TTOff, -2000
	}

return

TTOff:
	ToolTip,,,, 2
return ;}
;--------------------------------------------------------------------------------------------------------------
FocusSearchField:            	;{
	GuiControl, ARG: Focus, LVExpression
return ;}
;--------------------------------------------------------------------------------------------------------------
ListViewUp:
ListViewDown:                 	;{

	If !WinActive("AHK-Rare_TheGui ahk_class AutoHotkeyGUI")
			return
	If Instr(A_ThisLabel, "ListViewUp")
			Send, {Up}
	else
			Send, {Down}

	selRow:= LV_GetNext("F")
	gosub ShowFunctionsOnUpDown

return ;}
;--------------------------------------------------------------------------------------------------------------
ReloadScript:                   	;{	only for reloading the script after hotkey press (development purposes)

	Gui, Arg: Submit, NoHide
	win := GetWindowInfo(hARG)
	IniWrite, % SMode, % A_ScriptDir "\AHK-Rare.ini", Properties, SearchMode
	IniWrite, % win.WindowX "|" win.WindowY "|" (win.ClientW) "|" (win.ClientH), % A_ScriptDir "\AHK-Rare.ini", Properties, GuiOptions
	Reload

return ;}

;}

;{07. cooking club functions

RareSearch(LVExpression, AHKData, AHKFiles, mode:="RegEx") {               	;-- search all AHK Rare functions

		results:= Array()

	; collecting all results
	Loop, % AHKFiles.MaxIndex()
	{
			If RegExMatch(AHKFiles[A_Index], "(;\s*\<\d\d\.\d\d\.\d\d\d\d\d)|(;\s*\<\d\d\.\d\d\.\d\d.\d\d\d\d\d)")
			{
					RegExMatch(AHKFiles[A_Index], "[\d\.]+", FnHash)
					found:= 0
					continue
			}

			If (found = 0)
				If Instr(mode, "RegEx") && RegExMatch(AHKFiles[A_Index], LVExpression)
					results.Push(FnHash), found:= 1
				else if Instr(mode, "Basic") && Instr(AHKFiles[A_Index], LVExpression)
					results.Push(FnHash), found:= 1
	}

return results
}

RareLoad(FileFullPath) {                                                                       	;-- loads AHK Rare as an indexed array

	AHKFiles:= Array()

	FileRead, filestring, % FileFullPath
	Loop, Parse, filestring, `n, `r
		AHKFiles[A_Index]:= A_LoopField, i:= A_Index

	AHKFiles[i+1]:= FileFullPath

return AHKFiles
}

RareSave(AHKFiles) {                                                                               	;-- save back changes to AHK Rare

	filepath:= AHKFiles[AHKFiles.MaxIndex()]
	File:= FileOpen(filepath, "w")
	Loop, % AHKFiles.MaxIndex() - 1
		File.WriteLine(AHKFiles[A_Index])
	File.Close()

return Errorlevel
}

TTGui(title, BZN, x, y) {

	global
	RefIdentMaxW	:= 0
	RefLV1Width    	:= 0
	RefNextFile      	:= 0
	RefPauser         	:= 0
	RefCheck				:= 0
	RefOpen          	:= 0
	lIdent                	:= StrSplit(BZN, "|")

	Gui, Ref: New, -DPIScale +AlwaysOnTop +HWNDhRefGui
	Gui, Ref: Font, s8
	Gui, Ref: Color, cFFDFAE

	;-: progress info's
	Gui, Ref: Add, Listview	, % "x0 y0 w800 r" lIdent.MaxIndex() " BackgroundFFDFAE vREFLV1 HwndhRefLV1 +LV0x00400000 Section", % "ident|s|info"  ;ReadOnly -HDR
	Loop % lIdent.MaxIndex()
		LV_Add("", lIdent[A_Index], ":" )

	;-: debug or other info view
	GuiControlGet, RefLv, Ref: Pos, REFLV1
	Gui, Ref: Add	, Edit        	, % "x0 w800 h800 vRefDebug HWNDhRefDebug Section"

	;-: automatic break part
	Gui, Ref: Font	, s12 cRED bold q5
	Gui, Ref: Add	, Text           	, % "x0 y"+5 " vRefMsg1 Center", % " - - - - - - - - - - - - - - - - - - - - - - - - - "
	Gui, Ref: Font	, s8 cBlack normal q5
	Gui, Ref: Add	, Button       	, % "x10 y"+20 " vRefPause gRefButtons ", % "Pause"
	Gui, Ref: Add	, Button    	, % "x"+ 20 	" vRefStop gRefButtons ", % "Stop"
	Gui, Ref: Add	, Button    	, % "x"+ 20 	" vRefReload gRefButtons ", % "Reload"
	Gui, Ref: Add	, CheckBox	, % "x"+ 20 	" vRefCheck gRefButtons ", % "no automatic breaks"
	Gui, Ref: Add	, CheckBox	, % "y"+ 5 	" vRefOpen gRefButtons ", % "no automatic presentation of corrupt files"
	Gui, Ref: Add	, Button   		, % "x"+ 60 	" vRefNext HWNDhRefNext gRefButtons ", % "Next >>"
	Gui, Ref: Font	, s8 cBlack Normal q5
	Gui, Ref: Show	, % "x" X " y" Y " Hide", % title

	;-: adjust listview part
	LV_ModifyCol(1, "Right")
	LV_ModifyCol(1)
	LV_ModifyCol(2)
	LV_ModifyCol(3, 800)
	Loop 3
		RefLV1Width += LV_EX_GetColumnWidth(hRefLV1, A_Index)
	WinSet, Style 	 , 0x50014001 	, % "ahk_id " hRefLV1
	WinSet, ExStyle, 0x0            	, % "ahk_id " hRefLV1
	Gui, Ref: Show, % "x" X " y" Y " Hide", % title

	;-: adjust the automatic break part
	GuiControl, Ref: Move, RefLV1, % "w" RefLv1Width
	GuiControlGet, RefLv, Ref: Pos, RefLv1
	GuiControl, Ref: Move, RefDebug, % "y" RefLvY+RefLvH " w" RefLvW
	GuiControlGet, RefD, Ref: Pos, RefDebug
	GuiControl, Ref: Move, RefMsg1	, % "y" RefDY+RefDH " w" RefLVW
	GuiControlGet, RefD, Ref: Pos, RefMsg1
	GuiControl, Ref: Move, RefPause	, % "x" 30 	"y" RefDY+RefDH+5
	GuiControl, Ref: Move, RefStop  	, % "x" 100 	"y" RefDY+RefDH+5
	GuiControl, Ref: Move, RefReload	, % "x" 170 	"y" RefDY+RefDH+5
	GuiControl, Ref: Move, RefCheck	, % "x" 350 	"y" RefDY+RefDH+10
	GuiControl, Ref: Move, RefOpen  	, % "x" 350 	"y" RefDY+RefDH+35
	GuiControl, Ref: Move, RefNext  	, % "x" RefLVW-80 	"y" RefDY+RefDH+5

	;-: and now the circus show starts
	Gui, Ref: Show, % "AutoSize", % title

	;TTGuiAdjustSize()
	;Pause

return

RefButtons:

	Gui, Ref: Submit, NoHide

	If Instr(A_GuiControl, "RefNext")
			RefNextFile:= 1
	else If Instr(A_GuiControl, "RefStop")
			gosub RefGuiClose
	else if Instr(A_GuiControl, "RefPause")
			RefPauser:= !RefPauser
	else if Instr(A_GuiControl, "RefReload")
	{
			MsgBox, 4, AHK-Library-Cooking, Choose Yes if you wan't to reload this script!
			IfMsgBox, Yes
				Reload
	}

return

RefGuiEscape:
RefGuiClose:
	ExitApp
return
}

TTGuiAdjustSize() {

	Gui, Ref: Default
	GuiControl, Ref: Move, RefLV1, % "w" RefLv1Width

	GuiControlGet, RefLv, Ref: Pos, RefLv1
	GuiControl, Ref: Move, RefDebug, % "y" RefLvY+RefLvH " w" RefLvW

	GuiControlGet, RefD, Ref: Pos, RefDebug
	GuiControl, Ref: Move, RefMsg1	, % "y" RefDY+RefDH " w" RefLVW

	GuiControlGet, RefM, Ref: Pos, RefMsg1
	GuiControl, Ref: Move, RefPause, % "x" 60 	"y" RefMY+RefMH+5
	GuiControl, Ref: Move, RefNext	, % "x" 100 	"y" RefMY+RefMH+5

	tl:= GetWindowInfo(hRefLV1)
	td:= GetWindowInfo(hRefNext)
	;MsgBox, % tr.X "," tr.Y "," tr.W "," tr.H
	tt:= GetWindowInfo(hRefGui)
	WinMove, % "ahk_id " hRefGui,,,, % tl.W+tt.BW+5, % td.Y+td.H+tt.BH*2+5

}

TTShow(InfoLine, text) {

	Gui, Ref: Default
	LV_Modify(InfoLine, "Col3", text)

}

FuncIndexing(AHKFiles) {                                                                        	;--

	;----------------------------------------------------------------------------------------------------------------------------------------------
	; defining some variables
	;----------------------------------------------------------------------------------------------------------------------------------------------;{
		;global functionName
		;global fncName
		global RefPauser
		global RefCheck
		global FEncoding

		AHKData:= Object()
		AHKData.DescriptionKeys := Object()
		tempObj:= Object()
		tempObj.DescriptionKeys := Object()

		q                      	:= Chr(0x22)
		totalfuncs        	:= 0
		totalclasses			:= 0
		totalextclasses 	:= 0
		totalcodelines   	:= 0
		totalfilesize      	:= 0
		startTime         	:= A_TickCount

		refFile:= FileOpen(A_ScriptDir "\FunctionReference.txt", "w", "UTF-8")
		refFile.WriteLine("------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
		refFile.WriteLine("function reference : " A_MM "/" A_DD "/" A_YYYY "     " A_Hour ":" A_Min ":" A_Sec )
		refFile.WriteLine("tabledescription : function name | parameters | inside class | start | end | md5hash |" )
		refFile.WriteLine("------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")

		TTGui("operating...", "file name|encoding|file no.|codelines|actual line|Class|functions found|funcbody process|commentblock|brackets left|total functions|total text lines processed", 2500, 300)
	;}

	;----------------------------------------------------------------------------------------------------------------------------------------------
	; parsing algorithm
	;----------------------------------------------------------------------------------------------------------------------------------------------;{
		Loop, % AHKFiles.MaxIndex()
		{
			;---------------------------------------------------------------------------------------------------
			; preparations
			;---------------------------------------------------------------------------------------------------;{
				WaitFuncBracket	:= false
				commentblock	:= false
				global fileName  	:= AHKFiles[A_index].FileFullPath
				tmodified         	:= AHKFiles[A_index].tmodified
				filesizeBytes     	:= AHKFiles[A_index].filesizeBytes
				fileObject         	:= FileToObj(fileName)
				totalfilessize	    	+= filesizeBytes
				fncNr                	:= 0
				prcdNr                	:= 0
				ClassStart	        	:= 0
				towrite1 =
				(LTrim
				****************************************************************************************************************************************************************************************
				File: -- %fileName% --
				last modification date: %tmodified%
				file size in bytes: %filesizeBytes%
				file encoding: %FEncoding%
				------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

				)
			;}

			;---------------------------------------------------------------------------------------------------
			; progress gui
			;---------------------------------------------------------------------------------------------------;{
				RegExMatch(filename, ".*?(\\[^\\]*?\\*[^\\]*?\\*[^\\]*$)", shortPath)
				TTShow(1, ShortPath1)
				TTShow(3, A_Index "/" AHKFiles.MaxIndex())
				TTShow(4, fileObject.Count())
				TotalCodeLines += fileObject.Count()

				While (RefPauser=1)
					sleep, 20
			;}

			;---------------------------------------------------------------------------------------------------
			; parses one file for functions
			;---------------------------------------------------------------------------------------------------;{
				For lNr, line in fileObject
				{
						TTShow(5, lNr)
						TTShow(6, fncClass)
						TTShow(7, fncNr " - "  fncName "   (" fncParam ")")
						TTShow(11, totalfuncs)

						If (lNr < prcdNr)
							continue

						prcdNr := 0

						If !commentblock && RegExMatch(line, "^\s*\/\*") {		                                                 	; found start of block comment
								commentblock:= true
						} else if commentblock && RegExMatch(line, "^\s*\*\/") {  ; found end of block comment
								commentblock:= false
						} else If (StrLen(Line) > 0) {

								If RegExMatch(line, "i)^Class\s") {

										ClassNr    	++
										If (ClassStart > 0)
										{
												ClassEnd	:= lNr - 1
												towriteClass .= "ClassName: " fncClass "|" ClassStart "|" ClassEnd "`n"
										}
										fncClass   	:= RegExReplace(line, "i)^Class\s")
										fncClass   	:= RegExReplace(fncClass, "i)\{")
										fncClass   	:= RegExReplace(fncClass, ";.*")
										ClassStart 	:= lNr

								} else If RegExMatch(line, "i)^#include\s") {
										towrite1   	.= "includes: " RegExReplace(line, "i)^#include\s") "`n"
								} else If RegExMatch(line, "^\s*([\w\_]+)\[.*?\])") && !RegExMatch(line, "i)^\s*(\sif)") {				;e.g. columnsDelimiter[] {  - i have no idea of classes - is this a function concept?
										prcdNr     	:= FuncBody(fileObject,lNr, Trash, "") + 1
								} else If RegExMatch(line, "^\s*([\w\_]+)\(.*?\)") && !RegExMatch(line, "i)^\s*(\sif)") {              ;function found ;(StrLen(fnc) = 0) &&

										RegExMatch(line, "^\s*(?<Name>[\w_]+)\((?<Param>[^\)]*)\)", fnc)
										;functionName := fncName
										fncNr       	++
										totalfuncs	++
										fncStart    	:= lNr
										fncParam 	:= RegExReplace(fncparam, "(ByRef)|\s|\=|\" q)
										fncEnd     	:= FuncBody(fileObject, lNr, fncHash, fncName)
										prcdNr     	:= fncEnd + 1
										towriteFnc  	.= fncName "|" fncParam "|" fncClass "|"  fncStart "|" fncEnd "|" fncHash  "|`n"
										TTShow(7, fncNr " - " fncName "   (" fncParam ")" )
										If (fncEnd = 0)
											break

								}

						}
				}				;}


			;---------------------------------------------------------------------------------------------------
			; save data
			;---------------------------------------------------------------------------------------------------;{
				TTShow(12, totalcodelines)
				refFile.WriteLine(towrite1)

				If (ClassStart > 0)
					refFile.WriteLine(towriteClass)

				If (fncEnd>0) ;&& (fncStart < fncEnd)
					refFile.WriteLine(towriteFnc)

				towrite1:= towriteFnc:=towriteClass := ""

			;}
		}
	;}

	;----------------------------------------------------------------------------------------------------------------------------------------------
	; writing last data
	;----------------------------------------------------------------------------------------------------------------------------------------------;{
		EndTime       	:= A_TickCount
		totalTime     	:= EndTime - StartTime
		tmin             	:= Floor(totalTime/1000/60)
		tsec               	:= Floor(totalTime/1000)
		tms              	:= Mod(totalTime, 1000) * 1000
		totalcodelines	:= RegExReplace(totalcodelines, "(.*)(\d{3})*(\d{3})(\d{3})", "$1$2.$3.$4")
		totalfuncs    	:= RegExReplace(totalfuncs, "(.*)(\d{3})*(\d{3})(\d{3})", "$1$2.$3.$4")
		filesmax       	:= RegExReplace(AHKFiles.MaxIndex(), "(.*)(\d{3})*(\d{3})(\d{3})", "$1$2.$3.$4")

		refFile.WriteLine("------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
		refFile.WriteLine("sum of all operations")
		refFile.WriteLine("time is taken            : " totaltime "ms"  -- tmin ":" tsec "::" tms)
		refFile.WriteLine("files processed         : " filesmax)
		refFile.WriteLine("functions found       : " totalfuncs)
		refFile.WriteLine("text lines processed : " totalcodelines)
		refFile.WriteLine("size of all files          : " Round(totalfilessize/1024/1024, 2) " MB")

		refFile.Close()
		Pause
	;}

return ;AHKData
}

FuncBody(fileObject, startLine, byRef bodyHash, functionName) {

	local

	global fileName
	;global functionName
	;global fncName
	global RefCheck
	global RefOpen
	global EditorPath
	global RefNextFile

	tcbr              	:= 0
	tobr             	:= 0
	commentblock:= false
	continuationsection:=false
	funcstart			:= true
	startbNr			:= bNr
	q                  	:= Chr(0x22)
	subbrackets		:= 0
	bNr := startLine

	Loop
	{
			TTShow(8, bNr "(" fileObject.Count() ")   --|"  fileObject[bNr] "|--")
			TTShow(9, (commentblock ? "true":"false") "[" SubStr("0000" cmtBlockStart, -3) ":" SubStr("0000" cmtBlockEnd, -3) "] , continuitation section: " (continuationsection ? "true":"false") "[" SubStr("0000" conBlockStart, -3) ":" SubStr("0000" conBlockEnd, -3) "]" )

			;----------------------------------------------------------------------------------------------------------------------------------------------
			; end of file - view informations about missing bracket
			;----------------------------------------------------------------------------------------------------------------------------------------------
			If (bNr > fileObject.Count()) {

					Gui, Ref: Default
					GuiControlGet, tDebug, Ref:, RefDebug
					tDebug .= "----------------------------------------------------------------------------------------------------------------------------------------------------------------------`n"
					tDebug .= "func`t: " functionName "`n"
					tDebug .= "file `t: " filename "`n"
					tDebug .= "info`t: The end of this function can not be determined!`n"
					tDebug .= "      `t   missing " q "}" q " probably between line no. " sbLine1 " and " sbLine2 ".`n`n"
					tDebug .= "the following log shows all lines where a successful bracket comparison was present:`n"
					tDebug .= out
					GuiControl, Ref:, RefDebug, % tDebug

					If (RefOpen = 0) {
							If (StrLen(filename) > 0)
								Run, % EditorPath " " q filename q

							WinWait, % filename,, 5

							; goto line + unfold
							If Instr(EditorPath, "scite") {
									Scite:= GetSciTEInstance()
									hScite := GetHex(SciTE.SciTEHandle)
									ControlGet, hSci, Hwnd,, Scintilla1, % "ahk_id " SciTE.SciTEHandle
									SendMessage, 2152, 0, 0,, % "ahk_id " hSci
									If (ErrorLevel < startLine - 1) {
										;Get the number of lines on screen. SCI_LINESONSCREEN
										SendMessage, 2370, 0, 0,,% "ahk_id " hSci
										;Go to the line wanted + lines on screen. SCI_GOTOLINE
										SendMessage, 2024, % line - 1 + ErrorLevel, 0,, % "ahk_id " hSci
									}
									SendMessage, 2024, % startLine - 1, 0,, % "ahk_id " hSci ; Sci_GotoLine := 2024
							}
					}

					If (RefCheck=0) {
							While, (RefNextFile = 0)
										sleep, 20
							RefNextFile := 0
					}

					bNr := 0
					break
			}

			funcbodyLine := fileObject[bNr]
			strippedLine:= RegExReplace(funcbodyLine, "(" q "[^" q "]+" q ")")
			strippedLine:= RegExReplace(strippedLine, ";.*")				; removes comments
			strippedLine:= RegExReplace(strippedLine, q ".*" q)		; removes all >> ".*" <<

			;-: continue box comment or empty line
			If (!commentblock && !continuationsection && RegExMatch(strippedLine, "^\s*\/\*"))
			{ ; found block comment
					commentblock:= true
					cmtblockStart:= bNr
					cmtBlockEnd:= 0
			}
			else If (commentblock && RegExMatch(strippedLine, "^\s*\*\/")) ; found end of block comment
			{
					commentblock:= false
					cmtBlockEnd:= bNr
			}
			else If (!continuationsection && !commentblock && RegExMatch(strippedLine, "^\s*\(") && !Instr(strippedLine, ")"))
			{
					continuationsection:= true
					conBlockStart:= bNr
					conBlockEnd:= 0
			}
			else if continuationsection && RegExMatch(strippedLine, "^\s*\)")
			{
					continuationsection:= false
					conBlockEnd:= bNr
			}
			else if (RegExMatch(strippedLine, "^\s*(\w+\s*\,)") || RegExMatch(strippedLine, "^\s*\,") || RegExMatch(strippedLine, "\=\s*\{"))   ; do not match a line with a command or ',' is followed by a { or }
			{
					nomatch:= 1
			}
			else If (!commentblock && !continuationsection && (StrLen(strippedLine) > 0))
			{
					RegExReplace(strippedLine, "i)\}", "", cbr)
					RegExReplace(strippedLine, "i)\{", "", obr)

					If (subbrackets=0) && (brackets=1)  && ((obr-cbr) > 0)
						subbrackets := (obr - cbr), sbLine1:= bNr
					else if (subbrackets > 0) {
						subbrackets += (obr - cbr)
						If (subbrackets = 1)
							sbLine2:= bNr
					}

					brackets += (obr - cbr)
					If funcstart && (brackets > 0)
						funcstart:= false

					If cbr || obr			; for debugging purposes
						out.= SubStr("00000" bNr, -3) . "| " . "  (" . (SubStr("00" brackets, -1)) . ") " . obr . "-" cbr . "  (" . (SubStr("00" subbrackets, -1)) . ") |   " . StrReplace(strippedLine, "`t") . "`n"

					tcbr	+= cbr
					tobr	+= obr

					TTShow(10, brackets " (" obr "{, " cbr "})    total brackets: " tobr "x '{'  " tcbr "x '}'")

					If funcstart && (startbNR <bNr) && RegExMatch(strippedLine, "^\s*[\w\(\)]+")
					{
							bNr:= 0
							break
					}

					If !funcstart && (brackets = 0)
							break
			}

			bNr++

			funcbodyLine := RegExReplace(funcbodyLine, ";.*", "")    ;remove comments
			funcbodyLine := RegExReplace(funcbodyLine, "\s", "")                    ;whitespace
			body.= funcbodyLine
	}

	If (bNr > 0)
		bodyHash:= bcrypt_md5(body)   ; used to hash the whole function

	TTShow(8, "")
	TTShow(9, "")
	TTShow(10, "")


return bNr
}

FileIndexer(Dir, opt:="") {

		files:= []
		Loop, Files, % dir "\*.ahk", R
			files.Push({"FileFullPath":A_LoopFileFullPath, "tmodified":A_LoopFileTimeModified, "filesizeBytes": A_LoopFileSize})

return files
}

FileToObj(filepath) {

	local
	global FEncoding
	obj:= Object()

	FEncoding:= GetFileEncoding(filepath)
	TTShow(2, FEncoding)
	FileRead, file, % filepath

	If !InStr(FEncoding, "UTF-8")
	{
		unicodefile := Ansi2UTF8(file)
	}
	else
		unicodefile := file

	Loop, Parse, unicodefile, `n, `r
			obj.Push(A_LoopField)

return obj
}

RareGetFunctionObject(hash) {                                                           	;-- returns the data object to one function

	For i, function in AHKData
		If Instr(function.FnHash, fnr)
				break

return AHKData[i]
}

RareClipChanged(Type) {

	Gui, ARG: Default

	If Type = 0
			SB_SetText("clipboard is empty" )
	else If Type = 1
	{
			clip:= Clipboard
			ToolTip, % "funcNr: " currentFuncNR "`nType: " Type "`nfName: " StrReplace(AHKData[currentFuncNr].name, "()") "`nFunc in clipboard?: " Instr(clip, StrReplace(AHKData[currentFuncNr].name, "()"))
			If Instr(clip, StrReplace(AHKData[currentFuncNr].name, "()"))
					SB_SetText("clipboard contains " AHKData[currentFuncNr].name " to clipboard" )
			else
					SB_SetText("clipboard contains something that is not from AHK-Rare" )
	}
	else if Type = 2
		SB_SetText("clipboard contains something that is not from AHK-Rare" )

}

BracketCount(str, brackets:="{}") {                                                       	;-- helps to find the last bracket of a function
	RegExReplace(str, SubStr(brackets, 1, 1), "", open)
	RegExReplace(str, SubStr(brackets, 2, 1), "", closed)
return open - closed
}

countTrailingSpaces(str) {                                                                    	;-- counts all leading spaces of a string

	Loop, % StrLen(str)
		If Instr(A_Space "`t", SubStr(str, A_Index, 1))
				TrailingSpaces ++
		else
				Break

return TrailingSpaces
}

;}

;{08. all the  other functions

GetSciTEInstance() {
	olderr := ComObjError()
	ComObjError(false)
	scite := ComObjActive("{D7334085-22FB-416E-B398-B5038A5A0784}")
	ComObjError(olderr)
	return IsObject(scite) ? scite : ""
}

GetFocusedControl()  {   																								                            				;-- retrieves the ahk_id (HWND) of the active window's focused control.

   ; This script requires Windows 98+ or NT 4.0 SP3+.
   guiThreadInfoSize := 8 + 6 * A_PtrSize + 16
   VarSetCapacity(guiThreadInfo, guiThreadInfoSize, 0)
   NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
   ; DllCall("RtlFillMemory" , "PTR", &guiThreadInfo, "UInt", 1 , "UChar", guiThreadInfoSize)   ; Below 0xFF, one call only is needed
   if (DllCall("GetGUIThreadInfo" , "UInt", 0, "PTR", &guiThreadInfo) = 0) {   ; Foreground thread
			ErrorLevel := A_LastError   ; Failure
			Return 0
   }

Return NumGet(guiThreadInfo, 8+A_PtrSize, "Ptr") ; *(addr + 12) + (*(addr + 13) << 8) +  (*(addr + 14) << 16) + (*(addr + 15) << 24)
}

HighlightAHK(Settings, ByRef Code) {
	static Flow := "break|byref|catch|class|continue|else|exit|exitapp|finally|for|global|gosub|goto|if|ifequal|ifexist|ifgreater|ifgreaterorequal|ifinstring|ifless|iflessorequal|ifmsgbox|ifnotequal|ifnotexist|ifnotinstring|ifwinactive|ifwinexist|ifwinnotactive|ifwinnotexist|local|loop|onexit|pause|return|settimer|sleep|static|suspend|throw|try|until|var|while"
	, Commands := "autotrim|blockinput|clipwait|control|controlclick|controlfocus|controlget|controlgetfocus|controlgetpos|controlgettext|controlmove|controlsend|controlsendraw|controlsettext|coordmode|critical|detecthiddentext|detecthiddenwindows|drive|driveget|drivespacefree|edit|envadd|envdiv|envget|envmult|envset|envsub|envupdate|fileappend|filecopy|filecopydir|filecreatedir|filecreateshortcut|filedelete|fileencoding|filegetattrib|filegetshortcut|filegetsize|filegettime|filegetversion|fileinstall|filemove|filemovedir|fileread|filereadline|filerecycle|filerecycleempty|fileremovedir|fileselectfile|fileselectfolder|filesetattrib|filesettime|formattime|getkeystate|groupactivate|groupadd|groupclose|groupdeactivate|gui|guicontrol|guicontrolget|hotkey|imagesearch|inidelete|iniread|iniwrite|input|inputbox|keyhistory|keywait|listhotkeys|listlines|listvars|menu|mouseclick|mouseclickdrag|mousegetpos|mousemove|msgbox|outputdebug|pixelgetcolor|pixelsearch|postmessage|process|progress|random|regdelete|regread|regwrite|reload|run|runas|runwait|send|sendevent|sendinput|sendlevel|sendmessage|sendmode|sendplay|sendraw|setbatchlines|setcapslockstate|setcontroldelay|setdefaultmousespeed|setenv|setformat|setkeydelay|setmousedelay|setnumlockstate|setregview|setscrolllockstate|setstorecapslockmode|settitlematchmode|setwindelay|setworkingdir|shutdown|sort|soundbeep|soundget|soundgetwavevolume|soundplay|soundset|soundsetwavevolume|splashimage|splashtextoff|splashtexton|splitpath|statusbargettext|statusbarwait|stringcasesense|stringgetpos|stringleft|stringlen|stringlower|stringmid|stringreplace|stringright|stringsplit|stringtrimleft|stringtrimright|stringupper|sysget|thread|tooltip|transform|traytip|urldownloadtofile|winactivate|winactivatebottom|winclose|winget|wingetactivestats|wingetactivetitle|wingetclass|wingetpos|wingettext|wingettitle|winhide|winkill|winmaximize|winmenuselectitem|winminimize|winminimizeall|winminimizeallundo|winmove|winrestore|winset|winsettitle|winshow|winwait|winwaitactive|winwaitclose|winwaitnotactive"
	, Functions := "abs|acos|array|asc|asin|atan|ceil|chr|comobjactive|comobjarray|comobjconnect|comobjcreate|comobject|comobjenwrap|comobjerror|comobjflags|comobjget|comobjmissing|comobjparameter|comobjquery|comobjtype|comobjunwrap|comobjvalue|cos|dllcall|exception|exp|fileexist|fileopen|floor|func|getkeyname|getkeysc|getkeystate|getkeyvk|il_add|il_create|il_destroy|instr|isbyref|isfunc|islabel|isobject|isoptional|ln|log|ltrim|lv_add|lv_delete|lv_deletecol|lv_getcount|lv_getnext|lv_gettext|lv_insert|lv_insertcol|lv_modify|lv_modifycol|lv_setimagelist|mod|numget|numput|objaddref|objclone|object|objgetaddress|objgetcapacity|objhaskey|objinsert|objinsertat|objlength|objmaxindex|objminindex|objnewenum|objpop|objpush|objrawset|objrelease|objremove|objremoveat|objsetcapacity|onmessage|ord|regexmatch|regexreplace|registercallback|round|rtrim|sb_seticon|sb_setparts|sb_settext|sin|sqrt|strget|strlen|strput|strsplit|substr|tan|trim|tv_add|tv_delete|tv_get|tv_getchild|tv_getcount|tv_getnext|tv_getparent|tv_getprev|tv_getselection|tv_gettext|tv_modify|tv_setimagelist|varsetcapacity|winactive|winexist|_addref|_clone|_getaddress|_getcapacity|_haskey|_insert|_maxindex|_minindex|_newenum|_release|_remove|_setcapacity"
	, Keynames := "alt|altdown|altup|appskey|backspace|blind|browser_back|browser_favorites|browser_forward|browser_home|browser_refresh|browser_search|browser_stop|bs|capslock|click|control|ctrl|ctrlbreak|ctrldown|ctrlup|del|delete|down|end|enter|esc|escape|f1|f10|f11|f12|f13|f14|f15|f16|f17|f18|f19|f2|f20|f21|f22|f23|f24|f3|f4|f5|f6|f7|f8|f9|home|ins|insert|joy1|joy10|joy11|joy12|joy13|joy14|joy15|joy16|joy17|joy18|joy19|joy2|joy20|joy21|joy22|joy23|joy24|joy25|joy26|joy27|joy28|joy29|joy3|joy30|joy31|joy32|joy4|joy5|joy6|joy7|joy8|joy9|joyaxes|joybuttons|joyinfo|joyname|joypov|joyr|joyu|joyv|joyx|joyy|joyz|lalt|launch_app1|launch_app2|launch_mail|launch_media|lbutton|lcontrol|lctrl|left|lshift|lwin|lwindown|lwinup|mbutton|media_next|media_play_pause|media_prev|media_stop|numlock|numpad0|numpad1|numpad2|numpad3|numpad4|numpad5|numpad6|numpad7|numpad8|numpad9|numpadadd|numpadclear|numpaddel|numpaddiv|numpaddot|numpaddown|numpadend|numpadenter|numpadhome|numpadins|numpadleft|numpadmult|numpadpgdn|numpadpgup|numpadright|numpadsub|numpadup|pause|pgdn|pgup|printscreen|ralt|raw|rbutton|rcontrol|rctrl|right|rshift|rwin|rwindown|rwinup|scrolllock|shift|shiftdown|shiftup|space|tab|up|volume_down|volume_mute|volume_up|wheeldown|wheelleft|wheelright|wheelup|xbutton1|xbutton2"
	, Builtins := "base|clipboard|clipboardall|comspec|errorlevel|false|programfiles|true"
	, Keywords := "abort|abovenormal|activex|add|ahk_class|ahk_exe|ahk_group|ahk_id|ahk_pid|all|alnum|alpha|altsubmit|alttab|alttabandmenu|alttabmenu|alttabmenudismiss|alwaysontop|and|autosize|background|backgroundtrans|base|belownormal|between|bitand|bitnot|bitor|bitshiftleft|bitshiftright|bitxor|bold|border|bottom|button|buttons|cancel|capacity|caption|center|check|check3|checkbox|checked|checkedgray|choose|choosestring|click|clone|close|color|combobox|contains|controllist|controllisthwnd|count|custom|date|datetime|days|ddl|default|delete|deleteall|delimiter|deref|destroy|digit|disable|disabled|dpiscale|dropdownlist|edit|eject|enable|enabled|error|exit|expand|exstyle|extends|filesystem|first|flash|float|floatfast|focus|font|force|fromcodepage|getaddress|getcapacity|grid|group|groupbox|guiclose|guicontextmenu|guidropfiles|guiescape|guisize|haskey|hdr|hidden|hide|high|hkcc|hkcr|hkcu|hkey_classes_root|hkey_current_config|hkey_current_user|hkey_local_machine|hkey_users|hklm|hku|hotkey|hours|hscroll|hwnd|icon|iconsmall|id|idlast|ignore|imagelist|in|insert|integer|integerfast|interrupt|is|italic|join|label|lastfound|lastfoundexist|left|limit|lines|link|list|listbox|listview|localsameasglobal|lock|logoff|low|lower|lowercase|ltrim|mainwindow|margin|maximize|maximizebox|maxindex|menu|minimize|minimizebox|minmax|minutes|monitorcount|monitorname|monitorprimary|monitorworkarea|monthcal|mouse|mousemove|mousemoveoff|move|multi|na|new|no|noactivate|nodefault|nohide|noicon|nomainwindow|norm|normal|nosort|nosorthdr|nostandard|not|notab|notimers|number|off|ok|on|or|owndialogs|owner|parse|password|pic|picture|pid|pixel|pos|pow|priority|processname|processpath|progress|radio|range|rawread|rawwrite|read|readchar|readdouble|readfloat|readint|readint64|readline|readnum|readonly|readshort|readuchar|readuint|readushort|realtime|redraw|regex|region|reg_binary|reg_dword|reg_dword_big_endian|reg_expand_sz|reg_full_resource_descriptor|reg_link|reg_multi_sz|reg_qword|reg_resource_list|reg_resource_requirements_list|reg_sz|relative|reload|remove|rename|report|resize|restore|retry|rgb|right|rtrim|screen|seconds|section|seek|send|sendandmouse|serial|setcapacity|setlabel|shiftalttab|show|shutdown|single|slider|sortdesc|standard|status|statusbar|statuscd|strike|style|submit|sysmenu|tab|tab2|tabstop|tell|text|theme|this|tile|time|tip|tocodepage|togglecheck|toggleenable|toolwindow|top|topmost|transcolor|transparent|tray|treeview|type|uncheck|underline|unicode|unlock|updown|upper|uppercase|useenv|useerrorlevel|useunsetglobal|useunsetlocal|vis|visfirst|visible|vscroll|waitclose|wantctrla|wantf2|wantreturn|wanttab|wrap|write|writechar|writedouble|writefloat|writeint|writeint64|writeline|writenum|writeshort|writeuchar|writeuint|writeushort|xdigit|xm|xp|xs|yes|ym|yp|ys|__call|__delete|__get|__handle|__new|__set"
	, Needle :="
	(LTrim Join Comments
		ODims)
		((?:^|\s);[^\n]+)                	; Comments
		|(^\s*\/\*.+?\n\s*\*\/)      	; Multiline comments
		|((?:^|\s)#[^ \t\r\n,]+)      	; Directives
		|([+*!~&\/\\<>^|=?:
			,().```%{}\[\]\-]+)           	; Punctuation
		|\b(0x[0-9a-fA-F]+|[0-9]+)	; Numbers
		|(""[^""\r\n]*"")                	; Strings
		|\b(A_\w*|" Builtins ")\b   	; A_Builtins
		|\b(" Flow ")\b                  	; Flow
		|\b(" Commands ")\b       	; Commands
		|\b(" Functions ")\b          	; Functions (builtin)
		|\b(" Keynames ")\b         	; Keynames
		|\b(" Keywords ")\b          	; Other keywords
		|(([a-zA-Z_$]+)(?=\())       	; Functions
		|(^\s*[A-Z()-\s]+\:\N)        	; Descriptions
	)"

	GenHighlighterCache(Settings)
	Map := Settings.Cache.ColorMap

	Pos := 1
	while (FoundPos := RegExMatch(Code, Needle, Match, Pos))
	{
		RTF .= "\cf" Map.Plain " "
		RTF .= EscapeRTF(SubStr(Code, Pos, FoundPos-Pos))

		; Flat block of if statements for performance
		if (Match.Value(1) != "")
			RTF .= "\cf" Map.Comments
		else if (Match.Value(2) != "")
			RTF .= "\cf" Map.Multiline
		else if (Match.Value(3) != "")
			RTF .= "\cf" Map.Directives
		else if (Match.Value(4) != "")
			RTF .= "\cf" Map.Punctuation
		else if (Match.Value(5) != "")
			RTF .= "\cf" Map.Numbers
		else if (Match.Value(6) != "")
			RTF .= "\cf" Map.Strings
		else if (Match.Value(7) != "")
			RTF .= "\cf" Map.A_Builtins
		else if (Match.Value(8) != "")
			RTF .= "\cf" Map.Flow
		else if (Match.Value(9) != "")
			RTF .= "\cf" Map.Commands
		else if (Match.Value(10) != "")
			RTF .= "\cf" Map.Functions
		else if (Match.Value(11) != "")
			RTF .= "\cf" Map.Keynames
		else if (Match.Value(12) != "")
			RTF .= "\cf" Map.Keywords
		else if (Match.Value(13) != "")
			RTF .= "\cf" Map.Functions
		else If (Match.Value(14) != "")
			RTF .= "\cf" Map.Descriptions
		else
			RTF .= "\cf" Map.Plain

		RTF .= " " EscapeRTF(Match.Value())
		Pos := FoundPos + Match.Len()
	}

	return Settings.Cache.RTFHeader . RTF . "\cf" Map.Plain " " EscapeRTF(SubStr(Code, Pos)) "\`n}"
}

GenHighlighterCache(Settings) {

	if Settings.HasKey("Cache")
		return
	Cache := Settings.Cache := {}


	; --- Process Colors ---
	Cache.Colors := Settings.Colors.Clone()

	; Inherit from the Settings array's base
	BaseSettings := Settings
	while (BaseSettings := BaseSettings.Base)
		for Name, Color in BaseSettings.Colors
			if !Cache.Colors.HasKey(Name)
				Cache.Colors[Name] := Color

	; Include the color of plain text
	if !Cache.Colors.HasKey("Plain")
		Cache.Colors.Plain := Settings.FGColor

	; Create a Name->Index map of the colors
	Cache.ColorMap := {}
	for Name, Color in Cache.Colors
		Cache.ColorMap[Name] := A_Index


	; --- Generate the RTF headers ---
	RTF := "{\urtf"

	; Color Table
	RTF .= "{\colortbl;"
	for Name, Color in Cache.Colors
	{
		RTF .= "\red"    	Color>>16	& 0xFF
		RTF .= "\green"	Color>>8 	& 0xFF
		RTF .= "\blue"  	Color        	& 0xFF ";"
	}
	RTF .= "}"

	; Font Table
	if Settings.Font
	{
		FontTable .= "{\fonttbl{\f0\fmodern\fcharset0 "
		FontTable .= Settings.Font.Typeface
		FontTable .= ";}}"
		RTF .= "\fs" Settings.Font.Size * 2 ; Font size (half-points)
		if Settings.Font.Bold
			RTF .= "\b"
	}

	; Tab size (twips)
	RTF .= "\deftab" GetCharWidthTwips(Settings.Font) * Settings.TabSize

	Cache.RTFHeader := RTF
}

GetCharWidthTwips(Font) {

	static Cache := {}

	if Cache.HasKey(Font.Typeface "_" Font.Size "_" Font.Bold)
		return Cache[Font.Typeface "_" font.Size "_" Font.Bold]

	; Calculate parameters of CreateFont
	Height	:= -Round(Font.Size*A_ScreenDPI/72)
	Weight	:= 400+300*(!!Font.Bold)
	Face 	:= Font.Typeface

	; Get the width of "x"
	hDC 	:= DllCall("GetDC", "UPtr", 0)
	hFont 	:= DllCall("CreateFont"
					, "Int", Height 	; _In_ int       	  nHeight,
					, "Int", 0         	; _In_ int       	  nWidth,
					, "Int", 0        	; _In_ int       	  nEscapement,
					, "Int", 0        	; _In_ int       	  nOrientation,
					, "Int", Weight ; _In_ int        	  fnWeight,
					, "UInt", 0     	; _In_ DWORD   fdwItalic,
					, "UInt", 0     	; _In_ DWORD   fdwUnderline,
					, "UInt", 0     	; _In_ DWORD   fdwStrikeOut,
					, "UInt", 0     	; _In_ DWORD   fdwCharSet, (ANSI_CHARSET)
					, "UInt", 0     	; _In_ DWORD   fdwOutputPrecision, (OUT_DEFAULT_PRECIS)
					, "UInt", 0     	; _In_ DWORD   fdwClipPrecision, (CLIP_DEFAULT_PRECIS)
					, "UInt", 0     	; _In_ DWORD   fdwQuality, (DEFAULT_QUALITY)
					, "UInt", 0     	; _In_ DWORD   fdwPitchAndFamily, (FF_DONTCARE|DEFAULT_PITCH)
					, "Str", Face   	; _In_ LPCTSTR  lpszFace
					, "UPtr")
	hObj := DllCall("SelectObject", "UPtr", hDC, "UPtr", hFont, "UPtr")
	VarSetCapacity(SIZE, 8, 0)
	DllCall("GetTextExtentPoint32", "UPtr", hDC, "Str", "x", "Int", 1, "UPtr", &SIZE)
	DllCall("SelectObject", "UPtr", hDC, "UPtr", hObj, "UPtr")
	DllCall("DeleteObject", "UPtr", hFont)
	DllCall("ReleaseDC", "UPtr", 0, "UPtr", hDC)

	; Convert to twpis
	Twips := Round(NumGet(SIZE, 0, "UInt")*1440/A_ScreenDPI)
	Cache[Font.Typeface "_" Font.Size "_" Font.Bold] := Twips
	return Twips
}

EscapeRTF(Code) {
	for each, Char in ["\", "{", "}", "`n"]
		Code := StrReplace(Code, Char, "\" Char)
	return StrReplace(StrReplace(Code, "`t", "\tab "), "`r")
}

ControlIsFocused(ControlID) {                                                                  	;-- true or false if specified gui control is active or not

	GuiControlGet, FControlID, ARG:Focus
	If Instr(FControlID, ControlID)
			return true

return false
}

LV_AutoColumSizer(hLV, Sizes, Options:="") {                                         	;-- computes and changes the pixel width of the columns across the full width of a listview

	; PARAMETERS:
	; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	; Sizes   	- 	this example is for a 4 column listview, for a better understanding it is possible to use a different syntax
	;               	Sizes:= "15%, 18%, 60%" or "15, 18, 60" or "15,18,60" or "15|18|60" or "15% 18% 60%"
	;               	It does not matter which characters or strings you use for subdivision, the little RegEx algorithm recognizes the dividers
	;               	REMARK: !avoid specifying the last column width, this size will be computed!
	;                 	    *		*		*		*		*		*		*		*		*		*		*		*		*		*		*
	; ** todo **	there is also an automatic mode which calculates the column width of the listview over the maximum pixel width of the content of the columns
	;                	you have to use Sizes:= "AutoColumnWidth"
	;
	; ** todo ** Options 	-	can be passed to limit the maximum column width to the maximum pixel width of the column contents
	;                  	or to prevent undersizing of columns

	static hHeader, LVP, hLVO, SizesO
	w:= LVP:= []

	If hLVO <> hLV
			hHeader:= LV_EX_GetHeader(hLV), hLVO:= hLV

	If SizesO <> Sizes
	{
			pos := 1
			If !Instr(Sizes, "AutoColumnWidth")
					While pos:= RegExMatch(Sizes, "\d+", num, StrLen(num)+pos)
							LVP[A_Index] := num
			else
				nin:=1

			LVP_Last := 100

			Loop, % LVP.MaxIndex()
			{
					LVP[A_Index]	:= 	"0" . LVP[A_Index]
					LVP[A_Index]	+=	0
					LVP_Last      	-=	LVP[A_Index]
					LVP[A_Index]	:= 	Round(LVP[A_Index]/100, 2)
			}
			LVP.Push(Round((LVP_Last-1)/100, 2))
			SizesO:= Sizes
	}

	ControlGetPos,,, LV_Width,,, % "ahk_id " hLV
	LV_Width -= DllCall("GetScrollPos", "UInt", hLV, "Int", 1)	;subtracts the width of the vertical scrollbar to get the client size of the listview

	Loop, % LVP.MaxIndex()
		DllCall("SendMessage", "uint", hLV, "uint", 4126, "uint", A_Index-1, "int", Floor(LV_Width * LVP[A_Index])) 	;sets the column width
}

LV_EX_GetHeader(HLV) {                                                                         	;-- Retrieves the handle of the header control used by the list-view control.
   ; LVM_GETHEADER = 0x101F -> http://msdn.microsoft.com/en-us/library/bb774937(v=vs.85).aspx
   SendMessage, 0x101F, 0, 0, , % "ahk_id " . HLV
   Return ErrorLevel
}

LV_EX_GetColumnWidth(HLV, Column) {                                                	;-- gets the width of a column in report or list view.
   ; LVM_GETCOLUMNWIDTH = 0x101D -> http://msdn.microsoft.com/en-us/library/bb774915(v=vs.85).aspx
   SendMessage, 0x101D, % (Column - 1), 0, , % "ahk_id " . HLV
   Return ErrorLevel
}

OnMouseHover(wparam, lparam, msg, hwnd) {                                     	;-- Autofocus for Listview, Edit and RichEdit controls ;{

	static lastFocusedControl

	MouseGetPos,mx, my,, hControlOver
	WinGetClass, cclass, % "ahk_id " hwnd

	;ToolTip, % hControlOver "`n" hWinOver "`n" GetHex(wparam) "`n" GetHex(lparam) "`n" GetHex(msg) "`n" GetHex(hwnd) "`n" cclass
	If RegExMatch(hControlOver, "(Edit)|(SysListView32)|(SysListviewHeader)|(RichEdit)|(ComboBox)")
	{
			If (lastFocusedControl != hControlOver)
			{
					If !Instr(hControlOver, "SysListView32")
						ControlFocus, % hControlOver 	, % "ahk_id " hARG

					ControlGetText, SText, Edit1    	, % "ahk_id " hARG
					If (Trim(SText) = "type your search pattern here") && (hControlOver = "Edit1")
							NormalEditFont()
					else If (Trim(SText) = "") && (hControlOver <> "Edit1")
							ItalicEditFont()
			}
			lastFocusedControl := hControlOver
	}
	else if Instr(cclass, "RichEdit")
	{
			If !Instr(lastFocusedControl, cclass)
			{
					ControlFocus,, % "ahk_id " hwnd
					WinGetPos, wx, wy, ww, wh, % "ahk_id " hARG
					ControlGetPos, tx, ty, tw, th,, % "ahk_id " hTabs
					ToolTip, % "Press the right`nmouse button`nto copy the text.",% (wx + tx + tw - 195), % (wy + ty + 40), 2
					SetTimer, TTOff, -4000
			}

			ControlGetText, SText, Edit1, % "ahk_id " hArg
			If (Trim(SText) = "")
					ItalicEditFont()

			lastFocusedControl := cclass
	}

}

NormalEditFont() {
	Gui, Arg: Font, % "S" 11-fdecr1 " Normal C000000"
	GuiControl, ARG:Font	, Edit1
	GuiControl, ARG:     	, Edit1, % ""
return
}

ItalicEditFont() {

	Gui, Arg: Font, % "S" 11-fdecr1 " Italic CAAAAAA"
	GuiControl, ARG:Font	, Edit1
	GuiControl, ARG:     	, Edit1, % "type your search pattern here"
	; restore all functions
	If foundIndex
	{
			LV_Delete()
			For i, function in AHKData
					LV_Add("", function.mainsection, function.name, function.short, function.FnHash)
			GuiControl, Text, Field3, % "displayed functions: " fc
			foundIndex:= 0
	}

return
} ;}

GetHex(hwnd) {                                                                                       	;-- integer to hex
return Format("0x{:x}", hwnd)
}

GetDec(hwnd) {                                                                                       	;-- hex to integer
return Format("{:u}", hwnd)
}

Edit_SetFont(hEdit,hFont,p_Redraw=False) {

	;{------------------------------
	;
	; Function: Edit_SetFont
	;
	; Description:
	;
	;   Sets the font that the Edit control is to use when drawing text.
	;
	; Parameters:
	;
	;   hEdit - Handle to the Edit control.
	;
	;   hFont - Handle to the font (HFONT).  Set to 0 to use the default system
	;       font.
	;
	;   p_Redraw - Specifies whether the control should be redrawn immediately upon
	;       setting the font.  If set to TRUE, the control redraws itself.
	;
	; Remarks:
	;
	; * This function can be used to set the font on any control.  Just specify
	;   the handle to the desired control as the first parameter.
	;   Ex: Edit_SetFont(hLV,hFont) where "hLV" is the handle to ListView control.
	;
	; * The size of the control does not change as a result of receiving this
	;   message.  To avoid clipping text that does not fit within the boundaries of
	;   the control, the program should set/correct the size of the control before
	;   the font is set.
	;
	;-------------------------------------------------------------------------------;}
    Static WM_SETFONT:=0x30
    SendMessage WM_SETFONT,hFont,p_Redraw,,ahk_id %hEdit%
    }

Edit_SetMargins(hEdit, p_LeftMargin:="",p_RightMargin:="")  {

    Static 	 EM_SETMARGINS 	:=0xD3
		    	,EC_LEFTMARGIN 	:=0x1
		    	,EC_RIGHTMARGIN	:=0x2
	    		,EC_USEFONTINFO	:=0xFFFF

    l_Flags  	:= 0
    l_Margins	:= 0

    if p_LeftMargin is Integer
	{
        l_Flags  	|= EC_LEFTMARGIN
        l_Margins	|= p_LeftMargin           	;-- LOWORD
    }

    if p_RightMargin is Integer
    {
        l_Flags  	|=EC_RIGHTMARGIN
        l_Margins	|=p_RightMargin<<16	;-- HIWORD
    }

    if l_Flags
        SendMessage EM_SETMARGINS, l_Flags, l_Margins,, % "ahk_id " %hEdit%
}

RE_FindTextAndSelect(hRichEdit, Text, Mode) {

	; from Class_RichEdit modified to be a function without class

	Static FR:= {DOWN: 1, WHOLEWORD: 2, MATCHCASE: 4}
      Flags := 0
      For Each, Value In Mode
         If FR.HasKey(Value)
            Flags |= FR[Value]

	  Sel := RE_GetSel(hRichEdit)
      Min := (Flags & FR.DOWN) ? Sel.E : Sel.S
      Max := (Flags & FR.DOWN) ? -1 : 0

	VarSetCapacity(FT, 16 + A_PtrSize, 0)
	NumPut(CpMin,	FT, 0, "Int")
	NumPut(CpMax,	FT, 4, "Int")
	NumPut(&Text,	FT, 8, "Ptr")

	SendMessage, 0x047C, % hFlags, &FT, , % "ahk_id " hRichEdit
	S := NumGet(FT, 8 + A_PtrSize	, "Int")
	E := NumGet(FT, 12 + A_PtrSize	, "Int")
	 If (S = -1) && (E = -1)
         Return False

Return RE_SetSel(S, E, hRichEdit)
}

RE_GetSel(hRichEdit) {                                                                             	;-- Retrieves the starting and ending character positions of the selection in a rich edit control.
      ; Returns an object containing the keys S (start of selection) and E (end of selection)).
      ; EM_EXGETSEL = 0x0434
      VarSetCapacity(CR, 8, 0)
      SendMessage, 0x0434, 0, &CR, , % "ahk_id " hRichEdit
      Return {S: NumGet(CR, 0, "Int"), E: NumGet(CR, 4, "Int")}
}

RE_SetSel(Start, End, hRichEdit) {                                                            	;-- Selects a range of characters.
      ; Start : zero-based start index
      ; End   : zero-based end index (-1 = end of text))
      ; EM_EXSETSEL = 0x0437
      VarSetCapacity(CR, 8, 0)
      NumPut(Start, CR, 0, "Int")
      NumPut(End,   CR, 4, "Int")
      SendMessage, 0x0437, 0, &CR, , % "ahk_id " hRichEdit
      Return ErrorLevel
}

RE_GetTextLen(hRichEdit) {                                                                     	;-- Calculates text length in various ways.
      ; EM_GETTEXTLENGTHEX = 0x045F
      VarSetCapacity(GTL, 8, 0)     ; GETTEXTLENGTHEX structure
      NumPut(1200, GTL, 4, "UInt")  ; codepage = Unicode
      SendMessage, 0x045F, &GTL, 0, , % "ahk_id " hRichEdit
      Return ErrorLevel
}

Gdip_GetImagePixelFormat(pBitmap, mode:=0) {
; Mode options
; 0 - in decimal
; 1 - in hex
; 2 - in human readable string
;
; PXF01INDEXED = 0x00030101  ; 1 bpp, indexed
; PXF04INDEXED = 0x00030402  ; 4 bpp, indexed
; PXF08INDEXED = 0x00030803  ; 8 bpp, indexed
; PXF16GRAYSCALE = 0x00101004; 16 bpp, grayscale
; PXF16RGB555 = 0x00021005   ; 16 bpp; 5 bits for each RGB
; PXF16RGB565 = 0x00021006   ; 16 bpp; 5 bits red, 6 bits green, and 5 bits blue
; PXF16ARGB1555 = 0x00061007 ; 16 bpp; 1 bit for alpha and 5 bits for each RGB component
; PXF24RGB = 0x00021808   ; 24 bpp; 8 bits for each RGB
; PXF32RGB = 0x00022009   ; 32 bpp; 8 bits for each RGB, no alpha.
; PXF32ARGB = 0x0026200A  ; 32 bpp; 8 bits for each RGB and alpha
; PXF32PARGB = 0x000E200B ; 32 bpp; 8 bits for each RGB and alpha, pre-mulitiplied
; PXF48RGB = 0x0010300C   ; 48 bpp; 16 bits for each RGB
; PXF64ARGB = 0x0034400D  ; 64 bpp; 16 bits for each RGB and alpha
; PXF64PARGB = 0x001A400E ; 64 bpp; 16 bits for each RGB and alpha, pre-multiplied
; modified by Marius Șucan

   Static PixelFormatsList := {0x30101:"1-INDEXED", 0x30402:"4-INDEXED", 0x30803:"8-INDEXED", 0x101004:"16-GRAYSCALE", 0x021005:"16-RGB555", 0x21006:"16-RGB565", 0x61007:"16-ARGB1555", 0x21808:"24-RGB", 0x22009:"32-RGB", 0x26200A:"32-ARGB", 0xE200B:"32-PARGB", 0x10300C:"48-RGB", 0x34400D:"64-ARGB", 0x1A400E:"64-PARGB"}
   E := DllCall("gdiplus\GdipGetImagePixelFormat", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "UInt*", PixelFormat)
   If E
      Return -1

   If (mode=0)
      Return PixelFormat

   inHEX := Format("{1:#x}", PixelFormat)
   If (PixelFormatsList.Haskey(inHEX) && mode=2)
      result := PixelFormatsList[inHEX]
   Else
      result := inHEX
   return result
}

calcIMGdimensions(imgW, imgH, givenW, givenH, ByRef ResizedW
, ByRef ResizedH) {
   PicRatio := Round(imgW/imgH, 5)
   givenRatio := Round(givenW/givenH, 5)
   If (imgW <= givenW) && (imgH <= givenH)
   {
      ResizedW := givenW
      ResizedH := Round(ResizedW / PicRatio)
      If (ResizedH>givenH)
      {
         ResizedH := (imgH <= givenH) ? givenH : imgH
         ResizedW := Round(ResizedH * PicRatio)
      }
   } Else If (PicRatio > givenRatio)
   {
      ResizedW := givenW
      ResizedH := Round(ResizedW / PicRatio)
   } Else
   {
      ResizedH := (imgH >= givenH) ? givenH : imgH         ;set the maximum picture height to the original height
      ResizedW := Round(ResizedH * PicRatio)
   }
}

HighlightTab(hTab, TabNr, status) {                                                        	;-- Sendmessage Wrapper for highlight a tab
	SendMessage, 0x1333, % TabNr, % status,, %  "ahk_id " hTab ; TCM_HIGHLIGHTITEM
}

screenDims() {                                                                                         	;--returns a key:value pair of width screen dimensions (only for primary monitor)

	W := A_ScreenWidth
	H := A_ScreenHeight
	DPI := A_ScreenDPI
	Orient := (W>H)?"L":"P"
	yEdge := DllCall("GetSystemMetrics", "Int", SM_CYEDGE)
	yBorder := DllCall("GetSystemMetrics", "Int", SM_CYBORDER)

 return {W:W, H:H, DPI:DPI, OR:Orient, yEdge:yEdge, yBorder:yBorder}
}

GetWindowInfo(hWnd) {                                                                         	;-- returns an Key:Val Object with the most informations about a window (Pos, Client Size, Style, ExStyle, Border size...)
    NumPut(VarSetCapacity(WINDOWINFO, 60, 0), WINDOWINFO)
    DllCall("GetWindowInfo", "Ptr", hWnd, "Ptr", &WINDOWINFO)
    wi := Object()
    wi.X 	:= NumGet(WINDOWINFO, 4	, "Int")
    wi.Y		:= NumGet(WINDOWINFO, 8	, "Int")
    wi.W 	:= NumGet(WINDOWINFO, 12, "Int") 	- wi.X
    wi.H 	:= NumGet(WINDOWINFO, 16, "Int") 	- wi.Y
    wi.CX 		:= NumGet(WINDOWINFO, 20, "Int")
    wi.CY 		:= NumGet(WINDOWINFO, 24, "Int")
    wi.CW   	:= NumGet(WINDOWINFO, 28, "Int") 	- wi.CX
    wi.CH    	:= NumGet(WINDOWINFO, 32, "Int") 	- wi.CY
    wi.Style   	    	:= NumGet(WINDOWINFO, 36, "UInt")
    wi.ExStyle 		:= NumGet(WINDOWINFO, 40, "UInt")
    wi.Active  		:= NumGet(WINDOWINFO, 44, "UInt")
    wi.BW  	:= NumGet(WINDOWINFO, 48, "UInt")
    wi.BH   	:= NumGet(WINDOWINFO, 52, "UInt")
    wi.Atom        	:= NumGet(WINDOWINFO, 56, "UShort")
    wi.Version    	:= NumGet(WINDOWINFO, 58, "UShort")
    Return wi
}

bcrypt_md5(string) {
    static BCRYPT_MD5_ALGORITHM := "MD5"
    static BCRYPT_OBJECT_LENGTH := "ObjectLength"
    static BCRYPT_HASH_LENGTH   := "HashDigestLength"

    if !(hBCRYPT := DllCall("LoadLibrary", "str", "bcrypt.dll", "ptr"))
        throw Exception("Failed to load bcrypt.dll", -1)

    if (NT_STATUS := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", hAlgo, "ptr", &BCRYPT_MD5_ALGORITHM, "ptr", 0, "uint", 0) != 0)
        throw Exception("BCryptOpenAlgorithmProvider: " NT_STATUS, -1)

    if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", hAlgo, "ptr", &BCRYPT_OBJECT_LENGTH, "uint*", cbHashObject, "uint", 4, "uint*", cbResult, "uint", 0) != 0)
        throw Exception("BCryptGetProperty: " NT_STATUS, -1)

    if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", hAlgo, "ptr", &BCRYPT_HASH_LENGTH, "uint*", cbHash, "uint", 4, "uint*", cbResult, "uint", 0) != 0)
        throw Exception("BCryptGetProperty: " NT_STATUS, -1)

    VarSetCapacity(pbHashObject, cbHashObject, 0)
    if (NT_STATUS := DllCall("bcrypt\BCryptCreateHash", "ptr", hAlgo, "ptr*", hHash, "ptr", &pbHashObject, "uint", cbHashObject, "ptr", 0, "uint", 0, "uint", 0) != 0)
        throw Exception("BCryptCreateHash: " NT_STATUS, -1)

    VarSetCapacity(pbInput, StrPut(string, "UTF-8"), 0) && cbInput := StrPut(string, &pbInput, "UTF-8") - 1
    if (NT_STATUS := DllCall("bcrypt\BCryptHashData", "ptr", hHash, "ptr", &pbInput, "uint", cbInput, "uint", 0) != 0)
        throw Exception("BCryptHashData: " NT_STATUS, -1)

    VarSetCapacity(pbHash, cbHash, 0)
    if (NT_STATUS := DllCall("bcrypt\BCryptFinishHash", "ptr", hHash, "ptr", &pbHash, "uint", cbHash, "uint", 0) != 0)
        throw Exception("BCryptFinishHash: " NT_STATUS, -1)

    loop % cbHash
        hash .= Format("{:02x}", NumGet(pbHash, A_Index - 1, "uchar"))

    DllCall("bcrypt\BCryptDestroyHash", "ptr", hHash)
    DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgo, "uint", 0)
    DllCall("FreeLibrary", "ptr", hBCRYPT)

    return hash
}

bcrypt_sha512(string) {                                                                            	;-- used to compare versions of files
    static BCRYPT_SHA512_ALGORITHM := "SHA512"
    static BCRYPT_OBJECT_LENGTH    := "ObjectLength"
    static BCRYPT_HASH_LENGTH      := "HashDigestLength"

    if !(hBCRYPT := DllCall("LoadLibrary", "str", "bcrypt.dll", "ptr"))
        throw Exception("Failed to load bcrypt.dll", -1)

    if (NT_STATUS := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", hAlgo, "ptr", &BCRYPT_SHA512_ALGORITHM, "ptr", 0, "uint", 0) != 0)
        throw Exception("BCryptOpenAlgorithmProvider: " NT_STATUS, -1)

    if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", hAlgo, "ptr", &BCRYPT_OBJECT_LENGTH, "uint*", cbHashObject, "uint", 4, "uint*", cbResult, "uint", 0) != 0)
        throw Exception("BCryptGetProperty: " NT_STATUS, -1)

    if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", hAlgo, "ptr", &BCRYPT_HASH_LENGTH, "uint*", cbHash, "uint", 4, "uint*", cbResult, "uint", 0) != 0)
        throw Exception("BCryptGetProperty: " NT_STATUS, -1)

    VarSetCapacity(pbHashObject, cbHashObject, 0)
    if (NT_STATUS := DllCall("bcrypt\BCryptCreateHash", "ptr", hAlgo, "ptr*", hHash, "ptr", &pbHashObject, "uint", cbHashObject, "ptr", 0, "uint", 0, "uint", 0) != 0)
        throw Exception("BCryptCreateHash: " NT_STATUS, -1)

    VarSetCapacity(pbInput, StrPut(string, "UTF-8"), 0) && cbInput := StrPut(string, &pbInput, "UTF-8") - 1
    if (NT_STATUS := DllCall("bcrypt\BCryptHashData", "ptr", hHash, "ptr", &pbInput, "uint", cbInput, "uint", 0) != 0)
        throw Exception("BCryptHashData: " NT_STATUS, -1)

    VarSetCapacity(pbHash, cbHash, 0)
    if (NT_STATUS := DllCall("bcrypt\BCryptFinishHash", "ptr", hHash, "ptr", &pbHash, "uint", cbHash, "uint", 0) != 0)
        throw Exception("BCryptFinishHash: " NT_STATUS, -1)

    loop % cbHash
        hash .= Format("{:02x}", NumGet(pbHash, A_Index - 1, "uchar"))

    DllCall("bcrypt\BCryptDestroyHash", "ptr", hHash)
    DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgo, "uint", 0)
    DllCall("FreeLibrary", "ptr", hBCRYPT)

    return hash
}

UpdateAHKRare() {

	hash := []
	FileRead, file, % A_ScriptDir "\..\AHK-Rare.txt"
	hash[1]:= bcrypt_sha512(file)
	FileRead, file, % A_ScriptDir "\..\AHKRareTheGui.ahk"
	hash[2] := bcrypt_sha512(file)

	;Download(versions, "")
}

Download(ByRef Result,URL) {
 UserAgent := "" ;User agent for the request
 Headers := "" ;Headers to append to the request

 hModule := DllCall("LoadLibrary","Str","wininet.dll"), hInternet := DllCall("wininet\InternetOpenA","UInt",&UserAgent,"UInt",0,"UInt",0,"UInt",0,"UInt",0), hURL := DllCall("wininet\InternetOpenUrlA","UInt",hInternet,"UInt",&URL,"UInt",&Headers,"UInt",-1,"UInt",0x80000000,"UInt",0)
 If Not hURL
 {
  DllCall("FreeLibrary","UInt",hModule)
  Return, 0
 }
 VarSetCapacity(Buffer,512,0), TotalRead := 0
 Loop
 {
  DllCall("wininet\InternetReadFile","UInt",hURL,"UInt",&Buffer,"UInt",512,"UInt*",ReadAmount)
  If Not ReadAmount
   Break
  Temp1 := DllCall("LocalAlloc","UInt",0,"UInt",ReadAmount), DllCall("RtlMoveMemory","UInt",Temp1,"UInt",&Buffer,"UInt",ReadAmount), BufferList .= Temp1 . "|" . ReadAmount . "`n", TotalRead += ReadAmount
 }
 BufferList := SubStr(BufferList,1,-1), TotalRead -= 2, VarSetCapacity(Result,TotalRead,122), pResult := &Result
 Loop, Parse, BufferList, `n
 {
  StringSplit, Temp, A_LoopField, |
  DllCall("RtlMoveMemory","UInt",pResult,"UInt",Temp1,"UInt",Temp2), DllCall("LocalFree","UInt",Temp1), pResult += Temp2
 }
 DllCall("wininet\InternetCloseHandle","UInt",hURL), DllCall("wininet\InternetCloseHandle","UInt",hInternet), DllCall("FreeLibrary","UInt",hModule)
 Return, TotalRead
}

TheEnd(ExitReason, ExitCode) {
	;OnExit("")
	ExitApp
}

GetFileEncoding(File){
	Attribs := FileExist(File)
	If (!Attribs || InStr(Attribs, "D"))
	{	; If there are no attributes or the file has a folder attribute
		MsgBox, 262160, File encoding :, The file is not valid!`n%File%, 2
		Return
	}
	oFile := FileOpen(File, "r")	; Opens the file to be read
	oFile.Close()
	Return, oFile.Encoding
}

Ansi2UTF8(sString) {
   Ansi2Unicode(sString, wString, 0)
   Unicode2Ansi(wString, zString, 65001)
   Return zString
}

UTF82Ansi(zString) {
   Ansi2Unicode(zString, wString, 65001)
   Unicode2Ansi(wString, sString, 0)
   Return sString
}

Ansi2Unicode(ByRef sString, ByRef wString, CP = 0) {
     nSize := DllCall("MultiByteToWideChar" , "Uint", CP , "Uint", 0 , "Uint", &sString, "int",  -1, "Uint", 0 , "int",  0)
   VarSetCapacity(wString, nSize * 2)
   DllCall("MultiByteToWideChar", "Uint", CP, "Uint", 0, "Uint", &sString, "int",  -1, "Uint", &wString, "int",  nSize)
}

Unicode2Ansi(ByRef wString, ByRef sString, CP = 0) {
	nSize := DllCall("WideCharToMultiByte", "Uint", CP, "Uint", 0, "Uint", &wString, "int",  -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
	VarSetCapacity(sString, nSize)
	DllCall("WideCharToMultiByte", "Uint", CP, "Uint", 0, "Uint", &wString, "int",  -1, "Uint", 0), "str",  sString, "int",  nSize, "Uint", 0
}



;}

;{08. Include(s) and TrayIcon + Logo

Create_GemSmall_png(NewHandle := False) {
Static hBitmap := 0
If (NewHandle)
   hBitmap := 0
If (hBitmap)
   Return hBitmap
VarSetCapacity(B64, 31464 << !!A_IsUnicode)
;{
B64 := "iVBORw0KGgoAAAANSUhEUgAAADAAAAAyCAYAAAFtzWgaAAAACXBIWXMAAA7EAAAOxAGVKw4bAABB82lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMwNjcgNzkuMTU3NzQ3LCAyMDE1LzAzLzMwLTIzOjQwOjQyICAgICAgICAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIKICAgICAgICAgICAgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIgogICAgICAgICAgICB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIKICAgICAgICAgICAgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIKICAgICAgICAgICAgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIgogICAgICAgICAgICB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyI+CiAgICAgICAgIDx4bXA6Q3JlYXRvclRvb2w+QWRvYmUgUGhvdG9zaG9wIENDIDIwMTUgKFdpbmRvd3MpPC94bXA6Q3JlYXRvclRvb2w+CiAgICAgICAgIDx4bXA6Q3JlYXRlRGF0ZT4yMDE4LTEyLTE1VDE2OjE1OjM2KzAxOjAwPC94bXA6Q3JlYXRlRGF0ZT4KICAgICAgICAgPHhtcDpNb2RpZnlEYXRlPjIwMTgtMTItMTVUMTY6NDI6MzErMDE6MDA8L3htcDpNb2RpZnlEYXRlPgogICAgICAgICA8eG1wOk1ldGFkYXRhRGF0ZT4yMDE4LTEyLTE1VDE2OjQyOjMxKzAxOjAwPC94bXA6TWV0YWRhdGFEYXRlPgogICAgICAgICA8ZGM6Zm9ybWF0PmltYWdlL3BuZzwvZGM6Zm9ybWF0PgogICAgICAgICA8cGhvdG9zaG9wOkNvbG9yTW9kZT4zPC9waG90b3Nob3A6Q29sb3JNb2RlPgogICAgICAgICA8eG1wTU06SW5zdGFuY2VJRD54bXAuaWlkOmU5ZjdkMGIwLTdmMDctMTY0MC05ZmU3LWI1YmEzYTNiNzU3YTwveG1wTU06SW5zdGFuY2VJRD4KICAgICAgICAgPHhtcE1NOkRvY3VtZW50SUQ+YWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOmZiNzY3NDhlLTAwN2YtMTFlOS04YWQ0LWYwZGEyMWYxNDhhYTwveG1wTU06RG9jdW1lbnRJRD4KICAgICAgICAgPHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD54bXAuZGlkOjI0YmE4NTQ1LTdhMjEtYmQ0OC05M2JkLWYzMDVhMDkzYjhiZDwveG1wTU06T3JpZ2luYWxEb2N1bWVudElEPgogICAgICAgICA8eG1wTU06SGlzdG9yeT4KICAgICAgICAgICAgPHJkZjpTZXE+CiAgICAgICAgICAgICAgIDxyZGY6bGkgcmRmOnBhcnNlVHlwZT0iUmVzb3VyY2UiPgogICAgICAgICAgICAgICAgICA8c3RFdnQ6YWN0aW9uPmNyZWF0ZWQ8L3N0RXZ0OmFjdGlvbj4KICAgICAgICAgICAgICAgICAgPHN0RXZ0Omluc3RhbmNlSUQ+eG1wLmlpZDoyNGJhODU0NS03YTIxLWJkNDgtOTNiZC1mMzA1YTA5M2I4YmQ8L3N0RXZ0Omluc3RhbmNlSUQ+CiAgICAgICAgICAgICAgICAgIDxzdEV2dDp3aGVuPjIwMTgtMTItMTVUMTY6MTU6MzYrMDE6MDA8L3N0RXZ0OndoZW4+CiAgICAgICAgICAgICAgICAgIDxzdEV2dDpzb2Z0d2FyZUFnZW50PkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE1IChXaW5kb3dzKTwvc3RFdnQ6c29mdHdhcmVBZ2VudD4KICAgICAgICAgICAgICAgPC9yZGY6bGk+CiAgICAgICAgICAgICAgIDxyZGY6bGkgcmRmOnBhcnNlVHlwZT0iUmVzb3VyY2UiPgogICAgICAgICAgICAgICAgICA8c3RFdnQ6YWN0aW9uPmNvbnZlcnRlZDwvc3RFdnQ6YWN0aW9uPgogICAgICAgICAgICAgICAgICA8c3RFdnQ6cGFyYW1ldGVycz5mcm9tIGltYWdlL3BuZyB0byBhcHBsaWNhdGlvbi92bmQuYWRvYmUucGhvdG9zaG9wPC9zdEV2dDpwYXJhbWV0ZXJzPgogICAgICAgICAgICAgICA8L3JkZjpsaT4KICAgICAgICAgICAgICAgPHJkZjpsaSByZGY6cGFyc2VUeXBlPSJSZXNvdXJjZSI+CiAgICAgICAgICAgICAgICAgIDxzdEV2dDphY3Rpb24+c2F2ZWQ8L3N0RXZ0OmFjdGlvbj4KICAgICAgICAgICAgICAgICAgPHN0RXZ0Omluc3RhbmNlSUQ+eG1wLmlpZDo2OWZlNzMzZS0wOTM0LTkyNGYtODA4OS1mZjY2OTBlY2ZhMTE8L3N0RXZ0Omluc3RhbmNlSUQ+CiAgICAgICAgICAgICAgICAgIDxzdEV2dDp3aGVuPjIwMTgtMTItMTVUMTY6NDA6NDErMDE6MDA8L3N0RXZ0OndoZW4+CiAgICAgICAgICAgICAgICAgIDxzdEV2dDpzb2Z0d2FyZUFnZW50PkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE1IChXaW5kb3dzKTwvc3RFdnQ6c29mdHdhcmVBZ2VudD4KICAgICAgICAgICAgICAgICAgPHN0RXZ0OmNoYW5nZWQ+Lzwvc3RFdnQ6Y2hhbmdlZD4KICAgICAgICAgICAgICAgPC9yZGY6bGk+CiAgICAgICAgICAgICAgIDxyZGY6bGkgcmRmOnBhcnNlVHlwZT0iUmVzb3VyY2UiPgogICAgICAgICAgICAgICAgICA8c3RFdnQ6YWN0aW9uPnNhdmVkPC9zdEV2dDphY3Rpb24+CiAgICAgICAgICAgICAgICAgIDxzdEV2dDppbnN0YW5jZUlEPnhtcC5paWQ6ZWM3YzY4ZTMtNzY5Ny1iMjQ1LThmZTMtMzYzZWY4NWJhZjI2PC9zdEV2dDppbnN0YW5jZUlEPgogICAgICAgICAgICAgICAgICA8c3RFdnQ6d2hlbj4yMDE4LTEyLTE1VDE2OjQyOjMxKzAxOjAwPC9zdEV2dDp3aGVuPgogICAgICAgICAgICAgICAgICA8c3RFdnQ6c29mdHdhcmVBZ2VudD5BZG9iZSBQaG90b3Nob3AgQ0MgMjAxNSAoV2luZG93cyk8L3N0RXZ0OnNvZnR3YXJlQWdlbnQ+CiAgICAgICAgICAgICAgICAgIDxzdEV2dDpjaGFuZ2VkPi88L3N0RXZ0OmNoYW5nZWQ+CiAgICAgICAgICAgICAgIDwvcmRmOmxpPgogICAgICAgICAgICAgICA8cmRmOmxpIHJkZjpwYXJzZVR5cGU9IlJlc291cmNlIj4KICAgICAgICAgICAgICAgICAgPHN0RXZ0OmFjdGlvbj5jb252ZXJ0ZWQ8L3N0RXZ0OmFjdGlvbj4KICAgICAgICAgICAgICAgICAgPHN0RXZ0OnBhcmFtZXRlcnM+ZnJvbSBhcHBsaWNhdGlvbi92bmQuYWRvYmUucGhvdG9zaG9wIHRvIGltYWdlL3BuZzwvc3RFdnQ6cGFyYW1ldGVycz4KICAgICAgICAgICAgICAgPC9yZGY6bGk+CiAgICAgICAgICAgICAgIDxyZGY6bGkgcmRmOnBhcnNlVHlwZT0iUmVzb3VyY2UiPgogICAgICAgICAgICAgICAgICA8c3RFdnQ6YWN0aW9uPmRlcml2ZWQ8L3N0RXZ0OmFjdGlvbj4KICAgICAgICAgICAgICAgICAgPHN0RXZ0OnBhcmFtZXRlcnM+Y29udmVydGVkIGZyb20gYXBwbGljYXRpb24vdm5kLmFkb2JlLnBob3Rvc2hvcCB0byBpbWFnZS9wbmc8L3N0RXZ0OnBhcmFtZXRlcnM+CiAgICAgICAgICAgICAgIDwvcmRmOmxpPgogICAgICAgICAgICAgICA8cmRmOmxpIHJkZjpwYXJzZVR5cGU9IlJlc291cmNlIj4KICAgICAgICAgICAgICAgICAgPHN0RXZ0OmFjdGlvbj5zYXZlZDwvc3RFdnQ6YWN0aW9uPgogICAgICAgICAgICAgICAgICA8c3RFdnQ6aW5zdGFuY2VJRD54bXAuaWlkOmU5ZjdkMGIwLTdmMDctMTY0MC05ZmU3LWI1YmEzYTNiNzU3YTwvc3RFdnQ6aW5zdGFuY2VJRD4KICAgICAgICAgICAgICAgICAgPHN0RXZ0OndoZW4+MjAxOC0xMi0xNVQxNjo0MjozMSswMTowMDwvc3RFdnQ6d2hlbj4KICAgICAgICAgICAgICAgICAgPHN0RXZ0OnNvZnR3YXJlQWdlbnQ+QWRvYmUgUGhvdG9zaG9wIENDIDIwMTUgKFdpbmRvd3MpPC9zdEV2dDpzb2Z0d2FyZUFnZW50PgogICAgICAgICAgICAgICAgICA8c3RFdnQ6Y2hhbmdlZD4vPC9zdEV2dDpjaGFuZ2VkPgogICAgICAgICAgICAgICA8L3JkZjpsaT4KICAgICAgICAgICAgPC9yZGY6U2VxPgogICAgICAgICA8L3htcE1NOkhpc3Rvcnk+CiAgICAgICAgIDx4bXBNTTpEZXJpdmVkRnJvbSByZGY6cGFyc2VUeXBlPSJSZXNvdXJjZSI+CiAgICAgICAgICAgIDxzdFJlZjppbnN0YW5jZUlEPnhtcC5paWQ6ZWM3YzY4ZTMtNzY5Ny1iMjQ1LThmZTMtMzYzZWY4NWJhZjI2PC9zdFJlZjppbnN0YW5jZUlEPgogICAgICAgICAgICA8c3RSZWY6ZG9jdW1lbnRJRD54bXAuZGlkOjI0YmE4NTQ1LTdhMjEtYmQ0OC05M2JkLWYzMDVhMDkzYjhiZDwvc3RSZWY6ZG9jdW1lbnRJRD4KICAgICAgICAgICAgPHN0UmVmOm9yaWdpbmFsRG9jdW1lbnRJRD54bXAuZGlkOjI0YmE4NTQ1LTdhMjEtYmQ0OC05M2JkLWYzMDVhMDkzYjhiZDwvc3RSZWY6b3JpZ2luYWxEb2N1bWVudElEPgogICAgICAgICA8L3htcE1NOkRlcml2ZWRGcm9tPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICAgICA8dGlmZjpYUmVzb2x1dGlvbj45NjAwMDAvMTAwMDA8L3RpZmY6WFJlc29sdXRpb24+CiAgICAgICAgIDx0aWZmOllSZXNvbHV0aW9uPjk2MDAwMC8xMDAwMDwvdGlmZjpZUmVzb2x1dGlvbj4KICAgICAgICAgPHRpZmY6UmVzb2x1dGlvblVuaXQ+MjwvdGlmZjpSZXNvbHV0aW9uVW5pdD4KICAgICAgICAgPGV4aWY6Q29sb3JTcGFjZT42NTUzNTwvZXhpZjpDb2xvclNwYWNlPgogICAgICAgICA8ZXhpZjpQaXhlbFhEaW1lbnNpb24+NDg8L2V4aWY6UGl4ZWxYRGltZW5zaW9uPgogICAgICAgICA8ZXhpZjpQaXhlbFlEaW1lbnNpb24+NTA8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg"
B64 .= "ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAKPD94cGFja2V0IGVuZD0idyI/Plszt9AAAAAgY0hSTQAAeiUAAICDAAD5/wAAgOkAAHUwAADqYAAAOpgAABdvkl/FRgAAGbNJREFUeNpiZIAARgYGBj4GBgY2BgaGXwwMDJ8YGRgYGHMdPP9Zf9ZiYGG+zWCYX89wdOc+BhYGBgYmtXJ+hh3ZGxiYdQwZ/j+azvDp/V0Ghk2LlzOEePnWJ7ma/N9pIv//yvZd/xkYGDgZZ+9cy8DAwMDgG5X6392Vg8H3je1z7QQfKSa5NyIMGi//MUi8fcfywpuHoWXPShk2Li4GdMABYwAAAAD//2JGEuBjYGDgYWBg+M/AwPCHMZ4t+f8fqysMYb+EGa6XOzAUWWcwOLk7lzAJsN9i+H/5JcMMCQGG38f5GdYn9jAcOXt6IdPEz4eZ+PSFGJIef2cIUeZiOHj3GMOm9aveMECdK5rnKPY/zz/wPwMDA+vyJYsZmDRe/GY4vGj164D9fxi2nr8wc+26tb85eLlRnMoIxQwMDAwMAAAAAP//Yty1dRaDm3ca8xJm5T/lUXwMmRd/M7CwsTPw/+FmeKUsx6DCycbwmKWQgVWi/HFxxzYFZlcbuypLLfODPF8eMiR/EGFg/+vO4PTrM8Pk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"
;}
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
VarSetCapacity(Dec, DecLen, 0)
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
; Bitmap creation adopted from "How to convert Image data (JPEG/PNG/GIF) to hBITMAP?" by SKAN
; -> http://www.autohotkey.com/board/topic/21213-how-to-convert-image-data-jpegpnggif-to-hbitmap/?p=139257
hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
DllCall("Gdiplus.dll\GdipCreateHICONFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
Return hBitmap
}

Create_AHKRareGuiLogo4k_png(NewHandle := False) {
Static hBitmap := Create_AHKRareGuiLogo4k_png()
oImage:= Object()
If (NewHandle)
   hBitmap := 0
If (hBitmap)
   Return hBitmap
VarSetCapacity(B64, 131888 << !!A_IsUnicode)
;{
B64 := "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"
B64 .= "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"
B64 .= "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"
B64 .= "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"
B64 .= "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"
B64 .= "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"
B64 .= "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"
B64 .= "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"
B64 .= "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"
;}
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
VarSetCapacity(Dec, DecLen, 0)
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
; Bitmap creation adopted from "How to convert Image data (JPEG/PNG/GIF) to hBITMAP?" by SKAN
; -> http://www.autohotkey.com/board/topic/21213-how-to-convert-image-data-jpegpnggif-to-hbitmap/?p=139257
hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
DllCall("gdiplus\GdipGetImageWidth"                         	, A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", width)
DllCall("gdiplus\GdipGetImageHeight"                      	, A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", height)
DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap"	,"Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
oImage.hBitmap:= hBitmap, oImage.height:= height, oImage.width:= width, oImage.pBitmap:= 0
Return oImage
}

Create_AHKRareGuiLogo2k_png(NewHandle := False) {
Static hBitmap := Create_AHKRareGuiLogo2k_png()
oImage:= Object()
If (NewHandle)
   hBitmap := 0
If (hBitmap)
   Return hBitmap
VarSetCapacity(B64, 44272 << !!A_IsUnicode) ;{
B64 := "iVBORw0KGgoAAAANSUhEUgAAAcgAAABICAYAAAByZmWGAAAExGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS41LjAiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgeG1sbnM6YXV4PSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wL2F1eC8iCiAgICB4bWxuczpleGlmRVg9Imh0dHA6Ly9jaXBhLmpwL2V4aWYvMS4wLyIKICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIgogICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIgogICAgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iCiAgICB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIKICAgIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiCiAgIGF1eDpMZW5zPSIiCiAgIGV4aWZFWDpMZW5zTW9kZWw9IiIKICAgdGlmZjpJbWFnZUxlbmd0aD0iNzIiCiAgIHRpZmY6SW1hZ2VXaWR0aD0iNDU2IgogICB0aWZmOlJlc29sdXRpb25Vbml0PSIyIgogICB0aWZmOlhSZXNvbHV0aW9uPSI3Mi4wIgogICB0aWZmOllSZXNvbHV0aW9uPSI3Mi4wIgogICB4bXA6Q3JlYXRvclRvb2w9IkFkb2JlIEltYWdlUmVhZHkiCiAgIHhtcDpNb2RpZnlEYXRlPSIyMDE5LTA5LTIxVDIxOjM2OjAyKzAyOjAwIgogICB4bXA6TWV0YWRhdGFEYXRl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"
B64 .= "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"
B64 .= "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"
B64 .= "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"
B64 .= "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" ;}
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
VarSetCapacity(Dec, DecLen, 0)
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
; Bitmap creation adopted from "How to convert Image data (JPEG/PNG/GIF) to hBITMAP?" by SKAN
; -> http://www.autohotkey.com/board/topic/21213-how-to-convert-image-data-jpegpnggif-to-hbitmap/?p=139257
hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
DllCall("gdiplus\GdipGetImageWidth"                         	, A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", width)
DllCall("gdiplus\GdipGetImageHeight"                      	, A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", height)
DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
oImage.hBitmap:= hBitmap, oImage.height:= height, oImage.width:= width, oImage.pBitmap:= 0
Return oImage
}

Gdip_ResizeBitmap(oImage, givenW, givenH, KeepRatio                          	;-- resizes a pBitmap image (function is modified!!)
, InterpolationMode:=7, KeepPixelFormat:=0) {

	; function is modified to work only here, it uses an object created by Create_AHKRareGuiLogo_png()
	; It returns a pointer to a new pBitmap.

    If KeepRatio=1
		calcIMGdimensions(oImage.Width, oImage.Height, givenW, givenH, ResizedW, ResizedH)
    Else
       ResizedW := givenW, ResizedH := givenH

    If (KeepPixelFormat=1)
		PixelFormat := Gdip_GetImagePixelFormat(oImage.pBitmap, 1)
	else
		PixelFormat := 0x26200A  ; 32-ARGB

	new_pBitmap:= ""
	new_pBitmap:= DllCall("gdiplus\GdipCreateBitmapFromScan0"
	           	, "int"                                   	, ResizedW
				, "int"                                   	, 0
				, "int"                                   	, PixelFormat
				, A_PtrSize ? "UPtr" : "UInt"  	, 0
				, "int"                                   	, ResizedH
				, A_PtrSize ? "UPtr*" : "uint*"	, 0)

	ToolTip, % "pBitmap: " GetHex(new_pBitmap) "`nw: " ResizedW "`nh: " ResizedH

	DllCall("gdiplus\GdipGetImageGraphicsContext"
											, A_PtrSize ? "UPtr" : "UInt"  	, new_pBitmap
											, A_PtrSize ? "UPtr*" : "UInt*"	, pGraphics)				           	;G := Gdip_GraphicsFromImage(new_Bitmap)

    DllCall("gdiplus\GdipSetInterpolationMode"
											, A_PtrSize ? "UPtr" : "UInt"  	, pGraphics
											, "int"                                   	, InterpolationMode)         	;Gdip_SetInterpolationMode(G, InterpolationMode)

	DllCall("gdiplus\GdipDrawImageRect"
											, A_PtrSize ? "UPtr" : "UInt"  	, pGraphics
											, A_PtrSize ? "UPtr" : "UInt"  	, new_pBitmap
											, "float"                                	, 0
											, "float"                                	, 0
											, "float"                                 	, ResizedW
											, "float"                                	, ResizedH)                       	;Gdip_DrawImageRect(G, pBitmap, 0, 0, ResizedW, ResizedH)

    DllCall("gdiplus\GdipDeleteGraphics", A_PtrSize ? "UPtr" : "UInt", pGraphics)         	;Gdip_DeleteGraphics(G)

Return new_pBitmap
}


#Include %A_ScriptDir%\classes\class_RichCode.ahk
#Include %A_ScriptDir%\classes\class_bcrypt.ahk
;}



