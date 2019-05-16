#Include <Scintilla>
; Assumes Scintilla.ahk is in a lib folder

main := GuiCreate()
main.OnEvent("Close", () => ExitApp())
; main.MarginX := main.MarginY := 0
addBtn := main.addButton("section vAddDoc", "Add New")
addBtn.OnEvent("click", "AddNewDoc")
main.addButton("ys Disabled vDeleteDoc", "Delete").OnEvent("click", "deleteDoc")
main.addText("ys w1 h" addBtn.pos.h + 2 " 0x11")
main.addButton("ys Disabled vPrevDoc", "Previous").OnEvent("click", (ctrl) => changeDoc(ctrl, false))
main.addButton("ys Disabled vNextDoc", "Next").OnEvent("click", (ctrl) => changeDoc(ctrl, true))
main.addButton("ys x+400 vSplitDoc", "Split Doc").OnEvent("click", "splitDoc")
main.addButton("ys Disabled vUnsplitDoc", "Unsplit Doc").OnEvent("click", "unsplitDoc")

global sciDocs := [] ; store doc pointers
global currentDoc := 0

global sci := new Scintilla(main, "w800 h400 xs Section vEdit", , 0, 0)
currentDoc := sciDocs.push(sci.GetDocPointer()) ; store the initial doc pointer

; apply generic styling
setupSciControl(sci)

; listen for double clicks and show the current selection if it contains text
sci.OnNotify(sci.SCN_DOUBLECLICK, (ctrl, l) => showCurrentSelection(sci, l))

