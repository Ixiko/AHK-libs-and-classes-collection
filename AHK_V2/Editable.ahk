#Requires Autohotkey v2.0+
#Include UIA.ahk
toc := "
(
    Table of contents:

    F1: inserts 'text' at the caret
    F2: displays the current selection
    F3: selects characters 4-10
    F4: runs Notepad, inserts 'ipsum' into the text
    F6: displays the caret offset
)"
MsgBox(toc)
F1::
{
    el := Editable()
    el.Insert("test")
    ToolTip "Inserted 'test' into: " el.Dump()
    SetTimer(ToolTip, -3000)
}
F2::
{
    selection := Editable().Selection
    ToolTip "Text: " selection.text "`nStart: " selection.start "`nEnd: " selection.end
    SetTimer(ToolTip, -3000)
}
F3::
{
    Editable().Select(4, 10)
}
F4::
{
    winTitle := "ahk_exe notepad.exe"
    if WinExist(winTitle)
        WinActivate winTitle
    else
        Run "notepad.exe"     
    WinWaitActive winTitle
    element := UIA.ElementFromHandle().FindElement({IsTextPatternAvailable:1})
    if !element.Value
        element.Value := "Lorem dolor"
    Editable(element).Insert(" ipsum", 5)
}
F6::
{
    ToolTip Editable().CaretOffset
    SetTimer(ToolTip, -3000)
}

/**
 * Editable class can be used to interact with editable elements suchs as textbox and manipulate their content.
 * Editable extends IUIAutomationElement class, so all normal UIA element methods can be used with the returned object.
 * 
 * Editable()         => creates a new instance for the element with the caret (selected element)
 * Editable(element)  => creates a new instance for an editable UIA element
 * 
 * Editable class static methods:
 * Editable.GetCaretPos(&x:=0, &y:=0)       => returns the current caret screen position coordinates
 * Editable.NearestEditableElement(element) => returns an editable element which is either the element itself, a child, or a parent
 * 
 * Editable class instance properties:
 * Editable().Value       => gets or sets the current text
 * Editable().Selection   => returns an object {start, end, text} with the current selection text, and start and end offsets
 * Editable().CaretOffset => returns the position of the caret relative to the beginning of the text
 * 
 * Editable class instance methods:
 * Editable().Select(from, to)      => selects text from offsets (starting from beginning of the element)
 * Editable().Insert(text, offset?) => inserts text, by default to the current caret position
 */
class Editable extends UIA.IUIAutomationElement {
    static __pLib := DllCall("LoadLibrary", "str", "oleacc")
    static __Delete => DllCall("FreeLibrary", "ptr", Editable.__pLib)

    /**
     * Creates a new Editable instance, either from the element with caret, or a provided UIA element.
     * UIAutomation is activated for Chromium windows automatically.
     * @returns {Editable}
     */
    __New(element?) {
        static activatedHwnds := Map(), OBJID_WINDOW := 0x00000000, OBJID_CLIENT := 0xfffffffc, OBJID_CARET := 0xfffffff8, WM_GETOBJECT := 0x003D, IID := Buffer(16)
        hWnd := WinExist("A"), cHwnd := 0, pLib := Editable.__pLib, this.DefineProp("IsIAccessible2", {value:0})
        if IsSet(element) {
            this.DefineProp("ptr", {value:element.ptr}), element.AddRef()
            try {
                this.DefineProp("IAccessible", {value:this.GetIAccessible()})
                DllCall("oleacc\WindowFromAccessibleObject", "Ptr", this.IAccessible, "uint*", &hWnd:=0)
                hWnd := DllCall("GetAncestor", "UInt", hWnd, "UInt", 2)
                cHwnd := ControlGetHwnd("Chrome_RenderWidgetHostHWND1", hWnd)
                this.DefineProp("IAccessible2Text", {value:ComObjQuery(ComObjValue(this.IAccessible), "{618736e0-3c3d-11cf-810c-00aa00389b71}", "{24FD2FFB-3AAD-4A08-8335-A3AD89C0FB4B}")}) ; IAccessibleText
                this.IsIAccessible2 := cHwnd
            }
            return
        }
        try cHwnd := ControlGetHwnd("Chrome_RenderWidgetHostHWND1", hWnd)
        if cHwnd
            UIA.ActivateChromiumAccessibility(hWnd)
    
        Editable.GetCaretPos(&x, &y)
        target := Editable.NearestEditableElement(UIA.ElementFromPoint(x, y))
        this.DefineProp("ptr", {Value:target.ptr})
        target.AddRef()
        try {
            this.DefineProp("IAccessible", {value:this.GetIAccessible()})
            this.DefineProp("IAccessible2Text", {value:ComObjQuery(ComObjValue(this.IAccessible), "{618736e0-3c3d-11cf-810c-00aa00389b71}", "{24FD2FFB-3AAD-4A08-8335-A3AD89C0FB4B}")}) ; IAccessibleText
            this.IsIAccessible2 := hWnd
        }
    }

