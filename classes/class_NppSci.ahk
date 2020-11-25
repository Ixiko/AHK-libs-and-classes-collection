; Link:   	https://raw.githubusercontent.com/Vismund-Cygnus/AutoHotkey/37c4da39274ec14b53e9c0712cd75f09879ac368/Notepad%2B%2B%20Stuff/NppSci.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

class NppSci    
{
    ; - Internal methods -------------------------------------------------------
    __New() {
        static init := new NppSci

        if (init)
            return init

        className := this.__Class
        %className% := this

        this.WM_USER         := 1024
        this.NPPMSG          := this.WM_USER + 1000
        this.RUNCOMMAND_USER := this.WM_USER + 3000

        this.LangType := ["TEXT", "PHP", "C", "CPP", "CS", "OBJC", "JAVA", "RC", "HTML", "XML", "MAKEFILE", "PASCAL", "BATCH", "INI", "ASCII", "USER", "ASP", "SQL", "VB", "JS", "CSS", "PERL", "PYTHON", "LUA", "TEX", "FORTRAN", "BASH", "FLASH", "NSIS", "TCL", "LISP", "SCHEME", "ASM", "DIFF", "PROPS", "PS", "RUBY", "SMALLTALK", "VHDL", "KIX", "AU3", "CAML", "ADA", "VERILOG", "MATLAB", "HASKELL", "INNO", "SEARCHRESULT", "CMAKE", "YAML", "COBOL", "GUI4CLI", "D", "POWERSHELL", "R", "JSP", "COFFEESCRIPT", "JSON", "JAVASCRIPT", "FORTRAN_77", "BAANC", "SREC", "IHEX", "TEHEX", "SWIFT", "ASN1", "AVS", "BLITZBASIC", "PUREBASIC", "FREEBASIC", "CSOUND", "ERLANG", "ESCRIPT", "FORTH", "LATEX", "MMIXAL", "NIMROD", "NNCRONTAB", "OSCRIPT", "REBOL", "REGISTRY", "RUST", "SPICE", "TXT2TAGS", "VISUALPROLOG", "EXTERNAL"]
        this.winVer := ["UNKNOWN", "WIN32S", "95", "98", "ME", "NT", "W2K", "XP", "S2003", "XPX64", "VISTA", "WIN7", "WIN8", "WIN81", "WIN10"]
        this.Platform := ["UNKNOWN", "X86", "X64", "IA64"]
    }

    __Delete() {
        if (this.hProc) {
            return this.CloseProcess()
        }
    }

    OpenBuffer(bytes) {
        return DllCall("VirtualAllocEx", "Ptr", this.hProc, "Ptr", 0, "Ptr", bytes, "UInt", 0x1000
                                       ,"UInt", 0x4, "Ptr")
    }

    CloseBuffer(address) {
        return DllCall("VirtualFreeEx", "Ptr", this.hProc, "Ptr", address, "Ptr", 0, "UInt", 0x8000)
    }

    ReadBuffer(address, bytes, encoding := "CP1200") {
        VarSetCapacity(localBuffer, bytes)
        DllCall("ReadProcessMemory", "Ptr", this.hProc,   "Ptr", address, "Ptr", &localBuffer
                                   , "Ptr", bytes,        "Ptr", 0)
        return StrGet(&localbuffer, bytes, encoding)
    }

    WriteBuffer(string, address := 0, encoding := "CP1200") {
        bufferBytes := StrPut(string, encoding)
                     * (encoding = "CP1200" || encoding = "UTF-16" ? 2 : 1)
        if (address = 0)
            return bufferBytes
        VarSetCapacity(buffer, bufferBytes)
        StrPut(string, &buffer, bufferBytes, encoding)
        return DllCall("WriteProcessMemory",  "Ptr", this.hProc,   "Ptr", address, "Ptr", &buffer
                                           , "UInt", bufferBytes, "UInt", 0)
    }

    OpenProcess() {
        if !(this.hProc)
            this.hProc := DllCall("OpenProcess", "UInt", 0x38, "Int", false
                                               , "UInt", this.GetProcessID(), "Ptr")
    }

