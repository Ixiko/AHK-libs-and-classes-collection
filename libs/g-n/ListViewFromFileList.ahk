; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=63003
; Author:
; Date:
; for:     	AHK_L

/*

	If !FileExist(StrSplit(fileList, "`n")[1])	;if first item on list doesn't exist prompt for a new list...
		FileSelectFile, fileList, M2, % A_ScriptDir, Select Files From Which To Generate A File List.
	Loop Parse, fileList, `n	;FileSelectFile seems to provide file names & folder name separately,so this fixes that...
		If (A_Index > 1)
			fL .= StrSplit(fileList, "`n")[1] "\" A_LoopField "`n"
	;MsgBox % fL

	ListViewFromFileList(fL)
	ExitApp

*/


ListViewFromFileList(ByRef fileList){
	Static
	Global LV
	;menu to handle right clicking on menu entry
	Menu,Menu1,Add,Copy Path to Clipboard, &CopyToClipboard ;Used when rightclicking
	Menu,Menu1,Add,Show in Explorer, HighlightInExplorer ;Used when rightclicking
	;allow gui to be Resized, to be used along side AutoXYWH()
	Gui, +Resize +LastFound
	Gui, Color, Black
	; Create the ListView with two columns, Name and Size:
	Gui, Add, ListView, r20 w800 BackgroundBlack cWhite hwndListViewFromFileListHwnd gMyListView vLV altsubmit,Name|Size|Path		;with altsubmit A_GuiEvent returns proper values, while without it returns just 'DoubleClick' or 'R' for double rightclick
	; Gather a list of file names from a folder and put them into the ListView:
	Loop, Parse, fileList, `n
		If A_LoopField
			LV_Add("", SplitPath(A_LoopField).OutFileName, FileFolderGetSize(A_LoopField) . (IsDir(A_LoopField) ? " - " ComObjCreate("Scripting.FileSystemObject").GetFolder(A_LoopField).Files.Count . " Files"  : ""), A_LoopField)
	LV_ModifyCol()  ; Auto-size each column to fit its contents.
	LV_ModifyCol(2, "Integer")  ; For sorting purposes, indicate that column 2 is an integer.

	; Display the window and return. The script will be notified whenever the user double clicks a row.
	Gui, Show
	;wait until search results gui is closed
	while WinExist("ahk_id" ListViewFromFileListHwnd)
		Sleep 50
	return

	MyListView:
	LV_GetText(RowText, A_EventInfo)  ; Get the text from the row's first field.
	LV_GetText(RowText3rdColumn, A_EventInfo, 3)  ; Get the text from the row's first field.
	if (A_GuiEvent = "DoubleClick")
		Run, % RowText3rdColumn		;open file with default application
	else if (A_GuiEvent = "RightClick"){	;right double click
		keywait, rbutton, d, t0.2
		if !errorlevel
			gosub, HighlightInExplorer
		else
			Menu,Menu1,Show
	}
	return
	GuiSize:
	If (A_EventInfo = 1) ; The window has been minimized.
		Return
	AutoXYWH("wh", "LV")
	return

	GuiEsc:
	GuiClose:  ; Indicate that the script should exit automatically when the window is closed.
	Gui Destroy
	return

	&CopyToClipboard:	;if one file it can be pasted inside explorer,else if more than one selection the list of files is copied...
	selectedFile:=Trim(LV_GetSelected(ListViewFromFileListHwnd),"`n")
	( InStr(selectedFile,"`n") ? (clipboard := selectedFile) : InvokeVerb(selectedFile, "Copy") )
	return

	HighlightInExplorer:
	Run,% "explorer.exe /e`, /n`, /select`, """ RowText3rdColumn """"
	return
}

IsDir(path){
	Return % InStr( FileExist(path), "D" ) ? 1 : 0
}

FileFolderGetSize(path){
	If InStr( FileExist(path), "D" )
		Loop, %path%\*.*, , 1
			fileFolderSize += %A_LoopFileSize%
	Else, FileGetSize, fileFolderSize , % path

	size := StrLen(buf := "0123456789ABCDEF")
	if !(pstr := DllCall("shlwapi.dll\StrFormatByteSize64A", "int64", fileFolderSize, "str", buf, "uint", size, "astr"))
		throw Exception("StrFormatByteSize64 failed: " pstr, -1)
	return pstr
}

SplitPath(path){
	SplitPath, path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive	;maintained default naming for ease of use...
	Loop %path%, 1
		fileLongPath := A_LoopFileLongPath
	Return {OutFileName:OutFileName, OutDir:OutDir, OutExtension:OutExtension, OutNameNoExt:OutNameNoExt, OutDrive:OutDrive, OutLongPath:OutLongPath}
}

/*
	-------------------------------------------------------------------------------------------------------------
	LV.ahk
	Useful ListView functions.
	Note: No function is dependant upon another within this file.
	-------------------------------------------------------------------------------------------------------------
*/
LV_GetSelected(hwnd){
	Loop, % LV_GetCount()
		If LV_EX_IsRowSelected(hwnd, A_Index)
			LV_GetText(selectedText, A_Index, 3),list := list . selectedText . "`n"
	Return list
}
; ======================================================================================================================
; LV_EX_IsRowSelected - Indicates if a row in the list-view control is selected.
; ======================================================================================================================
LV_EX_IsRowSelected(HLV, Row) {
	Return LV_EX_GetItemState(HLV, Row).Selected
}
; ======================================================================================================================
; LV_EX_GetItemState - Retrieves the state of a list-view item.
; ======================================================================================================================
LV_EX_GetItemState(HLV, Row) {
	; LVM_GETITEMSTATE = 0x102C -> http://msdn.microsoft.com/en-us/library/bb761053(v=vs.85).aspx
	Static LVIS := {Cut: 0x04, DropHilited: 0x08, Focused: 0x01, Selected: 0x02, Checked: 0x2000}
	SendMessage, 0x102C, % (Row - 1), 0xFFFF, , % "ahk_id " . HLV ; all states
	States := ErrorLevel
	Result := {}
	For Key, Value In LVIS
		Result[Key] := States & Value
	Return Result
}

; =================================================================================
; Function: AutoXYWH
;   Move and resize control automatically when GUI resizes.
; Parameters:
;   DimSize - Can be one or more of x/y/w/h  optional followed by a fraction
;             add a '*' to DimSize to 'MoveDraw' the controls rather then just 'Move', this is recommended for Groupboxes
;   cList   - variadic list of ControlIDs
;             ControlID can be a control HWND, associated variable name, ClassNN or displayed text.
;             The later (displayed text) is possible but not recommend since not very reliable
; Examples:
;   AutoXYWH("xy", "Btn1", "Btn2")
;   AutoXYWH("w0.5 h 0.75", hEdit, "displayed text", "vLabel", "Button1")
;   AutoXYWH("*w0.5 h 0.75", hGroupbox1, "GrbChoices")
; ---------------------------------------------------------------------------------
; Version: 2015-5-29 / Added 'reset' option (by tmplinshi)
;          2014-7-03 / toralf
;          2014-1-2  / tmplinshi
; requires AHK version : 1.1.13.01+
; =================================================================================
AutoXYWH(DimSize, cList*){       ; http://ahkscript.org/boards/viewtopic.php?t=1079
	static cInfo := {}

	If (DimSize = "reset")
		Return cInfo := {}

	For i, ctrl in cList {
		ctrlID := A_Gui ":" ctrl
		If ( cInfo[ctrlID].x = "" ){
			GuiControlGet, i, %A_Gui%:Pos, %ctrl%
			MMD := InStr(DimSize, "*") ? "MoveDraw" : "Move"
			fx := fy := fw := fh := 0
			For i, dim in (a := StrSplit(RegExReplace(DimSize, "i)[^xywh]")))
				If !RegExMatch(DimSize, "i)" dim "\s*\K[\d.-]+", f%dim%)
					f%dim% := 1
			cInfo[ctrlID] := { x:ix, fx:fx, y:iy, fy:fy, w:iw, fw:fw, h:ih, fh:fh, gw:A_GuiWidth, gh:A_GuiHeight, a:a , m:MMD}
		}Else If ( cInfo[ctrlID].a.1) {
			dgx := dgw := A_GuiWidth  - cInfo[ctrlID].gw  , dgy := dgh := A_GuiHeight - cInfo[ctrlID].gh
			For i, dim in cInfo[ctrlID]["a"]
				Options .= dim (dg%dim% * cInfo[ctrlID]["f" dim] + cInfo[ctrlID][dim]) A_Space
			GuiControl, % A_Gui ":" cInfo[ctrlID].m , % ctrl, % Options
} } }

InvokeVerb(path, menu, validate=True) {
	;by A_Samurai
	;v 1.0.1 http://sites.google.com/site/ahkref/custom-functions/invokeverb
	objShell := ComObjCreate("Shell.Application")
	if InStr(FileExist(path), "D") || InStr(path, "::{") {
		objFolder := objShell.NameSpace(path)
		objFolderItem := objFolder.Self
	} else {
		SplitPath, path, name, dir
		objFolder := objShell.NameSpace(dir)
		objFolderItem := objFolder.ParseName(name)
	}
	if validate {
		colVerbs := objFolderItem.Verbs
		loop % colVerbs.Count {
			verb := colVerbs.Item(A_Index - 1)
			retMenu := verb.name
			StringReplace, retMenu, retMenu, &
			if (retMenu = menu) {
				verb.DoIt
				Return True
			}
		}
		Return False
	} else
		objFolderItem.InvokeVerbEx(Menu)
}
