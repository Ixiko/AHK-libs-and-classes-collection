; Title: Scintilla Wrapper for AHK

; Group: Helper Functions

/*
    Function: Add
    Creates a Scintilla component and adds it to the Parent GUI.

    This function initializes the Scintilla Component.
    See <http://www.scintilla.org/Steps.html> for more information on how to add the component to a GUI/Control.

    Parameters:
    SCI_Add(hParent, [x, y, w, h, Styles, MsgHandler, DllPath])

    hParent     -   Hwnd of the parent control who will host the Scintilla Component
    x           -   x position for the control (default 5)
    y           -   y position for the control (default 15)
    w           -   Width of the control (default 390)
    h           -   Height of the control (default 270)
    Styles      -   List of window style variable names separated by spaces.
                    The WS_ prefix for the variables is optional.
                    Full list of Style names can be found at
                    <http://msdn.microsoft.com/en-us/library/ms632600%28v=vs.85%29.aspx>.

    MsgHandler  -   Name of the function that will handle the window messages sent by the control.
                    This is very useful for when creating personalized lexing or folding for your control.
    DllPath     -   Path to the SciLexer.dll file, if omitted the function looks for it in *a_scriptdir*.

    Returns:
    HWND - Component handle.

    Examples:
    (start code)
    ; Add a component with default values.
    ; It expects scilexer.dll to be on the script's location.
    ; The default values are calculated to fit optimally on a 400x300 GUI/Control

    Gui +LastFound
    hwnd:=WinExist()
    hSci:=SCI_Add(hwnd)
    Gui, show, w400 h300
    return

    ;---------------------
    ; Add a component with default values.
    ; It expects scilexer.dll to be on the script's location.
    ; This script also adds some styles.
    ; If variables "x,y,w,h" are empty the default values are used.

    Gui +LastFound
    hwnd:=WinExist()
    hSci:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_BORDER WS_VISIBLE")
    Gui, show, w400 h300
    return

    ;---------------------
    ; Add a component embedded in a tab with additional code for
    ; hiding/showing the component depending on which tab is open.
    ; If variables "x,w,h" are empty the default values are used.

    Gui, add, Tab2, HWNDhwndtab x0 y0 w400 h300 gtabHandler vtabLast,one|two
    hSci:=SCI_Add(hwndtab,x,25,w,h,"Child Border Visible","",a_desktop "\scilexer.dll")
    Gui, show, w400 h300
    return

    tabHandler:                             ; Tab Handler for the Scintilla Control
    Gui, submit, Nohide
    action := tabLast = "one" ? "Show" : "Hide" ; decide which action to take
    Control,%action%,,,ahk_id %hSci%
    return
    (end)
*/
SCI_Add(hParent, x=5, y=15, w=390, h=270, Styles="", MsgHandler="", DllPath=""){
    static WS_OVERLAPPED:=0x00000000,WS_POPUP:=0x80000000,WS_CHILD:=0x40000000,WS_MINIMIZE:=0x20000000
    ,WS_VISIBLE:=0x10000000,WS_DISABLED:=0x08000000,WS_CLIPSIBLINGS:=0x04000000,WS_CLIPCHILDREN:=0x02000000
    ,WS_MAXIMIZE:=0x01000000,WS_CAPTION:=0x00C00000,WS_BORDER:=0x00800000,WS_DLGFRAME:=0x00400000
    ,WS_VSCROLL:=0x00200000,WS_HSCROLL:=0x00100000,WS_SYSMENU:=0x00080000,WS_THICKFRAME:=0x00040000
    ,WS_GROUP:=0x00020000,WS_TABSTOP:=0x00010000,WS_MINIMIZEBOX:=0x00020000,WS_MAXIMIZEBOX:=0x00010000
    ,WS_TILED:=0x00000000,WS_ICONIC:=0x20000000,WS_SIZEBOX:=0x00040000,WS_EX_CLIENTEDGE:=0x00000200
    ,GuiID:=311210,init:=False, NULL:=0

    if !init        ;  WM_NOTIFY = 0x4E
        old:=OnMessage(0x4E,"SCI_onNotify"),init:=True,old!="SCI_onNotify" ? SCI("oldNotify", RegisterCallback(old))

    if !SCIModule:=DllCall("LoadLibrary", "Str", DllPath ? DllPath : "SciLexer.dll")
        return debug ? A_ThisFunc "> Could not load library: " DllPath : -1

    hStyle := WS_CHILD | (VISIBILITY := InStr(Styles, "Hidden") ? 0 : WS_VISIBLE) | WS_TABSTOP

    if Styles
        Loop, Parse, Styles, %a_tab%%a_space%, %a_tab%%a_space%
            hStyle |= %a_loopfield%+0 ? %a_loopfield% : WS_%a_loopfield% ? WS_%a_loopfield% : 0

    hSci:=DllCall("CreateWindowEx"
                 ,Uint ,WS_EX_CLIENTEDGE        ; Ex Style
                 ,Str  ,"Scintilla"             ; Class Name
                 ,Str  ,""                      ; Window Name
                 ,UInt ,hStyle                  ; Window Styles
                 ,Int  ,x ? x : 5               ; x
                 ,Int  ,y ? y : 15              ; y
                 ,Int  ,w ? w : 390             ; Width
                 ,Int  ,h ? h : 270             ; Height
                 ,UInt ,hParent                 ; Parent HWND
                 ,UInt ,GuiID                   ; (HMENU)GuiID
                 ,UInt ,NULL                    ; hInstance
                 ,UInt ,NULL, "UInt")           ; lpParam

                 ,SCI(hSci, True)               ; used to check if that handle exist.
                 ,SCI_sendEditor(hSci)          ; initialize SCI_sendEditor function
                 ,IsFunc(MsgHandler) ? SCI(hSci "MsgHandler", MsgHandler)

    return hSci
}

/*  Group: Text
    Group of funtions that handle the text in the scintilla component.

    <http://www.scintilla.org/ScintillaDoc.html#TextRetrievalAndModification>

    Each byte in a Scintilla document is followed by an associated byte of styling information. The combination of
    a character byte and a style byte is called a cell. Style bytes are interpreted an index into an array of
    styles.

    Style bytes may be split into an index and a set of indicator bits but this use is discouraged and indicators
    should now use *SCI_INDICATORFILLRANGE* and related calls. The default split is with the index in the low 5
    bits and 3 high bits as indicators. This allows 32 fundamental styles, which is enough for most languages, and
    three independent indicators so that, for example, syntax errors, deprecated names and bad indentation could
    all be displayed at once. The number of bits used for styles can be altered with *SCI_SETSTYLEBITS* up to a
    maximum of 8 bits. The remaining bits can be used for indicators.

    In this document, 'character' normally refers to a byte even when multi-byte characters are used. Lengths
    measure the numbers of bytes, not the amount of characters in those bytes.

    Positions within the Scintilla document refer to a character or the gap before that character. The first
    character in a document is 0, the second 1 and so on. If a document contains nLen characters, the last
    character is numbered nLen-1. The caret exists between character positions and can be located from before the
    first character (0) to after the last character (nLen).

    There are places where the caret can not go where two character bytes make up one character. This occurs when a
    DBCS character from a language like Japanese is included in the document or when line ends are marked with the
    CP/M standard of a carriage return followed by a line feed. The *INVALID_POSITION* constant (-1) represents an
    invalid position within the document.

    All lines of text in Scintilla are the same height, and this height is calculated from the largest font in any
    current style. This restriction is for performance; if lines differed in height then calculations involving
    positioning of text would require the text to be styled first.
*/

; Group: General Text Functions

/*
    Function: ReplaceSel
    <http://www.scintilla.org/ScintillaDoc.html#SCI_REPLACESEL>

    The currently selected text between the anchor and the current position is replaced by the 0 terminated text
    string. If the anchor and current position are the same, the text is inserted at the caret position. The caret
    is positioned after the inserted text and the caret is scrolled into view.

    Parameters:
    SCI_ReplaceSel(rStr[, hwnd])

    rStr    -   String of text to use for replacing the current selection.
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    >SCI_ReplaceSel("replace currently selected text with this", hSci)
*/
SCI_ReplaceSel(rStr, hwnd=0){
    
    a_isunicode ? (VarSetCapacity(rStrA, StrPut(rStr, "CP0")), StrPut(rStr, &rStrA, "CP0"))
    return SCI_sendEditor(hwnd, "SCI_REPLACESEL", 0, a_isunicode ? &rStrA : &rStr)
}

/* 
    Function: Allocate
    <http://www.scintilla.org/ScintillaDoc.html#SCI_ALLOCATE>

    Allocate a document buffer large enough to store a given number of bytes. The document will not be made
    smaller than its current contents.

    Parameters:
    SCI_Allocate(nBytes[, hwnd])

    nBytes  -   Number of bytes to allocate for the document buffer.
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    >SCI_Allocate(1024, hSci)
*/
SCI_Allocate(nBytes, hwnd=0){
    
    return SCI_sendEditor(hwnd, "SCI_ALLOCATE", nBytes)
}

/*
    Function: AddText
    <http://www.scintilla.org/ScintillaDoc.html#SCI_ADDTEXT>

    This inserts the first *len* characters from the string *aStr* at the current position.
    The current position is set at the end of the inserted text, but it is *not* scrolled into view.

    Parameters:
    SCI_AddText(aStr[, len, hwnd])

    aStr    -   The string to be added to the component at current caret position.
    len     -   Lenght of the string that will be added to the component. If 0 or blank it will be calculated
                automatically using StrLen()
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (start code)
    #include ../SCI.ahk
    
    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h)
    Gui, show, w400 h300
    SCI_SetWrapMode(True, hSci1)
    SCI_AddText(x:="my text",StrLen(x), hSci)
    return
    ;---------------------

    #include ../SCI.ahk
    
    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h)
    Gui, show, w400 h300
    SCI_SetWrapMode(True, hSci1)
    
    ; stores "This is my truncated text".
    SCI_AddText("This is my truncated text, this is not added!",25)
    return
    ;---------------------

    #include ../SCI.ahk
    
    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h)
    Gui, show, w400 h300
    SCI_SetWrapMode(True, hSci1)
    
    ; In this example the whole text is stored because the length is calculated internally.
    SCI_AddText("This is my truncated text, this is added!")
    return
    (end)
*/
SCI_AddText(aStr, len=0, hwnd=0){

    a_isunicode ? (VarSetCapacity(aStrA, StrPut(aStr, "CP0")), StrPut(aStr, &aStrA, "CP0"))
    return SCI_sendEditor(hwnd, "SCI_ADDTEXT", len ? len : strLen(aStr), a_isunicode ?  &aStrA : &aStr)
}

/* needs work
    ; Function: AddStyledText
    ; <http://www.scintilla.org/ScintillaDoc.html#SCI_ADDSTYLEDTEXT>

    ; This behaves just like <AddText()>, but inserts styled text.

    ; Parameters:
    ; SCI_AddText(cell[, len, hwnd])

    ; cell    -   The styled string cell to be added to the component at current caret position.
    ; len     -   lenght of the string that will be added to the component. If 0 or blank it will be calculated
                ; automatically using StrLen()
    ; hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                ; Scintilla components in the same script. The wrapper will remember the last used hwnd,
                ; so you can specify it once and only specify it again when you want to operate on a different
                ; component.

    ; Returns:
    ; Zero - Nothing is returned by this function.

    ; Examples:
 */
; SCI_AddStyledText(cell, len=0, hwnd=0){

    ; a_isunicode ? (VarSetCapacity(cellA, StrPut(cell, "CP0")), StrPut(cell, &cellA, "CP0"))
    ; return SCI_sendEditor(hwnd, "SCI_ADDSTYLEDTEXT", len ? len : strLen(cell), a_isunicode ?  &cellA : &cell)
; }

/*
    Function: AppendText
    <http://www.scintilla.org/ScintillaDoc.html#SCI_APPENDTEXT>
    
    This adds the first *len* characters from the string *aStr* to the end of the document. 
    The current selection is not changed and the new text is *not* scrolled into view.
    
    Parameters:
    SCI_AppendText(aStr[, len, hwnd])

    aStr    -   The string to be appended to the end  of the current document on the selected component.
    len     -   Lenght of the string that will be added to the component. If 0 or blank it will be calculated
                automatically using StrLen()
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (start code)
    #include ../SCI.ahk
    
    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h)
    Gui, show, w400 h300
    SCI_SetWrapMode(True, hSci1)
    SCI_AppendText(x:="my text",StrLen(x), hSci)
    return
    ;---------------------

    #include ../SCI.ahk
    
    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h)
    Gui, show, w400 h300
    SCI_SetWrapMode(True, hSci1)
    
    ; stores "This is my truncated text".
    SCI_AppendText("This is my truncated text, this is not added!",25)
    return
    ;---------------------

    #include ../SCI.ahk
    
    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h)
    Gui, show, w400 h300
    SCI_SetWrapMode(True, hSci1)
    
    ; In this example the whole text is stored because the length is calculated internally.
    SCI_AppendText("This is my truncated text, this is added!")
    return
    (end)
*/
SCI_AppendText(aStr, len=0, hwnd=0){
    
    a_isunicode ? (VarSetCapacity(aStrA, StrPut(aStr, "CP0")), StrPut(aStr, &aStrA, "CP0"))
    return SCI_sendEditor(hwnd, "SCI_APPENDTEXT", len ? len : strLen(aStr), a_isunicode ?  &aStrA : &aStr)
}

/*
    Function: InsertText
    <http://www.scintilla.org/ScintillaDoc.html#SCI_INSERTTEXT>
    
    This inserts the text string at position *pos* or at the current position  if pos is not specified. 
    If the current position is after the insertion point then it is moved along  with its surrounding text 
    but no scrolling is performed.
    
    Parameters:
    SCI_InsertText(iStr[, pos,hwnd])
    
    iStr    -   String of text to be inserted.
    pos     -   Position where the text is to be inserted. If not specified it defaults to current caret position.
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    Zero - Nothing is returned by this function.
    
    Examples:
*/
SCI_InsertText(iStr, pos=-1,hwnd=0){
    
    a_isunicode ? (VarSetCapacity(iStrA, StrPut(iStr, "CP0")), StrPut(iStr, &iStrA, "CP0"))
    return SCI_sendEditor(hwnd, "SCI_INSERTTEXT", pos, a_isunicode ? &iStrA : &iStr)
}

/*
    Function: ClearAll
    <http://www.scintilla.org/ScintillaDoc.html#SCI_CLEARALL>
    
    Unless the document is read-only, this deletes all the text.
    
    Parameters:
    SCI_ClearAll([hwnd])
    
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.
    
    Returns:
    Zero - Nothing is returned by this function.
    
    Examples:
    >SCI_ClearAll(hSci)
*/
SCI_ClearAll(hwnd=0){
    
    return SCI_sendEditor(hwnd, "SCI_CLEARALL")
}