    ; Returns IUIAutomationTextRange for the current selection
    SelectionRange {
        get => this.TextPattern.GetSelection()[1]
    }

    ; Returns an object {start, end, text} with the current selection text, and start and end offsets
    Selection {
        get {
            if this.IsIAccessible2 {
                try {
                    ComCall(9, this.IAccessible2Text, "int", 0, "int*", &startOffset:=0, "int*", &endOffset:=0) ; Selection
                    ComCall(10, this.IAccessible2Text, "int", startOffset, "int", endOffset, "ptr*", &text:=0) ; Text
                    return {start:startOffset, end:endOffset, text:UIA.BSTR(text)}
                }
            }
            selection := this.SelectionRange, offset := this.CaretOffset
            return {start:offset, end:offset+selection.CompareEndpoints(UIA.TextPatternRangeEndpoint.End, selection, UIA.TextPatternRangeEndpoint.Start), text:selection.GetText()}
        } 
    }

    /**
     * Selects text from offsets, starting from beginning of the element.
     * @param from The starting offset
     * @param to The ending offset
     */
    Select(from, to) {
        if this.IsIAccessible2 {
            ComCall(16, this.IAccessible2Text, "int", 0, "int", from, "int", to)
        } else {
            doc := this.DocumentRange
            doc.MoveEndpointByUnit(UIA.TextPatternRangeEndpoint.End, UIA.TextUnit.Document, -1)
            doc.MoveEndpointByUnit(UIA.TextPatternRangeEndpoint.End, UIA.TextUnit.Character, to)
            doc.MoveEndpointByUnit(UIA.TextPatternRangeEndpoint.Start, UIA.TextUnit.Character, from)
            doc.Select()
        }
    }

    ; Returns the caret offset from the beginning of the element
    CaretOffset {
        get {
            if this.IsIAccessible2 {
                ComCall(5, this.IAccessible2Text, "int*", &offset:=0) ; CaretOffset
                return offset
            } else {
                selected := this.TextPattern.GetSelection()[1]
                document := this.DocumentRange
                offset := selected.CompareEndpoints(UIA.TextPatternRangeEndpoint.Start, document, UIA.TextPatternRangeEndpoint.Start)
                if offset != 1
                    return offset
                ; This is required pretty much only for Edge
                timeOut := A_TickCount+500, counter := 0
                While A_TickCount < timeOut { 
                    if offset = 0
                        break
                    document.MoveEndpointByUnit(UIA.TextPatternRangeEndpoint.Start, UIA.TextUnit.Character, 1)
                    counter++
                    offset := selected.CompareEndpoints(UIA.TextPatternRangeEndpoint.Start, document, UIA.TextPatternRangeEndpoint.Start)
                }
                if A_TickCount >= timeOut
                    throw TimeoutError("Getting caret offset timed out", -1)
                return counter
            }
        }
        set {
            if this.IsIAccessible2
                ComCall(15, this.IAccessible2Text, "int", Value)
            else
                this.Select(Value, Value)
        } 
    }