    GetProcessID() {
        VarSetCapacity(PID, 4)
        DllCall("GetWindowThreadProcessId", "Ptr", this.GetNppHwnd(), "Ptr", &PID)
        return NumGet(&PID, "UInt")
    }

    CloseProcess() {
        DllCall("CloseHandle", "Ptr", this.hProc)
        return this.hProc := ""
    }

    GetNppHwnd() {
        return WinExist("ahk_class Notepad++ ahk_exe Notepad++.exe")
    }

    GetSciHwnd() {
        Loop, % this.GetCurrentView() + 1
            hSci := DllCall("FindWindowEx", "Ptr", this.GetNppHwnd(), "Ptr", hSci
                                          , "Str", "Scintilla",       "Ptr", 0, "Ptr")
        return hSci
    }

    SendMsg(hwnd, msg, wP := 0, lP := 0) {
        return DllCall("SendMessage", "Ptr", hwnd, "UInt", msg, "Ptr", wP, "Ptr", lP, "Ptr")
    }

    PostMsg(hwnd, msg, wP := 0, lP := 0) {
        return DllCall("PostMessage", "Ptr", hwnd, "UInt", msg, "Ptr", wP, "Ptr", lP)
     }
;-- Notepad++ methods ----------------------------------------------------------
    ; returns '0' for 'MAIN_VIEW' or '1' for 'SUB_VIEW'
    GetCurrentScintilla() {
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(4)
        this.SendMsg(this.GetNppHwnd(), this.NPPMSG + 4, 4, bufferAddress)
        stringresult := this.ReadBuffer(bufferAddress, 4)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return NumGet(&stringresult, "UInt")
    }

    GetCurrentLangType() {
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(4)
        this.SendMsg(this.GetNppHwnd(), this.NPPMSG + 5, 4, bufferAddress)
        stringresult := this.ReadBuffer(bufferAddress, 4)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return this.LangType[NumGet(&stringresult, "UInt") + 1]
    }

    ; pass '0' for PRIMARY_VIEW or '1' for "SUB_VIEW"
    GetNbOpenFiles(view := -1) {
        return this.SendMsg(this.GetNppHwnd(), this.NPPMSG + 7, ,view)
    }

    ; pass '0' for PRIMARY_VIEW or '1' for "SUB_VIEW"
    GetOpenFileNames(whichView := "") {
        fileNames := []
        if (whichView != 1) {
            nbOpenFiles := this.GetNbOpenFiles(1)
            Loop, %nbOpenFiles% {
                ID := this.GetBufferIdFromPos(A_Index - 1, 0)
                fileNames.Push(this.GetFullPathFromBufferId(ID))
            }
        }
        if (whichView != 0) {
            nbOpenFiles := this.GetNbOpenFiles(2)
            Loop, %nbOpenFiles% {
                ID := this.GetBufferIdFromPos(A_Index - 1, 1)
                fileNames.Push(this.GetFullPathFromBufferId(ID))
            }
        }
        return fileNames
    }
    
    MenuCommand(cmdID) {
        return this.PostMsg(this.GetNppHwnd(), this.NPPMSG + 48, 0, cmdID)
    }
    HideTabBar(hideOrNot) {
        return this.PostMsg(this.GetNppHwnd(), this.NPPMSG + 51, 0, hideOrNot)
    }
    IsTabBarHidden() {
        return this.SendMsg(this.GetNppHwnd(), this.NPPMSG + 52)
    }
    GetFullPathFromBufferID(bufferID) {
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(520)
        this.SendMsg(this.GetNppHwnd(), this.NPPMSG + 58, bufferID, bufferAddress)
        stringresult := this.ReadBuffer(bufferAddress, 520)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }
    ; index and view are 0-based
    GetBufferIDFromPos(index := 0, view := 0) {
        return this.SendMsg(this.GetNppHwnd(), this.NPPMSG + 59, index, view)
    }
    DoOpen(path) {
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(520)
        this.WriteBuffer(path, bufferAddress)
        this.SendMsg(this.GetNppHwnd(), this.NPPMSG + 77, , bufferAddress)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
    }
    GetCurrentView() {
        return this.SendMsg(this.GetNppHwnd(), this.NPPMSG + 88)
    }
    GetFullCurrentPath() {
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(520)
        this.SendMsg(this.GetNppHwnd(), this.RUNCOMMAND_USER + 1, 520, bufferAddress)
        stringresult := this.ReadBuffer(bufferAddress, 520)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }

