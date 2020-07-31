#include ..\SCI.ahk
#singleinstance force

;---------------------
; This is an example of how to select a Lexer located in a scintilla dll and make some basic highlighting.
; In this example we will select the AutoHotkey Lexer. Keywords are to be added manually so we will add some random words.
;
; The idea is to first select which lexer to use (specially if scilexer.dll has more than one) with SetLexer(lexNum)
; Then you can add some keywords to the keyword lists which will be colored as soon as they appear.
; Finally you can change the Font properties with StyleSetXXXX functions in this case I changed the color of the styles.

Gui +LastFound
sci := new scintilla(WinExist())

sci.SetWrapMode(true), sci.SetLexer(SCLEX_AHKL), sci.StyleClearAll()
sci.SetKeywords(AHKL_LIST_USERDEFINED1, "true msgbox another testing") ; this is the first User Defined list in this lexer, there are two UD lists.

sci.StyleSetBold(SCE_AHKL_USERDEFINED1, true)
sci.StyleSetFore(SCE_AHKL_USERDEFINED1, 0x0000FF) ; This is the style linked to the list above.

sci.SetText(unused, "Start Typing here and add some of the words from line 16`nFeel free to add more words to the list.")
Gui, show, w600 h400
return

GuiClose:
    ExitApp