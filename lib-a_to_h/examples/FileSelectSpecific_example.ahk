#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force

; ONE OR MORE NON-RTF FILES WITHIN C:
WinWaitClose % "ahk_id " FileSelectSpecific("","C:","File","Please Choose file(s) in C: (no rtf)","",1,,,"rtf",1)
if !glb_FSReturn
	msgbox No selection
else
	msgbox selection was %glb_FSReturn%
	
;ANY SINGLE FILE ANYWHERE
WinWaitClose % "ahk_id " FileSelectSpecific("","","File","Please Choose a file")
if !glb_FSReturn
	msgbox No selection
else
	msgbox selection was %glb_FSReturn%
return

FileSelectSpecific(P_OwnerNum,P_Path,P_SelectFileOrFolder="File",P_Prompt="",P_ComplementText="",P_Multi="",P_DefaultView="Icon",P_FilterOK="",P_FilterNO="",P_Restrict=1,P_LVHeight="220",P_LVWidth="350") {
global
	
	;*****************************
	; MAKE SURE PREVIOUS OWNER IS RE-ENABLED AND EXISTING FS DESTROYED
	;*****************************
	if glb_FSOwnerNum
		try, Gui,%glb_FSOwnerNum%:-Disabled
	try Gui,FileSelectSpecific:Destroy
	;*****************************
	; CONTEXT MENU
	;*****************************
	try
	Menu, FSContextMenu, Add, SELECT, FSSelect
	Menu, FSContextMenu, Add, Create Folder, FSCreateFolder
	Menu, FSContextMenu, Add, Open Folder in Explorer, FSDisplayFolder
	Menu, FSContextMenu, Default, 1&

	;*****************************
	; GLOBAL VARS
	;*****************************
	glb_FSTitle=%A_ScriptName% - File Select Dialog
	
	glb_FSInit:=1
	glb_FSFolder:=P_Path
	glb_FSCurrent:=glb_FSFolder
	glb_FSFilterOK:=P_FilterOK
	glb_FSFilterNO:=P_FilterNO
	glb_FSRestrict:=P_Restrict

	glb_FSType:=P_SelectFileOrFolder
	glb_FSReturn:=""
	glb_FSOwnerNum:=P_OwnerNum
	
	
	if (P_SelectFileOrFolder="File" or P_SelectFileOrFolder="All")
		LoopType:="FD"
	else if (P_SelectFileOrFolder="Folder")
		LoopType:="D"
		
	glb_FSLoopType:=LoopType
	
	if P_Multi
		glb_FSNoMulti:=""
	else
		glb_FSNoMulti:="-Multi"
		
	; Check if the last character of the folder name is a backslash, which happens for root
	; directories such as C:\. If it is, remove it to prevent a double-backslash later on.
	StringRight, LastChar, glb_FSFolder, 1
	if LastChar = \
		StringTrimRight, glb_FSFolder, glb_FSFolder, 1  ; Remove the trailing backslash.
	glb_FSCurrent:=glb_FSFolder
		
	;*****************************
	; GUI CREATION
	;*****************************
	Gui, FileSelectSpecific:Default
	Gui, FileSelectSpecific: New
	Gui +HwndFSHwnd
	Gui +Resize +MinSize330x280
	
	;SET AND DISABLE OWNER
	if (glb_FSOwnerNum) {
		Gui +Owner%glb_FSOwnerNum%
		Gui, %glb_FSOwnerNum%:+Disabled
		}
	
	Gui +OwnDialogs  ; Forces user to dismiss the following dialog before using main window.

	; Create some buttons:
	Gui, Add, Button, xm w20 gFSSwitchView, % Chr(0x02630)
	Gui, Font, Bold
	Gui, Add, Button, x+5 yp gFSRefresh, % Chr(0x21BB)
	Gui, Add, Button, x+5 w30 gFSPrevious, % Chr(0x2190)
	; Gui, Font
	; Gui, Font, Bold
	Gui, Add, Button, x+5 yp gFSSelect, % "SELECT"
	Gui, Font
	Gui, Add, Edit, xm y+8 w%P_LVWidth% vFSNavBarv, % glb_FSCurrent
	Gui, Add, Text, xm y+8 w%P_LVWidth% vFSPromptv, % P_Prompt
	

	; Create the ListView and its columns:
	ListViewPos:= " w" P_LVWidth
	ListViewPos:= " h" P_LVHeight
	
	Gui, Add, ListView, xm y+10 %ListViewPos% vFSListView gFSListViewHandler %glb_FSNoMulti%, Name|In Folder|Size (KB)|Type
	LV_ModifyCol(3, "Integer")  ; For sorting, indicate that the Size column is an integer.
	
	if (P_DefaultView="Icon") {
		GuiControl, +Icon, FSListView    ; Switch to icon view.
		Glb_FSIconView:=1
	} else {
		GuiControl, +Report, FSListView  ; Switch back to details view.
		Glb_FSIconView:=0
	}
	
	Gui, Font, s10
	if P_ComplementText
		Gui, Add, Text, xm y+8 w%P_LVWidth% vFSComplementv, % P_ComplementText
	
	Gui, Font, Italic s9
	if !glb_FSNoMulti
		Gui, Add, Text, xm y+5 w%P_LVWidth% vFSMultiIndicv, % "Hold Ctrl or Shift for Multi-Selection"
	
	Gui, Font
	
	;*****************************
	; ICONS CREATION
	;*****************************
	; Calculate buffer size required for SHFILEINFO structure.
	FSIconArray:={}

	FSImageListID1 := IL_Create(10)
	FSImageListID2 := IL_Create(10, 10, true)  ; A list of large icons to go with the small ones.
	; Attach the ImageLists to the ListView so that it can later display the icons:
	LV_SetImageList(FSImageListID1)
	LV_SetImageList(FSImageListID2)

	; Gather a list of file names from the selected folder and append them to the ListView:
	;*****************************
	; SEARCH FILES AND SHOW GUI
	;*****************************
	GuiControl, -Redraw, FSListView  ; Improve performance by disabling redrawing during load.
	
	FSAddLoopFiles()
	FSRedrawCol()
	
	GuiControl, +Redraw, FSListView  ; Re-enable redrawing (it was disabled above).
	
	Gui, Show,,% glb_FSTitle
	glb_FSInit:=0
	
	return FSHwnd
}