/*
    Function: ClearDocumentStyle
    <http://www.scintilla.org/ScintillaDoc.html#SCI_CLEARDOCUMENTSTYLE>
    
    When wanting to completely restyle the document, for example after choosing a lexer, the 
    *ClearDocumentStyle()* can be used to clear all styling information and reset the folding state.
    
    Parameters:
    SCI_ClearDocumentStyle([hwnd])
    
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.
                
    Returns:
    Zero - Nothing is returned by this function.
    
    Examples:
    >SCI_ClearDocumentStyle(hSci)
*/
SCI_ClearDocumentStyle(hwnd=0){
    
    return SCI_sendEditor(hwnd, "SCI_CLEARDOCUMENTSTYLE")
}

/* needs work TargetAsUTF8
    ; Function: TargetAsUTF8
    ; <http://www.scintilla.org/ScintillaDoc.html#SCI_TARGETASUTF8>
    
    ; This function retrieves the value of the target encoded as UTF-8, so is useful for retrieving text for use in 
    ; other parts of the user interface, such as find and replace dialogs. The length of the encoded text in bytes 
    ; is returned. 
    
    ; Parameters:
    ; SCI_TargetAsUTF8(tStr[, hwnd])
    
    ; tStr    -   Target string that will be converted to UTF-8 encoding.
    ; hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                ; Scintilla components in the same script. The wrapper will remember the last used hwnd,
                ; so you can specify it once and only specify it again when you want to operate on a different
                ; component.
                
    ; Returns:
    ; utfLen  -   Length of the encoded text in bytes. 
    
    ; Example:

; SCI_TargetAsUTF8(tStr, hwnd=0){
    
    ; a_isunicode ? (VarSetCapacity(tStrA, StrPut(tStr, "CP0")), StrPut(tStr, &tStrA, "CP0"))
    ; return SCI_sendEditor(hwnd, "SCI_TARGETASUTF8", 0, a_isunicode ? &tStrA : &tStr)
; }
*/

/* needs work
    ; Function: EncodedFromUTF8
    ; <http://www.scintilla.org/ScintillaDoc.html#SCI_ENCODEDFROMUTF8>
    
    ; *EncodedFromUTF8()* converts a UTF-8 string into the document's encoding which is useful for taking the 
    ; results of a find dialog, for example, and receiving a string of bytes that can be searched for in the 
    ; document. Since the text can contain nul bytes, the <SetLengthForEncode()> function can be used to set the 
    ; length that will be converted. If set to -1, the length is determined by finding a nul byte. The length of the 
    ; converted string is returned.
    
    ; Parameters:
    ; SCI_EncodedFromUTF8(utf8Str, encStr[, hwnd])
    
    ; utf8Str -
    ; encStr  -
    ; hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                ; Scintilla components in the same script. The wrapper will remember the last used hwnd,
                ; so you can specify it once and only specify it again when you want to operate on a different
                ; component.
    
    ; Examples:
;
; SCI_EncodedFromUTF8(utf8Str, encStr, hwnd=0){
    ; return
; }
 */
 
; Group: Text Set Functions
/*
    Function: SetText
    <http://www.scintilla.org/ScintillaDoc.html#SCI_SETTEXT>
    
    Replaces all the text in the document with the zero terminated text string you pass in.
    
    Parameters:
    SCI_SetText(sStr[, hwnd])
    
    sStr    -   String of text to be set on the Scintilla component.
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.
                
    Returns:
    Zero - Nothing is returned by this function.
    
    Examples:
*/
SCI_SetText(sStr, hwnd=0){
    
    a_isunicode ? (VarSetCapacity(sStrA, StrPut(sStr, "CP0")), StrPut(sStr, &sStrA, "CP0"))
    return SCI_sendEditor(hwnd, "SCI_SETTEXT", 0, a_isunicode ? &sStrA : &sStr)
}

/*
    Function: SetSavePoint
    <http://www.scintilla.org/ScintillaDoc.html#SCI_SETSAVEPOINT>
    
    This message tells Scintilla that the current state of the document is unmodified. This is usually done when 
    the file is saved or loaded, hence the name "save point". As Scintilla performs undo and redo operations, it 
    notifies the container that it has entered or left the save point with *SCN_SAVEPOINTREACHED* and 
    *SCN_SAVEPOINTLEFT* notification messages, allowing the container to know if the file should be considered 
    dirty or not.
    
    Parameters:
    SCI_SetSavePoint([hwnd])
    
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.
                
    Returns:
    Zero - Nothing is returned by this function.
    
    Examples:
*/
SCI_SetSavePoint(hwnd=0){
    
    return SCI_sendEditor(hwnd, "SCI_SETSAVEPOINT")
}

/*
    Function: SetReadOnly
    <http://www.scintilla.org/ScintillaDoc.html#SCI_SETREADONLY>
    
    These messages set and get the read-only flag for the document. If you mark a document as read only, attempts to modify the text cause the *SCN_MODIFYATTEMPTRO* notification.
    
    Parameters:
    SCI_SetReadOnly(roMode[, hwnd])
    
    roMode  -   True (1) or False (0).
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.
    
    Returns:
    Zero - Nothing is returned by this function.
    
    Examples:
*/
SCI_SetReadOnly(roMode, hwnd=0){
    
    return SCI_sendEditor(hwnd, "SCI_SETREADONLY", roMode)
}

/*
    Function: SetStyleBits
    <http://www.scintilla.org/ScintillaDoc.html#SCI_SETSTYLEBITS>
    
    This Routine sets the number of bits in each cell to use for styling, to a maximum of 8 style bits. The remaining bits can be used as indicators. The standard setting is *SCI_SETSTYLEBITS(5)*. The number of styling bits needed by the current lexer can be found with <GetStyleBitsNeeded>.
    
    Parameters:
    SCI_SetStyleBits(bits[, hwnd])
    
    bits    -   
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.
                
    Returns:
    Zero - Nothing is returned by this function.
    
    Examples:
*/
SCI_SetStyleBits(bits, hwnd=0){
    
    return SCI_sendEditor(hwnd, "SCI_SETSTYLEBITS", bits)
}

/*
    Function: SetLengthForEncode
    http://www.scintilla.org/ScintillaDoc.html#SCI_SETLENGTHFORENCODE
    
    <EncodedFromUTF8()> converts a UTF-8 string into the document's encoding which is useful for taking the 
    results of a find dialog, for example, and receiving a string of bytes that can be searched for in the 
    document. Since the text can contain nul bytes, the *SetLengthForEncode()* method can be used to set the 
    length that will be converted. If set to -1, the length is determined by finding a nul byte. The length of the 
    converted string is returned.
    
    Parameters:
    SCI_SetLengthForEncode(bytes[, hwnd])
    
    bytes   -   Length of the string that will be converted with <EncodedFromUTF8()>
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.
                
    Returns:
    Zero - Nothing is returned by this function.
    
    Examples:
*/
SCI_SetLengthForEncode(bytes, hwnd=0){
    
    return SCI_sendEditor(hwnd, "SCI_SETLENGTHFORENCODE", bytes)
}

; Group: Text Get Functions
/*
    Function: GetText
    <http://www.scintilla.org/ScintillaDoc.html#SCI_GETTEXT>
    
    This returns len-1 characters of text from the start of the document plus one terminating 0 character. 
    To collect all the text in a document, use <GetLength()> to get the number of characters in the document 
    (nLen), allocate a character buffer of length nLen+1 bytes, then call *GetText*(nLen+1, vText).
    If the vText argument is 0 then the length that should be allocated to store the entire document is returned.
    If you then save the text, you should use <SetSavePoint()> to mark the text as unmodified.
    
    See also: <GetSelText()>, <GetCurLine()>, <GetLine()>, <GetStyledText()>, <GetTextRange()>
    
    Parameters:
    len     -
    vText   -
    
    Returns:
    
    Examples:    
*/
SCI_GetText(len=0, Byref vText=0, hwnd=0){
    
    VarSetCapacity(str, len * (a_isunicode ? 2 : 1)), cLen := SCI_sendEditor(hwnd, "SCI_GETTEXT", len, &str)
    vText := StrGet(&str, "CP0")
    return cLen
}

/* needs work SCI_GetLine(line, vText, hwnd=0)  (LineLenght() from selection and information)
    ; Function: GetLine
    ; <http://www.scintilla.org/ScintillaDoc.html#SCI_GETLINE>
    
    ; This fills the buffer defined by text with the contents of the nominated line (lines start at 0). The buffer 
    ; is not terminated by a 0 character. It is up to you to make sure that the buffer is long enough for the text, 
    ; use <LineLength()> for that. The returned value is the number of characters copied to the buffer. 
    ; The returned text includes any end of line characters. If you ask for a line number outside the range of lines 
    ; in the document, 0 characters are copied. If the text argument is 0 then the length that should be allocated 
    ; to store the entire line is returned.
    
    ; See also: <GetCurLine()>, <GetSelText()>, <GetTextRange()>, <GetStyledText()>, <GetText()>
    
;
; SCI_GetLine(line, vText, hwnd=0){

    ; VarSetCapacity(str, SCI_LineLength(hwnd) * (a_isunicode ? 2 : 1))
    ; cLen := SCI_sendEditor(hwnd, "SCI_GETLINE", len, &str)
    ; vText := StrGet(&str, "CP0")
    ; return cLen
; }
 */

/*
    Function: GetReadonly
    <http://www.scintilla.org/ScintillaDoc.html#SCI_GETREADONLY>
    
    This function gets the read-only flag for the document. If you mark a document as read only, attempts to 
    modify the text cause the *SCN_MODIFYATTEMPTRO* notification.
    
    Parameters:
    
*/
SCI_GetReadonly(){

    return
}

/*
    Function: GetTextRange
    <http://www.scintilla.org/ScintillaDoc.html#SCI_GETTEXTRANGE>
    
    This collects the text between the positions cpMin and cpMax and copies it to lpstrText (see struct 
    <SCI_TextRange>). If cpMax is -1, text is returned to the end of the document. The text is 0 terminated, so 
    you must supply a buffer that is at least 1 character longer than the number of characters you wish to read. 
    The return value is the length of the returned text not including the terminating 0.
    
    See also: <SCI_GetSelText()>, <SCI_GetLine()>, <SCI_GetCurLine()>, <SCI_GetStyledText()>, <SCI_GetText()>
*/
SCI_GetTextRange(){
}

/*
    Function: GetCharAt
    <http://www.scintilla.org/ScintillaDoc.html#SCI_GETCHARAT>
    
    This returns the character at pos in the document or 0 if pos is negative or past the end of the document.
*/
SCI_GetCharAt(){
    
    return
}

/*
    Function: GetStyleAt
    <http://www.scintilla.org/ScintillaDoc.html#SCI_GETSTYLEAT>
    
    This returns the style at pos in the document, or 0 if pos is negative or past the end of the document.
*/
SCI_GetStyleAt(){
    
    return
}

/*
    Function: GetStyledText
    <http://www.scintilla.org/ScintillaDoc.html#SCI_GETSTYLEDTEXT>
    
    This collects styled text into a buffer using two bytes for each cell, with the character at the lower address 
    of each pair and the style byte at the upper address. Characters between the positions cpMin and cpMax are 
    copied to lpstrText (see struct <SCI_TextRange>). Two 0 bytes are added to the end of the text, so the buffer 
    that lpstrText points at must be at least 2*(cpMax-cpMin)+2 bytes long. No check is made for sensible values 
    of cpMin or cpMax. Positions outside the document return character codes and style bytes of 0.

See also: <GetSelText()>, <GetLine()>, <GetCurLine()>, <GetTextRange()>, <GetText()>
*/
SCI_GetStyledText(){
    
    return
}

/*
    Function: GetStyleBits
    <http://www.scintilla.org/ScintillaDoc.html#SCI_GETSTYLEBITS>
    
    This routine reads back the number of bits in each cell to use for styling, to a maximum of 8 style bits. The 
    remaining bits can be used as indicators. The standard setting is *SetStyleBits(5)*. The number of styling 
    bits needed by the current lexer can be found with <GetStyleBitsNeeded()>.
*/
SCI_GetStyleBits(){
    
    return
}

/* Group: Selection and information
*/

/*
    Function: GetTextLength
    <http://www.scintilla.org/ScintillaDoc.html#SCI_GETTEXTLENGTH>
    
    Returns the length of the document in bytes.
    
    Parameters:
    SCI_GetTextLength([hwnd])
    
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.
    
    Returns
    nLen    -   Length of the document in bytes.
    
    Examples
*/
SCI_GetTextLength(hwnd=0){
    
    return SCI_sendEditor(hwnd, "SCI_GETTEXTLENGTH")
}

/*
    Function: GetLength
    <http://www.scintilla.org/ScintillaDoc.html#SCI_GETLENGTH>
    
    Returns the length of the document in bytes.
    
    Parameters:
    SCI_GetLength([hwnd])
    
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.
    
    Returns
    nLen    -   Length of the document in bytes.
    
    Examples
*/
SCI_GetLength(hwnd=0){
    
    return SCI_sendEditor(hwnd, "SCI_GETLENGTH")
}

/* Group: Style Definition
    <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>

    While the style setting messages mentioned above change the style numbers associated with text, these messages
    define how those style numbers are interpreted visually. There are 256 lexer styles that can be set, numbered 0
    to *STYLE_MAX* (255). Unless you use *SCI_SETSTYLEBITS* to change the number of style bits,
    styles 0 to 31 are used to set the text attributes. There are also some predefined numbered styles starting at
    32, The following *STYLE_** constants are defined:

    - *STYLE_DEFAULT*       (32) This style defines the attributes that all styles receive when the
    *SCI_STYLECLEARALL* message is used.

    - *STYLE_LINENUMBER*    (33) This style sets the attributes of the text used to display line numbers in a line
    number margin. The background colour set for this style also sets the background colour for all margins that do
    not have any folding mask bits set. That is, any margin for which mask & *SC_MASK_FOLDERS* is 0. See
    *SCI_SETMARGINMASKN* for more about masks.

    - *STYLE_BRACELIGHT*    (34) This style sets the attributes used when highlighting braces with the
    *SCI_BRACEHIGHLIGHT* message and when highlighting the corresponding indentation with *SCI_SETHIGHLIGHTGUIDE*.

    - *STYLE_BRACEBAD*      (35) This style sets the display attributes used when marking an unmatched brace with the
    *SCI_BRACEBADLIGHT* message.

    - *STYLE_CONTROLCHAR*   (36) This style sets the font used when drawing control characters. Only the font, size,
    bold, italics, and character set attributes are used and not the colour attributes. See also:
    *SCI_SETCONTROLCHARSYMBOL*.

    - *STYLE_INDENTGUIDE*   (37) This style sets the foreground and background colours used when drawing the
    indentation guides.

    - *STYLE_CALLTIP*       (38) Call tips normally use the font attributes defined by *STYLE_DEFAULT*. Use of
    *SCI_CALLTIPUSESTYLE* causes call tips to use this style instead. Only the font face name, font size, foreground
    and background colours and character set attributes are used.

    - *STYLE_LASTPREDEFINED* (39) To make it easier for client code to discover the range of styles that are
    predefined, this is set to the style number of the last predefined style. This is currently set to 39 and the
    last style with an identifier is 38, which reserves space for one future predefined style.

    - *STYLE_MAX*           (255) This is not a style but is the number of the maximum style that can be set. Styles
    between *STYLE_LASTPREDEFINED* and *STYLE_MAX* would be appropriate if you used *SCI_SETSTYLEBITS* to set more
    than 5 style bits.

    For each style you can set the font name, size and use of bold, italic and underline, foreground and background colour and the character set. You can also choose to hide text with a given style, display all characters as upper or lower case and fill from the last character on a line to the end of the line (for embedded languages). There is also an experimental attribute to make text read-only.

    It is entirely up to you how you use styles. If you want to use syntax colouring you might use style 0 for white space, style 1 for numbers, style 2 for keywords, style 3 for strings, style 4 for preprocessor, style 5 for operators, and so on.
*/