    GetCurrentDirectory() {
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(520)
        this.SendMsg(this.GetNppHwnd(), this.RUNCOMMAND_USER + 2, 520, bufferAddress)
        stringresult := this.ReadBuffer(bufferAddress, 520)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }

    GetFileName() {
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(520)
        this.SendMsg(this.GetNppHwnd(), this.RUNCOMMAND_USER + 3, 520, bufferAddress)
        stringresult := this.ReadBuffer(bufferAddress, 520)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }

    GetNamePart() {
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(520)
        this.SendMsg(this.GetNppHwnd(), this.RUNCOMMAND_USER + 4, 520, bufferAddress)
        stringresult := this.ReadBuffer(bufferAddress, 520)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }

    GetExtPart() {
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(520)
        this.SendMsg(this.GetNppHwnd(), this.RUNCOMMAND_USER + 5, 520, bufferAddress)
        stringresult := this.ReadBuffer(bufferAddress, 520)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }

    GetCurrentWord() {
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(520)
        this.SendMsg(this.GetNppHwnd(), this.RUNCOMMAND_USER + 6, 520, bufferAddress)
        stringresult := this.ReadBuffer(bufferAddress, 520)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }

    GetNppDirectory() {
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(520)
        this.SendMsg(this.GetNppHwnd(), this.RUNCOMMAND_USER + 7, 520, bufferAddress)
        stringresult := this.ReadBuffer(bufferAddress, 520)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }

    GetFileNameatCursor() {
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(520)
        this.SendMsg(this.GetNppHwnd(), this.RUNCOMMAND_USER + 11, 520, bufferAddress)
        stringresult := this.ReadBuffer(bufferAddress, 520)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }

    GetCurrentLine() {
        return this.SendMsg(this.GetNppHwnd(), this.RUNCOMMAND_USER + 8)
    }

    GetCurrentColumn() {
        return this.SendMsg(this.GetNppHwnd(), this.RUNCOMMAND_USER + 9)
    }

    GetNppFullFilePath() {
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(520)
        this.SendMsg(this.GetNppHwnd(), this.RUNCOMMAND_USER + 10, 520, bufferAddress)
        stringresult := this.ReadBuffer(bufferAddress, 520)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }

;-- Scintilla methods ----------------------------------------------------------
    ; Add text to the document at current position.
    ; If included, only the first 'length' characters are added
    AddText(text, length := false) {
        encoding := "CP" this.GetCodePage()
        bufferBytes := this.WriteBuffer(text, , encoding)
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(bufferBytes)
        this.WriteBuffer(text, bufferAddress, encoding)
        if (length = false)
            length := StrLen(text)
        this.SendMsg(this.GetSciHwnd(), 2001, length, bufferAddress)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
    }

    ; Insert string at a position.
    InsertText(pos, text) {
        encoding := "CP" this.GetCodePage()
        bufferBytes := this.WriteBuffer(text, , encoding)
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(bufferBytes)
        this.WriteBuffer(text, bufferAddress, encoding)
        this.SendMsg(this.GetSciHwnd(), 2003, pos, bufferAddress)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
    }

    ; Delete all text in the document.
    ClearAll() {
        return this.PostMsg(this.GetSciHwnd(), 2004)
    }

    ; Returns the number of bytes in the document.
    GetLength() {
        return this.SendMsg(this.GetSciHwnd(), 2006) 
    }