global sci2 := new Scintilla(main, "yp xp+" (sci.ctrl.pos.w) // 2 " w0 h400 Hidden vEdit2", , 0, 0)
; apply generic styling
setupSciControl(sci2)

main.show()
Return

splitDoc(ctrl) {
    gui := ctrl.gui
    
    ; cut the original in half plus some margin
    gui.control["Edit"].move("w" (gui.control["Edit"].pos.w - gui.marginX) // 2)
    
    ; make the second control the same width (height was already set) and make it visible
    sci2.ctrl.move("w" gui.control["Edit"].pos.w)
    sci2.ctrl.Visible := true
    gui.control["splitDoc"].enabled := false
    gui.control["unsplitDoc"].enabled := true
    
    setupSciControl(sci2)
    sci2.SetDocPointer(0, sciDocs[currentDoc])
    
    updateScrollWidth(sci)
}

unSplitDoc(ctrl) {
    gui := ctrl.gui
    
    ; Set the second control to a new document
    ; this reduces the ref count on the document that was split by one
    sci2.SetDocPointer(0, 0)
    
    ; make the main control back to its original width
    sci.ctrl.move("w800")
    
    sci2.ctrl.visible := false
    updateScrollWidth(sci)
    
    gui.control["unsplitDoc"].enabled := false
    gui.control["splitDoc"].enabled := true
}

changeDoc(ctrl, next) {
    ; This shouldn't ever happen since we disable the buttons but just make sure that the index is valid
    if (sciDocs.HasKey(currentDoc - (next ? -1 : 1))) {
        ; add a ref to the current doc before switching
        sci.AddRefDocument(0, sciDocs[currentDoc])
        
        nextDoc := next ? ++currentDoc : --currentDoc
        
        ; change the pointer
        sci.SetDocPointer(0, sciDocs[nextDoc])
        
        if (ctrl.gui.control["edit2"].visible) {
            sci2.SetDocPointer(0, sciDocs[nextDoc])
        }
        
        ; release the ref that we were holding to the now current doc so that Scintilla is the sole owner
        sci.ReleaseDocument(0, sciDocs[nextDoc])
        
        if (nextDoc = 1) {
            ctrl.gui.control["prevDoc"].enabled := false
            ctrl.gui.control["nextDoc"].enabled := true
        }
        else if (nextDoc = sciDocs.length()) {
            ctrl.gui.control["prevDoc"].enabled := true
            ctrl.gui.control["nextDoc"].enabled := false
        }
        else {
            ctrl.gui.control["prevDoc"].enabled := true
            ctrl.gui.control["nextDoc"].enabled := true
        }
    }
}


AddNewDoc(ctrl) {
    ; add a ref to the current doc before switching to a new one
    sci.AddRefDocument(0, sciDocs[currentDoc])
    
    sci.SetDocPointer(0, 0)
    
    ; Save the pointer to the newly created doc
    currentDoc := sciDocs.push(sci.GetDocPointer())
    
    ; If showing the second control, set it to point to the same new document
    if (ctrl.gui.control["edit2"].visible) {
        sci2.SetDocPointer(0, sciDocs[currentDoc])
    }
    
    ; apply generic styling
    setupSciControl(sci)
    
    ctrl.gui.control["prevDoc"].enabled := true
    ctrl.gui.control["nextDoc"].enabled := false
    ctrl.gui.control["deleteDoc"].enabled := true
}

deleteDoc(ctrl) {
    ; save our pointer of the current doc locally to make things easier
    prevDoc := sciDocs[currentDoc]
    
    ; determine which doc we are going to show after deleting the current one
    ; If we are deleting the last doc, then show the previous one
    ; if we are deleting any other doc, then show the document whose pointer will now occupy the currentDoc position of sciDocs
    showNext := currentDoc = sciDocs.length() ? currentDoc - 1 : currentDoc

    ; Store our own ref to the current document
    sci.AddRefDocument(0, sciDocs[currentDoc])
    
    ; if the split doc is visible, then call the unsplit routine to hide it and release its reference
    if (sci2.ctrl.visible) {
        unSplitDoc(ctrl)
    }
    
    ; Remove our current doc from tracking
    sciDocs.RemoveAt(currentDoc)
    
    ; Change the current document to the next one
    sci.SetDocPointer(0, sciDocs[showNext])
    
    ; release our ref from the previous document which drops the ref count to 0 and clears the memory
    ; You should never drop the count to 0 if the Scintilla control is the last to own the document
    sci.ReleaseDocument(0, prevDoc)
    
    currentDoc := showNext ; current is now equal to showNext, do this because in this example, currentDoc is global
    newLength := sciDocs.length()
    
    if (newLength = currentDoc || newLength = 1) {
        ctrl.gui.control["nextDoc"].enabled := false
    }
    if (currentDoc = 1) {
        ctrl.gui.control["prevDoc"].enabled := false
    }
    
    if (newLength = 1) {
        ctrl.gui.control["deleteDoc"].enabled := false
    }
}

updateScrollWidth(sci) {
    lineNumberWidth := sci.GetMarginWidthN(0)
    sci.SetScrollWidth(sci.ctrl.pos.w - lineNumberWidth - SysGet(11)) ; Also subtract the width of a vertical scrollbar
}

showCurrentSelection(sci, l) {
    ; if the selection just contains spaces, this will be false
    if (trim(text := GetSelText(sci))) {
        ToolTip(text)
        SetTimer(() => ToolTip(), -3000) ; close after 3 seconds
    }
}

; helper to get text from buffer
GetSelText(sci) {
    len := sci.GetSelText() - 1
    VarSetCapacity(text, len)
    sci.GetSelText("", &text)
    Return StrGet(&Text,, "UTF-8")
}

setupSciControl(sci) {
    sci.SetBufferedDraw(0) ; Scintilla docs recommend turning this off for current systems as they perform window buffering
    sci.SetTechnology(1) ; uses Direct2D and DirectWrite APIs for higher quality

    sci.SetLexer(7) ; SQL
    
    ; Indentation
    sci.SetTabWidth(4)
    sci.SetUseTabs(false) ; Indent with spaces
    sci.SetTabIndents(1)
    sci.SetBackspaceUnindents(1) ; Backspace will delete spaces that equal a tab
    sci.SetIndentationGuides(sci.SC_IV_LOOKBOTH)
    
    sci.StyleSetFont(sci.STYLE_DEFAULT, "Consolas", 1)
    sci.StyleSetSize(sci.STYLE_DEFAULT, 10)
    sci.StyleSetFore(sci.STYLE_DEFAULT, CvtClr(0xF8F8F2))
    sci.StyleSetBack(sci.STYLE_DEFAULT, CvtClr(0x272822))
    sci.StyleClearAll() ; This message sets all styles to have the same attributes as STYLE_DEFAULT.

    ; Active line background color
    sci.SetCaretLineBack(CvtClr(0x3E3D32))
    sci.SetCaretLineVisible(True)
    sci.SetCaretLineVisibleAlways(1)
    sci.SetCaretFore(CvtClr(0xF8F8F0))

    sci.StyleSetFore(sci.STYLE_LINENUMBER, CvtClr(0xF8F8F2)) ; Margin foreground color
    sci.StyleSetBack(sci.STYLE_LINENUMBER, CvtClr(0x272822)) ; Margin background color

    ; Selection
    Sci.SetSelBack(1, CvtClr(0xBEC0BD))
    sci.SetSelAlpha(80)

    sci.StyleSetFore(sci.SCE_SQL_COMMENT, CvtClr(0x75715E))
    sci.StyleSetFore(sci.SCE_SQL_COMMENTLINE, CvtClr(0x75715E))
    sci.StyleSetFore(sci.SCE_SQL_COMMENTDOC, CvtClr(0x75715E))
    sci.StyleSetFore(sci.SCE_SQL_COMMENTDOCKEYWORD, CvtClr(0x66D9EF))
    sci.StyleSetFore(sci.SCE_SQL_WORD, CvtClr(0xF92672))
    sci.StyleSetFore(sci.SCE_SQL_NUMBER, CvtClr(0xAE81FF))
    sci.StyleSetFore(sci.SCE_SQL_STRING, CvtClr(0xE6DB74))
    sci.StyleSetFore(sci.SCE_SQL_OPERATOR, CvtClr(0xF92672))
    sci.StyleSetFore(sci.SCE_SQL_USER1, CvtClr(0x66D9EF))

    sci.SetKeywords(0, keywords("keywords"), 1)
    sci.SetKeywords(4, keywords("functions"), 1)

    ; line number margin
    PixelWidth := sci.TextWidth(sci.STYLE_LINENUMBER, "9999", 1)
    sci.SetMarginWidthN(0, PixelWidth)
    sci.SetMarginLeft(0, 2) ; Left padding
    
    ; used as a border between line numbers and content
    borderMarginW := 1
    sci.SetMarginTypeN(1, sci.SC_MARGIN_FORE) ; change the second margin to be of type SC_MARGIN_FORE
    sci.SetMarginWidthN(1, borderMarginW) ; set width to 1 pixel

    sci.SetScrollWidth(sci.ctrl.pos.w - PixelWidth - SysGet(11)) ; Also subtract the width of a vertical scrollbar
}

keywords(key) {
    static keywords := {
        keywords: "abort action add after all alter analyze and as asc attach autoincrement before begin between by cascade case cast check collate column commit conflict constraint create cross current current_date current_time current_timestamp database default deferrable deferred delete desc detach distinct do drop each else end escape except exclusive exists explain fail filter following for foreign from full glob group having if ignore immediate in index indexed initially inner insert instead intersect into is isnull join key left like limit match natural no not nothing notnull null of offset on or order outer over partition plan pragma preceding primary query raise range recursive references regexp reindex release rename replace restrict right rollback row rows savepoint select set table temp temporary then to transaction trigger unbounded union unique update using vacuum values view virtual when where window with without",
        functions: "abs avg changes char coalesce count cume_dist date datetime dense_rank first_value glob group_concat hex ifnull instr json json_array json_array_length json_extract json_insert json_object json_patch json_remove json_replace json_set json_type json_valid json_quote json_group_array json_group_object json_each json_tree julianday lag last_insert_rowid last_value lead length like likelihood likely load_extension lower ltrim max min nth_value ntile nullif percent_rank printf quote random randomblob rank replace round row_number rtrim soundex sqlite_compileoption_get sqlite_compileoption_used sqlite_offset sqlite_source_id sqlite_version strftime substr substr sum time total total_changes trim typeof unicode unlikely upper zeroblob"
    }
    
    return keywords.HasKey(key) ? keywords[key] : ""
}

CvtClr(Color) {
    Return (Color & 0xFF) << 16 | (Color & 0xFF00) | (Color >> 16)
}