; Group: General Style Functions

/*
    Function: StyleResetDefault
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLERESETDEFAULT>

    This message resets STYLE_DEFAULT to its state when Scintilla was initialised.

    Parameters:
    SCI_StyleResetDefault([hwnd])

    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    >SCI_StyleResetDefault(hSci)
*/
SCI_StyleResetDefault(hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLERESETDEFAULT")
}

/*
    Function: StyleClearAll
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLECLEARALL>

    This message sets all styles to have the same attributes as STYLE_DEFAULT.
    If you are setting up Scintilla for syntax coloring, it is likely that the lexical styles you set
    will be very similar. One way to set the styles is to:

    - Set STYLE_DEFAULT to the common features of all styles.
    - Use SCI_STYLECLEARALL to copy this to all styles.
    - Set the style attributes that make your lexical styles different.

    Parameters:
    SCI_StyleClearAll([hwnd])

    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    >SCI_StyleClearAll(hSci)
*/
SCI_StyleClearAll(hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLECLEARALL")
}

; Group: Set Style Functions

/*
    Function: StyleSetFont
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETFONT>

    These functions (plus SCI_StyleSetCharacterset) set the font attributes that are used to match
    the fonts you request to those available. The fName parameter is a zero terminated string holding
    the name of a font. Under Windows, only the first 32 characters of the name are used and
    the name is not case sensitive. For internal caching, Scintilla tracks fonts by name
    and does care about the casing of font names, so please be consistent.

    Parameters:
    SCI_StyleSetFont(stNumber, fName[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to *STYLE_MAX* (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    fName       -   Name of the font to apply.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570

    ; Each component will have its own font
    SCI_StyleSetFont("STYLE_DEFAULT", "Courier New", hSci1)
    SCI_StyleSetFont("STYLE_DEFAULT", "Arial Black", hSci2)
    return
    (End)
*/
SCI_StyleSetFont(stNumber, fName, hwnd=0){

    a_isunicode ? (VarSetCapacity(fNameA, StrPut(fName, "CP0")), StrPut(fName, &fNameA, "CP0"))
    return SCI_sendEditor(hwnd, "SCI_STYLESETFONT", stNumber, a_isunicode ?  &fNameA : &fName)
}

/*
    Function: StyleSetSize
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETSIZE>

    Parameters:
    SCI_StyleSetSize(stNumber, fSize[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to *STYLE_MAX* (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    fSize       -   Size in points of the font to apply.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570

    ; Each component will have its own font size
    SCI_StyleSetSize("STYLE_DEFAULT", 12, hSci1)
    SCI_StyleSetSize("STYLE_DEFAULT", 32, hSci2)
    return
    (End)
*/
SCI_StyleSetSize(stNumber, fSize, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLESETSIZE", stNumber, fSize)
}

/*
    Function: StyleSetBold
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETBOLD>

    Parameters:
    SCI_StyleSetBold(stNumber, bMode[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to *STYLE_MAX* (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    bMode       -   True (1) or False (0).
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570

    ; Each component will have its own bold status
    SCI_StyleSetBold("STYLE_DEFAULT", True, hSci1)
    SCI_StyleSetBold("STYLE_DEFAULT", False, hSci2)
    return
    (End)
*/
SCI_StyleSetBold(stNumber, bMode, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLESETBOLD", stNumber, bMode)
}

/*
    Function: StyleSetItalic
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETITALIC>

    Parameters:
    SCI_StyleSetItalic(stNumber, iMode[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to *STYLE_MAX* (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    iMode       -   True (1) or False (0).
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570

    ; Each component will have its own bold status
    SCI_StyleSetItalic("STYLE_DEFAULT", True, hSci1)
    SCI_StyleSetItalic("STYLE_DEFAULT", False, hSci2)
    return
    (End)
*/
SCI_StyleSetItalic(stNumber, iMode, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLESETITALIC", stNumber, iMode)
}

/*
    Function: StyleSetUnderline
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETUNDERLINE>

    Parameters:
    SCI_StyleSetUnderline(stNumber, uMode[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to *STYLE_MAX* (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    uMode       -   True (1) or False (0).
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    Zero - Nothing is returned by this function.

    Note:
    - If you set the underline option for the *STYLE_DEFAULT* style
    you *have* to call <StyleClearAll()> for the changes to take effect.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570

    ; Each component will have its own underline status
    SCI_StyleSetUnderline("STYLE_DEFAULT", True, hSci1)
    SCI_StyleClearAll() ; the last hwnd is remembered by the wrapper, so no need to put it here.
    SCI_StyleSetUnderline("STYLE_DEFAULT", False, hSci2)
    SCI_StyleClearAll() ; the last hwnd is remembered by the wrapper, so no need to put it here.
    return
    (End)
*/
SCI_StyleSetUnderline(stNumber, uMode, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLESETUNDERLINE", stNumber, uMode)
}

/*
    Function: StyleSetFore
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETFORE>

    Sets the foreground color of the specified style number.

    Parameters:
    SCI_StyleSetFore(stNumber, r, [g, b, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to *STYLE_MAX* (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    r,g,b       -   Colors are set using the RGB format (Red, Green, Blue). The intensity of each color
                    is set in the range 0 to 255.

                -   *Note 1:* If you set all intensities to 255, the color is white.
                    If you set all intensities to 0, the color is black.
                    When you set a color, you are making a request.
                    What you will get depends on the capabilities of the system and the current screen mode.

                -   *Note 2:* If you omit *g* and *b* you can specify the hex value of the color as
                    well as one of the many predefined names available.
                    You can take a look at the available color names with their hex values here:
                    <http://www.w3schools.com/html/html_colornames.asp>.

                -   *Note 3:* the parameter *g* can be used to specify the hwnd of the component you want
                    to control, only if you are using *r* to specify a hex value or a color name.
                    See the examples below for more information.

    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Note:
    - If you change the color of the *STYLE_DEFAULT* style
    you *have* to call <StyleClearAll()> for the changes to take effect.
    This is not true for setting the background color though.


    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    ; This all mean the same
    SCI_StyleSetFore("STYLE_DEFAULT", 0xFF0000, hSci) ; using the parameter g to specify the hwnd.
    SCI_StyleSetFore("STYLE_DEFAULT", "red", hSci)
    SCI_StyleSetFore("STYLE_DEFAULT", 255,0,0, hSci) ; using the last parameter to specify the hwnd.

    ; Remember to always call SCI_StyleClearAll()
    ; if you are setting the foreground color of the STYLE_DEFAULT style
    SCI_StyleClearAll()

    ;---------------------
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570

    SCI_StyleSetFore("STYLE_DEFAULT", 0xFF0000, hSci1)
    SCI_StyleClearAll() ; the last hwnd is remembered by the wrapper, so no need to put it here.
    SCI_StyleSetFore("STYLE_DEFAULT", "blue", hSci2)
    SCI_StyleClearAll() ; the last hwnd is remembered by the wrapper, so no need to put it here.
    return
    (End)
*/
SCI_StyleSetFore(stNumber, r, g=0, b=0, hwnd=0){

    SCI(g) ? (hwnd:=g, g:=0) ; check if g contains a valid component handle
    r && !g && !b ? (r:=SCI_getHex(r)
                    ,g:="0x" SubStr(r,5,2)
                    ,b:="0x" SubStr(r,7,2)
                    ,r:="0x" SubStr(r,3,2) ; has to be modified last since the others depend on it.
                    ,r+=0,g+=0,b+=0)
    return SCI_sendEditor(hwnd, "SCI_STYLESETFORE", stNumber, r | g << 8 | b << 16)
}

/*
    Function: StyleSetBack
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETBACK>

    Sets the Background color of the specified style number.

    Parameters:
    SCI_StyleSetBack(stNumber, r, [g, b, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to *STYLE_MAX* (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    r,g,b       -   Colors are set using the RGB format (Red, Green, Blue). The intensity of each color
                    is set in the range 0 to 255.

                -   *Note 1:* If you set all intensities to 255, the color is white.
                    If you set all intensities to 0, the color is black.
                    When you set a color, you are making a request.
                    What you will get depends on the capabilities of the system and the current screen mode.

                -   *Note 2:* If you omit *g* and *b* you can specify the hex value of the color as
                    well as one of the many predefined names available.
                    You can take a look at the available color names with their hex values here:
                    <http://www.w3schools.com/html/html_colornames.asp>.

                -   *Note 3:* the parameter *g* can be used to specify the hwnd of the component you want
                    to control, only if you are using *r* to specify a hex value or a color name.
                    See the examples below for more information.

    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    ; This all mean the same
    SCI_StyleSetBack("STYLE_DEFAULT", 0xFF0000, hSci) ; using the parameter g to specify the hwnd.
    SCI_StyleSetBack("STYLE_DEFAULT", "red", hSci)
    SCI_StyleSetBack("STYLE_DEFAULT", 255,0,0, hSci) ; using the last parameter to specify the hwnd.

    ;---------------------
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570

    SCI_StyleSetBack("STYLE_DEFAULT", 0xFF0000, hSci1)
    SCI_StyleSetBack("STYLE_DEFAULT", "blue", hSci2)
    return
    (End)
*/
SCI_StyleSetBack(stNumber, r, g=0, b=0, hwnd=0){

    SCI(g) ? (hwnd:=g, g:=0) ; check if g contains a valid component handle
    r && !g && !b ? (r:=SCI_getHex(r)
                    ,g:="0x" SubStr(r,5,2)
                    ,b:="0x" SubStr(r,7,2)
                    ,r:="0x" SubStr(r,3,2) ; has to be modified last since the others depend on it.
                    ,r+=0,g+=0,b+=0)
    return SCI_sendEditor(hwnd, "SCI_STYLESETBACK", stNumber, r | g << 8 | b << 16)
}

/*
    Function: StyleSetEOLFilled
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETEOLFILLED>

    If the last character in the line has a style with this attribute set, the remainder of the line
    up to the right edge of the window is filled with the background color set for the last character.

    Parameters:
    SCI_StyleSetEOLFilled(stNumber, eolMode[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to *STYLE_MAX* (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    eolMode     -   True or False.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    >SCI_StyleSetEOLFilled(STYLE_DEFAULT, 1)
    >SCI_StyleSetEOLFilled(0, false)
*/
SCI_StyleSetEOLFilled(stNumber, eolMode, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLESETEOLFILLED", stNumber, eolMode)
}

/*
    Function: StyleSetCase
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETCASE>

    The value of cMode determines how text is displayed.
    This does not change the stored text, only how it is displayed.

    Parameters:
    SCI_StyleSetCase(stNumber, cMode[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to *STYLE_MAX* (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    cMode       -   We have three case modes available:
                    - *SC_CASE_MIXED* (0) Display normal case.
                    - *SC_CASE_UPPER* (1) Display text in upper case.
                    - *SC_CASE_LOWER* (2) Display text in lower case.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Note:
    - If you set this option for the *STYLE_DEFAULT* style
    you *have* to call <StyleClearAll()> for the changes to take effect.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570

    SCI_StyleSetCase("STYLE_DEFAULT", "SC_CASE_UPPER", hSci1)
    SCI_StyleClearAll() ; the last hwnd is remembered by the wrapper, so no need to put it here.
    SCI_StyleSetCase("STYLE_DEFAULT", "SC_CASE_LOWER", hSci2)
    SCI_StyleClearAll() ; the last hwnd is remembered by the wrapper, so no need to put it here.
    return
    (End)
*/
SCI_StyleSetCase(stNumber, cMode, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLESETCASE", stNumber, cMode)
}

/*
    Function: StyleSetVisible
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETVISIBLE>

    Text is normally visible. However, you can completely hide it by giving it a style with the visible set to 0.
    This could be used to hide embedded formatting instructions or hypertext keywords in HTML or XML.

    Parameters:
    SCI_StyleSetVisible(stNumber, vMode[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to *STYLE_MAX* (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    vMode       -   True (1) or False (0).
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Note:
    - If you set this option for the *STYLE_DEFAULT* style
    you *have* to call <StyleClearAll()> for the changes to take effect.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570

    SCI_StyleSetVisible("STYLE_DEFAULT", True, hSci1)
    SCI_StyleClearAll() ; the last hwnd is remembered by the wrapper, so no need to put it here.
    SCI_StyleSetVisible("STYLE_DEFAULT", False, hSci2)
    SCI_StyleClearAll() ; the last hwnd is remembered by the wrapper, so no need to put it here.
    return
    (End)
*/
SCI_StyleSetVisible(stNumber, vMode, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLESETVISIBLE", stNumber, vMode)
}

/*
    Function: StyleSetChangeable
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETCHANGEABLE>

    This is an experimental and incompletely implemented style attribute.
    The default setting is changeable set true but when set false it makes text read-only.

    You can type text on a control that has this mode set to false but after the text is written
    it cannot be modified.

    This option also stops the caret from being within not-changeable text but does not prevent
    you from selecting non-changeable text by double clicking it or dragging the mouse.


    Parameters:
    SCI_StyleSetChangeable(stNumber, cMode[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to *STYLE_MAX* (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    cMode       -   True (1) or False (0).
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Note:
    - If you set this option for the *STYLE_DEFAULT* style
    you *have* to call <StyleClearAll()> for the changes to take effect.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570

    SCI_StyleSetChangeable("STYLE_DEFAULT", True, hSci1)
    SCI_StyleClearAll() ; the last hwnd is remembered by the wrapper, so no need to put it here.
    SCI_StyleSetChangeable("STYLE_DEFAULT", False, hSci2)
    SCI_StyleClearAll() ; the last hwnd is remembered by the wrapper, so no need to put it here.
    return
    (End)
*/
SCI_StyleSetChangeable(stNumber, cMode, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLESETCHANGEABLE", stNumber, cMode)
}