    ; Returns the character byte at the position.
    GetCharAt(pos) {
        return this.SendMsg(this.GetSciHwnd(), 2007, pos)
    }

    ; Returns the position of the caret.
    GetCurrentPos() {
        return this.SendMsg(this.GetSciHwnd(), 2008)
    }

    ; Returns the position of the opposite end of the selection to the caret.
    GetAnchor() {
        return this.SendMsg(this.GetSciHwnd(), 2009)
    }

    ; # Redoes the next action on the undo history.
    Redo() {
        this.PostMsg(this.GetSciHwnd(), 2011)
    }

    ; # Choose between collecting actions into the undo history and discarding them.
    SetUndoCollection(collectUndo) {
        return this.PostMsg(this.GetSciHwnd(), 2012, collectUndo)
    }

    ; # Select all the text in the document.
    SelectAll() {
        return this.PostMsg(this.GetSciHwnd(), 2013)
    }

    ; # Are there any redoable actions in the undo history?
    CanRedo() {
        return this.SendMsg(this.GetSciHwnd(), 2016)
    }

    ; # Set caret to start of a line and ensure it is visible.
    GotoLine(line) {
        return this.PostMsg(this.GetSciHwnd(), 2024, line)
    }

    ; # Set caret to a position and ensure it is visible.
    GotoPos(pos) {
        return this.PostMsg(this.GetSciHwnd(), 2025, pos)
    }

    ; # Set the selection anchor to a position. The anchor is the opposite end of the selection from the caret.
    SetAnchor(posAnchor) {
        return this.PostMsg(this.GetSciHwnd(), 2026, posAnchor)
    }

    ; # Retrieve the text of the line containing the caret. Returns the index of the caret on the line. Result is NUL-terminated.
    GetCurLine() {
        bufferBytes := this.SendMsg(this.GetSciHwnd(), 2027) + 1
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(bufferBytes)
        this.SendMsg(this.GetSciHwnd(), 2027, , bufferAddress)
        encoding := "CP" this.GetCodePage()
        stringresult := this.ReadBuffer(bufferAddress, bufferBytes, encoding)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }
    
    ; # Start a sequence of actions that is undone and redone as a unit.
    ; # May be nested.
    BeginUndoAction() {
        return this.PostMsg(this.GetSciHwnd(), 2078)
    }

    ; # End a sequence of actions that is undone and redone as a unit.
    EndUndoAction() {
        return this.PostMsg(this.GetSciHwnd(), 2079)
    }

    ; # Retrieve indentation size.
    GetIndent() {
        return this.SendMsg(this.GetSciHwnd(), 2123)
    }

    ; # Change the indentation of a line to a number of columns.
    SetLineIndentation(line, indentSize) {
        return this.PostMsg(this.GetSciHwnd(), 2126, line, indentSize)
    }

    ; # Retrieve the number of columns that a line is indented.
    GetLineIndentation(line) {
        return this.SendMsg(this.GetSciHwnd(), 2127, line)
    }

    ; # Retrieve the column number of a position, taking tab width into account.
    GetColumn(pos) {
        return this.SendMsg(this.GetSciHwnd(), 2129, pos)
    }

    ; # Get the position after the last visible characters on a line.
    GetLineEndPosition(line) {
        return this.SendMsg(this.GetSciHwnd(), 2136, line)
    }

    ; Get the code page used to interpret the bytes of the document as characters.
    GetCodePage() {
        return this.SendMsg(this.GetSciHwnd(), 2137)
    }

    ; # Sets the position of the caret.
    SetCurrentPos(pos) {
        return this.PostMsg(this.GetSciHwnd(), 2141, pos)
    }

    ; # Sets the position that starts the selection - this becomes the anchor.
    SetSelectionStart(pos) {
        return this.PostMsg(this.GetSciHwnd(), 2142, pos)
    }

    ; # Returns the position at the start of the selection.
    GetSelectionStart() {
        return this.SendMsg(this.GetSciHwnd(), 2143)
    }

