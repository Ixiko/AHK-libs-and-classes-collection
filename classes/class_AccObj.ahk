; ================================================================================================================================
; = Active Accessibility Client Functions -> msdn.microsoft.com/en-us/library/dd742692(v=vs.85).aspx =
; ================================================================================================================================

AccObj_FromPoint(X := "", Y := "") {
; AccessibleObjectFromPoint()
; Retrieves the address of the IAccessible interface pointer for the object displayed at a specified point on the screen.
; --------------------------------------------------------------------------------------------------------------------------------
If (X = "") || (Y = "")
DllCall("GetCursorPos", "Int64P", PT)
Else
PT := (X & 0xFFFFFFFF) | (Y << 32)
VarSetCapacity(CID, 24, 0)
HR := DllCall("Oleacc.dll\AccessibleObjectFromPoint", "Int64", PT, "PtrP", IAP, "Ptr", &CID, "UInt")
Return (HR = 0 ? New AccObj_Object(IAP, NumGet(CID, 8, "Int")) : False)
}
AccObj_FromWindow(HWND, ObjID := "WINDOW") {
; --------------------------------------------------------------------------------------------------------------------------------
; AccessibleObjectFromWindow()
; Retrieves the address of the interface for the specified object associated with the specified window.
; Object Identifiers -> msdn.microsoft.com/en-us/library/dd373606(v=vs.85).aspx
; --------------------------------------------------------------------------------------------------------------------------------
; Not supported: QUERYCLASSNAMEIDX = 0xFFFFFFF4, NATIVEOM = 0xFFFFFFF0,
Static OBJECTID := {WINDOW: 0x00000000, SYSMENU: 0xFFFFFFFF, TITLEBAR: 0xFFFFFFFE, MENU: 0xFFFFFFFD, CLIENT: 0xFFFFFFFC
, VSCROLL: 0xFFFFFFFB, HSCROLL: 0xFFFFFFFA, SIZEGRIP: 0xFFFFFFF9, CARET: 0xFFFFFFF8, CURSOR: 0xFFFFFFF7
, ALERT: 0xFFFFFFF6, SOUND: 0xFFFFFFF5}
If ((ObjID := OBJECTID[ObjID]) = "")
Return False
VarSetCapacity(IID, 16, 0)
NumPut(0x719B3800AA000C81, NumPut(0x11CF3C3D618736E0, IID, "Int64") + 0, "Int64") ; IID_IAccessible
HR := DllCall("Oleacc.dll\AccessibleObjectFromWindow", "Ptr", HWND, "UInt", ObjID, "Ptr", &IID, "PtrP", IAP, "UInt")
Return (HR = 0 ? New AccObj_Object(IAP) : False)
}
AccObj_GetRoleText(Role) {
; --------------------------------------------------------------------------------------------------------------------------------
; GetRoleText()
; Retrieves the localized string that describes the object's role for the specified role value.
; --------------------------------------------------------------------------------------------------------------------------------
If (Size := DllCall("Oleacc.dll\GetRoleText", "UInt", Role, "Ptr", 0, "UInt", 0)) {
VarSetCapacity(RoleText, Size * 2, 0)
DllCall("Oleacc.dll\GetRoleText", "UInt", Role, "Str", RoleText, "UInt", Size + 1)
Return RoleText
}
}
AccObj_GetStateText(StateBit) {
; --------------------------------------------------------------------------------------------------------------------------------
; GetStateText()
; Retrieves a localized string that describes an object's state for a single predefined state bit flag. Because state values are
; a combination of one or more bit flags, clients call this function more than once to retrieve all state strings.
; --------------------------------------------------------------------------------------------------------------------------------
If (Size := DllCall("Oleacc.dll\GetStateText", "UInt", StateBit, "Ptr", 0, "UInt", 0)) {
VarSetCapacity(StateText, Size * 2, 0)
DllCall("Oleacc.dll\GetStateText", "UInt", StateBit, "Str", StateText, "UInt", Size + 1)
Return StateText
}
}
AccObj_GetRoleName(Role) {
; ================================================================================================================================
; = Additional Helper Functions  =
; ================================================================================================================================
; GetRoleName()
; Retrieves the last part of the constant name used to define the role (e.g. ROLE_SYSTEM_WINDOW -> WINDOW).
; Object Roles -> msdn.microsoft.com/en-us/library/dd373608(v=vs.85).aspx
; --------------------------------------------------------------------------------------------------------------------------------
Static Names := ["TITLEBAR", "MENUBAR", "SCROLLBAR", "GRIP", "SOUND", "CURSOR", "CARET", "ALERT", "WINDOW", "CLIENT"
, "MENUPOPUP", "MENUITEM", "TOOLTIP", "APPLICATION", "DOCUMENT", "PANE", "CHART", "DIALOG", "BORDER"
, "GROUPING", "SEPARATOR", "TOOLBAR", "STATUSBAR", "TABLE", "COLUMNHEADER", "ROWHEADER", "COLUMN", "ROW"
, "CELL", "LINK", "HELPBALLOON", "CHARACTER", "LIST", "LISTITEM", "OUTLINE", "OUTLINEITEM", "PAGETAB"
, "PROPERTYPAGE", "INDICATOR", "GRAPHIC", "STATICTEXT", "TEXT", "PUSHBUTTON", "CHECKBUTTON", "RADIOBUTTON"
, "COMBOBOX", "DROPLIST", "PROGRESSBAR", "DIAL", "HOTKEYFIELD", "SLIDER", "SPINBUTTON", "DIAGRAM"
, "ANIMATION", "EQUATION", "BUTTONDROPDOWN", "BUTTONMENU", "BUTTONDROPDOWNGRID", "WHITESPACE", "PAGETABLIST"
, "CLOCK", "SPLITBUTTON", "IPADDRESS", "OUTLINEBUTTON"]
Return (N := Names[Role + 0]) ? N : "UNDEFINED"
}
AccObj_GetStateName(StateBit) {
; --------------------------------------------------------------------------------------------------------------------------------
; GetStateName()
; Retrieves the last part of the constant name used to define the state (e.g. STATE_SYSTEM_CHECKED -> CHECKED).
; Object State Constants -> msdn.microsoft.com/en-us/library/dd373609(v=vs.85).aspx
; --------------------------------------------------------------------------------------------------------------------------------
Static Names := {0x00000000: "NORMAL", 0x00000001: "UNAVAILABLE", 0x00000002: "SELECTED", 0x00000004: "FOCUSED"
, 0x00000008: "PRESSED", 0x00000010: "CHECKED", 0x00000020: "MIXED", 0x00000020: "INDETERMINATE"
, 0x00000040: "READONLY", 0x00000080: "HOTTRACKED", 0x00000100: "DEFAULT", 0x00000200: "EXPANDED"
, 0x00000400: "COLLAPSED", 0x00000800: "BUSY", 0x00001000: "FLOATING", 0x00002000: "MARQUEED"
, 0x00004000: "ANIMATED", 0x00008000: "INVISIBLE", 0x00010000: "OFFSCREEN", 0x00020000: "SIZEABLE"
, 0x00040000: "MOVEABLE", 0x00080000: "SELFVOICING", 0x00100000: "FOCUSABLE", 0x00200000: "SELECTABLE"
, 0x00400000: "LINKED", 0x00800000: "TRAVERSED", 0x01000000: "MULTISELECTABLE", 0x02000000: "EXTSELECTABLE"
, 0x04000000: "ALERT_LOW", 0x08000000: "ALERT_MEDIUM", 0x10000000: "ALERT_HIGH", 0x20000000: "PROTECTED"
, 0x40000000: "HASPOPUP"}
Return (N := Names[StateBit + 0]) ? N : "UNDEFINED (" . StateBit . ")"
}
AccObj_FromPath(RootHwnd, ObjPath) {
; --------------------------------------------------------------------------------------------------------------------------------
; FromPath()
; Retrieves the accessible object for the specified root window and path, e.g. as retrieved form AccObj_GetPath().
; --------------------------------------------------------------------------------------------------------------------------------
PathObj := ""
If (PathObj := AccObj_FromWindow(RootHwnd))
Loop, Parse, ObjPath, .
PathObj := (PathObj.Children)[A_LoopField]
Return (IsObject(PathObj) ? PathObj : False)
}
AccObj_GetPath(AccObj) {
; --------------------------------------------------------------------------------------------------------------------------------
; GetPath()
; Retrieves the path of the specified accessible object relative to its root window.
; --------------------------------------------------------------------------------------------------------------------------------
ChildPath := ""
If (RootHwnd := DllCall("GetAncestor", "Ptr", AccObj.Window, "UInt", 2, "UPtr")) { ; GA_ROOT
RootRole := AccObj_FromWindow(RootHwnd).Role
ChildPos := AccObj.Location.Str
ChildRole := AccObj.Role
Parent := AccObj
While (Parent := Parent.Parent) {
Children := Parent.Children
For Index, Child In Children {
If (ChildRole = Child.Role) && (ChildPos = Child.Location.Str) {
ChildPath := "." . Index . ChildPath
ChildPos := Parent.Location.Str
ChildRole := Parent.Role
Break
}
}
If (Parent.Window = RootHwnd) && (Parent.Role = RootRole)
Break
}
}
Return (ChildPath ? SubStr(ChildPath, 2) : "")
}