/*
    Function: StyleSetHotspot
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETHOTSPOT>

    Marks ranges of text that can detect mouse clicks.
    The default values are that the cursor changes to a hand over hotspots
    and an underline appear to indicate that the text is sensitive to clicking.
    This may be used to allow hyperlinks to other documents.

    Other options may be changed with the following functions:
    - <SetHotSpotActiveFore()>
    - <SetHotSpotActiveBack()>
    - <SetHotSpotActiveUnderline()>
    - <SetHotSpotSingleLine()>

    Parameters:
    SCI_StyleSetHotspot(stNumber, hMode[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to *STYLE_MAX* (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    hMode       -   True (1) or False (0).
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300

    SCI_StyleSetHotspot("STYLE_DEFAULT", True, hSci1)
    SCI_StyleClearAll()
    return
    (End)
*/
SCI_StyleSetHotspot(stNumber, hMode, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLESETHOTSPOT", stNumber, hMode)
}

; Group: Get Style Functions

/*
    Function: StyleGetFont
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETFONT>

    Parameters:
    SCI_StyleGetFont(stNumber[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to STYLE_MAX (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition.>
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    fName       -   Name of the font applied to that style number.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570

    SCI_StyleSetFont("STYLE_DEFAULT", "Arial", hSci1)
    SCI_StyleSetFont("STYLE_DEFAULT", "Courier New", hSci2)
    msgbox % "Component 1: " SCI_StyleGetFont("STYLE_DEFAULT", hSci1)
    msgbox % "Component 2: " SCI_StyleGetFont("STYLE_DEFAULT", hSci2)
    return
    (End)
*/
SCI_StyleGetFont(stNumber, hwnd=0){

    VarSetCapacity(fName,32), SCI_sendEditor(hwnd, "SCI_STYLEGETFONT", stNumber, &fName)
    return StrGet(&fName, "cp0")
}

/*
    Function: StyleGetSize
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETSIZE>

    Parameters:
    SCI_StyleGetSize(stNumber[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to STYLE_MAX (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    fSize       -   Size in points of the font applied to that style number.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570

    SCI_StyleSetSize("STYLE_DEFAULT", 10, hSci1)
    SCI_StyleSetSize("STYLE_DEFAULT", 25, hSci2)
    msgbox % "Component 1: " SCI_StyleGetSize("STYLE_DEFAULT", hSci1)
    msgbox % "Component 2: " SCI_StyleGetSize("STYLE_DEFAULT", hSci2)
    return
    (End)
*/
SCI_StyleGetSize(stNumber, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLEGETSIZE", stNumber)
}

/*
    Function: StyleGetBold
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETBOLD>

    Parameters:
    SCI_StyleSetBold(stNumber[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to STYLE_MAX (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    bMode       -   True or False.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300
    SCI_StyleSetBold("STYLE_DEFAULT", 1, hSci1)
    msgbox % SCI_StyleGetBold("STYLE_DEFAULT")
    return
    (End)
*/
SCI_StyleGetBold(stNumber, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLEGETBOLD", stNumber)
}

/*
    Function: StyleGetItalic
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETITALIC>

    Parameters:
    SCI_StyleGetItalic(stNumber[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to STYLE_MAX (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    iMode       -   True or False.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300
    SCI_StyleSetItalic("STYLE_DEFAULT", 1, hSci1)
    msgbox % SCI_StyleGetItalic("STYLE_DEFAULT")
    return
    (End)
*/
SCI_StyleGetItalic(stNumber, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLEGETITALIC", stNumber)
}

/*
    Function: StyleGetUnderline
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETUNDERLINE>

    Parameters:
    SCI_StyleGetUnderline(stNumber[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to STYLE_MAX (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    uMode       -   True or False.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300
    SCI_StyleSetUnderline("STYLE_DEFAULT", 1, hSci1)
    SCI_StyleClearAll()
    msgbox % SCI_StyleGetUnderline("STYLE_DEFAULT")
    return
    (End)
*/
SCI_StyleGetUnderline(stNumber, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLEGETUNDERLINE", stNumber)
}

/*
    Function: StyleGetFore
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETFORE>

    Gets the RGB value stored in the specified style number. 0 if none has been set.

    Parameters:
    SCI_StyleGetFore(stNumber[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to STYLE_MAX (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    RGB         -   RGB value in the format (red | green << 8 | blue << 16) of the queried style number.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300
    SCI_StyleSetFore("STYLE_DEFAULT", "darkblue", hSci1)
    SCI_StyleClearAll()
    msgbox % SCI_StyleGetFore("STYLE_DEFAULT", hSci1)
    return
    (End)
*/
SCI_StyleGetFore(stNumber, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLEGETFORE", stNumber)
}

/*
    Function: StyleGetBack
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETFORE>

    Gets the RGB value stored in the specified style number. 0 if none has been set.

    Parameters:
    SCI_StyleGetBack(stNumber[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to STYLE_MAX (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    RGB         -   RGB value in the format (red | green << 8 | blue << 16) of the queried style number.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300
    SCI_StyleSetBack("STYLE_DEFAULT", "blue", hSci1)
    msgbox % SCI_StyleGetBack("STYLE_DEFAULT", hSci1)
    return
    (End)
*/
SCI_StyleGetBack(stNumber, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLEGETBACK", stNumber)
}

/*
    Function: StyleGetEOLFilled
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETEOLFILLED>

    Parameters:
    SCI_StyleGetEOLFilled(stNumber[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to STYLE_MAX (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    eolMode     -   True or False

    Examples:
    (Start Code)
    ; there is no notizable effect due to the default background being white.
    ; if you try this on a style other than the default (making sure the other style has a different
    ; background color than the default style) you should be able to see the effect. But you can
    ; see that the option has been set correctly.
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300
    SCI_StyleSetEOLFilled("STYLE_DEFAULT", True, hSci1)
    msgbox % SCI_StyleGetEOLFilled("STYLE_DEFAULT", hSci1)
    return
    (End)
*/
SCI_StyleGetEOLFilled(stNumber, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLEGETEOLFILLED", stNumber)
}

/*
    Function: StyleGetCase
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETCASE>

    Gets the case mode currently set to the queried style number.

    Parameters:
    SCI_StyleGetCase(stNumber[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to STYLE_MAX (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.
    Returns:
    cMode       -   Current case mode of the selected style. The modes can be:
                    - *SC_CASE_MIXED* (0) Display normal case.
                    - *SC_CASE_UPPER* (1) Display text in upper case.
                    - *SC_CASE_LOWER* (2) Display text in lower case.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300
    SCI_StyleSetCase("STYLE_DEFAULT", "SC_CASE_UPPER", hSci1)
    SCI_StyleClearAll()
    msgbox % SCI_StyleGetCase("STYLE_DEFAULT", hSci1)
    return
    (End)
*/
SCI_StyleGetCase(stNumber, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLEGETCASE", stNumber)
}

/*
    Function: StyleGetVisible
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETVISIBLE>

    Gets the visibility mode curently assigned to the queried style number.

    Parameters:
    SCI_StyleGetVisible(stNumber[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to STYLE_MAX (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.
    Returns:
    vMode       -   True or False.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300
    SCI_StyleSetVisible("STYLE_DEFAULT", False, hSci1)
    SCI_StyleClearAll()
    msgbox % SCI_StyleGetVisible("STYLE_DEFAULT", hSci1)
    return
    (End)
*/
SCI_StyleGetVisible(stNumber, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLEGETVISIBLE", stNumber)
}

/*
    Function: StyleGetChangeable
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETCHANGEABLE>

    Gets the status of the queried style number. Returns false if is read only else it returns true.

    Parameters:
    SCI_StyleGetChangeable(stNumber[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to STYLE_MAX (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    cMode       -   True or False.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300
    SCI_StyleSetChangeable("STYLE_DEFAULT", False, hSci1)
    SCI_StyleClearAll()
    msgbox % SCI_StyleGetChangeable("STYLE_DEFAULT", hSci1)
    return
    (End)
*/
SCI_StyleGetChangeable(stNumber, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLEGETCHANGEABLE", stNumber)
}

/*
    Function: StyleGetHotspot
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETHOTSPOT>

    Gets the status of the queried style number and returns true if the style has the HOTSPOT style set to it
    and false if not.

    Parameters:
    SCI_StyleGetHotspot(stNumber[, hwnd])

    stNumber    -   Style Number on which to operate.
                    There are 256 lexer styles that can be set, numbered 0 to STYLE_MAX (255)
                    See: <http://www.scintilla.org/ScintillaDoc.html#StyleDefinition>.
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    hMode       -   True or False.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300
    SCI_StyleSetHotspot("STYLE_DEFAULT", True, hSci1)
    SCI_StyleClearAll()
    msgbox % SCI_StyleGetHotspot("STYLE_DEFAULT", hSci1)
    return
    (End)
*/
SCI_StyleGetHotspot(stNumber, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLEGETHOTSPOT", stNumber)
}

/*  Group: Margins
    <http://www.scintilla.org/ScintillaDoc.html#Margins>

    There may be up to five margins to the left of the text display, plus a gap either side of the text. Each
    margin can be set to display either symbols or line numbers with <SetMarginTypeN()>. The markers that can be
    displayed in each margin are set with <SetMarginMaskN()>. Any markers not associated with a visible margin will
    be displayed as changes in background colour in the text. A width in pixels can be set for each margin. Margins
    with a zero width are ignored completely. You can choose if a mouse click in a margin sends a *SCN_MARGINCLICK*
    notification to the container or selects a line of text.

    The margins are numbered 0 to 4. Using a margin number outside the valid range has no effect. By default,
    margin 0 is set to display line numbers, but is given a width of 0, so it is hidden. Margin 1 is set to display
    non-folding symbols and is given a width of 16 pixels, so it is visible. Margin 2 is set to display the folding
    symbols, but is given a width of 0, so it is hidden. Of course, you can set the margins to be whatever you wish.

    Styled text margins used to show revision and blame information:

    (see styledmargin.png)
*/

; Group: Margins [Set]

/*
    Function: SetMarginWidthN
    <http://www.scintilla.org/ScintillaDoc.html#SCI_SETMARGINWIDTHN>

    These routines set and get the width of a margin in pixels. A margin with zero width is invisible.
    By default, Scintilla sets margin 1 for symbols with a width of 16 pixels,
    so this is a reasonable guess if you are not sure what would be appropriate.
    Line number margins widths should take into account the number of lines in the document and
    the line number style. You could use something like SCI_TextWidth("STYLE_LINENUMBER", "_99999")
    to get a suitable width.

    Parameters:
    SCI_SetMarginWidthN(mar, px[, hwnd])

    mar     -   Numeric value for the margin you wish to modify (0-4).
    px      -   Size of the margin in pixels.
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570
    SCI_SetMarginWidthN(0, 40, hSci1)
    SCI_SetMarginWidthN(1, 10)
    SCI_SetMarginWidthN(1, 5, hSci2)
    return
    (End)
*/
SCI_SetMarginWidthN(mar, px, hwnd=0){

    return SCI_SendEditor(hwnd, "SCI_SETMARGINWIDTHN", mar, px)
}

; Group: Margins [Get]

/*
    Function: GetMarginWidthN
    <http://www.scintilla.org/ScintillaDoc.html#SCI_GETMARGINWIDTHN>

    This is the routine that retrieves the width in pixels of the margin queried.

    Parameters:
    SCI_GetMarginWidthN(mar[, hwnd])

    mar     -   Numeric value for the margin you wish to query (0-4).
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    wMargin - Width in pixles of the selected margin.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300
    SCI_SetMarginWidthN(0, 25, hSci1)
    msgbox % SCI_GetMarginWidthN(0)
    return
    (End)
*/
SCI_GetMarginWidthN(mar, hwnd=0){

    return SCI_SendEditor(hwnd, "SCI_GETMARGINWIDTHN", mar)
}

/*  Group: Line Wrapping
    <http://www.scintilla.org/ScintillaDoc.html#LineWrapping>

    By default, Scintilla does not wrap lines of text. If you enable line wrapping, lines wider than the window
    width are continued on the following lines. Lines are broken after space or tab characters or between runs of
    different styles. If this is not possible because a word in one style is wider than the window then the break
    occurs after the last character that completely fits on the line. The horizontal scroll bar does not appear
    when wrap mode is on.

    For wrapped lines Scintilla can draw visual flags (little arrows) at end of a a subline of a wrapped line and
    at begin of the next subline. These can be enabled individually, but if Scintilla draws the visual flag at the
    beginning of the next subline this subline will be indented by one char. Independent from drawing a visual flag
    at the begin the subline can have an indention.

    Much of the time used by Scintilla is spent on laying out and drawing text. The same text layout calculations
    may be performed many times even when the data used in these calculations does not change. To avoid these
    unnecessary calculations in some circumstances, the line layout cache can store the results of the
    calculations. The cache is invalidated whenever the underlying data, such as the contents or styling of the
    document changes. Caching the layout of the whole document has the most effect, making dynamic line wrap as
    much as 20 times faster but this requires 7 times the memory required by the document contents plus around 80
    bytes per line.

    Wrapping is not performed immediately there is a change but is delayed until the display is redrawn. This delay
    improves peformance by allowing a set of changes to be performed and then wrapped and displayed once. Because
    of this, some operations may not occur as expected. If a file is read and the scroll position moved to a
    particular line in the text, such as occurs when a container tries to restore a previous editing session, then
    the scroll position will have been determined before wrapping so an unexpected range of text will be displayed.
    To scroll to the position correctly, delay the scroll until the wrapping has been performed by waiting for an
    initial *SCN_PAINTED* notification.
*/

; Group: Line Wrapping [Set]

/*
    Function: SetWrapMode
    <http://www.scintilla.org/ScintillaDoc.html#SCI_SETWRAPMODE>

    Enables, disables or changes the wrap mode for the Scintilla component.

    Parameters:
    SCI_SetWrapMode([wMode, hwnd])

    wMode   -   Numeric value for the mode (Default 1). The Available modes are:
                - *SC_WRAP_NONE* (0) to disable wrapping
                - *SC_WRAP_WORD* (1) to enable wrapping on word boundaries.
                - *SC_WRAP_CHAR* (2) to enable wrapping between any characters.
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570
    SCI_SetWrapMode(True, hSci1)
    SCI_SetWrapMode("SC_WRAP_CHAR", hSci2)
    return
    (End)
*/
SCI_SetWrapMode(wMode=1, hwnd=0){

    return SCI_SendEditor(hwnd, "SCI_SETWRAPMODE", wMode)
}

; Group: Line Wrapping [Get]

/*
    Function: GetWrapMode
    <http://www.scintilla.org/ScintillaDoc.html#SCI_GETWRAPMODE>

    Get the current state of the wrap mode for the Scintilla component.

    Parameters:
    SCI_SetWrapMode([hwnd])

    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    wMode   -   Numeric value of the current mode. The Available modes are:
                - *SC_WRAP_NONE* (0) wrapping disabled.
                - *SC_WRAP_WORD* (1) wrapping on word boundaries enabled.
                - *SC_WRAP_CHAR* (2) wrapping between any characters enabled.

    Examples:
    (Start Code)
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    hSci2:=SCI_Add(hwnd, x, 290, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h570
    SCI_SetWrapMode(True, hSci1)
    SCI_SetWrapMode("SC_WRAP_CHAR", hSci2)
    msgbox % SCI_GetWrapMode(hSci1)
    msgbox % SCI_GetWrapMode(hSci2)
    return
    (End)
*/
SCI_GetWrapMode(hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_GETWRAPMODE")
}

