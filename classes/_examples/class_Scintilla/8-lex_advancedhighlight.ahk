#include ..\SCI.ahk
#singleinstance force

/*
    ---------------------
    This is an example of how to highlight without selecting a pre-existing lexer.
    In this example we will manually tell scintilla which positions to color.

    In this case we use SCLEX_CONTAINER to tell scintilla that we will manually do the coloring.
    I set some random text in the control, set some styles and use the Search Label together with a simple search function
    To tell scintilla what to color.
*/

; Load some random text
Splitpath, a_ahkpath,,ahkDir
;FileRead, text, %ahkDir%/license.txt
FileRead, text, D:\Eigene Dateien\Eigene Dokumente\AutoIt Scripte\Addendum für AlbisOnWindows\logs'n'data\AlbisPatientenliste.txt

Gui -DPIScale
Gui +LastFound
sci := new scintilla(WinExist(), x, y, 1400, 1400)

; Set some options
sci.SetWrapMode(true), sci.SetLexer(SCLEX_CONTAINER), sci.StyleClearAll()
sci.SetText(unused, text), sci.SetReadOnly(true), sci.GrabFocus()

; Change a style

sci.StyleSetFore(SCE_AHKL_USERDEFINED1, 0xEE0000), sci.StyleSetBold(SCE_AHKL_USERDEFINED1, true)

Gui, Add, Edit, x10 y1410 w1500 -WantReturn vGuiMessage -0x100 gSearch
Gui, Add, Button, x+10 gSearchAgain, Search Again
Gui, +resize +minsize
Gui, show, AutoSize
return

Search:
    /*
        Manually highlighting goes like this:
        You first have to tell scintilla where you are going to start highlighting and which bits you will highlight.
        That is done with StartStyling. Then you use SetStyling with the length of characters you whish to highlight and which style you want to use.

        All other code is just for the sake of demonstration and not really needed.
        The most important lines are 50-55.
    */
    Gui, Submit, Nohide

    if !GuiMessage  ; If search box is empty clear all positions to start from the beginning again.
        pos := newpos := 0

    ; Clear old matches
    sci.StartStyling(0, 0x1f)
    sci.SetStyling(sci.GetLength()+1, STYLE_DEFAULT)

    ; Find and style new match
    sci.StartStyling(pos:=Search(sci, newpos ? newpos : 0, sci.GetLength()+1, GuiMessage), 0x1f) ; 0x1f sets text bits styles, no indicators.
    sci.SetStyling(strlen(GuiMessage), SCE_AHKL_USERDEFINED1), sci.GoToPos(pos) ; Change color of length of typed text to style #1, move caret to position.

    sci.ScrollCaret() ; scroll in to view.
return

F3::
SearchAgain:
    ; sets position forward to allow searching for next match
    newpos := pos + strlen(GuiMessage)
    GoSub, Search
return

GuiClose:
    ExitApp

/*
    This function is not really necesary but I made it for convenience...
    It returns the position of first found string match.
*/

Search(sci, tStart, tEnd, str, flags = ""){

    sci.SetSearchFlags(flags), sci.SetTargetStart(tStart), sci.SetTargetEnd(tEnd)
    return pos:=sci.SearchInTarget(strlen(str), str)
}