/* ; = AccObj_Object =
; ================================================================================================================================
; This class provides properties and methods wrapping calls to the IAccessible interface of the object.
; IAccessible Interface -> msdn.microsoft.com/en-us/library/dd318466(v=vs.85).aspx.
; Additionally, the AccessibleChildren() and WindowFromAccessibleObject() client functions are wrapped as methods.
; Active Accessibility Client Functions -> msdn.microsoft.com/en-us/library/dd742692(v=vs.85).aspx
;
; Instance properties:
; - Ptr
; Retrieves the raw pointer to the IAccessible interface of this instance.
; - CID
; Retrieves the child Id of this accessible object.
; IAccessible properties:
; - Child
; Retrieves the object for the specified child, if one exists. All objects must support this property.
; - ChildCount
; Retrieves the number of children that belong to this object. All objects must support this property.
; Note: If the AccObj contains an object element (CID > 0) 0 will be returned.
; - DefaultAction
; Retrieves a string that indicates the object's default action. Not all objects have a default action.
; - Description
; Retrieves a string that describes the visual appearance of the specified object. Not all objects have a description.
; - Focus
; Retrieves the object that has the keyboard focus.
; All objects that may receive the keyboard focus must support this property.
; - Help
; Retrieves the Help property string of an object. Not all objects support this property.
; - KeyboardShortcut
; Retrieves the specified object's shortcut key or access key, also known as the mnemonic.
; All objects that have a shortcut key or an access key support this property.
; - Name
; Retrieves the name of the specified object. All objects support this property.
; - Parent
; Retrieves the object's parent object. All objects support this property.
; Note: If the AccObj contains an object element (CID > 0) the element's object (CID = 0) will be returned as parent.
; - Role
; Retrieves information that describes the role of the specified object. All objects support this property.
; - Selection
; Retrieves the selected children of this object. All objects that support selection must support this property.
; - State
; Retrieves the current state of the specified object. All objects support this property.
; - Value
; Retrieves the value of the specified object. Not all objects have a value.
;
; IAccessible methods defined as properties:
; - Location
; Retrieves the specified object's current screen location. All visual objects support this method.
;
; Accessibility client functions wrapped as properties:
; - Children
; Calls the AccessibleChildren() client function.
; Retrieves the child ID or IAccessible of each child within an accessible container object.
; - Window
; Calls the WindowFromAccessibleObject() client function.
; Retrieves the window handle that corresponds to a particular instance of an IAccessible interface.
; IAccessible methods:
; - DoDefaultAction()
; Performs the specified object's default action. Not all objects have a default action.
; - HitTest(X := "", Y := "")
; Retrieves the child element or child object at a given point on the screen. All visual objects support this method.
; - Navigate(Direction) !deprecated!
; Traverses to another UI element within a container and retrieves the object. This method is optional.
; Navigation Constants -> msdn.microsoft.com/en-us/library/dd373600(v=vs.85).aspx
; - Select(SelectionFlags)
; Modifies the selection or moves the keyboard focus of the specified object. All objects that support selection or
; receive the keyboard focus must support this method.
; SELFLAG Constants -> msdn.microsoft.com/en-us/library/dd373634(v=vs.85).aspx
; ================================================================================================================================
*/
Class AccObj_Object {
; Load the required DLLs on start-up.
Static AccMod := DllCall("LoadLibrary", "Str", "Oleacc.dll", "UPtr")
Static AutMod := DllCall("LoadLibrary", "Str", "OleAut32.dll", "UPtr")
; =============================================================================================================================
; Construction and Destruction
; =============================================================================================================================
; Creates a new instance of this class object.
; Parameters:
; IAccPtr - a raw IAccessible interface pointer.
; ChildID - the child ID of the object's child element.
; Default: 0 (CHILDID_SELF)
; AddRef - for internal use only
; -----------------------------------------------------------------------------------------------------------------------------
__New(IAccPtr, ChildID := 0, AddRef := False) {
This["@"] := IAccPtr
This["#"] := ChildID
If (AddRef)
ObjAddRef(IAccPtr)
}
; -----------------------------------------------------------------------------------------------------------------------------
; Destroys this instance and releases its interface pointer.
; -----------------------------------------------------------------------------------------------------------------------------
__Delete() {
Try ObjRelease(This.Ptr)
}
; =============================================================================================================================
; Instance Properties
; =============================================================================================================================
Ptr[] {
Get {
Return This["@"]
}
 Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
CID[] {
Get {
Return This["#"]
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; =============================================================================================================================
; IAccessible Properties
; =============================================================================================================================
Child[] { ; get_accChild (9)
Get {
CallAddr := This._VTBL(9)
HR := (A_PtrSize = 8) ? DllCall(CallAddr, "Ptr", This.Ptr, "Ptr", This._ChildID(This.CID), "PtrP", ChildPtr, "UInt")
: DllCall(CallAddr, "Ptr", This.Ptr, "Int64", 3, "Int64", This.CID, "PtrP", ChildPtr, "UInt")
If (HR = 0) {
If (IAccPtr := This._Query(ChildPtr))
Return New AccObj_Object(IAccPtr)
Else
Try ObjRelease(ChildPtr)
}
Return False
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
ChildCount[] { ; get_accChildCount (8)
Get {
Return (This.CID > 0) ? 0 : (!DllCall(This._VTBL(8), "Ptr", This.Ptr, "IntP", ChildCount, "UInt") ? ChildCount : 0)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
DefaultAction[] { ; get_accDefaultAction (20)
Get {
Return This._GetBSTR(20)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
Description[] { ; get_accDescription (12)
Get {
Return This._GetBSTR(12)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
Focus[] { ; get_accFocus (18)
Get {
VarSetCapacity(Variant, 24, 0)
HR := DllCall(This._VTBL(18), "Ptr", This.Ptr, "Ptr", &Variant, "UInt")
Return (HR = 0 ? This._ObjFromVariant(&Variant) : False)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
Help[] { ; get_accHelp (15)
Get {
Return This._GetBSTR(15)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
KeyboardShortcut[] { ; get_accKeyboardShortcut (17)
Get {
Return This._GetBSTR(17)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
Name[] { ; get_accName (10)
Get {
Return This._GetBSTR(10)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
Parent[] { ; get_accParent (7)
Get {
If (This.CID) ; if this is a child element, return the associated parent object
Return New AccObj_Object(This.Ptr, 0, True)
HR := DllCall(This._VTBL(7), "Ptr", This.Ptr, "PtrP", ParentPtr, "UInt")
If (HR = 0) {
If (IAccPtr := This._Query(ParentPtr))
Return New AccObj_Object(IAccPtr)
Else
Try ObjRelease(ParentPtr)
}
Return False
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
Role[] { ; get_accRole (13)
Get {
Return This._GetVARIANT(13)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
Selection[] { ; get_accSelection (19)
Get {
Children := []
VarSetCapacity(Variant, 24, 0)
HR := DllCall(This._VTBL(19), "Ptr", This.Ptr, "Ptr", &Variant, "UInt")
If (HR = 0) {
VarType := NumGet(Variant, "UShort")
AccElem := NumGet(Variant, 8, VarType = 9 ? "UPtr" : "Int")
If (VarType = 0x0D) { ; IUnknown
If (IEnumPtr := ComObjQuery(AccElem, "{00020404-0000-0000-C000-000000000046}")) { ; IEnumVariant
ObjRelease(AccElem)
Return This._EnumVariant(IEnumPtr)
}
}
Else If (SelObj := This._ObjFromVariant(&Variant))
Children.Push(SelObj)
}
Return (Children.Length() ? Children : False)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
State[] { ; get_accState (14)
Get {
Return This._GetVARIANT(14)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
Value[] { ; get_accValue (11)
Get {
Return This._GetBSTR(11)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; =============================================================================================================================
; IAccessible methods implemented as properties
; =============================================================================================================================
Location[] { ; accLocation (22)
Get {
X := Y := W := H := 0
CallAddr := This._VTBL(22)
HR := A_PtrSize = 8 ? DllCall(CallAddr, "Ptr", This.Ptr, "IntP", X, "IntP", Y, "IntP", W, "IntP", H
, "Ptr", This._ChildID(This.CID), "UInt")
: DllCall(CallAddr, "Ptr", This.Ptr, "IntP", X, "IntP", Y, "IntP", W, "IntP", H
, "Int64", 3, "Int64", This.CID, "UInt")
Str := "x" . X . " y" . Y . " w" . W . " h" . H
Return (HR = 0 ? {X: X, Y: Y, W: W, H: H, Str: STr} : False)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; =============================================================================================================================
; Additional properties wrapping accessibility client functions
; =============================================================================================================================
Children[] { ; AccessibleChildren()
Get {
Static VariantSize := 8 + (2 * A_PtrSize)
If (This.CID) ; elements don't have children
Return False
Children := {}
If (CC := This.ChildCount) {
VarSetCapacity(IDArray, CC * VariantSize, 0)
 HR := DllCall("Oleacc.dll\AccessibleChildren", "Ptr", This.Ptr, "Int", 0, "Int", CC, "Ptr", &IDArray, "IntP", CC)
If (HR = 0) {
OffSet := 0
Loop, %CC% {
IF (ChildObj := This._ObjFromVariant(&IDArray + Offset))
Children.Push(ChildObj)
OffSet += VariantSize
}
}
}
Return (Children.Length() ? Children : False)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; -----------------------------------------------------------------------------------------------------------------------------
Window[] { ; WindowFromAccessibleObject()
Get {
HR := DllCall("Oleacc.dll\WindowFromAccessibleObject", "Ptr", This.Ptr, "PtrP", HWND, "UInt")
Return (HR = 0 ? HWND : False)
}
Set {
Throw Exception(A_ThisFunc, , "This property is read-only!")
}
}
; =============================================================================================================================
; IAccessible methods
; =============================================================================================================================
DoDefaultAction() { ; accDoDefaultAction (25)
CallAddr := This._VTBL(25)
HR := A_PtrSize = 8 ? DllCall(CallAddr, "Ptr", This.Ptr, "Ptr", This._ChildID(This.CID), "UInt")
: DllCall(CallAddr, "Ptr", This.Ptr, "Int64", 3, "Int64", This.CID, "UInt")
Return (HR ? False : True)
}
; -----------------------------------------------------------------------------------------------------------------------------
HitTest(X := "", Y := "") { ; accHitTest (24)
If (X = "") || (Y = "") {
VarSetCapacity(PT, 8, 0)
DllCall("GetCursorPos", "Ptr", &PT)
X := NumGet(PT, 0, "Int")
Y := NumGet(PT, 4, "Int")
}
If X Is Not Integer
Return False
If Y Is Not Integer
Return False
VarSetCapacity(Variant, 24, 0)
HR := DllCall(This._VTBL(24), "Ptr", This.Ptr, "Int", X, "Int", Y, "Ptr", &Variant, "UInt")
Return (HR = 0 ? This._ObjFromVariant(&Variant) : False)
}
; -----------------------------------------------------------------------------------------------------------------------------
Navigate(Dir) { ; accNavigate (23) - deprecated
Static NAVDIR := {UP: 1, DOWN: 2, LEFT: 3, RIGHT: 4, NEXT: 5, PREVIOUS: 6, FIRSTCHILD: 7, LASTCHILD: 8}
If !(Dir := NAVDIR[Dir])
Return False
VarSetCapacity(Variant, 24, 0)
CallAddr := This._VTBL(23)
HR := A_PtrSize = 8 ? DllCall(CallAddr, "Ptr", This.Ptr, "Int", Dir, "Ptr", This._ChildID(This.CID), "Ptr", &Variant, "UInt")
: DllCall(CallAddr, "Ptr", This.Ptr, "Int", Dir, "Int64", 3, "Int64", This.CID, "Ptr", &Variant, "UInt")
Return (HR = 0 ? This._ObjFromVariant(&Variant) : False)
}
; -----------------------------------------------------------------------------------------------------------------------------
Select(SelFlag := 3) { ; accSelect (21)
SelFlag &= 0x1F
CallAddr := This._VTBL(21)
HR := A_PtrSize = 8 ? DllCall(CallAddr, "Ptr", This.Ptr, "Int", SelFlag, "Ptr", This._ChildID(This.CID), "UInt")
: DllCall(CallAddr, "Ptr", This.Ptr, "Int", SelFlag, "Int64", 3, "Int64", This.CID, "UInt")
Return (HR ? False : True)
}
; =============================================================================================================================
; Internal Class Methods
; =============================================================================================================================
_ChildID(ChildID) {
; Creates a VARIANT used to pass the ChildID to the IAccessible interface
Static Variant
VarSetCapacity(Variant, 24, 0)
NumPut(3, Variant, "UShort")
NumPut(ChildID, Variant, 8, "UInt")
Return &Variant
}
; -----------------------------------------------------------------------------------------------------------------------------
_EnumVariant(IEnumPtr) {
; Enumerates children using the IEnumVariant interface (Next = 3).
Next := NumGet(NumGet(IEnumPtr + 0, "UPtr") + (A_PtrSize * 3), "UPtr") ; IEnumVariant.Next
Children := {}
Loop {
VarSetCapacity(Variant, 24, 0) ; VARIANT structure
Fetched := 0
DllCall(Next, "Ptr", IEnumPtr, "Int", 1, "Ptr", &Variant, "UIntP", Fetched)
If (Fetched) && (AccObj := This._ObjFromVariant(&Variant))
Children.Push(AccObj)
} Until (Fetched = 0)
Try ObjRelease(IEnumPtr)
Return Children.Length() ? Children : False
}
; -----------------------------------------------------------------------------------------------------------------------------
_ObjFromVariant(VariantPtr) {
; Creates an AccObj from a Variant structure.
VarType := NumGet(VariantPtr + 0, 0, "UShort")
AccElem := NumGet(VariantPtr + 8, VarType = 9 ? "UPtr" : "Int")
If (VarType = 3) ; VT_I4 (ChildID)
Return New AccObj_Object(This.Ptr, AccElem, True)
If (VarType = 9) { ; VT_DISPATCH
If (IAccPtr := This._Query(AccElem))
Return New AccObj_Object(IAccPtr)
Else
Try ObjRelease(AccElem)
}
Return False
}
; -----------------------------------------------------------------------------------------------------------------------------
_GetBSTR(Index) {
; Called for IAccessible calls which return a BSTR
CallAddr := This._VTBL(Index)
BSTR := 0
HR := (A_PtrSize = 8) ? DllCall(CallAddr, "Ptr", This.Ptr, "Ptr", This._ChildID(This.CID), "PtrP", BSTR, "UInt")
: DllCall(CallAddr, "Ptr", This.Ptr, "Int64", 3, "Int64", This.CID, "PtrP", BSTR, "UInt")
If (BSTR) {
Len := DllCall("OleAut32.dll\SysStringLen", "Ptr", BSTR)
Str := StrGet(BSTR, Len, "UTF-16")
DllCall("OleAut32.dll\SysFreeString", "Ptr", BSTR)
Return Str
}
}
; -----------------------------------------------------------------------------------------------------------------------------
_GetVARIANT(Index) {
; Called for IAccessible calls which return a VARIANT
CallAddr := This._VTBL(Index)
VarSetCapacity(Variant, 24, 0)
NumPut(3, Variant, "UShort")
HR := (A_PtrSize = 8) ? DllCall(CallAddr, "Ptr", This.Ptr, "Ptr", This._ChildID(This.CID), "Ptr", &Variant, "UInt")
: DllCall(CallAddr, "Ptr", This.Ptr, "Int64", 3, "Int64", This.CID, "Ptr", &Variant, "UInt")
If (HR = 0) {
VarType := NumGet(Variant, "UShort")
If (VarType = 3) ; VT_I4
Return NumGet(Variant, 8, "Int")
Else If (VarType = 8) { ; VT_BSTR
BSTR := NumGet(Variant, 8, "UPtr")
Len := DllCall("OleAut32.dll\SysStringLen", "Ptr", BSTR)
Str := StrGet(BSTR, Len, "UTF-16")
DllCall("OleAut32.dll\SysFreeString", "Ptr", BSTR)
Return Str
}
}
Return 0
}
; -----------------------------------------------------------------------------------------------------------------------------
_Query(RawPtr) {
; Retrieves the IAccessible interface from an IDispatch interface, if any, and releases the IDispatch interface on success.
; Thanks Lexikos - www.autohotkey.com/forum/viewtopic.php?t=81731&p=509530#509530
If (IAccPtr := ComObjQuery(RawPtr, "{618736E0-3C3D-11CF-810C-00AA00389B71}")) { ; IAccessible
ObjRelease(RawPtr)
Return IAccPtr
}
Try ObjRelease(RawPtr)
Return 0
}
; -----------------------------------------------------------------------------------------------------------------------------
_VTBL(Index) {
; Resolves the IAccessible Vtbl
Return NumGet(NumGet(This.Ptr + 0, "UPtr") + (A_PtrSize * Index), "UPtr")
}
}

; ================================================================================================================================
; Object Identifiers -> msdn.microsoft.com/en-us/library/dd373606(v=vs.85).aspx
; ================================================================================================================================
Class AccObj_OBJID {
Static WINDOW := 0x00000000
Static SYSMENU := 0xFFFFFFFF
Static TITLEBAR := 0xFFFFFFFE
Static MENU := 0xFFFFFFFD
Static CLIENT := 0xFFFFFFFC
Static VSCROLL := 0xFFFFFFFB
Static HSCROLL := 0xFFFFFFFA
Static SIZEGRIP := 0xFFFFFFF9
Static CARET := 0xFFFFFFF8
Static CURSOR := 0xFFFFFFF7
Static ALERT := 0xFFFFFFF6
Static SOUND := 0xFFFFFFF5
Static QUERYCLASSNAMEIDX := 0xFFFFFFF4 ; not supported
Static NATIVEOM := 0xFFFFFFF0 ; not supported
}
; ================================================================================================================================
; Navigation Constants -> msdn.microsoft.com/en-us/library/dd373600(v=vs.85).aspx
; ================================================================================================================================
Class AccObj_NAVDIR {
Static UP := 0x01
Static DOWN := 0x02
Static LEFT := 0x03
Static RIGHT := 0x04
Static NEXT := 0x05
Static PREVIOUS := 0x06
Static FIRSTCHILD := 0x07
Static LASTCHILD := 0x08
}
; ================================================================================================================================
; Object Roles -> msdn.microsoft.com/en-us/library/dd373608(v=vs.85).aspx
; ================================================================================================================================
Class AccObj_ROLE {
Static TITLEBAR := 0x01
Static MENUBAR := 0x02
Static SCROLLBAR := 0x03
Static GRIP := 0x04
Static SOUND := 0x05
Static CURSOR := 0x06
Static CARET := 0x07
Static ALERT := 0x08
Static WINDOW := 0x09
Static CLIENT := 0x0A
Static MENUPOPUP := 0x0B
Static MENUITEM := 0x0C
Static TOOLTIP := 0x0D
Static APPLICATION := 0x0E
Static DOCUMENT := 0x0F
Static PANE := 0x10
Static CHART := 0x11
Static DIALOG := 0x12
Static BORDER := 0x13
Static GROUPING := 0x14
Static SEPARATOR := 0x15
Static TOOLBAR := 0x16
Static STATUSBAR := 0x17
Static TABLE := 0x18
Static COLUMNHEADER := 0x19
Static ROWHEADER := 0x1A
Static COLUMN := 0x1B
Static ROW := 0x1C
Static CELL := 0x1D
Static LINK := 0x1E
Static HELPBALLOON  := 0x1F
Static CHARACTER := 0x20
Static LIST := 0x21
Static LISTITEM := 0x22
Static OUTLINE := 0x23
Static OUTLINEITEM := 0x24
Static PAGETAB := 0x25
Static PROPERTYPAGE := 0x26
Static INDICATOR := 0x27
Static GRAPHIC := 0x28
Static STATICTEXT := 0x29
Static TEXT := 0x2A
Static PUSHBUTTON := 0x2B
Static CHECKBUTTON := 0x2C
Static RADIOBUTTON := 0x2D
Static COMBOBOX := 0x2E
Static DROPLIST := 0x2F
Static PROGRESSBAR := 0x30
Static DIAL := 0x31
Static HOTKEYFIELD := 0x32
Static SLIDER := 0x33
Static SPINBUTTON := 0x34
Static DIAGRAM := 0x35
Static ANIMATION := 0x36
Static EQUATION := 0x37
Static BUTTONDROPDOWN := 0x38
Static BUTTONMENU := 0x39
Static BUTTONDROPDOWNGRID := 0x3A
Static WHITESPACE := 0x3B
Static PAGETABLIST := 0x3C
Static CLOCK := 0x3D
Static SPLITBUTTON := 0x3E
Static IPADDRESS := 0x3F
Static OUTLINEBUTTON := 0x40
}
; ================================================================================================================================
; SELFLAG Constants -> msdn.microsoft.com/en-us/library/dd373634(v=vs.85).aspx
; ================================================================================================================================
Class AccObj_SELFLAG {
Static NONE := 0x00
Static TAKEFOCUS := 0x01
Static TAKESELECTION := 0x02
Static EXTENDSELECTION := 0x04
Static ADDSELECTION := 0x08
Static REMOVESELECTION := 0x10
Static VALID := 0x1F
}
; ================================================================================================================================
; Object State Constants -> msdn.microsoft.com/en-us/library/dd373609(v=vs.85).aspx
; ================================================================================================================================
Class AccObj_STATE {
; INDETERMINATE = MIXED
Static NORMAL := 0x00000000
Static UNAVAILABLE := 0x00000001
Static SELECTED := 0x00000002
Static FOCUSED := 0x00000004
Static PRESSED := 0x00000008
Static CHECKED := 0x00000010
Static MIXED := 0x00000020
Static INDETERMINATE := 0x00000020
Static READONLY := 0x00000040
Static HOTTRACKED := 0x00000080
Static DEFAULT := 0x00000100
Static EXPANDED := 0x00000200
Static COLLAPSED := 0x00000400
Static BUSY := 0x00000800
Static FLOATING := 0x00001000
Static MARQUEED := 0x00002000
Static ANIMATED := 0x00004000
Static INVISIBLE := 0x00008000
Static OFFSCREEN := 0x00010000
Static SIZEABLE := 0x00020000
Static MOVEABLE := 0x00040000
Static SELFVOICING := 0x00080000
Static FOCUSABLE := 0x00100000
Static SELECTABLE := 0x00200000
Static LINKED := 0x00400000
Static TRAVERSED := 0x00800000
Static MULTISELECTABLE := 0x01000000
Static EXTSELECTABLE := 0x02000000
Static ALERT_LOW := 0x04000000
Static ALERT_MEDIUM := 0x08000000
Static ALERT_HIGH := 0x10000000
Static PROTECTED := 0x20000000
Static HASPOPUP := 0x40000000
Static VALID := 0x7FFFFFFF
}