    ; # Sets the position that ends the selection - this becomes the currentPosition.
    SetSelectionEnd(pos) {
        return this.PostMsg(this.GetSciHwnd(), 2144, pos)
    }

    ; # Returns the position at the end of the selection.
    GetSelectionEnd() {
        return this.SendMsg(this.GetSciHwnd(), 2145)
    }

    ; # Retrieve the display line at the top of the display.
    GetFirstVisibleLine() {
        return this.SendMsg(this.GetSciHwnd(), 2152)
    }

    ; # Retrieve the contents of a line. Returns the length of the line.
    GetLine(line) {
        bufferBytes := this.SendMsg(this.GetSciHwnd(), 2153, line) + 1
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(bufferBytes)
        this.SendMsg(this.GetSciHwnd(), 2153, line, bufferAddress)
        encoding := "CP" this.GetCodePage()
        stringresult := this.ReadBuffer(bufferAddress, bufferBytes, encoding)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }

    ; # Returns the number of lines in the document. There is always at least one.
    GetLineCount() {
        return this.SendMsg(this.GetSciHwnd(), 2154)
    }

    ; Retrieve the selected text.
    GetSelText() {
        bufferBytes := this.SendMsg(this.GetSciHwnd(), 2161) + 1
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(bufferBytes)
        this.SendMsg(this.GetSciHwnd(), 2161, bufferBytes, bufferAddress)
        encoding := "CP" this.GetCodePage()
        stringresult := this.ReadBuffer(bufferAddress, bufferBytes, encoding)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }

    ; Replace the selected text with the argument text.
    ReplaceSel(text) {
        encoding := "CP" this.GetCodePage()
        bufferBytes := this.WriteBuffer(text, , encoding)
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(bufferBytes)
        this.WriteBuffer(text, bufferAddress, encoding)
        this.SendMsg(this.GetSciHwnd(), 2170, , bufferAddress)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return
    }

    ; # Replace the contents of the document with the argument text.
    ; fun void SetText=w2181(, string text)
    SetText(text) {
        return
    }

    ; # Retrieve all the text in the document.
    GetText() {
        bufferBytes := this.GetTextLength() + 1
        this.OpenProcess()
        bufferAddress := this.OpenBuffer(bufferBytes)
        this.SendMsg(this.GetSciHwnd(), 2182, bufferBytes, bufferAddress)
        encoding := "CP" this.GetCodePage()
        stringresult := this.ReadBuffer(bufferAddress, bufferBytes, encoding)
        this.CloseBuffer(bufferAddress)
        this.CloseProcess()
        return stringresult
    }

    ; # Retrieve the number of characters in the document.
    GetTextLength() {
        return this.SendMsg(this.GetSciHwnd(), 2183)
    }

    ; # Append a string to the end of the document without changing the selection.
    ; fun void AppendText=w2282(int length, string text)
    AppendText(length, text) {
        return
    }

    ; # Move caret down one line.
    LineDown() {
        return this.PostMsg(this.GetSciHwnd(), 2300)
    }

