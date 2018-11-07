
/*
See demo for example usage


TODO:
- returncol could be -1 to return entire row
- searches are currently done using regexmatch with i) on every word (separates by %space%). Compare with simple instring.
- add window resizing
- reordering listview (by clicking on the headers) is reset when searching. A stupid solution would be to add the selected column contents as a prefix to every line in LVS_List, then sorting that, then removing the prefix.
- if bottomtext has more than one line, shows only first line. Possible solution: https://autohotkey.com/board/topic/27393-resize-text-control-to-fit-new-contents/

*/

LVS_Init(CallbackFuncName := "LVS_Callback"
       , ColNames := "Item", ReturnCol := 1, SearchCol := 1
	   , ShowColHeaders := True, MultiSel := True
	   , GuiWidth := 500, LVRows := 20) {
	/*
	CallbackFuncName:  Function that will be called when pressing enter or closing GUI, as
	                   %CallbackFuncName%(selectedlist, escaped?)
	ColNames:  Separated by "|", like "Index|Name|Size"
	ReturnCol:  Column whose value is to be passed to the callback func.
	SearchCol:  Column which contains the info to be searched. -1 to search all cols (will match if any col matches all search terms).
	rest is self-explanatory
	
	returns the gui's Hwnd, but that's also made global as LVS_GuiHwnd
	
	creates a shitload of global vars with the prefix LVS_
	*/
	
	global LVS_CallbackFuncName, LVS_ReturnCol, LVS_SearchCol, LVS_GuiHwnd, LVS_EditHwnd, LVS_EditText, LVS_LVHwnd, LVS_BottomText
	
	LVS_CallbackFuncName := CallbackFuncName
	LVS_ReturnCol := ReturnCol
	LVS_SearchCol := SearchCol
	
	ShowColHeaders := ShowColHeaders ? "" : "-Hdr"
	MultiSel := MultiSel ? "" : "-Multi"
	
	if LVS_GuiHwnd != ""  ; if gui was already created, destroy it
	{
		DetectHiddenWindows, on
		if WinExist("ahk_id " LVS_GuiHwnd)
			Gui, Destroy
	}
	
	Gui, +LastFound
	LVS_GuiHwnd := WinExist()

	Gui, Add, Edit, w%GuiWidth% HwndLVS_EditHwnd vLVS_EditText gLVS_Search
	Gui, Add, Listview, w%GuiWidth% HwndLVS_LVHwnd %ShowColHeaders% %MultiSel% -WantF2 R%LVRows% , %ColNames%
	Gui, Add, Text, w%GuiWidth% vLVS_BottomText,
	Gui, Add, Button, Hidden Default gLVS_Ok, Ok
	
	
	Hotkey, IfWinActive, ahk_id %LVS_GuiHwnd%
		keys := "Up Down PgUp PgDn"
		Loop, parse, keys, %A_Space%
		{
			Hotkey, %A_LoopField%, LVS_SendKeyToLV, on
			Hotkey, ^%A_LoopField%, LVS_SendKeyToLV, on
			Hotkey, +%A_LoopField%, LVS_SendKeyToLV, on
		}
		Hotkey, ^Space, LVS_SendKeyToLV
		Hotkey, +Space, LVS_SendKeyToLV
	Hotkey, IfWinActive
		
	return LVS_GuiHwnd
}

LVS_SendKeyToLV: ;{ 
	; A_ThisHotkey can be eg. +Up, but ControlSend requires +{Up}
	if A_ThisHotkey contains ^,+
		ControlSend,, % SubStr(A_ThisHotkey, 1, 1) "{" SubStr(A_ThisHotkey, 2) "}", ahk_id %LVS_LVHwnd%
	else
		ControlSend,, {%A_ThisHotkey%}, ahk_id %LVS_LVHwnd%
return
;}

LVS_Ok: ;{ 
	%LVS_CallbackFuncName%(LVS_Selected())
return
;}

LVS_Search: ;{ 
	Loop
		if LVS_Search()
			break
return
;}

GuiClose:
GuiEscape: ;{ 
	%LVS_CallbackFuncName%("", True)
return
;}

LVS_Selected() {
; returns selected items as a string with items separated by a `n. Can return empty string, gotta check for that in callback.
	
	global LVS_ReturnCol

	Loop, % LV_GetCount("Selected")
	{
		if not (i := LV_GetNext(i))
			break
		
		LV_GetText(CurrentItem, i, LVS_ReturnCol)
		SelectedList .= CurrentItem . "`n"
	}
	
	StringTrimRight, SelectedList, SelectedList, 1	; removes trailing newline
	
	return SelectedList
}

