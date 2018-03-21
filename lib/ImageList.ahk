; used in lintalist.ahk and objectbundles.ahk

If (ShowIcons = 1)
	{
	 IL_Destroy(ImageListID1)
	 ; Create an ImageList so that the ListView can display some icons:
	 ImageListID1 := IL_Create(8, 10)
	 ; Attach the ImageLists to the ListView so that it can later display the icons:
	 LV_SetImageList(ImageListID1)
	}

IL_Add(ImageListID1, A_ScriptDir . "\Icons\" . Icon1 ".ico") ; assign texticon
IL_Add(ImageListID1, A_ScriptDir . "\Icons\" . Icon2 ".ico") ; assign scripticon
IL_Add(ImageListID1, A_ScriptDir . "\Icons\" . Icon1 "_HTML.ICO")  ; html/md icon
IL_Add(ImageListID1, A_ScriptDir . "\Icons\" . Icon1 "_RTF.ICO")   ; rtf icon
IL_Add(ImageListID1, A_ScriptDir . "\Icons\" . Icon1 "_Image.ICO") ; image icon
IL_Add(ImageListID1, A_ScriptDir . "\Icons\" . Icon2 "_HTML.ICO")  ; html/md icon
IL_Add(ImageListID1, A_ScriptDir . "\Icons\" . Icon2 "_RTF.ICO")   ; rtf icon
IL_Add(ImageListID1, A_ScriptDir . "\Icons\" . Icon2 "_Image.ICO") ; image icon