FileSelectSpecificAdjust(P_Path="") {
	global
	if !P_Path
		P_Path:=glb_FSCurrent
	Gui FileSelectSpecific: Default
	GuiControl, -Redraw, FSListView
	LV_Delete()
	FSAddLoopFiles()
	GuiControl,,FSNavBarv, % glb_FSCurrent
	FSRedrawCol()
	GuiControl, +Redraw, FSListView
}

FSAddLoopFiles() {
global
	Gui FileSelectSpecific: Default
	
	FSsfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
	VarSetCapacity(FSsfi, FSsfi_size,0)
	
	if !glb_FSCurrent {
		DriveGet, FSDriveList, list
		FSDriveLabels:={}
		
		Loop, parse, FSDriveList 
			{
			DriveGet, FSDriveLabel, Label, %A_Loopfield%:
			FSDriveLabels[A_Index]:=FSDriveLabel
		
			IconNumber:=FSSetIcon(A_Loopfield ":","",FSIconArray,FSImageListID1,FSImageListID2)
			
			LV_Add("Icon" . IconNumber, A_Loopfield ": " FSDriveLabels[A_Index], "", "", "")
			}
		return
	}

	Loop, Files, %glb_FSCurrent%\*, %glb_FSLoopType%
	{
		if A_LoopFileAttrib contains H,S  ; Skip any file that is either H (Hidden), or S (System). Note: No spaces in "H,S".
			continue  ; Skip this file and move on to the next one.
		
		; FileName := A_LoopFileFullPath  ; Must save it to a writable variable for use below.
		
		If glb_FSfilterOK
			If A_LoopFileExt not in ,%glb_FSfilterOK%
				continue
			
		If glb_FSFilterNO
			If A_LoopFileExt in %glb_FSFilterNO%
				continue
		
		IconNumber:=FSSetIcon(A_LoopFileFullPath,A_LoopFileExt,FSIconArray,FSImageListID1,FSImageListID2)

		; Create the new row in the ListView and assign it the icon number determined above:
		LV_Add("Icon" . IconNumber, A_LoopFileName, A_LoopFileDir, A_LoopFileSizeKB, A_LoopFileExt)
	}
}

