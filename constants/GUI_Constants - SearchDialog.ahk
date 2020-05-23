; ======================================================================================================================
; AHK 1.1+
; ======================================================================================================================
#NoEnv
SetBatchLines, -1
; ======================================================================================================================
EM_SCROLLCARET := 0x00B7
EM_SETSEL      := 0x00B1
ES_NOHIDESEL   := 256
PH := 600
; ======================================================================================================================
Gui, +Disabled +OwnDialogs
Gui, Margin, 20, 20
Gui, Font, s9 , Courier New
Gui, Add, Text, Section, Scripts:
Gui, Add, Listbox, xm y+5 w200 h600 r40 vLBScripts gSubLBScripts
GuiControlGet, P, Pos, LBScripts
Gui, Add, Text, ys w600 vTXCaption, Constants:
Gui, Add, Edit, y+5 w600 h600 vEDConstants hwndHEDConstants ReadOnly HScroll +%ES_NOHIDESEL%
Gui, Add, Text, y+5 r1, Search:
Gui, Add, Edit, xp y+5 w600 vEDSearch gSubEDSearch
Gui, Add, Button, xs w200 hp gSubGlobalSearch Section, Global Search >>>
Gui, Add, Edit, ys w600 vEDGlobalSearch,
Gui, Add, StatusBar, , % "   Select folder"
Gui, Show, , GUI_Constants
; ======================================================================================================================
; Select Const_xxx.ahk folder
FileSelectFolder, ConstFolder, *%A_ScriptDir%, 2, Select the folder containing the Const_ scripts, please:
If (ErrorLevel) {
   MsgBox, 16, GUI_Constants, You didn't select a folder,`nthe program will exit!
   ExitApp
}
Files := []
Loop, %ConstFolder%\Const_*.ahk
   Files.Insert(A_LoopFileLongPath)
If !Files.MaxIndex() {
   MsgBox, 16, GUI_Constants, The selected folder %ConstFolder%`ndoes not contain Const_ files! The program will exit!
   ExitApp
}
SB_SetText("  ... loading scripts ...")
GuiControl, , LBScripts, % LoadScripts(Files, Constants)
GuiControl, Choose, LBScripts, |1
Gui, -Disabled
Return
; ======================================================================================================================
GuiClose:
GuiEscape:
ExitApp
; ======================================================================================================================
SubLBScripts:
   GuiControlGet, LBScripts
   GuiControl, , EDConstants, % Constants[LBScripts]
   SB_SetText("   " . LBScripts . ".ahk")
   GuiControl, , TXCaption, Constants:
   GuiControl, , EDSearch
   GuiControl, Enable, EDSearch
   GuiControl, Focus, EDSearch
Return
; ======================================================================================================================
SubEDSearch:
   GuiControlGet, EDSearch
   EDSearch := Trim(EDSearch)
   If (EDSearch = "")
      Return
   GuiControlGet, LBScripts
   If (P := RegExMatch(Constants[LBScripts], "im)^Global\s+\K\Q" . EDSearch . "\E")) {
      P--
      SendMessage, EM_SETSEL, P, P + StrLen(EDSearch), , ahk_id %HEDConstants%
      SendMessage, EM_SCROLLCARET, 0, 0, , ahk_id %HEDConstants%
   } Else {
      SendMessage, EM_SETSEL, -1, 0, , ahk_id %HEDConstants%
   }
Return
; ======================================================================================================================
SubGlobalSearch:
   GuiControlGet, EDGlobalSearch
   EDGlobalSearch := Trim(EDGlobalSearch)
   If (EDGlobalSearch = "")
      Return
   SB_SetText("   Global search for '" . EDGlobalSearch . "' ...")
   Result := ""
   TotalMatches := 0
   For ScriptName, ScriptContent In Constants {
      If RegExMatch(ScriptContent, "im)^Global\s+\K\Q" . EDGlobalSearch . "\E") {
         Result := (Result <> "" ? "`r`n" : "") . ScriptName
         TotalMatches++
      }
   }
   GuiControl, , TXCaption, Result:
   GuiControl, , EDConstants, %Result%
   GuiControl, , EDSearch
   GuiControl, Disable, EDSearch
   SB_SetText("   " . TotalMatches . " match(es) found for '" . EDGlobalSearch . "'!")
Return
; ======================================================================================================================
Loadscripts(ByRef Files, ByRef Constants) {
   Constants := {}
   Scripts := ""
   For Each, FilePath In Files {
      FileRead, FileContent, %FilePath%
      If (ErrorLevel)
         Continue
      If !InStr(FileContent, "`r`n")
         StringReplace, FileContent, FileContent, `n, `r`n, All
      SplitPath, FilePath, , , , NameNoExt
      Constants[NameNoExt] := FileContent
      Scripts .= "|" . NameNoExt 
   }
   Return Scripts
}
; ======================================================================================================================