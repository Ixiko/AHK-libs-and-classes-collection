; ==================================================================================================================================
; IDropTarget interface -> msdn.microsoft.com/en-us/library/ms679679(v=vs.85).aspx
; Requires: IDataObject.ahk
; ==================================================================================================================================
; Creates a new instance of the IDropTarget object.
; Parameters:
;     HWND              -  HWND of the Gui window or control which shall be used as a drop target.
;     UserFuncSuffix    -  The suffix for the names of the user-defined functions which will be called on events (see Remarks).
;     RequiredFormats   -  An array containing the numeric clipboard formats required to permit drop.
;                          If omitted, only 15 (CF_HDROP) used for dropping files will be required.
;     Register          -  If set to True the target will be registered as a drop target on creation.
;                          Otherwise you have to call the RegisterDragDrop() method manually to activate the drop target.
;     UseHelper         -  Use the shell helper object if available (True/False).
; Return value:
;     New IDropTarget instance on success; in case of parameter errors, False.
; Remarks:
;     The interface permits up to 4 user-defined functions which will be called from the related methods:
;        IDropTargetOnEnter      Optional, called from IDropTarget.DragEnter()
;        IDropTargetOnOver       Optional, called from IDropTarget.DragOver()
;        IDropTargetOnLeave      Optional, called from IDropTarget.DragLeave()
;        IDropTargetOnDrop       Mandatory, called from IDropTarget.Drop()
;     The suffix passed in UserFuncSuffix which will be appended to this names to identify the instance specific functions.
;
;     Function parameters:
;        IDropTargetOnDrop and IDropTargetOnEnter must accept at least 6 parameters:
;           TargetObject   -  This instance.
;           pDataObj       -  A pointer to the IDataObject interface on the data object being dropped.
;           KeyState       -  The current state of the mouse buttons and keyboard modifier keys.
;           X              -  The current X coordinate of the cursor in screen coordinates.
;           Y              -  The current Y coordinate of the cursor in screen coordinates.
;           DropEffect     -  The drop effect determined by the Drop() method.
;        IDropTargetOnOver must accept at least 5 parameters:
;           TargetObject   -  This instance.
;           KeyState       -  The current state of the mouse buttons and keyboard modifier keys.
;           X              -  The current X coordinate of the cursor in screen coordinates.
;           Y              -  The current Y coordinate of the cursor in screen coordinates.
;           DropEffect     -  The drop effect determined by the Drop() method.
;        IDropTargetOnLeave must accept at least 1 parameter:
;           TargetObject   -  This instance.
;
;     What the functions must return:
;        The return value of IDropTargetOnDrop, IDropTargetOnEnter, and IDropTargetOnOver is used as the drop effect reported
;        as the result of the drop operation. In the easiest case the function returns the value passed in DropEffect.
;        Otherwise, it must return one of the following values:
;           0 (DROPEFFECT_NONE)
;           1 (DROPEFFECT_COPY)
;           2 (DROPEFFECT_MOVE)
;        The return value of IDropTargetOnLeave is not used.
;
;     As is the interface supports only left-dragging and permits DROPEFFECT_COPY and DROPEFFECT_MOVE. The default effect is
;     DROPEFFECT_COPY. It will be switched to DROPEFFECT_MOVE if either Ctrl or Shift is pressed. You can overwrite the default
;     from the IDropTargetOnEnter user function.
;
;     The dropped data have to be processed completely by the IDropTargetOnDrop user function.
; ==================================================================================================================================
IDropTarget_Create(HWND, UserFuncSuffix, RequiredFormats := "", Register := True, UseHelper := True) {
   Return New IDropTarget(HWND, UserFuncSuffix, RequiredFormats, Register, UseHelper)
}
; ==================================================================================================================================
Class IDropTarget {
   __New(HWND, UserFuncSuffix, RequiredFormats := "", Register := True, UseHelper := True) {
      Static Methods := ["QueryInterface", "AddRef", "Release", "DragEnter", "DragOver", "DragLeave", "Drop"]
      Static Params := (A_PtrSize = 8 ? [3, 1, 1, 5, 4, 1, 5] : [3, 1, 1, 6, 5, 1, 6])
      Static DefaultFormat := 15 ; CF_HDROP
      Static DropFunc := "IDropTargetOnDrop"
      Static EnterFunc := "IDropTargetOnEnter"
      Static OverFunc := "IDropTargetOnOver"
      Static LeaveFunc := "IDropTargetOnLeave"
      Static CLSID_IDTH := "{4657278A-411B-11D2-839A-00C04FD918D0}" ; CLSID_DragDropHelper
      Static IID_IDTH := "{4657278B-411B-11D2-839A-00C04FD918D0}"   ; IID_IDropTargetHelper
      If This.Base.HasKey("Ptr")
         Return False
      UserFunc := DropFunc . UserFuncSuffix
      If !IsFunc(UserFunc) || (Func(UserFunc).MinParams < 6)
         Return False
      This.DropUserFunc := Func(UserFunc)
      UserFunc := EnterFunc . UserFuncSuffix
      If (IsFunc(UserFunc) && (Func(UserFunc).MinParams > 5))
         This.EnterUserFunc := Func(UserFunc)
      UserFunc := OverFunc . UserFuncSuffix
      If (IsFunc(UserFunc) && (Func(UserFunc).MinParams > 4))
         This.OverUserFunc := Func(UserFunc)
      UserFunc := LeaveFunc . UserFuncSuffix
      If (IsFunc(UserFunc) && (Func(UserFunc).MinParams > 0))
         This.LeaveUserFunc := Func(UserFunc)
      This.HWND := HWND
      This.Registered := False
      If (RequiredFormats = -1)
         This.Required := 0
      Else If IsObject(RequiredFormats)
         This.Required := RequiredFormats
      Else
         This.Required := [DefaultFormat]
      This.PreferredDropEffect := 0
      SizeOfVTBL := (Methods.Length() + 2) * A_PtrSize
      This.SetCapacity("VTBL", SizeOfVTBL)
      This.Ptr := This.GetAddress("VTBL")
      DllCall("RtlZeroMemory", "Ptr", This.Ptr, "Ptr", SizeOfVTBL)
      NumPut(This.Ptr + A_PtrSize, This.Ptr + 0, "UPtr")
      For Index, Method In Methods {
         CB := RegisterCallback("IDropTarget." . Method, "", Params[Index], &This)
         NumPut(CB, This.Ptr + 0, A_Index * A_PtrSize, "UPtr")
      }
      This.Helper := ComObjCreate(CLSID_IDTH, IID_IDTH)
      If (Register)
         If !This.RegisterDragDrop()
            Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   ; Registers window/control as a drop target.
   ; -------------------------------------------------------------------------------------------------------------------------------
   RegisterDragDrop() {
      If !(This.Registered)
         If DllCall("Ole32.dll\RegisterDragDrop", "Ptr", This.HWND, "Ptr", This.Ptr, "Int")
            Return False
      Return (This.Registered := True)
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   ; Revokes registering of the window/control as a drop target.
   ; This method should be called before the window/control will be destroyed.
   ; -------------------------------------------------------------------------------------------------------------------------------
   RevokeDragDrop() {
      If (This.Registered)
         DllCall("Ole32.dll\RevokeDragDrop", "Ptr", This.HWND)
      Return !(This.Registered := False)
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   ; Notifies the drag-image manager, if used, to show or hide the drag image.
   ; Parameter:
   ;     Show  -  If true, the drag image will be shown; otherwise it will be hidden.
   ; -------------------------------------------------------------------------------------------------------------------------------
   HelperShow(Show := True) {
      Static HelperShow := A_PtrSize * 7
      If (This.Helper) {
         pVTBL := NumGet(This.Helper + 0, "UPtr")
         , DllCall(NumGet(pVTBL + HelperShow, "UPtr"), "Ptr", This.Helper, "UInt", !!Show)
         Return True
      }
      Return False
   }
   ; ===============================================================================================================================
   ; The following methods must not be called directly, they are reserved for internal and system use.
   ; ===============================================================================================================================
   __Delete() {
      This.RevokeDragDrop()
      While (CB := NumGet(This.Ptr + (A_PtrSize * A_Index), "Ptr"))
         DllCall("GlobalFree", "Ptr", CB)
      If (This.Helper)
         ObjRelease(This.Helper)
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   QueryInterface(RIID, PPV) {
      ; IUnknown -> msdn.microsoft.com/en-us/library/ms682521(v=vs.85).aspx
      Static IID := "{00000122-0000-0000-C000-000000000046}"
      VarSetCapacity(QID, 80, 0)
      QIDLen := DllCall("Ole32.dll\StringFromGUID2", "Ptr", RIID, "Ptr", &QID, "Int", 40, "Int")
      If (StrGet(&QID, QIDLen, "UTF-16") = IID) {
         NumPut(This, PPV + 0, "Ptr")
         Return 0 ; S_OK
      }
      Else {
         NumPut(0, PPV + 0, "Ptr")
         Return 0x80004002 ; E_NOINTERFACE
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   AddRef() {
      ; IUnknown -> msdn.microsoft.com/en-us/library/ms691379(v=vs.85).aspx
      ; Reference counting is not needed in this case.
      Return 1
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   Release() {
      ; IUnknown -> msdn.microsoft.com/en-us/library/ms682317(v=vs.85).aspx
      ; Reference counting is not needed in this case.
      Return 0
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   DragEnter(pDataObj, grfKeyState, P3 := "", P4 := "", P5 := "") {
      ; DragEnter -> msdn.microsoft.com/en-us/library/ms680106(v=vs.85).aspx
      ; Params 32: IDataObject *pDataObj, DWORD grfKeyState, LONG x, LONG y, DWORD *pdwEffect
      ; Params 64: IDataObject *pDataObj, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect
      Static HelperEnter := A_PtrSize * 3
      Instance := Object(A_EventInfo)
      Instance.PreferredDropEffect := 0
      If (A_PtrSize = 8)
         X := P2 & 0xFFFFFFFF, Y := P2 >> 32
      Else
         X := P2, Y := P3
      Effect := 0
      If !(grfKeyState & 0x02) { ; right-drag isn't supported by default
         If IDataObject_GetPreferredDropEffect(pDataObj, DropEffect)
            Effect := DropEffect
         Else
            Effect := NumGet((A_PtrSize = 8 ? P4 : P5) + 0, "UInt")
         Effect := (Effect & 0x01) ? 1 : (Effect & 0x02)
         If IsObject(Instance.Required) {
            Found := False
            For Each, Format In Instance.Required {
               IDataObject_CreateFormatEtc(FORMATETC, Format)
               If (Found := IDataObject_QueryGetData(pDataObj, FORMATETC))
                  Break
            }
            If !(Found)
               Effect := 0
         }
      }
      If (Effect) && (Instance.EnterUserFunc)
         Effect := Instance.EnterUserFunc.Call(Instance, pDataObj, grfKeyState, X, Y, Effect)
      Instance.PreferredDropEffect := Effect
      ; If Ctrl and/or Shift is pressed swap the effect
      Effect ^= grfKeyState & 0x0C ? 3 : 0
      ; Call IDropTargetHelper, if created
      If (Instance.Helper) {
         VarSetCapacity(PT, 8, 0)
         , NumPut(X, PT, 0, "Int")
         , NumPut(Y, PT, 0, "Int")
         , pVTBL := NumGet(Instance.Helper + 0, "UPtr")
         , DllCall(NumGet(pVTBL + HelperEnter, "UPtr")
                 , "Ptr", Instance.Helper, "Ptr", Instance.HWND, "Ptr", pDataObj, "Ptr", &PT, "UInt", Effect, "Int")
      }
      NumPut(Effect, (A_PtrSize = 8 ? P4 : P5) + 0, "UInt")
      Return 0 ; S_OK
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   DragOver(grfKeyState, P2 := "", P3 := "", P4 := "") {
      ; DragOver -> msdn.microsoft.com/en-us/library/ms680129(v=vs.85).aspx
      ; Params 32: DWORD grfKeyState, LONG x, LONG y, DWORD *pdwEffect
      ; Params 64: DWORD grfKeyState, POINTL pt, DWORD *pdwEffect
      Static HelperOver := A_PtrSize * 5
      Instance := Object(A_EventInfo)
      If (A_PtrSize = 8)
         X := P2 & 0xFFFFFFFF, Y := P2 >> 32
      Else
         X := P2, Y := P3
      ; If Ctrl and/or Shift is pressed swap the effect
      Effect := Instance.PreferredDropEffect ^ (grfKeyState & 0x0C ? 3 : 0)
      If (Effect) && (Instance.OverUserFunc)
         Effect := Instance.OverUserFunc.Call(Instance, grfKeyState, X, Y, Effect)
      If (Instance.Helper) {
         VarSetCapacity(PT, 8, 0)
         , NumPut(X, PT, 0, "Int")
         , NumPut(Y, PT, 0, "Int")
         , pVTBL := NumGet(Instance.Helper + 0, "UPtr")
         , DllCall(NumGet(pVTBL + HelperOver, "UPtr"), "Ptr", Instance.Helper, "Ptr", &PT, "UInt", Effect, "Int")
      }
      NumPut(Effect, (A_PtrSize = 8 ? P3 : P4) + 0, "UInt")
      Return 0 ; S_OK
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   DragLeave() {
      ; DragLeave -> msdn.microsoft.com/en-us/library/ms680110(v=vs.85).aspx
      Static HelperLeave := A_PtrSize * 4
      Instance := Object(A_EventInfo)
      Instance.PreferredDropEffect := 0
      If (Instance.LeaveUserFunc)
         Instance.LeaveUserFunc.Call(Instance)
      If (Instance.Helper) {
         pVTBL := NumGet(Instance.Helper + 0, "UPtr"), DllCall(NumGet(pVTBL + HelperLeave, "UPtr"), "Ptr", Instance.Helper)
      }
      Return 0 ; S_OK
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   Drop(pDataObj, grfKeyState, P3 := "", P4 := "", P5 := "") {
      ; Drop -> msdn.microsoft.com/en-us/library/ms687242(v=vs.85).aspx
      ; Params 32: IDataObject *pDataObj, DWORD grfKeyState, LONG x, LONG y, DWORD *pdwEffect
      ; Params 64: IDataObject *pDataObj, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect
      Static HelperDrop := A_PtrSize * 6
      Instance := Object(A_EventInfo)
      If (A_PtrSize = 8)
         X := P3 & 0xFFFFFFFF, Y := P3 >> 32
      Else
         X := P3, Y := P4
      Effect := Instance.PreferredDropEffect ^ (grfKeyState & 0x0C ? 3 : 0)
      Effect := Instance.DropUserFunc.Call(Instance, pDataObj, grfKeyState, X, Y, Effect)
      NumPut(Effect, (A_PtrSize = 8 ? P4 : P5) + 0, "UInt")
      If (Instance.Helper) {
         VarSetCapacity(PT, 8, 0)
         , NumPut(X, PT, 0, "Int")
         , NumPut(Y, PT, 0, "Int")
         , pVTBL := NumGet(Instance.Helper + 0, "UPtr")
         , DllCall(NumGet(pVTBL + HelperDrop, "UPtr"), "Ptr", Instance.Helper, "Ptr", pDataObj, "Ptr", &PT, "UInt", Effect, "Int")
      }
      Return 0 ; S_OK
   }
}
; ==================================================================================================================================
#Include *i IDataObject.ahk
; ==================================================================================================================================