FSSetIcon(P_Filepath,P_FileExt,ByRef P_IconArray,ByRef P_Imagelist1,ByRef P_ImageList2) {
global
	
	if P_FileExt in EXE,ICO,ANI,CUR
	{
		ExtID := P_FileExt  ; Special ID as a placeholder.
		IconNumber = 0  ; Flag it as not found so that these types can each have a unique icon.
	}
	else  ; Some other extension/file-type, so calculate its unique ID.
	{
		;TTRICK: if no ext it can be drive or directory or a file without ext. In this case we create a fake ext so they won't use the same icons and icons can be re-used
		if !P_FileExt
		{
			
			if Regexmatch(P_Filepath, ":$")
				P_FileExt:="DRIVE"
			else if InStr(FileExist(P_Filepath), "D")
				P_FileExt:="DIR"
			else if FileExist(P_Filepath)
				P_FileExt:="NOEXT"
		}
		ExtID = 0  ; Initialize to handle extensions that are shorter than others.
		Loop 7     ; Limit the extension to 7 characters so that it fits in a 64-bit value.
			{
			StringMid, ExtChar, P_FileExt, A_Index, 1
			if not ExtChar  ; No more characters.
				break
			; Derive a Unique ID by assigning a different bit position to each character:
			ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
			}
		; Check if this file extension already has an icon in the ImageLists. If it does,
		; several calls can be avoided and loading performance is greatly improved,
		; especially for a folder containing hundreds of files:
		IconNumber := P_IconArray[ExtID]
	}
	;can debug icons here
	; msgbox IconNumber %IconNumber% P_Filepath %P_Filepath% P_FileExt %P_FileExt%
	if not IconNumber  ; There is not yet any icon for this extension, so load it.
	{
		; Get the high-quality small-icon associated with this file extension:
		if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str", P_Filepath, "uint", 0, "ptr", &FSsfi, "uint", FSsfi_size, "uint", 0x101)  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
			IconNumber = 9999999  ; Set it out of bounds to display a blank icon.
		else ; Icon successfully loaded.
		{
			; Extract the hIcon member from the structure:
			hIcon := NumGet(FSsfi, 0)
			; Add the HICON directly to the small-icon and large-icon lists.
			; Below uses +1 to convert the returned index from zero-based to one-based:
			IconNumber := DllCall("ImageList_ReplaceIcon", "ptr", P_Imagelist1, "int", -1, "ptr", hIcon) + 1
			DllCall("ImageList_ReplaceIcon", "ptr", P_ImageList2, "int", -1, "ptr", hIcon)
			; Now that it's been copied into the ImageLists, the original should be destroyed:
			DllCall("DestroyIcon", "ptr", hIcon)
			; Cache the icon to save memory and improve loading performance:
			P_IconArray[ExtID] := IconNumber
		}
	}
	return IconNumber
}


;*****************************
;FS GUI LABELS
;*****************************
FSCreateFolder:
	Gui FileSelectSpecific: Default
	InputBox, FolderName, , % "Enter Folder Name",,,120
	if (ErrorLevel or !FolderName)
		return
	FileCreateDir, % glb_FSCurrent "/" FolderName
	FileSelectSpecificAdjust(glb_FSCurrent)
return

FSDisplayFolder:
	Gui FileSelectSpecific: Default
	FSOpenFolderInExplorer(glb_FSCurrent)
return

FSSwitchView:
	Gui FileSelectSpecific: Default
	GuiControl, -Redraw, FSListView
	if not Glb_FSIconView
		GuiControl, +Icon, FSListView    ; Switch to icon view.
	else
		GuiControl, +Report, FSListView  ; Switch back to details view.
	Glb_FSIconView := not Glb_FSIconView             ; Invert in preparation for next time.
	FSRedrawCol()
	GuiControl, +Redraw, FSListView
