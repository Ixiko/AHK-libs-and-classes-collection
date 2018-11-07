; ================================================================================================================================
; =   AccObj_Object                                                                                                                 =
; ================================================================================================================================
; This class provides properties and methods wrapping calls to the IAccessible interface of the object.
; IAccessible Interface -> msdn.microsoft.com/en-us/library/dd318466(v=vs.85).aspx.
; Additionally, the AccessibleChildren() and WindowFromAccessibleObject() client functions are wrapped as methods.
; Active Accessibility Client Functions -> msdn.microsoft.com/en-us/library/dd742692(v=vs.85).aspx
;
; Instance properties:
; -   Ptr
;        Retrieves the raw pointer to the IAccessible interface of this instance.
; -   CID
;        Retrieves the child Id of this accessible object.

; IAccessible properties:
; -   Child
;        Retrieves the object for the specified child, if one exists. All objects must support this property.
; -   ChildCount
;        Retrieves the number of children that belong to this object. All objects must support this property.
;        Note: If the AccObj contains an object element (CID > 0) 0 will be returned.
; -   DefaultAction
;        Retrieves a string that indicates the object's default action. Not all objects have a default action.
; -   Description
;        Retrieves a string that describes the visual appearance of the specified object. Not all objects have a description.
; -   Focus
;        Retrieves the object that has the keyboard focus.
;        All objects that may receive the keyboard focus must support this property.
; -   Help
;        Retrieves the Help property string of an object. Not all objects support this property.
; -   KeyboardShortcut
;        Retrieves the specified object's shortcut key or access key, also known as the mnemonic.
;        All objects that have a shortcut key or an access key support this property.
; -   Name
;        Retrieves the name of the specified object. All objects support this property.
; -   Parent
;        Retrieves the object's parent object. All objects support this property.
;        Note: If the AccObj contains an object element (CID > 0) the element's object (CID = 0) will be returned as parent.
; -   Role
;        Retrieves information that describes the role of the specified object. All objects support this property.
; -   Selection
;        Retrieves the selected children of this object. All objects that support selection must support this property.
; -   State
;        Retrieves the current state of the specified object. All objects support this property.
; -   Value
;        Retrieves the value of the specified object. Not all objects have a value.
;
; IAccessible methods defined as properties:
; -   Location
;        Retrieves the specified object's current screen location. All visual objects support this method.
;
; Accessibility client functions wrapped as properties:
; -   Children
;        Calls the AccessibleChildren() client function.
;        Retrieves the child ID or IAccessible of each child within an accessible container object.
; -   Window
;        Calls the WindowFromAccessibleObject() client function.
;        Retrieves the window handle that corresponds to a particular instance of an IAccessible interface.

; IAccessible methods:
; -   DoDefaultAction()
;        Performs the specified object's default action. Not all objects have a default action.
; -   HitTest(X := "", Y := "")
;        Retrieves the child element or child object at a given point on the screen. All visual objects support this method.
; -   Navigate(Direction) !deprecated!
;        Traverses to another UI element within a container and retrieves the object. This method is optional.
;        Navigation Constants -> msdn.microsoft.com/en-us/library/dd373600(v=vs.85).aspx
; -   Select(SelectionFlags)
;        Modifies the selection or moves the keyboard focus of the specified object. All objects that support selection or
;        receive the keyboard focus must support this method.
;        SELFLAG Constants -> msdn.microsoft.com/en-us/library/dd373634(v=vs.85).aspx
; ================================================================================================================================
Class AccObj_Object {
   ; Load the required DLLs on start-up.
   Static AccMod := DllCall("LoadLibrary", "Str", "Oleacc.dll", "UPtr")
   Static AutMod := DllCall("LoadLibrary", "Str", "OleAut32.dll", "UPtr")
   ; =============================================================================================================================
   ; Construction and Destruction
   ; =============================================================================================================================
   ; Creates a new instance of this class object.
   ; Parameters:
   ;     IAccPtr  -  a raw IAccessible interface pointer.
   ;     ChildID  -  the child ID of the object's child element.
   ;                 Default: 0 (CHILDID_SELF)
   ;     AddRef   -  for internal use only
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
      }  Until (Fetched = 0)
      Try ObjRelease(IEnumPtr)
      Return Children.Length() ? Children : False
   }
   ; -----------------------------------------------------------------------------------------------------------------------------
   _ObjFromVariant(VariantPtr) {
      ; Creates an AccObj from a Variant structure.
      VarType := NumGet(VariantPtr + 0, 0, "UShort")
      AccElem := NumGet(VariantPtr + 8, VarType = 9 ? "UPtr" : "Int")
      If (VarType = 3)   ; VT_I4 (ChildID)
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