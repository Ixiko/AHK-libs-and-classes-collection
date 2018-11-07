; ==================================================================================================================================
; Class-based version of a script by nepter
; -> autohotkey.com/board/topic/96129-ahk-l-custom-autocompletion-for-edit-control-with-drop-down-list/
; Namespaces:
;     IAutoComplete
;     IEnumString
; Requires:
;     RegisterSyncCallback()  -> autohotkey.com/boards/viewtopic.php?f=6&t=21223
; MSDN:
;     IAutoComplete           -> msdn.microsoft.com/en-us/library/bb776292(v=vs.85).aspx
;     IAutoComplete2          -> msdn.microsoft.com/en-us/library/bb776288(v=vs.85).aspx
;     IAutoCompleteDropDown   -> msdn.microsoft.com/en-us/library/bb776286(v=vs.85).aspx
;     AUTOCOMPLETEOPTIONS     -> msdn.microsoft.com/en-us/library/bb762479(v=vs.85).aspx
; ==================================================================================================================================
; Creates a new autocompletion object (lib compatible).
; Parameters:
;     HEDT        -  Handle to an edit control.
;     Strings     -  Simple array of autocompletion strings. If you pass a non-object value the string table will be empty.
;     Options     -  Simple array of autocomplete options (see SetOptions() method).
;                    Default: "" -> AUTOSUGGEST
;     WantReturn  -  Set to True to pass the Return key to single-line edit controls to close the autosuggest drop-down list.
;                    Note: The edit control will be subclassed in this case.
;                    Default: False
;     Enable      -  By default, autocompletion will be enabled after creation. Pass False to disable it.
; Return values:
;     On success, the function returns a new instance of the AutoComplete class; otherwise an empty string.
; ==================================================================================================================================
IAutoComplete_Create(HEDT, Strings, Options := "", WantReturn := False, Enable := True) {
   Return New IAutoComplete(HEDT, Strings, Options, WantReturn, Enable)
}
; ==================================================================================================================================
; Used internally to pass the return key to single-line edit controls.
; ==================================================================================================================================
IAutoComplete_SubclassProc(HWND, Msg, wParam, lParam, ID, Data) {
   If (Msg = 0x0087) && (wParam = 13) ; WM_GETDLGCODE, VK_RETURN
      Return 0x0004 ; DLGC_WANTALLKEYS
   If (Msg = 0x0002) { ; WM_DESTROY
      DllCall("RemoveWindowSubclass", "Ptr", HWND, "Ptr", Data, "Ptr", ID)
      DllCall("GlobalFree", "Ptr", Data)
      If (IAutoCompleteAC := Object(ID))
         IAutoCompleteAC.SubclassProc := 0
   }
   Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", HWND, "UInt", Msg, "Ptr", wParam, "Ptr", lParam)
}
; ==================================================================================================================================
Class IAutoComplete {
   Static Attached := []
   ; -------------------------------------------------------------------------------------------------------------------------------
   ; Constructor - see AutoComplete_Create()
   ; -------------------------------------------------------------------------------------------------------------------------------
   __New(HEDT, Strings, Options := "", WantReturn := False, Enable := True) {
      Static IAC2_Init := A_PtrSize * 3
      If AutoComplete.Attached[HEDT]
         Return ""
      This.HWND := HEDT
      This.SubclassProc := 0
      If !(IAC2 := ComObjCreate("{00BB2763-6A77-11D0-A535-00C04FD7D062}", "{EAC04BC0-3791-11d2-BB95-0060977B464C}"))
         Return ""
      This.IAC2 := IAC2
      If !(IES := IEnumString_Create())
         Return ""
      If !IEnumString_SetStrings(IES, Strings) {
         DllCall("GlobalFree", "Ptr", IES)
         Return ""
      }
      This.IES := IES
      This.VTBL := NumGet(IAC2 + 0, "UPtr")
      If DllCall(NumGet(This.VTBL + IAC2_Init, "UPtr"), "Ptr", IAC2 + 0, "Ptr", HEDT, "Ptr", IES, "Ptr", 0, "Ptr", 0, "UInt")
         Return ""
      This.SetOptions(Options = "" ? ["AUTOSUGGEST"] : Options)
      This.Enabled := True
      If !(Enable)
         This.Disable()
      If (WantReturn) {
         ControlGet, Styles, Style, , , ahk_id %HEDT%
         If !(Styles & 0x0004) && (CB := RegisterCallback("IAutoComplete_SubclassProc")) { ; !ES_MULTILINE
            If DllCall("SetWindowSubclass", "Ptr", HEDT, "Ptr", CB, "Ptr", &This, "Ptr", CB, "UInt")
               This.SubclassProc := CB
            Else
               DllCall("GlobalFree", "Ptr", CB, "Ptr")
         }
      }
      AutoComplete.Attached[HEDT] := True
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   ; Destructor
   ; -------------------------------------------------------------------------------------------------------------------------------
   __Delete() {
      ; The edit control keeps own references to IAC2. Hence autocompletion has to be disabled before it can be released.
      ; The only way to reenable autocompletion is to assign a new autocompletion object to the edit.
      If (This.IAC2) {
         This.Disable()
         ObjRelease(This.IAC2)
      }
      If (This.SubclassProc) {
         DllCall("RemoveWindowSubclass", "Ptr", This.HWND, "Ptr", This.SubclassProc, "Ptr", &This)
         DllCall("GlobalFree", "Ptr", This.SubclassProc)
      }
      AutoComplete.Attached.Delete(This.HWND)
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   ; Enables / disables autocompletion.
   ;     Enable   -  True or False
   ; -------------------------------------------------------------------------------------------------------------------------------
   Enable(Enable := True) {
      Static IAC2_Enable := A_PtrSize * 4
      If !(This.VTBL)
         Return False
      This.Enabled := !!Enable
      Return !DllCall(NumGet(This.VTBL + IAC2_Enable, "UPtr"), "Ptr", This.IAC2, "Int", !!Enable, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   ; Disables autocompletion.
   ; -------------------------------------------------------------------------------------------------------------------------------
   Disable() {
      Return This.Enable(False)
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   ;  Sets the autocompletion options.
   ;     Options  -  Simple array of option strings corresponding to the keys defined in ACO
   ; -------------------------------------------------------------------------------------------------------------------------------
   SetOptions(Options) {
      Static IAC2_SetOptions := A_PtrSize * 5
      Static ACO := {NONE: 0, AUTOSUGGEST: 1, AUTOAPPEND: 2, SEARCH: 4, FILTERPREFIXES: 8, USETAB: 16
                   , UPDOWNKEYDROPSLIST: 32, RTLREADING: 64, WORD_FILTER: 128, NOPREFIXFILTERING: 256}
      If !(This.VTBL)
         Return False
      Opts := 0
      For Each, Opt In Options
         Opts |= (Opt := ACO[Opt]) <> "" ? Opt : 0
      Return !DllCall(NumGet(This.VTBL + IAC2_SetOptions, "UPtr"), "Ptr", This.IAC2, "UInt", Opts, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   ; Updates the autocompletion strings.
   ;     Strings  -  Simple array of strings. If you pass a non-object value the string table will be emptied.
   ; -------------------------------------------------------------------------------------------------------------------------------
   UpdStrings(Strings) {
      Static IID_IACDD := "{3CD141F4-3C6A-11d2-BCAA-00C04FD929DB}" ; IAutoCompleteDropDown
           , IACDD_ResetEnumerator := A_PtrSize * 4
      If !(This.IES)
         Return False
      If !(IEnumString_SetStrings(This.IES, Strings))
         Return False
      If (IACDD := ComObjQuery(This.IAC2, IID_IACDD)) {
         DllCall(NumGet(NumGet(IACDD + 0, "UPtr") + IACDD_ResetEnumerator, "UPtr"), "Ptr", This.IAC2, "UInt")
         ObjRelease(IACDD)
      }
      Return True
   }
}
; ==================================================================================================================================
; IEnumString -> msdn.microsoft.com/en-us/library/ms687257(v=vs.85).aspx
; For internal use by AutoComplete only!!!
; ==================================================================================================================================
IEnumString_Create() {
   Static IESInit := True, IESSize := A_PtrSize * 10, IESVTBL
   If (IESInit) {
      VarSetCapacity(IESVTBL, IESSize, 0)
      Addr := &IESVTBL + A_PtrSize
      Addr := NumPut(RegisterSyncCallback("IEnumString_QueryInterface") , Addr + 0, "UPtr")
      Addr := NumPut(RegisterSyncCallback("IEnumString_AddRef")         , Addr + 0, "UPtr")
      Addr := NumPut(RegisterSyncCallback("IEnumString_Release")        , Addr + 0, "UPtr")
      Addr := NumPut(RegisterSyncCallback("IEnumString_Next")           , Addr + 0, "UPtr")
      Addr := NumPut(RegisterSyncCallback("IEnumString_Skip")           , Addr + 0, "UPtr")
      Addr := NumPut(RegisterSyncCallback("IEnumString_Reset")          , Addr + 0, "UPtr")
      Addr := NumPut(RegisterSyncCallback("IEnumString_Clone")          , Addr + 0, "UPtr")
      IESInit := False
   }
   If !(IES := DllCall("GlobalAlloc", "UInt", 0x40, "Ptr", IESSize, "UPtr"))
      Return False
   DllCall("RtlMoveMemory", "Ptr", IES, "Ptr", &IESVTBL, "Ptr", IESSize)
   NumPut(IES + A_PtrSize, IES + 0, "UPtr")
   Return IES
}
; ----------------------------------------------------------------------------------------------------------------------------------
IEnumString_SetStrings(IES, ByRef Strings) {
   PrevTbl := NumGet(IES + (A_PtrSize * 9), "UPtr")
   StrSize := 0
   StrArray := []
   Loop, % Strings.Length()
      If ((S := Strings[A_Index]) <> "")
         L := StrPut(S, "UTF-16") * 2
         , StrSize += L
         , StrArray.Push({S: S, L: L})
      Else
         Break
   StrCount := StrArray.Length()
   StrTblSize := (A_PtrSize * 2) + (StrCount * A_PtrSize * 2) + StrSize
   If !(StrTbl := DllCall("GlobalAlloc", "UInt", 0x40, "Ptr", StrTblSize, "UPtr"))
      Return False
   Addr := StrTbl + A_PtrSize
   Addr := NumPut(StrCount, Addr + 0, "UPtr")
   StrPtr := Addr + (StrCount * A_PtrSize * 2)
   For Each, Str In StrArray {
      Addr := NumPut(StrPtr, Addr + 0, "UPtr")
      Addr := NumPut(Str.L, Addr + 0, "UPtr")
      StrPut(Str.S, StrPtr, "UTF-16")
      StrPtr += Str.L
   }
   If (PrevTbl)
      DllCall("GlobalFree", "Ptr", PrevTbl)
   NumPut(StrTbl, IES + (A_PtrSize * 9), "UPtr")
   Return True
}
; ----------------------------------------------------------------------------------------------------------------------------------
; VTBL
; ----------------------------------------------------------------------------------------------------------------------------------
IEnumString_QueryInterface(IES, RIID, ObjPtr) {
   Static IID := "{00000101-0000-0000-C000-000000000046}", IID_IEnumString := 0
        , Init := VarSetCapacity(IID_IEnumString, 16, 0) + DllCall("Ole32.dll\IIDFromString", "WStr", IID, "Ptr", &IID_IEnumString)
   Critical
   If DllCall("Ole32.dll\IsEqualGUID", "Ptr", RIID, "Ptr", &IID_IEnumString, "UInt") {
      IEnumString_AddRef(IES)
      Return !(NumPut(IES, ObjPtr + 0, "UPtr"))
   }
   Else
      Return 0x80004002
}
; ----------------------------------------------------------------------------------------------------------------------------------
IEnumString_AddRef(IES) {
   NumPut(RefCount := NumGet(IES + (A_PtrSize * 8), "UPtr") + 1,  IES + (A_PtrSize * 8), "UPtr")
   Return RefCount
}
; ----------------------------------------------------------------------------------------------------------------------------------
IEnumString_Release(IES) {
   RefCount := NumGet(IES + (A_PtrSize * 8), "UPtr")
   If (RefCount > 0) {
      NumPut(--RefCount, IES + (A_PtrSize * 8), "UPtr")
      If (RefCount = 0) {
         DllCall("GlobalFree", "Ptr", NumGet(IES + (A_PtrSize * 9), "UPtr")) ; string table
         DllCall("GlobalFree", "Ptr", IES)
      }
   }
   Return RefCount
}
; ----------------------------------------------------------------------------------------------------------------------------------
IEnumString_Next(IES, Fetch, Strings, Fetched) {
   Critical
   I := 0
   , StrTbl := NumGet(IES + (A_PtrSize * 9), "UPtr")
   , Current := NumGet(StrTbl + 0, "UPtr")
   , Maximum := NumGet(StrTbl + A_PtrSize, "UPtr")
   , StrAddr := StrTbl + (A_PtrSize * 2) + (A_PtrSize * Current * 2)
   While (Current < Maximum) && (I < Fetch)
      Ptr := NumGet(StrAddr + 0, "UPtr")
      , Len := NumGet(StrAddr + A_PtrSize, "UPtr")
      , Mem := DllCall("Ole32.dll\CoTaskMemAlloc", "Ptr", Len, "UPtr")
      , DllCall("RtlMoveMemory", "Ptr", Mem, "Ptr", Ptr, "Ptr", Len)
      , NumPut(Mem, Strings + (I * A_PtrSize), "Ptr")
      , NumPut(++I, Fetched + 0, "UInt")
      , NumPut(++Current, StrTbl + 0, "UPtr")
      , StrAddr += A_PtrSize * 2
   Return (I = Fetch) ? 0 : 1
}
; ----------------------------------------------------------------------------------------------------------------------------------
IEnumString_Skip(IES, Skip) {
   Critical
   StrTbl := NumGet(IES + (A_PtrSize * 9), "UPtr")
   , Current := NumGet(StrTbl + 0, "UPtr")
   , Maximum := NumGet(StrTbl + A_PtrSize, "UPtr")
   If ((Current + Skip) <= Maximum)
      Return (NumPut(Current + Skip, StrTbl, "UPtr") & 0)
   Return 1
}
; ----------------------------------------------------------------------------------------------------------------------------------
IEnumString_Reset(IES) {
   Return (NumPut(0, NumGet(IES + (A_PtrSize * 9), "UPtr"), "UPtr") & 0)
}
; ----------------------------------------------------------------------------------------------------------------------------------
IEnumString_Clone(IES, ObjPtr) { ; Not sure about the reference counter (IES + (A_PtrSize * 8))!
   IESSize := DllCall("GlobalSize", "Ptr", IES, "Ptr")
   StrTbl := NumGet(IES + (A_PtrSize * 9), "UPtr")
   StrTblSize := DllCall("GlobalSize", "Ptr", StrTbl, "Ptr")
   If !(IESClone := DllCall("GlobalAlloc", "UInt", 0x40, "Ptr", IESSize, "UPtr"))
      Return False
   If !(StrTblClone := DllCall("GlobalAlloc", "UInt", 0x40, "Ptr", StrTblSize, "UPtr")) {
      DllCall("GlobalFree", "Ptr", IESClone)
      Return False
   }
   DllCall("RtlMoveMemory", "Ptr", IESClone, "Ptr", IES, "Ptr", IESSize)
   DllCall("RtlMoveMemory", "Ptr", StrTblClone, "Ptr", StrTbl, "Ptr", StrTblSize)
   NumPut(0, IESClone + (A_PtrSize * 8), "UPtr") ; Set the reference counter to zero or one in this case???
   NumPut(StrTblClone, IESCLone + (A_PtrSIze * 9), "UPtr")
   Return (NumPut(IESClone, ObjPtr + 0, "UPtr") & 0)
}
; ==================================================================================================================================