    ; # Move caret down one line extending selection to new caret position.
    LineDownExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2301)
    }

    ; # Move caret up one line.
    LineUp() {
        return this.PostMsg(this.GetSciHwnd(), 2302)
    }

    ; # Move caret up one line extending selection to new caret position.
    LineUpExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2303)
    }

    ; # Move caret left one character.
    CharLeft() {
        return this.PostMsg(this.GetSciHwnd(), 2304)
    }

    ; # Move caret left one character extending selection to new caret position.
    CharLeftExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2305)
    }

    ; # Move caret right one character.
    CharRight() {
        return this.PostMsg(this.GetSciHwnd(), 2306)
    }

    ; # Move caret right one character extending selection to new caret position.
    CharRightExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2307)
    }

    ; # Move caret left one word.
    WordLeft() {
        return this.PostMsg(this.GetSciHwnd(), 2308)
    }

    ; # Move caret left one word extending selection to new caret position.
    WordLeftExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2309)
    }

    ; # Move caret right one word.
    WordRight() {
        return this.PostMsg(this.GetSciHwnd(), 2310)
    }

    ; # Move caret right one word extending selection to new caret position.
    WordRightExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2311)
    }

    ; # Move caret to first position on line.
    Home() {
        return this.PostMsg(this.GetSciHwnd(), 2312)
    }

    ; # Move caret to first position on line extending selection to new caret position.
    HomeExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2313)
    }

    ; # Move caret to last position on line.
    LineEnd() {
        return this.PostMsg(this.GetSciHwnd(), 2314)
    }

    ; # Move caret to last position on line extending selection to new caret position.
    LineEndExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2315)
    }

    ; # Move caret to first position in document.
    DocumentStart() {
        return this.PostMsg(this.GetSciHwnd(), 2316)
    }

    ; # Move caret to first position in document extending selection to new caret position.
    DocumentStartExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2317)
    }

    ; # Move caret to last position in document.
    DocumentEnd() {
        return this.PostMsg(this.GetSciHwnd(), 2318)
    }

    ; # Move caret to last position in document extending selection to new caret position.
    DocumentEndExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2319)
    }

    ; # Move caret one page up.
    PageUp() {
        return this.PostMsg(this.GetSciHwnd(), 2320)
    }

    ; # Move caret one page up extending selection to new caret position.
    PageUpExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2321)
    }

    ; # Move caret one page down.
    PageDown() {
        return this.PostMsg(this.GetSciHwnd(), 2322)
    }

    ; # Move caret one page down extending selection to new caret position.
    PageDownExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2323)
    }

    ; # Switch from insert to overtype mode or the reverse.
    EditToggleOvertype() {
        return this.PostMsg(this.GetSciHwnd(), 2324)
    }

    ; # Cancel any modes such as call tip or auto-completion list display.
    Cancel() {
        return this.PostMsg(this.GetSciHwnd(), 2325)
    }

    ; # Delete the selection or if no selection, the character before the caret.
    DeleteBack() {
        return this.PostMsg(this.GetSciHwnd(), 2326)
    }

    ; # If selection is empty or all on one line replace the selection with a tab character.
    ; # If more than one line selected, indent the lines.
    Tab() {
        return this.PostMsg(this.GetSciHwnd(), 2327)
    }

    ; # Dedent the selected lines.
    BackTab() {
        return this.PostMsg(this.GetSciHwnd(), 2328)
    }

    ; # Insert a new line, may use a CRLF, CR or LF depending on EOL mode.
    NewLine() {
        return this.PostMsg(this.GetSciHwnd(), 2329)
    }

    ; # Insert a Form Feed character.
    FormFeed() {
        return this.PostMsg(this.GetSciHwnd(), 2330)
    }

    ; # Move caret to before first visible character on line.
    ; # If already there move to first character on line.
    VCHome() {
        return this.PostMsg(this.GetSciHwnd(), 2331)
    }

    ; # Like VCHome but extending selection to new caret position.
    VCHomeExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2332)
    }

    ; # Magnify the displayed text by increasing the sizes by 1 point.
    ZoomIn() {
        return this.PostMsg(this.GetSciHwnd(), 2333)
    }

    ; # Make the displayed text smaller by decreasing the sizes by 1 point.
    ZoomOut() {
        return this.PostMsg(this.GetSciHwnd(), 2334)
    }

    ; # Delete the word to the left of the caret.
    DelWordLeft() {
        return this.PostMsg(this.GetSciHwnd(), 2335)
    }

    ; # Delete the word to the right of the caret.
    DelWordRight() {
        return this.PostMsg(this.GetSciHwnd(), 2336)
    }

    ; # Delete the word to the right of the caret, but not the trailing non-word characters.
    DelWordRightEnd() {
        return this.PostMsg(this.GetSciHwnd(), 2518)
    }

    ; # Cut the line containing the caret.
    LineCut() {
        return this.PostMsg(this.GetSciHwnd(), 2337)
    }

    ; # Delete the line containing the caret.
    LineDelete() {
        return this.PostMsg(this.GetSciHwnd(), 2338)
    }

    ; # Switch the current line with the previous.
    LineTranspose() {
        return this.PostMsg(this.GetSciHwnd(), 2339)
    }

    ; # Duplicate the current line.
    LineDuplicate() {
        return this.PostMsg(this.GetSciHwnd(), 2404)
    }

    ; # Transform the selection to lower case.
    LowerCase() {
        return this.PostMsg(this.GetSciHwnd(), 2340)
    }

    ; # Transform the selection to upper case.
    UpperCase() {
        return this.PostMsg(this.GetSciHwnd(), 2341)
    }

    ; # Scroll the document down, keeping the caret visible.
    LineScrollDown() {
        return this.PostMsg(this.GetSciHwnd(), 2342)
    }

    ; # Scroll the document up, keeping the caret visible.
    LineScrollUp() {
        return this.PostMsg(this.GetSciHwnd(), 2343)
    }

    ; # Delete the selection or if no selection, the character before the caret.
    ; # Will not delete the character before at the start of a line.
    DeleteBackNotLine() {
        return this.PostMsg(this.GetSciHwnd(), 2344)
    }

    ; # Move caret to first position on display line.
    HomeDisplay() {
        return this.PostMsg(this.GetSciHwnd(), 2345)
    }

    ; # Move caret to first position on display line extending selection to
    ; # new caret position.
    HomeDisplayExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2346)
    }

    ; # Move caret to last position on display line.
    LineEndDisplay() {
        return this.PostMsg(this.GetSciHwnd(), 2347)
    }

    ; # Move caret to last position on display line extending selection to new
    ; # caret position.
    LineEndDisplayExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2348)
    }

    ; # These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)?
    ; # except they behave differently when word-wrap is enabled:
    ; # They go first to the start / end of the display line, like (Home|LineEnd)Display
    ; # The difference is that, the cursor is already at the point, it goes on to the start
    ; # or end of the document line, as appropriate for (Home|LineEnd|VCHome)(Extend)?.
    HomeWrap() {
        return this.PostMsg(this.GetSciHwnd(), 2349)
    }
    HomeWrapExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2450)
    }
    LineEndWrap() {
        return this.PostMsg(this.GetSciHwnd(), 2451)
    }
    LineEndWrapExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2452)
    }
    VCHomeWrap() {
        return this.PostMsg(this.GetSciHwnd(), 2453)
    }
    VCHomeWrapExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2454)
    }

    ; Set the zoom level.
    ; This number of points is added to the size of all fonts.
    ; It may be positive to magnify or negative to reduce.
    SetZoom(zoom) {
        return this.PostMsg(this.GetSciHwnd(), 2373, zoom)
    }

    ; Retrieve the zoom level.
    GetZoom() {
        return this.SendMsg(this.GetSciHwnd(), 2374)
    }

    ; Move caret between paragraphs (delimited by empty lines).
    ParaDown() {
        return this.PostMsg(this.GetSciHwnd(), 2413)
    }

    ; Move caret between paragraphs (delimited by empty lines).
    ParaDownExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2414)
    }

    ; Move caret between paragraphs (delimited by empty lines).
    ParaUp() {
        return this.PostMsg(this.GetSciHwnd(), 2415)
    }

    ; Move caret between paragraphs (delimited by empty lines).
    ParaUpExtend() {
        return this.PostMsg(this.GetSciHwnd(), 2416)
    }

    ; # Set caret to a position, while removing any existing selection.
    SetEmptySelection(pos) {
        return this.PostMsg(this.GetSciHwnd(), 2556, pos)
    }

    ; # Count characters between two positions.
    CountCharacters(startPos, endPos) {
        return this.SendMsg(this.GetSciHwnd(), 2633, startPos, endPos)
    }

    ; # Delete a range of text in the document.
    DeleteRange(pos, deleteLength) {
        return this.PostMsg(this.GetSciHwnd(), 2645, pos, deleteLength)
    }
}