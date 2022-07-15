#Include SCI.ahk
#singleinstance force

Gui +LastFound
Gui +hwndhMainWnd
;Sci_GetIdealSize(SciX, SciY, SciW, SciH)
SciLexer := A_ScriptDir . (A_PtrSize == 8 ? "\SciLexer64.dll" : "\SciLexer32.dll")
;Sci := New Scintilla
;Sci.Add(hMainWnd, 8, 340, PGenisligiDef - 80, PYuksekligiDef - 390, SciLexer, 0x50000000, 0x200)

Keys := 
(  
";" , ";!"
) ;Characters to be emphasized are ";" and ";!" Post.

If (!LoadSciLexer(SciLexer)) {
	MsgBox 0x10, %g_AppName% - Error
    , % "Failed to load library """ . SciLexer . """.`n`n" ; . GetErrorMessage(A_LastError) . "`nThe program will exit."
	ExitApp
}

Sci := New Scintilla(hMainWnd, 8, 8, 600,390, 0x50000000, 0x200)
Sci.SetCodePage(65001) ; UTF-8
Gui, +resize +minsize
Gui, show, center w960 h690 , autosize doesnt recognize the scintilla control, width & height + 10px border
Text := 
(
"positive option ;!negative option2; positive option2; positive option3;!negative opt"
)
Sci.SetText("",Text, 1) 
return


GuiSize:
WinMove, % "ahk_id " sci.hwnd,, 5, 5, % a_guiwidth - 10, % a_guiheight - 10
return

GuiClose:
ExitApp

Pause::
Reload
return

+Pause::
Run run.ahk
ExitApp