return

FSRedrawCol() {
global
	Gui FileSelectSpecific: Default
	LV_ModifyCol()  ; Auto-size each column to fit its contents.
	LV_ModifyCol(2,0)  ; Hide FileDir Col
	LV_ModifyCol(3, 60) ; Make the Size column at little wider to reveal its header.
	LV_ModifyCol(4, "AutoHdr") ; Make the Size column at little wider to reveal its header.
}

FSListViewHandler:
	if A_GuiEvent = DoubleClick  ; There are many other possible values the script can check.
	{
		LV_GetText(FileName, A_EventInfo, 1) ; Get the text of the first field.
		LV_GetText(FileDir, A_EventInfo, 2)  ; Get the text of the second field.
		; LV_GetText(FileExt, A_EventInfo, 4)  ; Get the text of the fourth field.
		FilePath:=FileDir "\" FileName
		
		if !glb_FSCurrent
		{
			loop, parse, FileName, :
				if (A_Index=1) {
					FilePath := A_Loopfield ":"
					break
				}
		}
			
		if InStr(FileExist(FilePath), "D") {
			glb_FSCurrent:=FilePath
			FileSelectSpecificAdjust(glb_FSCurrent)
			return
		}
		
		else if (FileExist(FilePath) and (glb_FSType="File" or glb_FSType="All")) {
			if glb_FSNoMulti
				glb_FSReturn:=FilePath
			else
				glb_FSReturn:=FileDir "`n" FileName
			
			if (glb_FSOwnerNum)
				Gui, %glb_FSOwnerNum%:-Disabled
			Gui,FileSelectSpecific:Destroy
			return
		}
	}
return

FSPrevious:
	Gui FileSelectSpecific: Default
	if !glb_FSCurrent
		return
	if (glb_FSCurrent=glb_FSFolder and glb_FSRestrict) {
		tooltip You can not navigate above the folder `n%glb_FSFolder%
		SetTimer, RemoveToolTip, -3000
		return
	}
	if !InStr(FileExist(FSGetParentDir(glb_FSCurrent)), "D")
		glb_FSCurrent:=""
	else
		glb_FSCurrent:=FSGetParentDir(glb_FSCurrent)
		
	FileSelectSpecificAdjust(glb_FSCurrent)
return

FSRefresh:
	Gui FileSelectSpecific: Default
	FileSelectSpecificAdjust(glb_FSCurrent)
return

FSSelect:
	Gui FileSelectSpecific: Default
	RowNumber = 0
	RowOkayed = 0 
	if !LV_GetNext(RowNumber) {
		msgbox Please select an element first
		return
	}
		
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; Resume the search at the row after that found by the previous iteration.
		; msgbox RowNumber %RowNumber%
		if not RowNumber  ; The above returned zero, so there are no more selected rows.
			break
		LV_GetText(FileName, RowNumber, 1) ; Get the text of the first field.
		LV_GetText(FileDir, RowNumber, 2)  ; Get the text of the second field.
		FilePath:=FileDir "\" FileName
		
		if !glb_FSCurrent
		{
			loop, parse, FileName, :
				if (A_Index=1) {
					FilePath := A_Loopfield ":"
					FileName := A_Loopfield ":"
					break
				}
		}

		if !FileExist(FilePath)
			continue
		
		if (InStr(FileExist(FilePath), "D") and glb_FSType="File")
			continue
			
		if (!InStr(FileExist(FilePath), "D") and glb_FSType="Folder")
			continue
			
		RowOkayed++
		
		glb_FSMultiReturn.= "`n" FileName
		
	}
	
	if (RowOkayed=0) {
		msgbox sorry wrong selection
		return
	}
	
	if (RowOkayed=1 and glb_FSNoMulti)
		glb_FSReturn:=FilePath
	else
		glb_FSReturn:=FileDir . glb_FSMultiReturn

	if (glb_FSOwnerNum)
		Gui, %glb_FSOwnerNum%:-Disabled
		
	Gui,FileSelectSpecific:Destroy
