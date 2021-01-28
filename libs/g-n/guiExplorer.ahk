/*
Func: guiExplorer
    Form to explore and manipulate folders and files

Parameters:
    exploreDir		- Path to a folder

Returns:
	-
	
Examples:
    > guiExplorer("c:\Windows\")
    = Explorer gui opens and the script waits until closed
*/

guiExplorer(exploreDir) {
	global
	
	If !( InStr( FileExist(exploreDir), "D") )
	{
		msgbox guiExplorer: Specified folder does not exist`n`nexploreDir = %exploreDir%
		return
	}
	
	gx_rootDir := exploreDir 
	Gosub gx_setRootFolder
	
	gui gx: Margin, 5, 5
	gui gx: Default
	gui gx: +LastFound +AlwaysOnTop -MinimizeBox +Labelgx_
	gui gx: +Hwndgx_Hwnd
	
	gx_TvW := 275
	gx_TvH := 300
	
	gx_LvW := 375
	gx_LvH := 300
	
	gx_IL := IL_Create(5)
	Loop 5 
		IL_Add(gx_IL, "shell32.dll", A_Index)
	
	gui gx: Add, TreeView, % "section w" gx_TvW " h" gx_TvH " AltSubmit vgx_Tv ggx_Tv ImageList" gx_IL
	gui gx: Add, ListView, % "section w" gx_LvW " h" gx_LvH " x" gx_TvW + 10 " ys -Multi AltSubmit vgx_Lv ggx_Lv", File|Ext

	gui gx: Add, StatusBar
	SB_SetParts(283)
	
	gui gx: Show, AutoSize x0 y0, % gx_rootDir

	; xLvMenu
	Menu, xLvMenu, Add
	Menu, xLvMenu, DeleteAll

	Menu, xLvMenu, Add, Add, gx_LvAdd
	Menu, xLvMenu, Add, Rename, gx_LvRename
	Menu, xLvMenu, Add, Delete, gx_LvDelete

	Gosub gx_TvRefresh
	
	WinWaitClose, % "ahk_id " gx_Hwnd
	return
	
	gx_setRootFolder:
		gx_rootDir := RTrim(gx_rootDir, "\")
		SplitPath, gx_rootDir, gx_rootDirName
		
		IfWinExist, % "ahk_id " gx_Hwnd
		{
			Gosub gx_TvRefresh
			Gosub gx_LvRefresh
			gui gx: Show, , % gx_rootDir
		}
	return

	gx_Close:
		gui gx: Destroy
	return

	gx_Tv:
		if (A_GuiEvent = "Normal")
		{
			ParentText := ""
			
			TV_GetText(gx_sDir, A_EventInfo)
			
			gx_sFolder := gx_sDir
			
			ParentID := A_EventInfo
			Loop
			{
				ParentID := TV_GetParent(ParentID)
				if not ParentID
					break
				TV_GetText(ParentText, ParentID)
				gx_sDir = %ParentText%\%gx_sDir%
			}
			e_sDirFull := gx_sDir
			
			StringReplace, gx_sDir, gx_sDir, % ParentText "\"
			
			If (gx_sDir = gx_rootDirName) and (ParentText = "") ; selected folder is rootfolder
				gx_fSDir := gx_rootDir
			else
				gx_fSDir := gx_rootDir "\" gx_sDir
			
			SB_SetText(e_sDirFull)
			
			Gosub gx_LvRefresh
		}

		if (A_GuiEvent = "RightClick")
		{
			; xTvMenu
			Menu, xTvMenu, Add
			Menu, xTvMenu, DeleteAll

			Menu, xTvMenu, Add, New, gx_TvNew
			Menu, xTvMenu, Add, Add, gx_TvAdd
			Menu, xTvMenu, Add, Rename, gx_TvRename
			Menu, xTvMenu, Add
			Menu, xTvMenu, Add, Delete, gx_TvDelete
			Menu, xTvMenu, Add
			Menu, xTvMenu, Add, Open, gx_TvOpen
			Menu, xTvMenu, Show
			return
		}
	return

	gx_TvRefresh:
		gui gx: Default
		GuiControl, -Redraw, gx_Tv
		loadTree(gx_rootDir)
		GuiControl, +Redraw, gx_Tv
	return

	gx_TvNew:
		gui gx: +OwnDialogs
		
		InputBox, gx_nDirName, Name,,, 180, 100
		If (gx_nDirName = "")
			return
		
		FileCreateDir, % gx_fSDir "\" gx_nDirName
		
		Gosub gx_TvRefresh
	return

	gx_TvAdd:
		gui gx: +OwnDialogs
		
		FileSelectFolder, gx_nDir
		If (gx_nDir = "")
			return

		SplitPath, gx_nDir, gx_nDirName
		
		; FileCopyDir, % gx_nDir, % gx_fSDir "\" gx_nDirName
		cmd_FileCopyDir( gx_nDir, gx_fSDir "\" gx_nDirName )
		
		Gosub gx_TvRefresh
	return

	gx_TvRename:
		gui gx: +OwnDialogs
		
		InputBox, gx_nDirName, Name,,, 180, 100
		If (gx_nDirName = "")
			return
		SplitPath, gx_fSDir, , gx_fSDirDir
		FileMoveDir, % gx_fSDir, % gx_fSDirDir "\" gx_nDirName
		If (gx_sDir = gx_rootDirName) and (ParentText = "") ; selected folder is rootfolder
		{
			gx_rootDir := gx_fSDirDir "\" gx_nDirName ; set gx_rootDir var to new rootdir
			Gosub gx_setRootFolder ; calculate new gx_rootDir related vars
		}
		
		Gosub gx_tvRefresh
	return

	gx_TvDelete:
		gui gx: +OwnDialogs
		
		If (gx_sDir = gx_rootDirName) and (ParentText = "") ; selected folder is rootfolder
		{
			msgbox Don't delete the root folder ya mong
			return
		}
		
		Msgbox, 68, , Delete selected folder and subfolders?
		IfMsgBox No
			return

		; FileRemoveDir, % gx_fSDir, 1
		cmd_FileRemoveDir(gx_fSDir)
			
		Gosub gx_TvRefresh
	return

	gx_TvOpen:
		run, % gx_fSDir
	return

	gx_Lv:
		if (A_GuiEvent = "Normal") or (A_GuiEvent = "RightClick")
		{
			LV_GetText(gx_sFile, A_EventInfo)  ; Get the text from the row's first field and store it in the var xFile.
			LV_GetText(gx_sFileExt, A_EventInfo, 2)  ; Get the text from the row's first field and store it in the var xFileExt.
			
			If (gx_sFile = "File") and (gx_sFileExt = gx_sFileExt)
			{
				gx_sFile = ""
				gx_sFileExt = ""
				
				SB_SetText("", 2)
			}
			else
				SB_SetText(gx_sFile "." gx_sFileExt, 2)
		}
		
		if (A_GuiEvent = "RightClick")
		{
			Menu, xLvMenu, Show
		}

		if (A_GuiEvent = "DoubleClick")
		{
			Gosub gx_LvOpen
		}
	return

	gx_LvRefresh:
		gui gx: Default

		LV_Delete()
		
		IL_Destroy(gx_LvIL)
		gx_LvIL := IL_Create(10)
		LV_SetImageList(gx_LvIL)
		
		GuiControl, -Redraw, gx_Lv
		Loop, % gx_fSDir "\*.*"
		{
			GetIcon(A_LoopFileFullPath, gx_LvIL)
			
			SplitPath, A_LoopFileName, , , gx_TempNameExt, gx_TempNameNoExt
			
			LV_Add("Icon" . IconNumber, gx_TempNameNoExt, gx_TempNameExt)
		}
		GuiControl, +Redraw, gx_Lv
		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
	return

	gx_LvAdd:
		gui gx: +OwnDialogs

		If (gx_sDir = "")
		{
			msgbox No folder selected
			return
		}
		
		FileSelectFile, gx_nFiles, M3, , Choose Files
		if (gx_nFiles = "")
			return
		
		Loop, parse, gx_nFiles, `n
		if a_index = 1
			gx_nFilesDir := A_LoopField
		else
		{
			gx_nFileSource := gx_nFilesDir "\" A_LoopField
			; gx_nFileTarget := gx_fSDir "\" A_LoopField
			
			If FileExist(gx_nFileTarget)
			{ ; file with this name already exists in target folder, prompt overwrite
				Msgbox, 68, , File: "%A_LoopField%" already exists!`n`nOverwrite?
				IfMsgBox Yes
					cmd_fileCopy(gx_nFileSource, gx_fSDir)
					; FileCopy, % gx_nFileSource, % gx_nFileTarget, 1
			}
			else ; file does not exist, copy
				cmd_fileCopy(gx_nFileSource, gx_fSDir)
				; FileCopy, % gx_nFileSource, % gx_nFileTarget, 1
		}
		
		Gosub gx_LvRefresh
	return

	gx_LvDelete:
		gui gx: +OwnDialogs
		
		Msgbox, 68, , Delete selected file?
		IfMsgBox No
			return
		
		; FileDelete, % gx_fSDir "\" gx_sFile "." gx_sFileExt
		cmd_fileDelete(gx_fSDir "\" gx_sFile "." gx_sFileExt)
		
		Gosub gx_LvRefresh
	return

	gx_LvRename:
		gui gx: +OwnDialogs
		
		InputBox, gx_nFileName, Name,,, 180, 100
		If (gx_nFileName = "")
			return

		FileMove, % gx_fSDir "\" gx_sFile "." gx_sFileExt, % gx_fSDir "\" gx_nFileName "." gx_sFileExt
		Gosub gx_LvRefresh
	return

	gx_LvOpen:
		run % gx_fSDir "\" gx_sFile "." gx_sFileExt
	return
}

; ------------------------------------------------------------

loadTree(TreeRoot) {
	global
	TV_Delete()
	TreeRoot := RTrim(TreeRoot, "\")                         ; Remove trailing backslashes, if any.
	SplitPath, TreeRoot, TreeRootName, TreeRootDir           ; Split TreeRoot into TreeRootName and TreeRootDir.
	If (TreeRootName)                                        ; If TreeRootName is not empty
	   TreeRootID := TV_Add(TreeRootName, 0, "Expand Icon4") ;    add it to the TreeView
	Else                                                     ; Else
	   TreeRootID := 0                                       ;    set TreeRootId to zero.
	AddSubFoldersToTree(TreeRoot, TreeRootID)                ; Call AddSubFolders() passing TreeRoot and TreeRootID
	TreeRoot := TreeRootDir                                  ; Set TreeRoot to TreeRootDir.
}

AddSubFoldersToTree(Folder, ParentItemID = 0)
; This function adds to the TreeView all subfolders in the specified folder.
{
    ; It also calls itself recursively to gather nested folders to any depth.
    Loop %Folder%\*.*, 2 ; Retrieve all of Folder's sub-folders.
        AddSubFoldersToTree(A_LoopFileFullPath, TV_Add(A_LoopFileName, ParentItemID, "Expand Icon4 Sort"))   ; sort so that underscores and numbers are sorted to top of tree
}

getIcon(FilePath, ByRef ImageList) {
	global IconNumber
	static sfi_size, sfi
	
	If (sfi_size = "")
	{
		sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
		VarSetCapacity(sfi, sfi_size)
	}

	; Get the high-quality small-icon associated with this file extension:
	if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str", FilePath
		, "uint", 0, "ptr", &sfi, "uint", sfi_size, "uint", 0x101)  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
		IconNumber = 9999999  ; Set it out of bounds to display a blank icon.
	else ; Icon successfully loaded.
	{
		; Extract the hIcon member from the structure:
		hIcon := NumGet(sfi, 0)
		; Add the HICON directly to the small-icon and large-icon lists.
		; Below uses +1 to convert the returned index from zero-based to one-based:
		IconNumber := DllCall("ImageList_ReplaceIcon", "ptr", ImageList, "int", -1, "ptr", hIcon) + 1
		; Now that it's been copied into the ImageLists, the original should be destroyed:
		DllCall("DestroyIcon", "ptr", hIcon)
		; Cache the icon to save memory and improve loading performance:
		IconArray%ExtID% := IconNumber
	}
}