/* Group: Lexer
    <http://www.scintilla.org/ScintillaDoc.html#Lexer>

    If you define the symbol *SCI_LEXER* when building Scintilla, (this is sometimes called the SciLexer version of
    Scintilla), lexing support for a wide range of programming languages is included and the messages in this
    section are supported. If you want to set styling and fold points for an unsupported language you can either do
    this in the container or better still, write your own lexer following the pattern of one of the existing ones.

    Scintilla also supports external lexers. These are DLLs (on Windows) or .so modules (on GTK+/Linux) that export
    three functions: GetLexerCount, GetLexerName, and GetLexerFactory. See externalLexer.cxx for more.
*/

; Group: General Lexer Functions

 /* needs work
    ; Function: LoadLexerLibrary
    ; <http://www.scintilla.org/ScintillaDoc.html#SCI_LOADLEXERLIBRARY>

    ; Load a lexer implemented in a shared library. This is a .so file on GTK+/Linux or a .DLL file on Windows.

    ; Parameters:
    ; SCI_LoadLexerLibrary(lPath[, hwnd])

    ; lPath   -   Path to the dll lexer to be loaded.
    ; hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                ; Scintilla components in the same script. The wrapper will remember the last used hwnd,
                ; so you can specify it once and only specify it again when you want to operate on a different
                ; component.

    ; Returns:
    ; Zero - Nothing is returned by this function.

    ; Examples:
    ; >SCI_LoadLexerLibrary("c:\program files\dll\mylexer.dll")
    ; >SCI_LoadLexerLibrary(a_desktop "\mylexer.dll")

; 
; SCI_LoadLexerLibrary(lPath, hwnd=0){

    ; a_isunicode ? (VarSetCapacity(lPathA, StrPut(lPath, "CP0")), StrPut(lPath, &lPathA, "CP0"))
    ; return SCI_SendEditor(hwnd, "SCI_LOADLEXERLIBRARY", 0, a_isunicode ? &lPathA : &lPath)
; }
*/
/* not tested
    ; Function: Colorise
    ; <http://www.scintilla.org/ScintillaDoc.html#SCI_COLOURISE>

    ; This requests the current lexer or the container (if the lexer is set to *SCLEX_CONTAINER*)
    ; to style the document between stPos and endPos. If endPos is -1, the document is styled from
    ; stPos to the end.

    ; Parameters:
    ; SCI_Colorise(stPos, endPos[, hwnd])

    ; stPos   -   Starting position where to begin colorizing.
    ; endPos  -   End position.
    ; hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                ; Scintilla components in the same script. The wrapper will remember the last used hwnd,
                ; so you can specify it once and only specify it again when you want to operate on a different
                ; component.

    ; Returns:
    ; Zero - Nothing is returned by this function.

    ; Examples:
    ; >SCI_Colorise(0,-1)
; 
; SCI_Colorise(stPos, endPos, hwnd=0){

    ; return SCI_SendEditor(hwnd, "SCI_COLORISE", stPos, endPos)
; }

*/
/* not tested
    ; Function: ChangeLexerState
    ; <http://www.scintilla.org/ScintillaDoc.html#SCI_CHANGELEXERSTATE>

    ; Indicate that the internal state of a lexer has changed over a range and therefore there may be
    ; a need to redraw.

    ; Parameters:
    ; SCI_ChangeLexerState(stPos, endPos[, hwnd])

    ; stPos   -   Starting position where to begin colorizing.
    ; endPos  -   End position.
    ; hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                ; Scintilla components in the same script. The wrapper will remember the last used hwnd,
                ; so you can specify it once and only specify it again when you want to operate on a different
                ; component.

    ; Returns:
    ; Zero - Nothing is returned by this function.

    ; Examples:
    ; >SCI_ChangeLexerState(5,10)
; 
; SCI_ChangeLexerState(stPos, endPos, hwnd=0){

    ; return SCI_SendEditor(hwnd, "SCI_CHANGELEXERSTATE", stPos, endPos)
; }
*/

; Group: Lexer [Set]

/*
    Function: SetLexer
    <http://www.scintilla.org/ScintillaDoc.html#SCI_SETLEXER>

    You can select the lexer to use with an integer code from the SCLEX_* enumeration in Scintilla.h.
    There are two codes in this sequence that do not use lexers: *SCLEX_NULL* to select no lexing action and
    *SCLEX_CONTAINER* which sends the *SCN_STYLENEEDED* notification to the container whenever a range of text
    needs to be styled.
    You cannot use the *SCLEX_AUTOMATIC* value; this identifies additional external lexers that Scintilla assigns
    unused lexer numbers to.

    Parameters:
    SCI_SetLexer(lNumber[, hwnd])

    lNumber     -   The number of the lexer that you want to use (if you are loading SciLexer.dll) which can be
                    a number between *SCLEX_CONTAINER* (0) and SCLEX_BLITZMAX (78) the available lexers are:
                    - SCLEX_CONTAINER (0)
                    - SCLEX_NULL (1)
                    - SCLEX_PYTHON (2)
                    - SCLEX_CPP (3)
                    - SCLEX_HTML (4)
                    - SCLEX_XML (5)
                    - SCLEX_PERL (6)
                    - SCLEX_SQL (7)
                    - SCLEX_VB (8)
                    - SCLEX_PROPERTIES (9)
                    - SCLEX_ERRORLIST (10)
                    - SCLEX_MAKEFILE (11)
                    - SCLEX_BATCH (12)
                    - SCLEX_XCODE (13)
                    - SCLEX_LATEX (14)
                    - SCLEX_LUA (15)
                    - SCLEX_DIFF (16)
                    - SCLEX_CONF (17)
                    - SCLEX_PASCAL (18)
                    - SCLEX_AVE (19)
                    - SCLEX_ADA (20)
                    - SCLEX_LISP (21)
                    - SCLEX_RUBY (22)
                    - SCLEX_EIFFEL (23)
                    - SCLEX_EIFFELKW (24)
                    - SCLEX_TCL (25)
                    - SCLEX_NNCRONTAB (26)
                    - SCLEX_BULLANT (27)
                    - SCLEX_VBSCRIPT (28)
                    - SCLEX_BAAN (31)
                    - SCLEX_MATLAB (32)
                    - SCLEX_SCRIPTOL (33)
                    - SCLEX_ASM (34)
                    - SCLEX_CPPNOCASE (35)
                    - SCLEX_FORTRAN (36)
                    - SCLEX_F77 (37)
                    - SCLEX_CSS (38)
                    - SCLEX_POV (39)
                    - SCLEX_LOUT (40)
                    - SCLEX_ESCRIPT (41)
                    - SCLEX_PS (42)
                    - SCLEX_NSIS (43)
                    - SCLEX_MMIXAL (44)
                    - SCLEX_CLW (45)
                    - SCLEX_CLWNOCASE (46)
                    - SCLEX_LOT (47)
                    - SCLEX_YAML (48)
                    - SCLEX_TEX (49)
                    - SCLEX_METAPOST (50)
                    - SCLEX_POWERBASIC (51)
                    - SCLEX_FORTH (52)
                    - SCLEX_ERLANG (53)
                    - SCLEX_OCTAVE (54)
                    - SCLEX_MSSQL (55)
                    - SCLEX_VERILOG (56)
                    - SCLEX_KIX (57)
                    - SCLEX_GUI4CLI (58)
                    - SCLEX_SPECMAN (59)
                    - SCLEX_AU3 (60)
                    - SCLEX_APDL (61)
                    - SCLEX_BASH (62)
                    - SCLEX_ASN1 (63)
                    - SCLEX_VHDL (64)
                    - SCLEX_CAML (65)
                    - SCLEX_BLITZBASIC (66)
                    - SCLEX_PUREBASIC (67)
                    - SCLEX_HASKELL (68)
                    - SCLEX_PHPSCRIPT (69)
                    - SCLEX_TADS3 (70)
                    - SCLEX_REBOL (71)
                    - SCLEX_SMALLTALK (72)
                    - SCLEX_FLAGSHIP (73)
                    - SCLEX_CSOUND (74)
                    - SCLEX_FREEBASIC (75)
                    - SCLEX_INNOSETUP (76)
                    - SCLEX_OPAL (77)
                    - SCLEX_BLITZMAX (78)
    hwnd        -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                    Scintilla components in the same script. The wrapper will remember the last used hwnd,
                    so you can specify it once and only specify it again when you want to operate on a different
                    component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    ; The scintilla component will colorize any of the keywords below as blue and bold, using the
    ; internal C++ Lexer.
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300
    SCI_SetWrapMode(True, hSci1)
    SCI_SetLexer("SCLEX_CPP")
    SCI_StyleClearAll()

    SCI_SetKeywords(0, "if else switch case default break goto return for while do continue typedef sizeof NULL new delete throw try catch namespace operator this const_cast static_cast dynamic_cast reinterpret_cast true false using typeid and and_eq bitand bitor compl not not_eq or or_eq xor xor_eq")

    SCI_StyleSetFore(5, "blue")
    SCI_StyleSetBold(5, True)
    return
    (End)
*/
SCI_SetLexer(lNumber, hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_SETLEXER", lNumber)
}

/*
    Function: SetKeywords
    <http://www.scintilla.org/ScintillaDoc.html#SCI_SETKEYWORDS>

    Parameters:
    SCI_SetKeywords(kSet, kList[, hwnd])

    kSet    -   kSet can be 0 to 8 (actually 0 to KEYWORDSET_MAX) and selects which keyword list to replace.
    kList   -   is a list of keywords separated by spaces, tabs, "\n" or "\r" or any combination of these.
                It is expected that the keywords will be composed of standard ASCII printing characters,
                but there is nothing to stop you using any non-separator character codes from 1 to 255
                (except common sense).
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    (Start Code)
    ; The scintilla component will colorize any of the keywords below as blue and bold, using the
    ; internal C++ Lexer.
    #include ../SCI.ahk

    Gui +LastFound
    hwnd:=WinExist()
    hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
    Gui, show, w400 h300
    SCI_SetWrapMode(True, hSci1)
    SCI_SetLexer("SCLEX_CPP")
    SCI_StyleClearAll()

    SCI_SetKeywords(0, "if else switch case default break goto return for while do continue typedef sizeof NULL new delete throw try catch namespace operator this const_cast static_cast dynamic_cast reinterpret_cast true false using typeid and and_eq bitand bitor compl not not_eq or or_eq xor xor_eq")

    SCI_StyleSetFore(5, "blue")
    SCI_StyleSetBold(5, True)
    return
    (End)
*/
SCI_SetKeywords(kSet, kList, hwnd=0){

    a_isunicode ? (VarSetCapacity(kListA, StrPut(kList, "CP0")), StrPut(kList, &kListA, "CP0"))
    return SCI_SendEditor(hwnd, "SCI_SETKEYWORDS", kSet, a_isunicode ? &kListA : &kList)
}

; Group: Lexer [Get]

                               ; ---- [ INTERNAL FUNCTIONS ] ----- ;