return

;Context-sensitive hotkey to detect Enter on FS navigation bar
#If (FSHwnd and WinActive("ahk_id " FSHwnd))
Enter::
GuiControlGet, OutputVar, FileSelectSpecific:FocusV
; msgbox OutputVar %OutputVar%
if (OutputVar="FSNavBarv")
	Gosub, FSNavBar
Return
#If

;Enter on FS navigation bar
FSNavBar:
Gui, FileSelectSpecific:Default
GuiControlGet, FSNavBarv
StringRight, LastChar, FSNavBarv, 1
	if LastChar = \
		StringTrimRight, FSNavBarv, FSNavBarv, 1  ; Remove the trailing backslash.
if !InStr(FileExist(FSNavBarv), "D")
	return

if (glb_FSRestrict and !Instr(FSNavBarv,glb_FSFolder)) {
	tooltip You can not navigate above the folder `n%glb_FSFolder%
	SetTimer, RemoveToolTip, -3000
	return
	}
GuiControl,,FSNavBarv,% FSNavBarv

glb_FSCurrent:=FSNavBarv
FileSelectSpecificAdjust()
return

RemoveToolTip:
tooltip
return

;*****************************
;FS GUI SPECIAL LABELS
;*****************************
FileSelectSpecificGuiContextMenu:  ; Launched in response to a right-click or press of the Apps key.
Gui FileSelectSpecific: Default
	if A_GuiControl <> FSListView  ; This check is optional. It displays the menu only for clicks inside the ListView.
		return
	Menu, FSContextMenu, Show
return

FileSelectSpecificGuiClose:
	if glb_FSOwnerNum
		try, Gui,%glb_FSOwnerNum%:-Disabled
	Gui,Destroy
return

FileSelectSpecificGuiSize:  ; Readjust the controls in response to the user's resizing of the window.
	if A_EventInfo = 1  ; The window has been minimized.  No action needed.
		return
	;Do not trigger during init
	if glb_FSInit
		return
		
	GuiControl, -Redraw, FSListView

	GuiControlGet, FSComplementv
	GuiControlGet, FSMultiIndicv
	
	; Otherwise, the window has been resized or maximized. Resize the controls.
	
	GuiControlGet, FSListViewPos, Pos, FSListView
	
	GuiControl, MoveDraw, FSPromptv, % " W" . (A_GuiWidth-20)
	GuiControl, MoveDraw, FSNavBarv, % " W" . (A_GuiWidth-20)
	
	FSListGap=
	
	if (FSComplementv) {
		GuiControl, MoveDraw, FSComplementv, % "y" FSListViewPosY + FSListViewPosH + 10 " W" . (A_GuiWidth-20)
		FSListGap+=10
	}
	
	GuiControlGet, FSComplementPos, Pos, FSComplementv
	
	if (FSMultiIndicv) {
		GuiControl, MoveDraw, FSMultiIndicv, % "y" A_GuiHeight-20 " W" . (A_GuiWidth-20)
		FSListGap+=5
	}
	
	GuiControlGet, FSMultiIndicPos, Pos, FSMultiIndicv
	
	;Trick : Round() so that empty vars = 0
	FSListGap:=Round(FSComplementPosH) + Round(FSMultiIndicPosH) + 15
	
	GuiControl, MoveDraw, FSListView, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - FSListViewPosY - Round(FSListGap))
	
	;Set timer to recreate listview if icon view
	if (Glb_FSIconView)
		SetTimer, FileSelectSpecificAdjust, -200
	
	GuiControl, +Redraw, FSListView  ; Re-enable redrawing (it was disabled above).
	
return
;*****************************


;*****************************
;SMALL FS FUNCTIONS
;*****************************
FSGetParentDir(Path) {
	return SubStr(Path, 1, InStr(SubStr(Path,1,-1), "\", 0, 0)-1)
}

FSOpenFolderInExplorer(P_Folder) {
global
	if !InStr(FileExist(P_Folder), "D")
		return 0
	Run % P_Folder
}