    /**
     * Inserts text, by default to the current caret position. The caret is moved to the end of the inserted text.
     * Returns an object: {oldText, newText, caretOffset}
     * @param text The text to insert
     * @param offset Optional: the offset from the beginning of the element. Default is caret position
     * @returns {Object}
     */
    Insert(text, offset?) {
        if this.IsIAccessible2 {
            if !IsSet(offset)
                ComCall(5, this.IAccessible2Text, "int*", &offset:=0) ; CaretOffset
            curVal := this.IAccessible.accValue[0], newVal := SubStr(curVal, 1, offset) text SubStr(curVal, offset+1)
            this.IAccessible.accValue[0] := newVal
            Sleep 1
            ComCall(15, this.IAccessible2Text, "int", StrLen(SubStr(curVal, 1, offset) text))
        } else {
            selection := this.TextPattern.GetSelection()[1]
            if !IsSet(offset)
                offset := this.CaretOffset
            curVal := this.Value, newVal := SubStr(curVal, 1, offset) text SubStr(curVal, offset+1)
            this.Value := newVal
            selection.Move(UIA.TextUnit.Character, StrLen(SubStr(curVal, 1, offset) text))
            selection.Select()
        }
        return {oldText:curVal, newText:newVal, caretOffset:offset}
    }

    /**
     * Returns the caret screen position
     * @param x Is set to the x coordinate
     * @param y Is set to the y coordinate
     */
    static GetCaretPos(&x:=0, &y:=0) {
        static OBJID_CARET := 0xfffffff8, IID := Buffer(16)

        ; Get IAccessible for Caret
        if DllCall("oleacc\AccessibleObjectFromWindow", "ptr", WinExist("A"), "uint", OBJID_CARET
            , "ptr",-16 + NumPut("int64", 0x719B3800AA000C81, NumPut("int64", 0x11CF3C3D618736E0, IID))
            , "ptr*", oCaret := ComValue(9,0)) != 0
        throw Error("Unable to get caret IAccessible", -1)
        
        ; Get caret position
        x:=Buffer(4, 0), y:=Buffer(4, 0), w:=Buffer(4, 0), h:=Buffer(4, 0)
        oCaret.accLocation(ComValue(0x4003, x.ptr, 1), ComValue(0x4003, y.ptr, 1), ComValue(0x4003, w.ptr, 1), ComValue(0x4003, h.ptr, 1), 0)
        x := NumGet(x, 0, "int"), y := NumGet(y, 0, "int")
        if !x && !y {
            savedCaret := A_CoordModeCaret
            CoordMode "Caret", "Screen"
            CaretGetPos(&x, &y)
            CoordMode "Caret", savedCaret
        }
        if !x && !y {
            try {
                focused := UIA.GetFocusedElement()
                range := Editable.NearestEditableElement(focused).TextPattern.GetSelection()[1]
                rect := range.GetBoundingRectangles()[1]
                x := rect.x, y := rect.y
            }
        }
        if !x && !y
            throw Error("Unable to get the caret position", -1)
    }

    /**
     * Returns the nearest editable element to the element. First the element itself is checked
     * for editability, next the descendants are searched for an editable element, 
     * finally the parents are searched.
     * @param element The element to start the search with
     * @returns {UIA.IUIAutomationElement}
     */
    static NearestEditableElement(element) {
        if element.IsTextPatternAvailable
            return element
        try return element.FindElement({IsTextPatternAvailable:1})
        catch {
            try return UIA.CreateTreeWalker({IsTextPatternAvailable:1}).GetParentElement(element)
            catch
                throw TargetError("TextPattern not available for the element", -2)
        }
    }
}