SCI(var, val=""){
    static
    SCN_STYLENEEDED                   := 2000
    SCN_CHARADDED                     := 2001
    SCN_SAVEPOINTREACHED              := 2002
    SCN_SAVEPOINTLEFT                 := 2003
    SCN_MODIFYATTEMPTRO               := 2004
    SCN_KEY                           := 2005
    SCN_DOUBLECLICK                   := 2006
    SCN_UPDATEUI                      := 2007
    SCN_MODIFIED                      := 2008
    SCN_MACRORECORD                   := 2009
    SCN_MARGINCLICK                   := 2010
    SCN_NEEDSHOWN                     := 2011
    SCN_PAINTED                       := 2013
    SCN_USERLISTSELECTION             := 2014
    SCN_URIDROPPED                    := 2015
    SCN_DWELLSTART                    := 2016
    SCN_DWELLEND                      := 2017
    SCN_ZOOM                          := 2018
    SCN_HOTSPOTCLICK                  := 2019
    SCN_HOTSPOTDOUBLECLICK            := 2020
    SCN_CALLTIPCLICK                  := 2021
    SCN_AUTOCSELECTION                := 2022

	lvar := %var%, val != "" ? %var% := val
    return lvar
}
/*
    Function : sendEditor
    Posts the messages used to modify the control's behaviour.

    Parameters:
    SCI_sendEditor(hwnd, msg, [wParam, lParam])

    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.
    msg     -   The message to be posted, full list can be found here:
                <http://www.scintilla.org/ScintillaDoc.html>
    wParam  -   wParam for the message
    lParam  -   lParam for the message

    Returns:
    Status code of the DllCall performed.

    Examples:
    (Start Code)
    SCI_sendEditor(hSci1, "SCI_SETMARGINWIDTHN",0,40)  ; Set the margin 0 to 40px on the first component.
    SCI_sendEditor(0, "SCI_SETWRAPMODE",1,0)           ; Set wrap mode to True on the last used component.
    SCI_sendEditor(hSci2, "SCI_SETMARGINWIDTHN",0,50)  ; Set the margin 0 to 50px on the second component.
    (End)
*/
SCI_sendEditor(hwnd, msg=0, wParam=0, lParam=0){
    static

    hwnd := !hwnd ? oldhwnd : hwnd, oldhwnd := hwnd
    if !init
    {
        INVALID_POSITION:=-1,SCI_START:=2000,SCI_OPTIONAL_START:=3000,SCI_LEXER_START:=4000,SCI_ADDTEXT:=2001
        SCI_ADDSTYLEDTEXT:=2002,SCI_INSERTTEXT:=2003,SCI_CLEARALL:=2004,SCI_CLEARDOCUMENTSTYLE:=2005
        SCI_GETLENGTH:=2006,SCI_GETCHARAT:=2007,SCI_GETCURRENTPOS:=2008,SCI_GETANCHOR:=2009,SCI_GETSTYLEAT:=2010
        SCI_REDO:=2011,SCI_SETUNDOCOLLECTION:=2012,SCI_SELECTALL:=2013,SCI_SETSAVEPOINT:=2014
        SCI_GETSTYLEDTEXT:=2015,SCI_CANREDO:=2016,SCI_MARKERLINEFROMHANDLE:=2017,SCI_MARKERDELETEHANDLE:=2018
        SCI_GETUNDOCOLLECTION:=2019,SCWS_INVISIBLE:=0,SCWS_VISIBLEALWAYS:=1,SCWS_VISIBLEAFTERINDENT:=2
        SCI_GETVIEWWS:=2020,SCI_SETVIEWWS:=2021,SCI_POSITIONFROMPOINT:=2022,SCI_POSITIONFROMPOINTCLOSE:=2023
        SCI_GOTOLINE:=2024,SCI_GOTOPOS:=2025,SCI_SETANCHOR:=2026,SCI_GETCURLINE:=2027,SCI_GETENDSTYLED:=2028
        SC_EOL_CRLF:=0,SC_EOL_CR:=1,SC_EOL_LF:=2,SCI_CONVERTEOLS:=2029,SCI_GETEOLMODE:=2030,SCI_SETEOLMODE:=2031
        SCI_STARTSTYLING:=2032,SCI_SETSTYLING:=2033,SCI_GETBUFFEREDDRAW:=2034,SCI_SETBUFFEREDDRAW:=2035
        SCI_SETTABWIDTH:=2036,SCI_GETTABWIDTH:=2121,SC_CP_UTF8:=65001,SC_CP_DBCS:=1,SCI_SETCODEPAGE:=2037
        SCI_SETUSEPALETTE:=2039,MARKER_MAX:=31,SC_MARK_CIRCLE:=0,SC_MARK_ROUNDRECT:=1,SC_MARK_ARROW:=2
        SC_MARK_SMALLRECT:=3,SC_MARK_SHORTARROW:=4,SC_MARK_EMPTY:=5,SC_MARK_ARROWDOWN:=6,SC_MARK_MINUS:=7
        SC_MARK_PLUS:=8,SC_MARK_VLINE:=9,SC_MARK_LCORNER:=10,SC_MARK_TCORNER:=11,SC_MARK_BOXPLUS:=12
        SC_MARK_BOXPLUSCONNECTED:=13,SC_MARK_BOXMINUS:=14,SC_MARK_BOXMINUSCONNECTED:=15,SC_MARK_LCORNERCURVE:=16
        SC_MARK_TCORNERCURVE:=17,SC_MARK_CIRCLEPLUS:=18,SC_MARK_CIRCLEPLUSCONNECTED:=19,SC_MARK_CIRCLEMINUS:=20
        SC_MARK_CIRCLEMINUSCONNECTED:=21,SC_MARK_BACKGROUND:=22,SC_MARK_DOTDOTDOT:=23,SC_MARK_ARROWS:=24
        SC_MARK_PIXMAP:=25,SC_MARK_FULLRECT:=26,SC_MARK_CHARACTER:=10000,SC_MARKNUM_FOLDEREND:=25
        SC_MARKNUM_FOLDEROPENMID:=26,SC_MARKNUM_FOLDERMIDTAIL:=27,SC_MARKNUM_FOLDERTAIL:=28
        SC_MARKNUM_FOLDERSUB:=29,SC_MARKNUM_FOLDER:=30,SC_MARKNUM_FOLDEROPEN:=31,SC_MASK_FOLDERS:=0xFE000000
        SCI_MARKERDEFINE:=2040,SCI_MARKERSETFORE:=2041,SCI_MARKERSETBACK:=2042,SCI_MARKERADD:=2043
        SCI_MARKERDELETE:=2044,SCI_MARKERDELETEALL:=2045,SCI_MARKERGET:=2046,SCI_MARKERNEXT:=2047
        SCI_MARKERPREVIOUS:=2048,SCI_MARKERDEFINEPIXMAP:=2049,SCI_MARKERADDSET:=2466,SCI_MARKERSETALPHA:=2476
        SC_MARGIN_SYMBOL:=0,SC_MARGIN_NUMBER:=1,SCI_SETMARGINTYPEN:=2240,SCI_GETMARGINTYPEN:=2241
        SCI_SETMARGINWIDTHN:=2242,SCI_GETMARGINWIDTHN:=2243,SCI_SETMARGINMASKN:=2244,SCI_GETMARGINMASKN:=2245
        SCI_SETMARGINSENSITIVEN:=2246,SCI_GETMARGINSENSITIVEN:=2247,STYLE_DEFAULT:=32,STYLE_LINENUMBER:=33
        STYLE_BRACELIGHT:=34,STYLE_BRACEBAD:=35,STYLE_CONTROLCHAR:=36,STYLE_INDENTGUIDE:=37,STYLE_CALLTIP:=38
        STYLE_LASTPREDEFINED:=39,STYLE_MAX:=127,SC_CHARSET_ANSI:=0,SC_CHARSET_DEFAULT:=1,SC_CHARSET_BALTIC:=186
        SC_CHARSET_CHINESEBIG5:=136,SC_CHARSET_EASTEUROPE:=238,SC_CHARSET_GB2312:=134,SC_CHARSET_GREEK:=161
        SC_CHARSET_HANGUL:=129,SC_CHARSET_MAC:=77,SC_CHARSET_OEM:=255,SC_CHARSET_RUSSIAN:=204
        SC_CHARSET_CYRILLIC:=1251,SC_CHARSET_SHIFTJIS:=128,SC_CHARSET_SYMBOL:=2,SC_CHARSET_TURKISH:=162
        SC_CHARSET_JOHAB:=130,SC_CHARSET_HEBREW:=177,SC_CHARSET_ARABIC:=178,SC_CHARSET_VIETNAMESE:=163
        SC_CHARSET_THAI:=222,SC_CHARSET_8859_15:=1000,SCI_STYLECLEARALL:=2050,SCI_STYLESETFORE:=2051
        SCI_STYLESETBACK:=2052,SCI_STYLESETBOLD:=2053,SCI_STYLESETITALIC:=2054,SCI_STYLESETSIZE:=2055
        SCI_STYLESETFONT:=2056,SCI_STYLESETEOLFILLED:=2057,SCI_STYLEGETFORE:=2481,SCI_STYLEGETBACK:=2482
        SCI_STYLEGETBOLD:=2483,SCI_STYLEGETITALIC:=2484,SCI_STYLEGETSIZE:=2485,SCI_STYLEGETFONT:=2486
        SCI_STYLEGETEOLFILLED:=2487,SCI_STYLEGETUNDERLINE:=2488,SCI_STYLEGETCASE:=2489
        SCI_STYLEGETCHARACTERSET:=2490,SCI_STYLEGETVISIBLE:=2491,SCI_STYLEGETCHANGEABLE:=2492
        SCI_STYLEGETHOTSPOT:=2493,SCI_STYLERESETDEFAULT:=2058,SCI_STYLESETUNDERLINE:=2059,SC_CASE_MIXED:=0
        SC_CASE_UPPER:=1,SC_CASE_LOWER:=2,SCI_STYLESETCASE:=2060,SCI_STYLESETCHARACTERSET:=2066
        SCI_STYLESETHOTSPOT:=2409,SCI_SETSELFORE:=2067,SCI_SETSELBACK:=2068,SCI_GETSELALPHA:=2477
        SCI_SETSELALPHA:=2478,SCI_SETCARETFORE:=2069,SCI_ASSIGNCMDKEY:=2070,SCI_CLEARCMDKEY:=2071
        SCI_CLEARALLCMDKEYS:=2072,SCI_SETSTYLINGEX:=2073,SCI_STYLESETVISIBLE:=2074,SCI_GETCARETPERIOD:=2075
        SCI_SETCARETPERIOD:=2076,SCI_SETWORDCHARS:=2077,SCI_BEGINUNDOACTION:=2078,SCI_ENDUNDOACTION:=2079
        INDIC_MAX:=7,INDIC_PLAIN:=0,INDIC_SQUIGGLE:=1,INDIC_TT:=2,INDIC_DIAGONAL:=3,INDIC_STRIKE:=4
        INDIC_HIDDEN:=5,INDIC_BOX:=6,INDIC_ROUNDBOX:=7,INDIC0_MASK:=0x20,INDIC1_MASK:=0x40,INDIC2_MASK:=0x80
        INDICS_MASK:=0xE0,SCI_INDICSETSTYLE:=2080,SCI_INDICGETSTYLE:=2081,SCI_INDICSETFORE:=2082
        SCI_INDICGETFORE:=2083,SCI_SETWHITESPACEFORE:=2084,SCI_SETWHITESPACEBACK:=2085,SCI_SETSTYLEBITS:=2090
        SCI_GETSTYLEBITS:=2091,SCI_SETLINESTATE:=2092,SCI_GETLINESTATE:=2093,SCI_GETMAXLINESTATE:=2094
        SCI_GETCARETLINEVISIBLE:=2095,SCI_SETCARETLINEVISIBLE:=2096,SCI_GETCARETLINEBACK:=2097
        SCI_SETCARETLINEBACK:=2098,SCI_STYLESETCHANGEABLE:=2099,SCI_AUTOCSHOW:=2100,SCI_AUTOCCANCEL:=2101
        SCI_AUTOCACTIVE:=2102,SCI_AUTOCPOSSTART:=2103,SCI_AUTOCCOMPLETE:=2104,SCI_AUTOCSTOPS:=2105
        SCI_AUTOCSETSEPARATOR:=2106,SCI_AUTOCGETSEPARATOR:=2107,SCI_AUTOCSELECT:=2108
        SCI_AUTOCSETCANCELATSTART:=2110,SCI_AUTOCGETCANCELATSTART:=2111,SCI_AUTOCSETFILLUPS:=2112
        SCI_AUTOCSETCHOOSESINGLE:=2113,SCI_AUTOCGETCHOOSESINGLE:=2114,SCI_AUTOCSETIGNORECASE:=2115
        SCI_AUTOCGETIGNORECASE:=2116,SCI_USERLISTSHOW:=2117,SCI_AUTOCSETAUTOHIDE:=2118,SCI_AUTOCGETAUTOHIDE:=2119
        SCI_AUTOCSETDROPRESTOFWORD:=2270,SCI_AUTOCGETDROPRESTOFWORD:=2271,SCI_REGISTERIMAGE:=2405
        SCI_CLEARREGISTEREDIMAGES:=2408,SCI_AUTOCGETTYPESEPARATOR:=2285,SCI_AUTOCSETTYPESEPARATOR:=2286
        SCI_AUTOCSETMAXWIDTH:=2208,SCI_AUTOCGETMAXWIDTH:=2209,SCI_AUTOCSETMAXHEIGHT:=2210
        SCI_AUTOCGETMAXHEIGHT:=2211,SCI_SETINDENT:=2122,SCI_GETINDENT:=2123,SCI_SETUSETABS:=2124
        SCI_GETUSETABS:=2125,SCI_SETLINEINDENTATION:=2126,SCI_GETLINEINDENTATION:=2127
        SCI_GETLINEINDENTPOSITION:=2128,SCI_GETCOLUMN:=2129,SCI_SETHSCROLLBAR:=2130,SCI_GETHSCROLLBAR:=2131
        SCI_SETINDENTATIONGUIDES:=2132,SCI_GETINDENTATIONGUIDES:=2133,SCI_SETHIGHLIGHTGUIDE:=2134
        SCI_GETHIGHLIGHTGUIDE:=2135,SCI_GETLINEENDPOSITION:=2136,SCI_GETCODEPAGE:=2137,SCI_GETCARETFORE:=2138
        SCI_GETUSEPALETTE:=2139,SCI_GETREADONLY:=2140,SCI_SETCURRENTPOS:=2141,SCI_SETSELECTIONSTART:=2142
        SCI_GETSELECTIONSTART:=2143,SCI_SETSELECTIONEND:=2144,SCI_GETSELECTIONEND:=2145
        SCI_SETPRINTMAGNIFICATION:=2146,SCI_GETPRINTMAGNIFICATION:=2147,SC_PRINT_NORMAL:=0
        SC_PRINT_INVERTLIGHT:=1,SC_PRINT_BLACKONWHITE:=2,SC_PRINT_COLORONWHITE:=3
        SC_PRINT_COLORONWHITEDEFAULTBG:=4,SCI_SETPRINTCOLORMODE:=2148,SCI_GETPRINTCOLORMODE:=2149
        SCFIND_WHOLEWORD:=2,SCFIND_MATCHCASE:=4,SCFIND_WORDSTART:=0x00100000,SCFIND_REGEXP:=0x00200000
        SCFIND_POSIX:=0x00400000,SCI_FINDTEXT:=2150,SCI_FORMATRANGE:=2151,SCI_GETFIRSTVISIBLELINE:=2152
        SCI_GETLINE:=2153,SCI_GETLINECOUNT:=2154,SCI_SETMARGINLEFT:=2155,SCI_GETMARGINLEFT:=2156
        SCI_SETMARGINRIGHT:=2157,SCI_GETMARGINRIGHT:=2158,SCI_GETMODIFY:=2159,SCI_SETSEL:=2160
        SCI_GETSELTEXT:=2161,SCI_GETTEXTRANGE:=2162,SCI_HIDESELECTION:=2163,SCI_POINTXFROMPOSITION:=2164
        SCI_POINTYFROMPOSITION:=2165,SCI_LINEFROMPOSITION:=2166,SCI_POSITIONFROMLINE:=2167,SCI_LINESCROLL:=2168
        SCI_SCROLLCARET:=2169,SCI_REPLACESEL:=2170,SCI_SETREADONLY:=2171,SCI_NULL:=2172,SCI_CANPASTE:=2173
        SCI_CANUNDO:=2174,SCI_EMPTYUNDOBUFFER:=2175,SCI_UNDO:=2176,SCI_CUT:=2177,SCI_COPY:=2178,SCI_PASTE:=2179
        SCI_CLEAR:=2180,SCI_SETTEXT:=2181,SCI_GETTEXT:=2182,SCI_GETTEXTLENGTH:=2183,SCI_GETDIRECTFUNCTION:=2184
        SCI_GETDIRECTPOINTER:=2185,SCI_SETOVERTYPE:=2186,SCI_GETOVERTYPE:=2187,SCI_SETCARETWIDTH:=2188
        SCI_GETCARETWIDTH:=2189,SCI_SETTARGETSTART:=2190,SCI_GETTARGETSTART:=2191,SCI_SETTARGETEND:=2192
        SCI_GETTARGETEND:=2193,SCI_REPLACETARGET:=2194,SCI_REPLACETARGETRE:=2195,SCI_SEARCHINTARGET:=2197
        SCI_SETSEARCHFLAGS:=2198,SCI_GETSEARCHFLAGS:=2199,SCI_CALLTIPSHOW:=2200,SCI_CALLTIPCANCEL:=2201
        SCI_CALLTIPACTIVE:=2202,SCI_CALLTIPPOSSTART:=2203,SCI_CALLTIPSETHLT:=2204,SCI_CALLTIPSETBACK:=2205
        SCI_CALLTIPSETFORE:=2206,SCI_CALLTIPSETFOREHLT:=2207,SCI_CALLTIPUSESTYLE:=2212
        SCI_VISIBLEFROMDOCLINE:=2220,SCI_DOCLINEFROMVISIBLE:=2221,SCI_WRAPCOUNT:=2235,SC_FOLDLEVELBASE:=0x400
        SC_FOLDLEVELWHITEFLAG:=0x1000,SC_FOLDLEVELHEADERFLAG:=0x2000,SC_FOLDLEVELBOXHEADERFLAG:=0x4000
        SC_FOLDLEVELBOXFOOTERFLAG:=0x8000,SC_FOLDLEVELCONTRACTED:=0x10000,SC_FOLDLEVELUNINDENT:=0x20000
        SC_FOLDLEVELNUMBERMASK:=0x0FFF,SCI_SETFOLDLEVEL:=2222,SCI_GETFOLDLEVEL:=2223,SCI_GETLASTCHILD:=2224
        SCI_GETFOLDPARENT:=2225,SCI_SHOWLINES:=2226,SCI_HIDELINES:=2227,SCI_GETLINEVISIBLE:=2228
        SCI_SETFOLDEXPANDED:=2229,SCI_GETFOLDEXPANDED:=2230,SCI_TOGGLEFOLD:=2231,SCI_ENSUREVISIBLE:=2232
        SC_FOLDFLAG_LINEBEFORE_EXPANDED:=0x0002,SC_FOLDFLAG_LINEBEFORE_CONTRACTED:=0x0004
        SC_FOLDFLAG_LINEAFTER_EXPANDED:=0x0008,SC_FOLDFLAG_LINEAFTER_CONTRACTED:=0x0010
        SC_FOLDFLAG_LEVELNUMBERS:=0x0040,SC_FOLDFLAG_BOX:=0x0001,SCI_SETFOLDFLAGS:=2233
        SCI_ENSUREVISIBLEENFORCEPOLICY:=2234,SCI_SETTABINDENTS:=2260,SCI_GETTABINDENTS:=2261
        SCI_SETBACKSPACEUNINDENTS:=2262,SCI_GETBACKSPACEUNINDENTS:=2263,SC_TIME_FOREVER:=10000000
        SCI_SETMOUSEDWELLTIME:=2264,SCI_GETMOUSEDWELLTIME:=2265,SCI_WORDSTARTPOSITION:=2266
        SCI_WORDENDPOSITION:=2267,SC_WRAP_NONE:=0,SC_WRAP_WORD:=1,SC_WRAP_CHAR:=2,SCI_SETWRAPMODE:=2268
        SCI_GETWRAPMODE:=2269,SC_WRAPVISUALFLAG_NONE:=0x0000,SC_WRAPVISUALFLAG_END:=0x0001
        SC_WRAPVISUALFLAG_START:=0x0002,SCI_SETWRAPVISUALFLAGS:=2460,SCI_GETWRAPVISUALFLAGS:=2461
        SC_WRAPVISUALFLAGLOC_DEFAULT:=0x0000,SC_WRAPVISUALFLAGLOC_END_BY_TEXT:=0x0001
        SC_WRAPVISUALFLAGLOC_START_BY_TEXT:=0x0002,SCI_SETWRAPVISUALFLAGSLOCATION:=2462
        SCI_GETWRAPVISUALFLAGSLOCATION:=2463,SCI_SETWRAPSTARTINDENT:=2464,SCI_GETWRAPSTARTINDENT:=2465
        SC_CACHE_NONE:=0,SC_CACHE_CARET:=1,SC_CACHE_PAGE:=2,SC_CACHE_DOCUMENT:=3,SCI_SETLAYOUTCACHE:=2272
        SCI_GETLAYOUTCACHE:=2273,SCI_SETSCROLLWIDTH:=2274,SCI_GETSCROLLWIDTH:=2275,SCI_TEXTWIDTH:=2276
        SCI_SETENDATLASTLINE:=2277,SCI_GETENDATLASTLINE:=2278,SCI_TEXTHEIGHT:=2279,SCI_SETVSCROLLBAR:=2280
        SCI_GETVSCROLLBAR:=2281,SCI_APPENDTEXT:=2282,SCI_GETTWOPHASEDRAW:=2283,SCI_SETTWOPHASEDRAW:=2284
        SCI_TARGETFROMSELECTION:=2287,SCI_LINESJOIN:=2288,SCI_LINESSPLIT:=2289,SCI_SETFOLDMARGINCOLOR:=2290
        SCI_SETFOLDMARGINHICOLOR:=2291,SCI_LINEDOWN:=2300,SCI_LINEDOWNEXTEND:=2301,SCI_LINEUP:=2302
        SCI_LINEUPEXTEND:=2303,SCI_CHARLEFT:=2304,SCI_CHARLEFTEXTEND:=2305,SCI_CHARRIGHT:=2306
        SCI_CHARRIGHTEXTEND:=2307,SCI_WORDLEFT:=2308,SCI_WORDLEFTEXTEND:=2309,SCI_WORDRIGHT:=2310
        SCI_WORDRIGHTEXTEND:=2311,SCI_HOME:=2312,SCI_HOMEEXTEND:=2313,SCI_LINEEND:=2314,SCI_LINEENDEXTEND:=2315
        SCI_DOCUMENTSTART:=2316,SCI_DOCUMENTSTARTEXTEND:=2317,SCI_DOCUMENTEND:=2318,SCI_DOCUMENTENDEXTEND:=2319
        SCI_PAGEUP:=2320,SCI_PAGEUPEXTEND:=2321,SCI_PAGEDOWN:=2322,SCI_PAGEDOWNEXTEND:=2323
        SCI_EDITTOGGLEOVERTYPE:=2324,SCI_CANCEL:=2325,SCI_DELETEBACK:=2326,SCI_TAB:=2327,SCI_BACKTAB:=2328
        SCI_NEWLINE:=2329,SCI_FORMFEED:=2330,SCI_VCHOME:=2331,SCI_VCHOMEEXTEND:=2332,SCI_ZOOMIN:=2333
        SCI_ZOOMOUT:=2334,SCI_DELWORDLEFT:=2335,SCI_DELWORDRIGHT:=2336,SCI_LINECUT:=2337,SCI_LINEDELETE:=2338
        SCI_LINETRANSPOSE:=2339,SCI_LINEDUPLICATE:=2404,SCI_LOWERCASE:=2340,SCI_UPPERCASE:=2341
        SCI_LINESCROLLDOWN:=2342,SCI_LINESCROLLUP:=2343,SCI_DELETEBACKNOTLINE:=2344,SCI_HOMEDISPLAY:=2345
        SCI_HOMEDISPLAYEXTEND:=2346,SCI_LINEENDDISPLAY:=2347,SCI_LINEENDDISPLAYEXTEND:=2348,SCI_HOMEWRAP:=2349
        SCI_HOMEWRAPEXTEND:=2450,SCI_LINEENDWRAP:=2451,SCI_LINEENDWRAPEXTEND:=2452,SCI_VCHOMEWRAP:=2453
        SCI_VCHOMEWRAPEXTEND:=2454,SCI_LINECOPY:=2455,SCI_MOVECARETINSIDEVIEW:=2401,SCI_LINELENGTH:=2350
        SCI_BRACEHIGHLIGHT:=2351,SCI_BRACEBADLIGHT:=2352,SCI_BRACEMATCH:=2353,SCI_GETVIEWEOL:=2355
        SCI_SETVIEWEOL:=2356,SCI_GETDOCPOINTER:=2357,SCI_SETDOCPOINTER:=2358,SCI_SETMODEVENTMASK:=2359
        EDGE_NONE:=0,EDGE_LINE:=1,EDGE_BACKGROUND:=2,SCI_GETEDGECOLUMN:=2360,SCI_SETEDGECOLUMN:=2361
        SCI_GETEDGEMODE:=2362,SCI_SETEDGEMODE:=2363,SCI_GETEDGECOLOR:=2364,SCI_SETEDGECOLOR:=2365
        SCI_SEARCHANCHOR:=2366,SCI_SEARCHNEXT:=2367,SCI_SEARCHPREV:=2368,SCI_LINESONSCREEN:=2370
        SCI_USEPOPUP:=2371,SCI_SELECTIONISRECTANGLE:=2372,SCI_SETZOOM:=2373,SCI_GETZOOM:=2374
        SCI_CREATEDOCUMENT:=2375,SCI_ADDREFDOCUMENT:=2376,SCI_RELEASEDOCUMENT:=2377,SCI_GETMODEVENTMASK:=2378
        SCI_SETFOCUS:=2380,SCI_GETFOCUS:=2381,SCI_SETSTATUS:=2382,SCI_GETSTATUS:=2383
        SCI_SETMOUSEDOWNCAPTURES:=2384,SCI_GETMOUSEDOWNCAPTURES:=2385,SC_CURSORNORMAL:=-1,SC_CURSORWAIT:=4
        SCI_SETCURSOR:=2386,SCI_GETCURSOR:=2387,SCI_SETCONTROLCHARSYMBOL:=2388,SCI_GETCONTROLCHARSYMBOL:=2389
        SCI_WORDPARTLEFT:=2390,SCI_WORDPARTLEFTEXTEND:=2391,SCI_WORDPARTRIGHT:=2392,SCI_WORDPARTRIGHTEXTEND:=2393
        VISIBLE_SLOP:=0x01,VISIBLE_STRICT:=0x04,SCI_SETVISIBLEPOLICY:=2394,SCI_DELLINELEFT:=2395
        SCI_DELLINERIGHT:=2396,SCI_SETXOFFSET:=2397,SCI_GETXOFFSET:=2398,SCI_CHOOSECARETX:=2399
        SCI_GRABFOCUS:=2400,CARET_SLOP:=0x01,CARET_STRICT:=0x04,CARET_JUMPS:=0x10,CARET_EVEN:=0x08
        SCI_SETXCARETPOLICY:=2402,SCI_SETYCARETPOLICY:=2403,SCI_SETPRINTWRAPMODE:=2406,SCI_GETPRINTWRAPMODE:=2407
        SCI_SETHOTSPOTACTIVEFORE:=2410,SCI_SETHOTSPOTACTIVEBACK:=2411,SCI_SETHOTSPOTACTIVEUNDERLINE:=2412
        SCI_SETHOTSPOTSINGLELINE:=2421,SCI_PARADOWN:=2413,SCI_PARADOWNEXTEND:=2414,SCI_PARAUP:=2415
        SCI_PARAUPEXTEND:=2416,SCI_POSITIONBEFORE:=2417,SCI_POSITIONAFTER:=2418,SCI_COPYRANGE:=2419
        SCI_COPYTEXT:=2420,SC_SEL_STREAM:=0,SC_SEL_RECTANGLE:=1,SC_SEL_LINES:=2,SCI_SETSELECTIONMODE:=2422
        SCI_GETSELECTIONMODE:=2423,SCI_GETLINESELSTARTPOSITION:=2424,SCI_GETLINESELENDPOSITION:=2425
        SCI_LINEDOWNRECTEXTEND:=2426,SCI_LINEUPRECTEXTEND:=2427,SCI_CHARLEFTRECTEXTEND:=2428
        SCI_CHARRIGHTRECTEXTEND:=2429,SCI_HOMERECTEXTEND:=2430,SCI_VCHOMERECTEXTEND:=2431
        SCI_LINEENDRECTEXTEND:=2432,SCI_PAGEUPRECTEXTEND:=2433,SCI_PAGEDOWNRECTEXTEND:=2434
        SCI_STUTTEREDPAGEUP:=2435,SCI_STUTTEREDPAGEUPEXTEND:=2436,SCI_STUTTEREDPAGEDOWN:=2437
        SCI_STUTTEREDPAGEDOWNEXTEND:=2438,SCI_WORDLEFTEND:=2439,SCI_WORDLEFTENDEXTEND:=2440
        SCI_WORDRIGHTEND:=2441,SCI_WORDRIGHTENDEXTEND:=2442,SCI_SETWHITESPACECHARS:=2443
        SCI_SETCHARSDEFAULT:=2444,SCI_AUTOCGETCURRENT:=2445,SCI_ALLOCATE:=2446,SCI_TARGETASUTF8:=2447
        SCI_SETLENGTHFORENCODE:=2448,SCI_ENCODEDFROMUTF8:=2449,SCI_FINDCOLUMN:=2456,SCI_GETCARETSTICKY:=2457
        SCI_SETCARETSTICKY:=2458,SCI_TOGGLECARETSTICKY:=2459,SCI_SETPASTECONVERTENDINGS:=2467
        SCI_GETPASTECONVERTENDINGS:=2468,SCI_SELECTIONDUPLICATE:=2469,SC_ALPHA_TRANSPARENT:=0
        SC_ALPHA_OPAQUE:=255,SC_ALPHA_NOALPHA:=256,SCI_SETCARETLINEBACKALPHA:=2470
        SCI_GETCARETLINEBACKALPHA:=2471,SCI_STARTRECORD:=3001,SCI_STOPRECORD:=3002,SCI_SETLEXER:=4001
        SCI_GETLEXER:=4002,SCI_COLORISE:=4003,SCI_SETPROPERTY:=4004,KEYWORDSET_MAX:=8,SCI_SETKEYWORDS:=4005
        SCI_SETLEXERLANGUAGE:=4006,SCI_LOADLEXERLIBRARY:=4007,SCI_GETPROPERTY:=4008,SCI_GETPROPERTYEXPANDED:=4009
        SCI_GETPROPERTYINT:=4010,SCI_GETSTYLEBITSNEEDED:=4011,SC_MOD_INSERTTEXT:=0x1,SC_MOD_DELETETEXT:=0x2
        SC_MOD_CHANGESTYLE:=0x4,SC_MOD_CHANGEFOLD:=0x8,SC_PERFORMED_USER:=0x10,SC_PERFORMED_UNDO:=0x20
        SC_PERFORMED_REDO:=0x40,SC_MULTISTEPUNDOREDO:=0x80,SC_LASTSTEPINUNDOREDO:=0x100
        SC_MOD_CHANGEMARKER:=0x200,SC_MOD_BEFOREINSERT:=0x400,SC_MOD_BEFOREDELETE:=0x800
        SC_MULTILINEUNDOREDO:=0x1000,SC_MODEVENTMASKALL:=0x1FFF,SCEN_CHANGE:=768,SCEN_SETFOCUS:=512
        SCEN_KILLFOCUS:=256,SCK_DOWN:=300,SCK_UP:=301,SCK_LEFT:=302,SCK_RIGHT:=303,SCK_HOME:=304,SCK_END:=305
        SCK_PRIOR:=306,SCK_NEXT:=307,SCK_DELETE:=308,SCK_INSERT:=309,SCK_ESCAPE:=7,SCK_BACK:=8,SCK_TAB:=9
        SCK_RETURN:=13,SCK_ADD:=310,SCK_SUBTRACT:=311,SCK_DIVIDE:=312,SCMOD_NORM:=0,SCMOD_SHIFT:=1,SCMOD_CTRL:=2
        SCMOD_ALT:=4,SCLEX_CONTAINER:=0,SCLEX_NULL:=1,SCLEX_PYTHON:=2,SCLEX_CPP:=3,SCLEX_HTML:=4,SCLEX_XML:=5
        SCLEX_PERL:=6,SCLEX_SQL:=7,SCLEX_VB:=8,SCLEX_PROPERTIES:=9,SCLEX_ERRORLIST:=10,SCLEX_MAKEFILE:=11
        SCLEX_BATCH:=12,SCLEX_XCODE:=13,SCLEX_LATEX:=14,SCLEX_LUA:=15,SCLEX_DIFF:=16,SCLEX_CONF:=17
        SCLEX_PASCAL:=18,SCLEX_AVE:=19,SCLEX_ADA:=20,SCLEX_LISP:=21,SCLEX_RUBY:=22,SCLEX_EIFFEL:=23
        SCLEX_EIFFELKW:=24,SCLEX_TCL:=25,SCLEX_NNCRONTAB:=26,SCLEX_BULLANT:=27,SCLEX_VBSCRIPT:=28
        SCLEX_BAAN:=31,SCLEX_MATLAB:=32,SCLEX_SCRIPTOL:=33,SCLEX_ASM:=34,SCLEX_CPPNOCASE:=35
        SCLEX_FORTRAN:=36,SCLEX_F77:=37,SCLEX_CSS:=38,SCLEX_POV:=39,SCLEX_LOUT:=40,SCLEX_ESCRIPT:=41
        SCLEX_PS:=42,SCLEX_NSIS:=43,SCLEX_MMIXAL:=44,SCLEX_CLW:=45,SCLEX_CLWNOCASE:=46,SCLEX_LOT:=47
        SCLEX_YAML:=48,SCLEX_TEX:=49,SCLEX_METAPOST:=50,SCLEX_POWERBASIC:=51,SCLEX_FORTH:=52
        SCLEX_ERLANG:=53,SCLEX_OCTAVE:=54,SCLEX_MSSQL:=55,SCLEX_VERILOG:=56,SCLEX_KIX:=57,SCLEX_GUI4CLI:=58
        SCLEX_SPECMAN:=59,SCLEX_AU3:=60,SCLEX_APDL:=61,SCLEX_BASH:=62,SCLEX_ASN1:=63,SCLEX_VHDL:=64
        SCLEX_CAML:=65,SCLEX_BLITZBASIC:=66,SCLEX_PUREBASIC:=67,SCLEX_HASKELL:=68,SCLEX_PHPSCRIPT:=69
        SCLEX_TADS3:=70,SCLEX_REBOL:=71,SCLEX_SMALLTALK:=72,SCLEX_FLAGSHIP:=73,SCLEX_CSOUND:=74
        SCLEX_FREEBASIC:=75,SCLEX_INNOSETUP:=76,SCLEX_OPAL:=77,SCLEX_BLITZMAX:=78,SCLEX_AUTOMATIC:=1000,init:=True
    }

    if !%hwnd%_df
	{
        SendMessage, SCI_GETDIRECTFUNCTION,0,0,,ahk_id %hwnd%
        %hwnd%_df := ErrorLevel
        SendMessage, SCI_GETDIRECTPOINTER,0,0,,ahk_id %hwnd%
        %hwnd%_dp := ErrorLevel
	}

    if !msg && !wParam && !lParam   ; called only with the hwnd param from SCI_Add
        return                      ; Exit because we did what we needed to do already.
    
    ; The fast way to control Scintilla
    return DllCall(%hwnd%_df            ; DIRECT FUNCTION
                  ,"UInt" ,%hwnd%_dp    ; DIRECT POINTER
                  ,"UInt" ,%msg%
                  ,"Int"  ,inStr(wParam, "-") ? wParam : (%wParam%+0 ? %wParam% : wParam) ; handels negative ints
                  ,"Int"  ,%lParam%+0 ? %lParam% : lParam)
}
/*
    Function : getHex
    This function converts a color name to its hex value.

    The full list of color names supported by this function can be found
    here: <http://www.w3schools.com/html/html_colornames.asp>

    Parameters:
    cName       -   Real name of the color that you want to convert.

    Returns:
    hexColor    -   Hexadecimal representation of the color name provided.

    Examples:
    >hColor:=SCI_getHex("Black")
    >hColor:=SCI_getHex("MediumSpringGreen")
    >hColor:=SCI_getHex("DarkBlue")
*/
SCI_getHex(cName){
    static

    AliceBlue:=0xF0F8FF,AntiqueWhite:=0xFAEBD7,Aqua:=0x00FFFF,Aquamarine:=0x7FFFD4,Azure:=0xF0FFFF,Beige:=0xF5F5DC
    Bisque:=0xFFE4C4,Black:=0x000000,BlanchedAlmond:=0xFFEBCD,Blue:=0x0000FF,BlueViolet:=0x8A2BE2,Brown:=0xA52A2A
    BurlyWood:=0xDEB887,CadetBlue:=0x5F9EA0,Chartreuse:=0x7FFF00,Chocolate:=0xD2691E,Coral:=0xFF7F50
    CornflowerBlue:=0x6495ED,Cornsilk:=0xFFF8DC,Crimson:=0xDC143C,Cyan:=0x00FFFF,DarkBlue:=0x00008B
    DarkCyan:=0x008B8B,DarkGoldenRod:=0xB8860B,DarkGray:=0xA9A9A9,DarkGrey:=0xA9A9A9,DarkGreen:=0x006400
    DarkKhaki:=0xBDB76B,DarkMagenta:=0x8B008B,DarkOliveGreen:=0x556B2F,Darkorange:=0xFF8C00,DarkOrchid:=0x9932CC
    DarkRed:=0x8B0000,DarkSalmon:=0xE9967A,DarkSeaGreen:=0x8FBC8F,DarkSlateBlue:=0x483D8B,DarkSlateGray:=0x2F4F4F
    DarkSlateGrey:=0x2F4F4F,DarkTurquoise:=0x00CED1,DarkViolet:=0x9400D3,DeepPink:=0xFF1493,DeepSkyBlue:=0x00BFFF
    DimGray:=0x696969,DimGrey:=0x696969,DodgerBlue:=0x1E90FF,FireBrick:=0xB22222,FloralWhite:=0xFFFAF0
    ForestGreen:=0x228B22,Fuchsia:=0xFF00FF,Gainsboro:=0xDCDCDC,GhostWhite:=0xF8F8FF,Gold:=0xFFD700
    GoldenRod:=0xDAA520,Gray:=0x808080,Grey:=0x808080,Green:=0x008000,GreenYellow:=0xADFF2F,HoneyDew:=0xF0FFF0
    HotPink:=0xFF69B4,IndianRed:=0xCD5C5C,Indigo:=0x4B0082,Ivory:=0xFFFFF0,Khaki:=0xF0E68C,Lavender:=0xE6E6FA
    LavenderBlush:=0xFFF0F5,LawnGreen:=0x7CFC00,LemonChiffon:=0xFFFACD,LightBlue:=0xADD8E6,LightCoral:=0xF08080
    LightCyan:=0xE0FFFF,LightGoldenRodYellow:=0xFAFAD2,LightGray:=0xD3D3D3,LightGrey:=0xD3D3D3,LightGreen:=0x90EE90
    LightPink:=0xFFB6C1,LightSalmon:=0xFFA07A,LightSeaGreen:=0x20B2AA,LightSkyBlue:=0x87CEFA
    LightSlateGray:=0x778899,LightSlateGrey:=0x778899,LightSteelBlue:=0xB0C4DE,LightYellow:=0xFFFFE0
    Lime:=0x00FF00,LimeGreen:=0x32CD32,Linen:=0xFAF0E6,Magenta:=0xFF00FF,Maroon:=0x800000
    MediumAquaMarine:=0x66CDAA,MediumBlue:=0x0000CD,MediumOrchid:=0xBA55D3,MediumPurple:=0x9370D8
    MediumSeaGreen:=0x3CB371,MediumSlateBlue:=0x7B68EE,MediumSpringGreen:=0x00FA9A,MediumTurquoise:=0x48D1CC
    MediumVioletRed:=0xC71585,MidnightBlue:=0x191970,MintCream:=0xF5FFFA,MistyRose:=0xFFE4E1,Moccasin:=0xFFE4B5
    NavajoWhite:=0xFFDEAD,Navy:=0x000080,OldLace:=0xFDF5E6,Olive:=0x808000,OliveDrab:=0x6B8E23,Orange:=0xFFA500
    OrangeRed:=0xFF4500,Orchid:=0xDA70D6,PaleGoldenRod:=0xEEE8AA,PaleGreen:=0x98FB98,PaleTurquoise:=0xAFEEEE
    PaleVioletRed:=0xD87093,PapayaWhip:=0xFFEFD5,PeachPuff:=0xFFDAB9,Peru:=0xCD853F,Pink:=0xFFC0CB,Plum:=0xDDA0DD
    PowderBlue:=0xB0E0E6,Purple:=0x800080,Red:=0xFF0000,RosyBrown:=0xBC8F8F,RoyalBlue:=0x4169E1
    SaddleBrown:=0x8B4513,Salmon:=0xFA8072,SandyBrown:=0xF4A460,SeaGreen:=0x2E8B57,SeaShell:=0xFFF5EE
    Sienna:=0xA0522D,Silver:=0xC0C0C0,SkyBlue:=0x87CEEB,SlateBlue:=0x6A5ACD,SlateGray:=0x708090
    SlateGrey:=0x708090,Snow:=0xFFFAFA,SpringGreen:=0x00FF7F,SteelBlue:=0x4682B4,Tan:=0xD2B48C
    Teal:=0x008080,Thistle:=0xD8BFD8,Tomato:=0xFF6347,Turquoise:=0x40E0D0,Violet:=0xEE82EE,Wheat:=0xF5DEB3
    White:=0xFFFFFF,WhiteSmoke:=0xF5F5F5,Yellow:=0xFFFF00,YellowGreen:=0x9ACD32

    StringReplace, cName, cName, %a_space%,,All
    if cName is not alpha
    {
        oldFormat := a_formatinteger
        setformat, integer, H
        cName += 0              ; Converting integers to hexadecimal in case you tried that... (¬¬)
        setformat, integer, %oldFormat%
        return cName ""
    }
    else
        return %cName% ""
}