LVS_Search() {
; is called from inside a loop. If successfully populates the listview, returns True.
; if the search string changed while it was populating, returns False. Then it's called again.
	
	global LVS_List, LVS_EditHwnd, LVS_SearchCol, LVS_FieldsDelimiter, LVS_EditText
	
	LV_Delete()
	
	if (LVS_List = "")
		return True
	
	ControlGetText, Search,, ahk_id %LVS_EditHwnd%
	; Search is the text from edit control when function was called, vs LVS_EditText which is the current text in control.
	
	StringSplit, SearchTerms, Search, %A_Space%
	
	Loop, Parse, LVS_List, `n
	{
		; while populating list, keep checking if search str changed. If so, abort and start again.
		ControlGetText, LVS_EditText,, ahk_id %LVS_EditHwnd% ; TODO: compare with gui, submit
		IfNotEqual, LVS_EditText, %Search%
			return False
		
		CurrRowContents := A_LoopField
		if RegExMatch(CurrRowContents, "^\s*$")  ; is empty line
			continue
		
		if (Search = "")
		{
			LVS_Add(CurrRowContents)
			continue
		}
		
		StringSplit, ColContents, CurrRowContents, %LVS_FieldsDelimiter%
		if (ColContents0 < LVS_SearchCol)  ; maybe this specific row doensn't have all the fields?
			continue
		
		; ColContents%n% can contain some info from the previous row, but not a problem because they would be for n > SearchCol
		AddCurrentRow := True
		Loop, %SearchTerms0%
		{
			SearchTerm := SearchTerms%A_Index%
			
			if (LVS_SearchCol = -1)  ; should add if EVERY search term matches ANY column - all( any(=searchterm, columns) for searchterm in search )
			{
				AnyColMatches := False
				Loop, %ColContents0%
				{
					If RegExMatch(ColContents%A_Index%, "i)" SearchTerm)
					{
						AnyColMatches := True
						break
					}
				}
				if not AnyColMatches
				{
					AddCurrentRow := False
					break
				}
			}
			else
				if not RegExMatch(ColContents%LVS_SearchCol%, "i)" SearchTerm)
				{
					AddCurrentRow := False
					break
				}
		}
		
		If AddCurrentRow
			LVS_Add(CurrRowContents)  ; TODO: splits string again. Would be better with a variadic call
	}

	if (LV_GetCount("Selected") = 0)
		LV_Modify(1, "Select Focus")
	
	return True
}

LVS_SetBottomText(NewText) {
	global LVS_BottomText
	
	LVS_BottomText := NewText
	GuiControl,, LVS_BottomText, %LVS_BottomText%
}

LVS_SetList(NewList := "", FieldsDelimiter := ",", ClearSearch := True, UpdateLV := True) {
; FieldsDelimiter: are the rows in the form col1|col2|col3, or col1;col2;col3?
; creates global vars LVS_FieldsDelimiter and LVS_List.
; LVS_list is not passed by reference (would make sense especially for large datasets) because can change original data without altering listview contents.
	
	global LVS_FieldsDelimiter, LVS_List
	
	LVS_FieldsDelimiter := FieldsDelimiter
	LVS_List := NewList
	
	if ClearSearch
		LVS_SetSearch("", False)
	
	if UpdateLV
		LVS_Search()
}

LVS_SetSearch(NewSearch, UpdateLV) {
; sets search with the possibility of skip updating the LV.
; returns current search.

	global LVS_EditHwnd, LVS_EditText
	
	ControlGetText, OldSearch,, ahk_id %LVS_EditHwnd%
	
	if not UpdateLV
	{
		GuiControl, -g, LVS_EditText	; if this is not done, next line triggers search func.
		GuiControl,, LVS_EditText, %NewSearch%
		GuiControl, +gLVS_Search, LVS_EditText
	}
	else
		GuiControl,, LVS_EditText, %NewSearch%  ; already enters the searching loop
	
	return OldSearch
}

LVS_Show(GuiOpts := "Autosize") {
	Gui, Show, %GuiOpts%
}

LVS_Hide() {
	Gui, Hide
}

LVS_UpdateColOptions(ColOptions := "") {
; if you wanna adjust to the lv contents, you should put everything there before calling this.
; if no options are passed, AutoHdr all.

	if (ColOptions = "")
	{
		Loop, % LV_GetCount("Column")
			LV_ModifyCol(A_Index, "AutoHdr")
	}
	else
	{
		Loop, Parse, ColOptions, |
			LV_ModifyCol(A_Index, A_LoopField)
	}
}

LVS_Add(RowContents) {
	global LVS_FieldsDelimiter
	
	StringSplit, ColContents, RowContents, %LVS_FieldsDelimiter%
	LV_Add("", ColContents1, ColContents2, ColContents3, ColContents4, ColContents5, ColContents6, ColContents7, ColContents8, ColContents9)
	; TODO: this sucks. In newer versions of ahk could use a variadic construct and an array.
}

LVS_Callback(SelectedList, Escaped:=False) {
	if (Escaped)
		msgbox % "escaped from gui"
	else
		msgbox % SelectedList
	
	exitapp
}