keywords(x){
 if x=1
   return "autotrim blockinput break clipwait continue controlclick controlfocus controlget controlgetfocus controlgetpos controlgettext controlmove controlsend controlsendraw controlsettext coordmode critical detecthiddentext detecthiddenwindows drive driveget drivespacefree edit else endrepeat envadd envdiv envget envmult envset envsub envupdate exit exitapp fileappend filecopy filecopydir filecreatedir filecreateshortcut filedelete filegetattrib filegetshortcut filegetsize filegettime filegetversion fileinstall filemove filemovedir fileread filereadline filerecycle filerecycleempty fileremovedir fileselectfile fileselectfolder filesetattrib filesettime formattime getkeystate gosub goto groupactivate groupadd groupclose groupdeactivate gui guicontrol guicontrolget hideautoitwin hotkey if ifequal ifexist ifgreater ifgreaterorequal ifinstring ifless iflessorequal ifmsgbox ifnotequal ifnotexist ifnotinstring ifwinactive ifwinexist ifwinnotactive ifwinnotexist imagesearch inidelete iniread iniwrite input inputbox keyhistory keywait listhotkeys listlines listvars loop menu mouseclick mouseclickdrag mousegetpos mousemove msgbox onexit outputdebug pause pixelgetcolor pixelsearch postmessage process progress random regdelete regexmatch regexreplace regread regwrite reload repeat return run runas runwait send sendmessage sendraw sendinput setbatchlines setcapslockstate setcontroldelay setdefaultmousespeed setenv setformat setkeydelay setmousedelay setnumlockstate setscrolllockstate setstorecapslockmode settimer settitlematchmode setwindelay setworkingdir shutdown sleep sort soundbeep soundget soundgetwavevolume soundplay soundset soundsetwavevolume splashimage splashtextoff splashtexton splitpath statusbargettext statusbarwait stringcasesense stringgetpos stringleft stringlen stringlower stringmid stringreplace stringright stringsplit stringtrimleft stringtrimright stringupper suspend sysget thread tooltip transform traytip tv_add tv_modify tv_delete tv_getselection tv_getcount tv_getparent tv_getchild tv_getprev tv_getnext tv_gettext tv_get urldownloadtofile winactivate winactivatebottom winclose winget wingetactivestats wingetactivetitle wingetclass wingetpos wingettext wingettitle winhide winkill winmaximize winmenuselectitem winminimize winminimizeall winminimizeallundo winmove winrestore winset winsettitle winshow winwait winwaitactive winwaitclose winwaitnotactive"
 else if x=2
   return "a_ahkversion a_autotrim a_batchlines a_caretx a_carety a_computername a_controldelay a_cursor a_dd a_ddd a_dddd a_defaultmousespeed a_desktop a_desktopcommon a_detecthiddentext a_detecthiddenwindows a_endchar a_eventinfo a_exitreason a_formatfloat a_formatinteger a_gui a_guicontrol a_guicontrolevent a_guievent a_guiheight a_guiwidth a_guix a_guiy a_hour a_iconfile a_iconhidden a_iconnumber a_icontip a_index a_ipaddress1 a_ipaddress2 a_ipaddress3 a_ipaddress4 a_isadmin a_iscompiled a_issuspended a_keydelay a_language a_linefile a_linenumber a_loopfield a_loopfileattrib a_loopfiledir a_loopfileext a_loopfilefullpath a_loopfilelongpath a_loopfilename a_loopfileshortname a_loopfileshortpath a_loopfilesize a_loopfilesizekb a_loopfilesizemb a_loopfiletimeaccessed a_loopfiletimecreated a_loopfiletimemodified a_loopreadline a_loopregkey a_loopregname a_loopregsubkey a_loopregtimemodified a_loopregtype a_mday a_min a_mm a_mmm a_mmmm a_mon a_mousedelay a_msec a_mydocuments a_now a_nowutc a_numbatchlines a_ostype a_osversion a_priorhotkey a_programfiles a_programs a_programscommon a_screenheight a_screenwidth a_scriptdir a_scriptfullpath a_scriptname a_sec a_space a_startmenu a_startmenucommon a_startup a_startupcommon a_stringcasesense a_tab a_thishotkey a_thismenu a_thismenuitem a_thismenuitempos a_tickcount a_timeidle a_timeidlephysical a_timesincepriorhotkey a_timesincethishotkey a_titlematchmode a_titlematchmodespeed a_username a_wday a_windelay a_windir a_workingdir a_yday a_year a_yweek a_yyyy abort abs acos add ahk_class ahk_group ahk_id ahk_pid alnum alpha alt altdown altsubmit alttab alttabandmenu alttabmenu alttabmenudismiss altup alwaysontop appskey asc asin atan background backspace between bitand bitnot bitor bitshiftleft bitshiftright bitxor blind border bottom browser_back browser_favorites browser_forward browser_home browser_refresh browser_search browser_stop bs button buttons byref cancel capacity capslock caption ceil center check check3 checkbox checked checkedgray choose choosestring chr click clipboard clipboardall close color combobox contains control controllist cos count ctrl ctrlbreak ctrldown ctrlup date datetime days ddl default del delete deleteall delimiter deref destroy digit disable disabled down dropdownlist eject enable enabled end enter error errorlevel esc escape exp exstyle f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12"
 else if x=3
   return "allowsamelinecomments clipboardtimeout commentflag errorstdout escapechar hotkeyinterval hotkeymodifiertimeout hotstring include installkeybdhook installmousehook maxhotkeysperinterval maxmem maxthreads maxthreadsbuffer maxthreadsperhotkey noenv notrayicon persistent singleinstance usehook winactivateforce"
}

